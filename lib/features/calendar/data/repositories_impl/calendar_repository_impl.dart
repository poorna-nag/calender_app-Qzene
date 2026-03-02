import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_calendar/device_calendar.dart' as device_cal;
import '../models/event_model.dart';
import '../repositories/calendar_repository.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final device_cal.DeviceCalendarPlugin _deviceCalendarPlugin =
      device_cal.DeviceCalendarPlugin();

  static const String _eventsKey = 'events_cache';
  static const String _recycleBinKey = 'recycle_bin_cache';

  @override
  Future<List<EventModel>> loadUserEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString(_eventsKey);
    if (cachedData == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(cachedData);
      final List<EventModel> events = [];
      for (var j in jsonList) {
        try {
          final event = EventModel.fromJson(j);
          if (!event.id.startsWith('dev_')) events.add(event);
        } catch (e) {
          debugPrint('Error parsing single event: $e');
        }
      }
      return events;
    } catch (e) {
      debugPrint('Error decoding user events: $e');
      return [];
    }
  }

  @override
  Future<List<EventModel>> fetchDeviceEvents() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      bool hasPermission =
          permissionsGranted.isSuccess && (permissionsGranted.data ?? false);
      if (!hasPermission) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        hasPermission =
            permissionsGranted.isSuccess && (permissionsGranted.data ?? false);
        if (!hasPermission) return [];
      }
      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (!calendarsResult.isSuccess || calendarsResult.data == null) return [];
      final calendars = calendarsResult.data!;
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 120));
      final endDate = now.add(const Duration(days: 365));
      final List<EventModel> allDeviceEvents = [];
      for (var calendar in calendars) {
        if (calendar.id == null) continue;
        final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
          calendar.id,
          device_cal.RetrieveEventsParams(
            startDate: startDate,
            endDate: endDate,
          ),
        );
        if (eventsResult.isSuccess && eventsResult.data != null) {
          allDeviceEvents.addAll(
            eventsResult.data!
                .map(
                  (dEvent) => _mapDeviceEventToAppEvent(dEvent, calendar.color),
                )
                .where((e) => e != null)
                .cast<EventModel>(),
          );
        }
      }
      return allDeviceEvents;
    } catch (e) {
      debugPrint('Sync Exception: $e');
      return [];
    }
  }

  @override
  Future<void> saveEvent(EventModel event) async {
    final userEvents = await loadUserEvents();
    final index = userEvents.indexWhere((e) => e.id == event.id);
    if (index != -1)
      userEvents[index] = event;
    else
      userEvents.add(event);
    await _saveUserEvents(userEvents);

    // If we're restoring from bin, remove from bin
    if (!event.isDeleted) {
      final deleted = await loadDeletedEvents();
      if (deleted.any((e) => e.id == event.id)) {
        await permanentlyDeleteEvent(event.id);
      }
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    final userEvents = await loadUserEvents();
    final index = userEvents.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final event = userEvents[index];
      userEvents.removeAt(index);
      await _saveUserEvents(userEvents);

      // Move to recycle bin
      final deleted = await loadDeletedEvents();
      deleted.add(event.copyWith(isDeleted: true, deletedAt: DateTime.now()));
      await _saveDeletedEvents(deleted);
    }
  }

  @override
  Future<void> deleteEventsByGroupId(String groupId) async {
    final userEvents = await loadUserEvents();
    final toDelete = userEvents
        .where((e) => e.recurrenceGroupId == groupId)
        .toList();
    userEvents.removeWhere((e) => e.recurrenceGroupId == groupId);
    await _saveUserEvents(userEvents);

    final deleted = await loadDeletedEvents();
    for (var event in toDelete) {
      deleted.add(event.copyWith(isDeleted: true, deletedAt: DateTime.now()));
    }
    await _saveDeletedEvents(deleted);
  }

  @override
  Future<void> syncBirthdays(List<EventModel> birthdays) async {
    final userEvents = await loadUserEvents();
    final Set<String> existingIds = userEvents.map((e) => e.id).toSet();
    for (var birthday in birthdays) {
      if (!existingIds.contains(birthday.id)) {
        userEvents.add(birthday);
      }
    }
    await _saveUserEvents(userEvents);
  }

  @override
  Future<List<EventModel>> loadDeletedEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString(_recycleBinKey);
    if (cachedData == null) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(cachedData);
      final list = jsonList.map((j) => EventModel.fromJson(j)).toList();
      final now = DateTime.now();
      final cutoff = now.subtract(const Duration(days: 30));
      final filtered = list
          .where((e) => e.deletedAt != null && e.deletedAt!.isAfter(cutoff))
          .toList();
      if (filtered.length != list.length) await _saveDeletedEvents(filtered);
      return filtered;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> permanentlyDeleteEvent(String eventId) async {
    final deleted = await loadDeletedEvents();
    deleted.removeWhere((e) => e.id == eventId);
    await _saveDeletedEvents(deleted);
  }

  @override
  Future<void> emptyRecycleBin() async {
    await _saveDeletedEvents([]);
  }

  Future<void> _saveUserEvents(List<EventModel> events) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _eventsKey,
      jsonEncode(events.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> _saveDeletedEvents(List<EventModel> events) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _recycleBinKey,
      jsonEncode(events.map((e) => e.toJson()).toList()),
    );
  }

  EventModel? _mapDeviceEventToAppEvent(
    device_cal.Event dEvent,
    int? calendarColor,
  ) {
    if (dEvent.eventId == null || dEvent.start == null || dEvent.end == null)
      return null;
    final start = dEvent.start!;
    final end = dEvent.end!;
    final localStart = DateTime(
      start.year,
      start.month,
      start.day,
      start.hour,
      start.minute,
      start.second,
    );
    final localEnd = DateTime(
      end.year,
      end.month,
      end.day,
      end.hour,
      end.minute,
      end.second,
    );
    return EventModel(
      id: 'dev_${dEvent.eventId}',
      title: dEvent.title ?? 'No Title',
      startTime: localStart,
      endTime: localEnd,
      isAllDay: dEvent.allDay ?? false,
      color: EventColor.social,
      customColor: calendarColor != null ? Color(calendarColor) : null,
      location: dEvent.location,
      notes: dEvent.description,
      timeZone: dEvent.start?.timeZoneName,
    );
  }
}
