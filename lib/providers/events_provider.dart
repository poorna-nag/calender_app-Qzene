import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:device_calendar/device_calendar.dart' as device_cal;

import '../models/event.dart';
import '../services/notification_service.dart';
import '../services/holiday_service.dart';
import '../utils/recurrence_utils.dart';
import 'settings_provider.dart';

final deviceCalendarsProvider = FutureProvider<List<device_cal.Calendar>>((ref) async {
  final plugin = device_cal.DeviceCalendarPlugin();
  final permissionsGranted = await plugin.hasPermissions();
  if (permissionsGranted.isSuccess && (permissionsGranted.data ?? false)) {
    final calendarsResult = await plugin.retrieveCalendars();
    if (calendarsResult.isSuccess && calendarsResult.data != null) {
      return calendarsResult.data!;
    }
  }
  return [];
});

class EventsNotifier extends Notifier<LinkedHashMap<DateTime, List<Event>>> {
  final device_cal.DeviceCalendarPlugin _deviceCalendarPlugin = device_cal.DeviceCalendarPlugin();
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;
  Timer? _syncTimer;

  @override
  LinkedHashMap<DateTime, List<Event>> build() {
    _init();
    return LinkedHashMap<DateTime, List<Event>>(
      equals: isSameDay,
      hashCode: getHashCode,
    );
  }

  Future<void> _init() async {
    await _loadFromCache();
    // Start sync immediately; permission request is handled inside fetchDeviceEvents
    await fetchDeviceEvents();
    
    // Start periodic sync (every 30 seconds for "immediate" feel)
    _startSyncTimer();
    
    // Add observer for app lifecycle to manage timer and sync on resume
    WidgetsBinding.instance.addPostFrameCallback((_) {
       WidgetsBinding.instance.addObserver(_LifecycleObserver(this));
    });
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isSyncing) {
        fetchDeviceEvents();
      }
    });
  }

  void _stopSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString('events_cache');
      if (cachedData == null) return;

      final List<dynamic> jsonList = jsonDecode(cachedData); 
      // Filter out device events from cache so we don't duplicate them on re-sync
      // Or keep them until new sync overrides. 
      // Let's assume cache stores USER created events. Device events are re-fetched.
      final List<Event> userEvents = jsonList
          .map((j) => Event.fromJson(j))
          .where((e) => !e.id.startsWith('dev_')) // Filter out cached device events to avoid staleness
          .toList();

      final newState = LinkedHashMap<DateTime, List<Event>>(
        equals: isSameDay,
        hashCode: getHashCode,
      );

      for (var event in userEvents) {
        final date = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
        if (newState[date] == null) newState[date] = [];
        newState[date]!.add(event);
      }

      state = newState;
    } catch (e) {
      debugPrint('Error loading events cache: $e');
    }
  }

  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Only save USER events to cache. Device events should be fetched fresh.
      final allEvents = state.values.expand((e) => e).where((e) => !e.id.startsWith('dev_')).toList();
      final String jsonData = jsonEncode(allEvents.map((e) => e.toJson()).toList());
      await prefs.setString('events_cache', jsonData);
    } catch (e) {
      debugPrint('Error saving events cache: $e');
    }
  }


    Future<bool> fetchDeviceEvents() async {
    if (_isSyncing) return false;
    _isSyncing = true;
    
    try {
      // 1. Request/Check Permissions
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      bool hasPermission = permissionsGranted.isSuccess && (permissionsGranted.data ?? false);
      
      if (!hasPermission) {
        debugPrint('Sync: Requesting permissions...');
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        hasPermission = permissionsGranted.isSuccess && (permissionsGranted.data ?? false);
        if (!hasPermission) {
          debugPrint('Sync: Permissions denied or failed.');
          _isSyncing = false;
          return false;
        }
      }

      // 2. Get Calendars
      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (!calendarsResult.isSuccess || calendarsResult.data == null) {
        _isSyncing = false;
        return false;
      }
      
      final calendars = calendarsResult.data!;
      debugPrint('Sync: Found ${calendars.length} calendars.');
      
      if (calendars.isEmpty) {
        _isSyncing = false;
        return true; 
      }

      // Sync Range: 4 months back, 1 year forward
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 120)); 
      final endDate = now.add(const Duration(days: 365));       

      // 3. Fetch Events
      final List<Event> allDeviceEvents = [];
      
      // Fetch all in parallel without batching for now to ensure coverage
      final futures = calendars.where((c) => c.id != null).map((calendar) async {
        try {
          // Retrieve with specific params
          final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
            calendar.id,
            device_cal.RetrieveEventsParams(startDate: startDate, endDate: endDate),
          );
          
          if (eventsResult.isSuccess && eventsResult.data != null) {
            return eventsResult.data!
                .map((dEvent) => _mapDeviceEventToAppEvent(dEvent, calendar.color))
                .where((e) => e != null) // Filter failed mappings
                .cast<Event>()
                .toList();
          }
        } catch (e) {
          debugPrint('Sync Error for ${calendar.name}: $e');
        }
        return <Event>[];
      });

      final results = await Future.wait(futures);
      for (var list in results) {
        allDeviceEvents.addAll(list);
      }
      
      debugPrint('Sync: Fetched ${allDeviceEvents.length} events from device.');

      // 4. Merge
      final newState = LinkedHashMap<DateTime, List<Event>>(
        equals: isSameDay,
        hashCode: getHashCode,
      );
      
      final Set<String> existingEventKeys = {};

      // A. Keep User Events
      state.forEach((date, events) {
        for (var event in events) {
          if (!event.id.startsWith('dev_')) {
             if (newState[date] == null) newState[date] = [];
             newState[date]!.add(event);
             existingEventKeys.add('${event.id}_${event.startTime.millisecondsSinceEpoch}');
          }
        }
      });
      
      // B. Add Device Events
      for (var event in allDeviceEvents) {
        final key = '${event.id}_${event.startTime.millisecondsSinceEpoch}';
        if (!existingEventKeys.contains(key)) {
           final date = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
           if (newState[date] == null) newState[date] = [];
           newState[date]!.add(event);
           existingEventKeys.add(key);
        }
      }
      
      state = newState;
      return true;

    } catch (e) {
      debugPrint("Sync Exception: $e");
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  Event? _mapDeviceEventToAppEvent(device_cal.Event dEvent, int? calendarColor) {
    if (dEvent.eventId == null || dEvent.start == null || dEvent.end == null) return null;

    String? organizer;
    if (dEvent.attendees != null) {
      for (var a in dEvent.attendees!) {
        if (a?.isOrganiser == true) {
          organizer = a?.emailAddress ?? a?.name;
          break;
        }
      }
    }

    // Force exact wall-clock time to avoid TZDateTime toLocal() offset bugs (typically 5 hours off)
    final start = dEvent.start!;
    final end = dEvent.end!;
    final localStart = DateTime(start.year, start.month, start.day, start.hour, start.minute, start.second);
    final localEnd = DateTime(end.year, end.month, end.day, end.hour, end.minute, end.second);

    return Event(
      id: 'dev_${dEvent.eventId}',
      title: dEvent.title ?? 'No Title',
      startTime: localStart,
      endTime: localEnd,
      isAllDay: dEvent.allDay ?? false,
      color: EventColor.social, 
      customColor: calendarColor != null ? Color(calendarColor) : null,
      location: dEvent.location,
      notes: dEvent.description,
      organizer: organizer,
      attendees: dEvent.attendees?.map((a) => a?.emailAddress ?? a?.name ?? '')
          .where((s) => s.isNotEmpty).toList(),
      timeZone: dEvent.start?.timeZoneName,
    );
  }

  void addEvent(Event event) {
    if (event.recurrence.isRecurring) {
      // Handle recurrence expansion
       final List<Event> instances = RecurrenceUtils.generateOccurrences(event);
        final newState = LinkedHashMap<DateTime, List<Event>>(
          equals: isSameDay, 
          hashCode: getHashCode
        );
        // Copy existing
        state.forEach((key, value) => newState[key] = List.from(value));
        
        for (var instance in instances) {
             final date = DateTime(instance.startTime.year, instance.startTime.month, instance.startTime.day);
             if (newState[date] == null) newState[date] = [];
             newState[date]!.add(instance);
              // Notifications
             for (var reminder in instance.reminders) {
                NotificationService().scheduleNotification(instance, reminder);
             }
        }
         state = newState;
    } else {
        // Single Event
        final date = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
        final newState = LinkedHashMap<DateTime, List<Event>>(
          equals: isSameDay, 
          hashCode: getHashCode
        );
        state.forEach((key, value) => newState[key] = List.from(value));

        if (newState[date] == null) newState[date] = [];
        newState[date]!.add(event);
        
        for (var reminder in event.reminders) {
             NotificationService().scheduleNotification(event, reminder);
        }
        state = newState;
    }
    _saveToCache();
  }

  void deleteEvent(Event event, {bool deleteAllInGroup = false, DateTime? deleteFromDate}) {
    NotificationService().cancelAllForEvent(event);
    
    // Create new mutable map
    final newState = LinkedHashMap<DateTime, List<Event>>(
      equals: isSameDay, 
      hashCode: getHashCode
    );
    state.forEach((key, value) => newState[key] = List.from(value));

    // Logic to remove
    if (deleteAllInGroup && event.recurrenceGroupId != null) {
       newState.forEach((date, events) {
          events.removeWhere((e) => e.recurrenceGroupId == event.recurrenceGroupId);
       });
    } else {
       final date = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
       if (newState[date] != null) {
         newState[date]!.removeWhere((e) => e.id == event.id);
       }
    }
    
    // Clean up empty days
    newState.removeWhere((key, value) => value.isEmpty);
    
    state = newState;
    _saveToCache();
  }

  void restoreEvent(Event event) {
    addEvent(event.copyWith(isDeleted: false, deletedAt: null));
  }

  Future<void> syncBirthdays(List<Event> birthdays) async {
    final newState = LinkedHashMap<DateTime, List<Event>>(
      equals: isSameDay, 
      hashCode: getHashCode
    );
    state.forEach((key, value) => newState[key] = List.from(value));

    final Set<String> existingIds = {};
    state.forEach((date, events) {
      for (var e in events) {
        existingIds.add(e.id);
      }
    });

    bool added = false;
    for (var birthday in birthdays) {
      if (!existingIds.contains(birthday.id)) {
        final date = DateTime(birthday.startTime.year, birthday.startTime.month, birthday.startTime.day);
        if (newState[date] == null) newState[date] = [];
        newState[date]!.add(birthday);
        added = true;
      }
    }

    if (added) {
      state = newState;
      _saveToCache();
    }
  }
}

class _LifecycleObserver extends WidgetsBindingObserver {
  final EventsNotifier notifier;
  _LifecycleObserver(this.notifier);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('App Resumed: Restarting sync timer and fetching events');
      notifier.fetchDeviceEvents();
      notifier._startSyncTimer();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      debugPrint('App Backgrounded: Stopping sync timer');
      notifier._stopSyncTimer();
    }
  }
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

final eventsProvider = NotifierProvider<EventsNotifier, LinkedHashMap<DateTime, List<Event>>>(() {
  return EventsNotifier();
});

final holidayServiceProvider = Provider((ref) => HolidayService());

final filteredEventsProvider = Provider<LinkedHashMap<DateTime, List<Event>>>((ref) {
  final baseEvents = ref.watch(eventsProvider);
  final settings = ref.watch(settingsProvider);
  final holidayService = ref.watch(holidayServiceProvider);

  final newState = LinkedHashMap<DateTime, List<Event>>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  // 1. Copy base events (User + Device + Synced Birthdays)
  baseEvents.forEach((date, events) {
    newState[date] = List.from(events);
  });

  // 2. Inject Holidays dynamically if enabled
  if (settings.showPublicHolidays || settings.showReligiousHolidays || settings.showSchoolHolidays) {
    final holidays = holidayService.getHolidays(
      countryCode: settings.holidayCountry,
      public: settings.showPublicHolidays,
      religious: settings.showReligiousHolidays,
      school: settings.showSchoolHolidays,
    );

    for (var holiday in holidays) {
      final date = DateTime(holiday.startTime.year, holiday.startTime.month, holiday.startTime.day);
      if (newState[date] == null) newState[date] = [];
      
      // Avoid duplicates if a holiday was somehow manually added
      if (!newState[date]!.any((e) => e.id == holiday.id)) {
        newState[date]!.add(holiday);
      }
    }
  }

  return newState;
});
