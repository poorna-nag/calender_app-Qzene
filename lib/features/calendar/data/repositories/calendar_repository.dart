import '../models/event_model.dart';

abstract class CalendarRepository {
  Future<List<EventModel>> loadUserEvents();
  Future<List<EventModel>> fetchDeviceEvents();
  Future<void> saveEvent(EventModel event);
  Future<void> deleteEvent(String eventId);
  Future<void> deleteEventsByGroupId(String groupId);
  Future<void> syncBirthdays(List<EventModel> birthdays);
  Future<List<EventModel>> loadDeletedEvents();
  Future<void> permanentlyDeleteEvent(String eventId);
  Future<void> emptyRecycleBin();
}
