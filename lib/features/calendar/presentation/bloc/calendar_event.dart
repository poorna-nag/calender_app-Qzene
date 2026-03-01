import 'package:equatable/equatable.dart';
import '../../data/models/event_model.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();
  @override
  List<Object?> get props => [];
}

class LoadCalendarEvents extends CalendarEvent {}

class FetchDeviceEvents extends CalendarEvent {}

class AddEvent extends CalendarEvent {
  final EventModel event;
  const AddEvent(this.event);
  @override
  List<Object?> get props => [event];
}

class UpdateEvent extends CalendarEvent {
  final EventModel event;
  const UpdateEvent(this.event);
  @override
  List<Object?> get props => [event];
}

class DeleteEvent extends CalendarEvent {
  final EventModel event;
  const DeleteEvent(this.event);
  @override
  List<Object?> get props => [event];
}

class RestoreEvent extends CalendarEvent {
  final EventModel event;
  const RestoreEvent(this.event);
  @override
  List<Object?> get props => [event];
}

class SyncBirthdays extends CalendarEvent {
  final List<EventModel> birthdays;
  const SyncBirthdays(this.birthdays);
  @override
  List<Object?> get props => [birthdays];
}
