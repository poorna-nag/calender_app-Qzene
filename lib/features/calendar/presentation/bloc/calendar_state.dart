import 'package:equatable/equatable.dart';
import 'dart:collection';
import '../../data/models/event_model.dart';

abstract class CalendarState extends Equatable {
  const CalendarState();
  @override
  List<Object?> get props => [];
}

class CalendarInitial extends CalendarState {}

class CalendarLoading extends CalendarState {}

class CalendarLoaded extends CalendarState {
  final LinkedHashMap<DateTime, List<EventModel>> events;
  final bool isSyncing;

  const CalendarLoaded(this.events, {this.isSyncing = false});

  @override
  List<Object?> get props => [events, isSyncing];
}

class CalendarError extends CalendarState {
  final String message;
  const CalendarError(this.message);

  @override
  List<Object?> get props => [message];
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}
