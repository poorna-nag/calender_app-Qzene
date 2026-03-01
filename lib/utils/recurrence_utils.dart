import '../features/calendar/data/models/event_model.dart';

class RecurrenceUtils {
  static List<EventModel> generateOccurrences(
    EventModel event, {
    DateTime? rangeStart,
    DateTime? rangeEnd,
  }) {
    if (!event.recurrence.isRecurring) return [event];

    final List<EventModel> instances = [];
    final DateTime baseStart = event.startTime;
    final DateTime baseEnd = event.endTime;
    final Duration duration = baseEnd.difference(baseStart);
    final RecurrenceRule rule = event.recurrence;
    final int interval = rule.interval > 0 ? rule.interval : 1;

    rangeEnd ??= baseStart.add(const Duration(days: 365 * 2));

    DateTime currentCheck = baseStart;
    int count = 0;
    int safetyCounter = 0;
    const int maxInstances = 1000;

    while (safetyCounter < 10000) {
      safetyCounter++;
      if (rule.endType == RecurrenceEndType.onDate &&
          rule.endDate != null &&
          currentCheck.isAfter(rule.endDate!))
        break;
      if (rule.endType == RecurrenceEndType.afterCount &&
          rule.count != null &&
          count >= rule.count!)
        break;
      if (currentCheck.isAfter(rangeEnd)) break;

      if (_matchesRecurrence(currentCheck, baseStart, rule)) {
        instances.add(
          event.copyWith(
            id: '${event.id}_$count',
            startTime: currentCheck,
            endTime: currentCheck.add(duration),
            recurrenceGroupId: event.id,
          ),
        );
        count++;
        if (count >= maxInstances) break;
      }

      switch (rule.type) {
        case RecurrenceType.daily:
          currentCheck = currentCheck.add(Duration(days: interval));
          break;
        case RecurrenceType.weekly:
          currentCheck = currentCheck.add(const Duration(days: 1));
          break;
        case RecurrenceType.monthly:
          currentCheck = currentCheck.add(const Duration(days: 1));
          break;
        case RecurrenceType.yearly:
          currentCheck = currentCheck.add(const Duration(days: 1));
          break;
        default:
          return instances;
      }
    }
    return instances;
  }

  static bool _matchesRecurrence(
    DateTime current,
    DateTime base,
    RecurrenceRule rule,
  ) {
    if (current.isBefore(base)) return false;
    final interval = rule.interval > 0 ? rule.interval : 1;
    switch (rule.type) {
      case RecurrenceType.daily:
        final diffDays = current
            .difference(DateTime(base.year, base.month, base.day))
            .inDays;
        return diffDays % interval == 0;
      case RecurrenceType.weekly:
        DateTime baseMonday = base.subtract(Duration(days: base.weekday - 1));
        DateTime currentMonday = current.subtract(
          Duration(days: current.weekday - 1),
        );
        final diffWeeks = (currentMonday.difference(baseMonday).inDays / 7)
            .round();
        if (diffWeeks % interval != 0) return false;
        if (rule.daysOfWeek != null && rule.daysOfWeek!.isNotEmpty)
          return rule.daysOfWeek!.contains(current.weekday);
        return current.weekday == base.weekday;
      case RecurrenceType.monthly:
        final diffMonths =
            (current.year - base.year) * 12 + (current.month - base.month);
        if (diffMonths % interval != 0) return false;
        if (rule.daysOfMonth != null && rule.daysOfMonth!.isNotEmpty)
          return rule.daysOfMonth!.contains(current.day);
        return current.day == base.day;
      case RecurrenceType.yearly:
        final diffYears = current.year - base.year;
        if (diffYears % interval != 0) return false;
        if (rule.monthsOfYear != null && rule.monthsOfYear!.isNotEmpty) {
          if (!rule.monthsOfYear!.contains(current.month)) return false;
        } else {
          if (current.month != base.month) return false;
        }
        if (rule.daysOfMonth != null && rule.daysOfMonth!.isNotEmpty)
          return rule.daysOfMonth!.contains(current.day);
        return current.day == base.day;
      default:
        return false;
    }
  }
}
