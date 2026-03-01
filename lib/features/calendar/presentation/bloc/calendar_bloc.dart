import 'dart:collection';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/calendar_repository.dart';
import '../../data/models/event_model.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final CalendarRepository repository;

  CalendarBloc({required this.repository}) : super(CalendarInitial()) {
    on<LoadCalendarEvents>(_onLoadCalendarEvents);
    on<AddEvent>(_onAddEvent);
    on<UpdateEvent>(_onUpdateEvent);
    on<DeleteEvent>(_onDeleteEvent);
    on<FetchDeviceEvents>(_onFetchDeviceEvents);
    on<SyncBirthdays>(_onSyncBirthdays);
    on<RestoreEvent>(_onRestoreEvent);
  }

  Future<void> _onLoadCalendarEvents(
    LoadCalendarEvents event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    final userEvents = await repository.loadUserEvents();
    final deviceEvents = await repository.fetchDeviceEvents();
    final allEvents = [...userEvents, ...deviceEvents];
    emit(CalendarLoaded(_mapEventsByDay(allEvents)));
  }

  Future<void> _onAddEvent(AddEvent event, Emitter<CalendarState> emit) async {
    await repository.saveEvent(event.event);
    _refreshEvents(emit);
  }

  Future<void> _onUpdateEvent(
    UpdateEvent event,
    Emitter<CalendarState> emit,
  ) async {
    await repository.saveEvent(event.event);
    _refreshEvents(emit);
  }

  Future<void> _onDeleteEvent(
    DeleteEvent event,
    Emitter<CalendarState> emit,
  ) async {
    await repository.deleteEvent(event.event.id);
    _refreshEvents(emit);
  }

  Future<void> _onRestoreEvent(
    RestoreEvent event,
    Emitter<CalendarState> emit,
  ) async {
    await repository.saveEvent(event.event);
    _refreshEvents(emit);
  }

  Future<void> _refreshEvents(Emitter<CalendarState> emit) async {
    final userEvents = await repository.loadUserEvents();
    final deviceEvents = await repository.fetchDeviceEvents();
    final allEvents = [...userEvents, ...deviceEvents];
    emit(CalendarLoaded(_mapEventsByDay(allEvents)));
  }

  Future<void> _onFetchDeviceEvents(
    FetchDeviceEvents event,
    Emitter<CalendarState> emit,
  ) async {
    if (state is CalendarLoaded) {
      emit(CalendarLoaded((state as CalendarLoaded).events, isSyncing: true));
    }
    final deviceEvents = await repository.fetchDeviceEvents();
    final userEvents = await repository.loadUserEvents();
    final allEvents = [...userEvents, ...deviceEvents];
    emit(CalendarLoaded(_mapEventsByDay(allEvents), isSyncing: false));
  }

  Future<void> _onSyncBirthdays(
    SyncBirthdays event,
    Emitter<CalendarState> emit,
  ) async {
    await repository.syncBirthdays(event.birthdays);
    final userEvents = await repository.loadUserEvents();
    final deviceEvents = await repository.fetchDeviceEvents();
    final allEvents = [...userEvents, ...deviceEvents];
    emit(CalendarLoaded(_mapEventsByDay(allEvents)));
  }

  LinkedHashMap<DateTime, List<EventModel>> _mapEventsByDay(
    List<EventModel> events,
  ) {
    final mapped = LinkedHashMap<DateTime, List<EventModel>>(
      equals: isSameDay,
      hashCode: getHashCode,
    );
    for (var event in events) {
      final date = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      if (mapped[date] == null) mapped[date] = [];
      mapped[date]!.add(event);
    }
    return mapped;
  }

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }
}
