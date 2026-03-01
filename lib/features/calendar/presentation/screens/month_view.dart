import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/models/event_model.dart';
import '../bloc/calendar_bloc.dart';
import '../bloc/calendar_state.dart';
import '../bloc/date_bloc.dart';
import '../bloc/date_event.dart';
import '../bloc/date_state.dart';
import '../../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_state.dart';
import 'event_detail_screen.dart'; // To be moved or updated

class MonthView extends StatefulWidget {
  const MonthView({super.key});

  @override
  State<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  late DateTime _focusedDay;
  DateTime _lastSyncedMonthYear = DateTime.now();

  @override
  void initState() {
    super.initState();
    _focusedDay = context.read<DateBloc>().state.selectedDate;
    _lastSyncedMonthYear = DateTime(_focusedDay.year, _focusedDay.month);
  }

  List<EventModel> _getEventsForDay(
    DateTime day,
    Map<DateTime, List<EventModel>> events,
  ) {
    final key = DateTime(day.year, day.month, day.day);
    return events[key] ?? [];
  }

  void _showDayEventsBottomSheet(
    BuildContext context,
    DateTime day,
    List<EventModel> dayEvents,
    double fs,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('EEEE, MMM d').format(day).toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                  Text(
                    '${dayEvents.length} EVENTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: dayEvents.length,
                itemBuilder: (context, index) {
                  final event = dayEvents[index];
                  final color = event.customColor ?? event.color.color;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)));
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: isDark ? 0.15 : 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: color.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 32,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title,
                                    style: TextStyle(
                                      fontSize: 16 * fs,
                                      fontWeight: FontWeight.bold,
                                      color: theme.textTheme.titleLarge?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    event.isAllDay
                                        ? 'All Day'
                                        : '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}',
                                    style: TextStyle(
                                      fontSize: 13 * fs,
                                      color: theme.textTheme.bodyMedium?.color
                                          ?.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: color.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final settings = settingsState.settings;
        final double fs = settings.fontSize;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return BlocBuilder<DateBloc, DateState>(
          builder: (context, dateState) {
            final selectedDate = DateTime(
              dateState.selectedDate.year,
              dateState.selectedDate.month,
              dateState.selectedDate.day,
            );

            // Sync focused day
            if ((selectedDate.year != _focusedDay.year ||
                    selectedDate.month != _focusedDay.month) &&
                (selectedDate.year != _lastSyncedMonthYear.year ||
                    selectedDate.month != _lastSyncedMonthYear.month)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _focusedDay = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                    );
                  });
                }
              });
            }

            return BlocBuilder<CalendarBloc, CalendarState>(
              builder: (context, calendarState) {
                final events = calendarState is CalendarLoaded
                    ? calendarState.events
                    : <DateTime, List<EventModel>>{};

                return Column(
                  children: [
                    Expanded(
                      child: Container(
                        color: theme.scaffoldBackgroundColor,
                        child: TableCalendar<EventModel>(
                          firstDay: DateTime(2000, 1, 1),
                          lastDay: DateTime(2050, 12, 31),
                          focusedDay: _focusedDay,
                          calendarFormat: CalendarFormat.month,
                          shouldFillViewport: true,
                          sixWeekMonthsEnforced: true,
                          selectedDayPredicate: (day) =>
                              isSameDay(selectedDate, day),
                          eventLoader: (day) => _getEventsForDay(day, events),
                          startingDayOfWeek: settings.firstDayOfWeek == 1
                              ? StartingDayOfWeek.monday
                              : (settings.firstDayOfWeek == 6
                                    ? StartingDayOfWeek.saturday
                                    : StartingDayOfWeek.sunday),
                          headerVisible: false,
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                            weekendStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.withValues(alpha: 0.8),
                            ),
                          ),
                          daysOfWeekHeight: 30,
                          calendarStyle: const CalendarStyle(
                            outsideDaysVisible: true,
                            outsideTextStyle: TextStyle(color: Colors.grey),
                            cellMargin: EdgeInsets.zero,
                            selectedDecoration: BoxDecoration(),
                            todayDecoration: BoxDecoration(),
                            markerDecoration: BoxDecoration(),
                            tableBorder: TableBorder(),
                          ),
                          onDaySelected: (selectedDay, focusedDay) {
                            context.read<DateBloc>().add(
                              SetSelectedDate(selectedDay),
                            );
                            final dayEvents = _getEventsForDay(
                              selectedDay,
                              events,
                            );
                            if (dayEvents.isNotEmpty) {
                              _showDayEventsBottomSheet(
                                context,
                                selectedDay,
                                dayEvents,
                                fs,
                              );
                            }
                            if (focusedDay.year != _focusedDay.year ||
                                focusedDay.month != _focusedDay.month) {
                              setState(() {
                                _focusedDay = focusedDay;
                              });
                            }
                          },
                          onPageChanged: (focusedDay) {
                            final newFocusedDay = DateTime(
                              focusedDay.year,
                              focusedDay.month,
                              focusedDay.day,
                            );
                            _lastSyncedMonthYear = DateTime(
                              focusedDay.year,
                              focusedDay.month,
                            );
                            setState(() {
                              _focusedDay = newFocusedDay;
                            });
                            Future.delayed(
                              const Duration(milliseconds: 50),
                              () {
                                if (mounted) {
                                  context.read<DateBloc>().add(
                                    SetSelectedDate(newFocusedDay),
                                  );
                                }
                              },
                            );
                          },
                          calendarBuilders: CalendarBuilders(
                            dowBuilder: (context, day) {
                              final text = DateFormat(
                                'E',
                              ).format(day).substring(0, 1);
                              final isSunday = day.weekday == DateTime.sunday;
                              return Center(
                                child: MediaQuery.withNoTextScaling(
                                  child: Text(
                                    text,
                                    style: TextStyle(
                                      color: isSunday
                                          ? Colors.red
                                          : (theme.brightness == Brightness.dark
                                                ? Colors.white70
                                                : Colors.black87),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12 * fs,
                                    ),
                                  ),
                                ),
                              );
                            },
                            defaultBuilder: (context, day, focusedDay) =>
                                _buildCell(
                                  context,
                                  day,
                                  events,
                                  isSelected: false,
                                  isToday: false,
                                  fs: fs,
                                  isExpanded: true,
                                ),
                            selectedBuilder: (context, day, focusedDay) =>
                                _buildCell(
                                  context,
                                  day,
                                  events,
                                  isSelected: true,
                                  isToday: isSameDay(day, DateTime.now()),
                                  fs: fs,
                                  isExpanded: true,
                                ),
                            todayBuilder: (context, day, focusedDay) =>
                                _buildCell(
                                  context,
                                  day,
                                  events,
                                  isSelected: false,
                                  isToday: true,
                                  fs: fs,
                                  isExpanded: true,
                                ),
                            outsideBuilder: (context, day, focusedDay) =>
                                _buildCell(
                                  context,
                                  day,
                                  events,
                                  isSelected: false,
                                  isToday: false,
                                  fs: fs,
                                  isOutside: true,
                                  isExpanded: true,
                                ),
                            markerBuilder: (context, day, events) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCell(
    BuildContext context,
    DateTime day,
    Map<DateTime, List<EventModel>> allEvents, {
    required bool isSelected,
    required bool isToday,
    required double fs,
    bool isOutside = false,
    bool isExpanded = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dayEvents = _getEventsForDay(day, allEvents);
    final isSunday = day.weekday == DateTime.sunday;

    return ClipRect(
      key: ValueKey('cell_${day.year}_${day.month}_${day.day}'),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected && !isExpanded
              ? (isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : theme.primaryColor.withValues(alpha: 0.04))
              : null,
          border: Border.all(color: Colors.transparent, width: 0),
        ),
        child: Column(
          children: [
            const SizedBox(height: 2),
            Container(
              height: 22,
              width: 22,
              alignment: Alignment.center,
              decoration: (isSelected || isToday)
                  ? BoxDecoration(
                      color: isSelected
                          ? theme.primaryColor
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday && !isSelected
                          ? Border.all(
                              color: isDark ? Colors.white : Colors.black,
                              width: 1.5,
                            )
                          : null,
                    )
                  : null,
              child: MediaQuery.withNoTextScaling(
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 13 * fs,
                    fontWeight: (isSelected || isToday)
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : isToday
                        ? (isDark ? Colors.white : Colors.black)
                        : isOutside
                        ? Colors.grey.withValues(alpha: 0.3)
                        : isSunday
                        ? Colors.red
                        : (isDark ? Colors.white : Colors.black),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Builder(
                  builder: (context) {
                    final sortedEvents = List<EventModel>.from(dayEvents)
                      ..sort((a, b) {
                        final aIsHoliday =
                            a.id.startsWith('in_') ||
                            a.id.startsWith('rel_') ||
                            a.id.startsWith('us_') ||
                            a.id.startsWith('gb_') ||
                            (a.notes?.toLowerCase().contains('holiday') ??
                                false);
                        final bIsHoliday =
                            b.id.startsWith('in_') ||
                            b.id.startsWith('rel_') ||
                            b.id.startsWith('us_') ||
                            b.id.startsWith('gb_') ||
                            (b.notes?.toLowerCase().contains('holiday') ??
                                false);
                        if (aIsHoliday != bIsHoliday)
                          return aIsHoliday ? -1 : 1;
                        if (a.isAllDay != b.isAllDay)
                          return a.isAllDay ? -1 : 1;
                        return a.startTime.compareTo(b.startTime);
                      });

                    final visibleEvents = sortedEvents.take(2);
                    final hasMore = sortedEvents.length > 2;

                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...visibleEvents.map((event) {
                            final color =
                                event.customColor ?? event.color.color;
                            final isMeeting =
                                event.title.toLowerCase().contains(
                                  'stand up',
                                ) ||
                                event.title.toLowerCase().contains('meet') ||
                                event.title.toLowerCase().contains('call') ||
                                event.title.toLowerCase().contains('session');
                            final bool isHoliday =
                                event.id.startsWith('in_') ||
                                event.id.startsWith('rel_') ||
                                event.id.startsWith('us_') ||
                                event.id.startsWith('gb_') ||
                                (event.notes?.toLowerCase().contains(
                                      'holiday',
                                    ) ??
                                    false);

                            if (isExpanded) {
                              Color displayColor = isOutside
                                  ? color.withValues(alpha: 0.5)
                                  : color;
                              return GestureDetector(
                                onTap: () {
                                  // Navigator.push(context, MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)));
                                },
                                child: Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 1.5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: displayColor.withValues(
                                      alpha: isDark ? 0.15 : 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: displayColor.withValues(
                                        alpha: 0.2,
                                      ),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 2.5,
                                        height: 12,
                                        margin: const EdgeInsets.only(
                                          top: 1,
                                          right: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: displayColor,
                                          borderRadius: BorderRadius.circular(
                                            1,
                                          ),
                                        ),
                                      ),
                                      if (isMeeting)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 1,
                                            right: 2,
                                          ),
                                          child: Icon(
                                            Icons.videocam_rounded,
                                            size: 11,
                                            color: displayColor,
                                          ),
                                        ),
                                      Expanded(
                                        child: MediaQuery.withNoTextScaling(
                                          child: Text(
                                            event.title,
                                            style: TextStyle(
                                              fontSize: 11.5 * fs,
                                              color: isDark
                                                  ? displayColor.withValues(
                                                      alpha: 0.95,
                                                    )
                                                  : displayColor,
                                              fontWeight:
                                                  (isHoliday || event.isAllDay)
                                                  ? FontWeight.w900
                                                  : FontWeight.w800,
                                              height: 1.1,
                                              letterSpacing: -0.2,
                                            ),
                                            maxLines: 4,
                                            softWrap: true,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Container(
                                height: 3,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 1.0,
                                ),
                                decoration: BoxDecoration(
                                  color: isOutside
                                      ? color.withValues(alpha: 0.3)
                                      : color,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            }
                          }).toList(),
                          if (hasMore && isExpanded)
                            Padding(
                              padding: const EdgeInsets.only(top: 1),
                              child: Center(
                                child: Text(
                                  '+${sortedEvents.length - 2} more',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
