import 'package:flutter_contacts/flutter_contacts.dart' as contacts;
import '../features/calendar/data/models/event_model.dart';

class BirthdayService {
  Future<List<EventModel>> fetchBirthdays() async {
    if (await contacts.FlutterContacts.requestPermission()) {
      final contactList = await contacts.FlutterContacts.getContacts(
        withProperties: true,
      );
      final List<EventModel> birthdayEvents = [];

      for (var contact in contactList) {
        if (contact.events.any(
          (e) => e.label == contacts.EventLabel.birthday,
        )) {
          final birthdayEvent = contact.events.firstWhere(
            (e) => e.label == contacts.EventLabel.birthday,
          );
          if (birthdayEvent.year != null ||
              (birthdayEvent.month > 0 && birthdayEvent.day > 0)) {
            final now = DateTime.now();
            final year = (birthdayEvent.year != null && birthdayEvent.year! > 0)
                ? birthdayEvent.year!
                : now.year;
            final birthday = DateTime(
              year,
              birthdayEvent.month,
              birthdayEvent.day,
            );

            birthdayEvents.add(
              EventModel(
                id: 'birthday_${contact.id}',
                title: "${contact.displayName}'s Birthday",
                startTime: DateTime(
                  birthday.year,
                  birthday.month,
                  birthday.day,
                  0,
                  0,
                ),
                endTime: DateTime(
                  birthday.year,
                  birthday.month,
                  birthday.day,
                  23,
                  59,
                ),
                isAllDay: true,
                color: EventColor.social, // Updated to a valid EventColor
                notes: "Source: Contacts",
                recurrence: const RecurrenceRule(type: RecurrenceType.yearly),
              ),
            );
          }
        }
      }
      return birthdayEvents;
    }
    return [];
  }
}
