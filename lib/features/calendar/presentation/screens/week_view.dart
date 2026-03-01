import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/calendar_bloc.dart';
import '../bloc/calendar_state.dart';
import '../bloc/date_bloc.dart';
import '../bloc/date_event.dart';
import '../bloc/date_state.dart';
import '../../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_state.dart';
import '../widgets/multi_day_timetable.dart';
import 'event_detail_screen.dart';
import 'add_event_screen.dart';
import '../../data/models/event_model.dart';

class WeekView extends StatefulWidget {
  const WeekView({super.key});

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  late PageController _pageController;
  final DateTime _baseDate = DateTime(2024, 1, 1);
  final int _basePage = 5000;

  @override
  void initState() {
    super.initState();
    final dateBloc = context.read<DateBloc>();
    final settingsBloc = context.read<SettingsBloc>();
    _pageController = PageController(
      initialPage: _calculatePage(
        dateBloc.state.selectedDate,
        settingsBloc.state.settings.firstDayOfWeek,
      ),
    );
  }

  int _calculatePage(DateTime date, int firstDayOfWeek) {
    final startOfDateWeek = _getStartOfWeek(date, firstDayOfWeek);
    final startOfBaseWeek = _getStartOfWeek(_baseDate, firstDayOfWeek);
    return _basePage +
        (startOfDateWeek.difference(startOfBaseWeek).inDays / 7).round();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getStartOfWeek(DateTime date, int startDay) {
    final daysToSubtract = (date.weekday - startDay + 7) % 7;
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: daysToSubtract));
  }

  List<EventModel> _getEventsForWeek(
    DateTime startOfWeek,
    Map<DateTime, List<EventModel>> eventsMap,
  ) {
    List<EventModel> weekEvents = [];
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final key = DateTime(date.year, date.month, date.day);
      if (eventsMap.containsKey(key)) weekEvents.addAll(eventsMap[key]!);
    }
    return weekEvents;
  }

  void _onPageChanged(int index) {
    final firstDayOfWeek = context
        .read<SettingsBloc>()
        .state
        .settings
        .firstDayOfWeek;
    final startOfNewWeek = _getStartOfWeek(
      _baseDate,
      firstDayOfWeek,
    ).add(Duration(days: (index - _basePage) * 7));
    final currentSelected = context.read<DateBloc>().state.selectedDate;
    final dayOfWeekOffset = currentSelected
        .difference(_getStartOfWeek(currentSelected, firstDayOfWeek))
        .inDays;
    context.read<DateBloc>().add(
      SetSelectedDate(startOfNewWeek.add(Duration(days: dayOfWeekOffset))),
    );
  }

  void _syncPageController(DateTime selectedDate, int firstDayOfWeek) {
    if (_pageController.hasClients) {
      final targetPage = _calculatePage(selectedDate, firstDayOfWeek);
      if (_pageController.page?.round() != targetPage) {
        _pageController.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final settings = settingsState.settings;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return BlocBuilder<DateBloc, DateState>(
          builder: (context, dateState) {
            final selectedDate = DateTime(
              dateState.selectedDate.year,
              dateState.selectedDate.month,
              dateState.selectedDate.day,
            );
            _syncPageController(selectedDate, settings.firstDayOfWeek);
            final weekStart = _getStartOfWeek(
              selectedDate,
              settings.firstDayOfWeek,
            );

            return BlocBuilder<CalendarBloc, CalendarState>(
              builder: (context, calendarState) {
                final eventsMap = calendarState is CalendarLoaded
                    ? calendarState.events
                    : <DateTime, List<EventModel>>{};
                return Column(
                  children: [
                    Center(
                      child: InkWell(
                        onTap: () =>
                            _showMonthYearPicker(context, selectedDate),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          child: Text(
                            weekStart.year == DateTime.now().year
                                ? DateFormat(
                                    'MMM',
                                  ).format(weekStart).toUpperCase()
                                : DateFormat(
                                    'MMM yyyy',
                                  ).format(weekStart).toUpperCase(),
                            style: TextStyle(
                              fontSize: 22 * settings.fontSize,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              color: theme.textTheme.titleLarge?.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildDateRow(
                      context,
                      weekStart,
                      theme,
                      isDark,
                      settings.fontSize,
                      selectedDate,
                      eventsMap,
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Expanded(
                                child: PageView.builder(
                                  controller: _pageController,
                                  onPageChanged: _onPageChanged,
                                  itemBuilder: (context, index) {
                                    final weekStartDate =
                                        _getStartOfWeek(
                                          _baseDate,
                                          settings.firstDayOfWeek,
                                        ).add(
                                          Duration(
                                            days: (index - _basePage) * 7,
                                          ),
                                        );
                                    final events = _getEventsForWeek(
                                      weekStartDate,
                                      eventsMap,
                                    );
                                    return MultiDayTimetable(
                                      initialDate: weekStartDate,
                                      numberOfDays: 7,
                                      events: events,
                                      hourHeight: 65,
                                      showHeader: false,
                                      fontSizeFactor: settings.fontSize,
                                    );
                                  },
                                ),
                              ),
                              _buildSelectedDayAgenda(
                                context,
                                selectedDate,
                                eventsMap,
                                isDark,
                                settings.fontSize,
                              ),
                              const SizedBox(height: 80),
                            ],
                          ),
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 16,
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () =>
                                        _showAddEvent(context, selectedDate),
                                    borderRadius: BorderRadius.circular(30),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.08,
                                              )
                                            : Colors.grey[100],
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.white10
                                              : Colors.white60,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.05,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        'Add event on ${DateFormat('MMM d').format(selectedDate)}',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black54,
                                          fontSize: 13 * settings.fontSize,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                FloatingActionButton(
                                  heroTag: null,
                                  onPressed: () =>
                                      _showAddEvent(context, selectedDate),
                                  backgroundColor: isDark
                                      ? Colors.white
                                      : Colors.black,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: isDark ? Colors.black : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  void _showAddEvent(BuildContext context, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40),
        child: AddEventScreen(initialDate: date),
      ),
    );
  }

  Widget _buildSelectedDayAgenda(
    BuildContext context,
    DateTime date,
    Map<DateTime, List<EventModel>> eventsMap,
    bool isDark,
    double fs,
  ) {
    final dayEvents = eventsMap[date] ?? [];
    if (dayEvents.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 120,
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Events for ${DateFormat('MMM d').format(date)}',
              style: TextStyle(
                fontSize: 12 * fs,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: dayEvents.length,
              itemBuilder: (context, index) {
                final event = dayEvents[index];
                final color = event.customColor ?? event.color.color;
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailScreen(event: event),
                    ),
                  ),
                  child: Container(
                    width: 200,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.grey[200]!,
                      ),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                event.title,
                                style: TextStyle(
                                  fontSize: 14 * fs,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                event.isAllDay
                                    ? 'All Day'
                                    : DateFormat(
                                        'h:mm a',
                                      ).format(event.startTime),
                                style: TextStyle(
                                  fontSize: 11 * fs,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.03),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: isDark ? Colors.white54 : Colors.black38,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(
    BuildContext context,
    DateTime weekStart,
    ThemeData theme,
    bool isDark,
    double fs,
    DateTime selectedDate,
    Map<DateTime, List<EventModel>> eventsMap,
  ) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      color: theme.scaffoldBackgroundColor,
      child: Row(
        children: List.generate(7, (index) {
          final day = weekStart.add(Duration(days: index));
          final isToday = isSameDay(day, DateTime.now());
          final isSelected = isSameDay(day, selectedDate);
          final isSunday = day.weekday == DateTime.sunday;
          final dayEvents = eventsMap[day] ?? [];
          return Expanded(
            child: GestureDetector(
              onTap: () => context.read<DateBloc>().add(SetSelectedDate(day)),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: isSelected
                    ? BoxDecoration(
                        color: theme.primaryColor.withValues(
                          alpha: isDark ? 0.2 : 0.1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: theme.primaryColor.withValues(alpha: 0.3),
                        ),
                      )
                    : null,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('E').format(day).substring(0, 1),
                      style: TextStyle(
                        fontSize: 12 * fs,
                        fontWeight: FontWeight.w600,
                        color: isSunday
                            ? Colors.red
                            : (isDark ? Colors.white70 : Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: isToday
                          ? BoxDecoration(
                              color: isDark ? Colors.white : Colors.black,
                              borderRadius: BorderRadius.circular(6),
                            )
                          : null,
                      child: MediaQuery.withNoTextScaling(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 13 * fs,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isToday
                                ? (isDark ? Colors.black : Colors.white)
                                : (isSunday
                                      ? Colors.red
                                      : (isDark
                                            ? Colors.white
                                            : Colors.black87)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (dayEvents.isNotEmpty)
                      Column(
                        children: [
                          ...dayEvents
                              .take(2)
                              .map(
                                (e) => Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 2),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (e.customColor ?? e.color.color)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(2),
                                    border: Border(
                                      left: BorderSide(
                                        color: (e.customColor ?? e.color.color),
                                        width: 2.5,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    e.title,
                                    style: TextStyle(
                                      fontSize: 8 * fs,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.8)
                                          : Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                          if (dayEvents.length > 2)
                            Text(
                              '+${dayEvents.length - 2} more',
                              style: TextStyle(
                                fontSize: 7 * fs,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white38
                                    : Colors.grey[500],
                              ),
                            ),
                        ],
                      )
                    else if (isToday)
                      Icon(
                        Icons.sentiment_satisfied_alt_outlined,
                        size: 14,
                        color: isDark ? Colors.white54 : Colors.grey[600],
                      )
                    else
                      const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _showMonthYearPicker(BuildContext context, DateTime initialDate) async {
    final DateTime? result = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WeekMonthYearPickerSheet(initialDate: initialDate),
    );
    if (result != null && mounted)
      context.read<DateBloc>().add(SetSelectedDate(result));
  }
}

class _WeekMonthYearPickerSheet extends StatefulWidget {
  final DateTime initialDate;
  const _WeekMonthYearPickerSheet({required this.initialDate});
  @override
  State<_WeekMonthYearPickerSheet> createState() =>
      _WeekMonthYearPickerSheetState();
}

class _WeekMonthYearPickerSheetState extends State<_WeekMonthYearPickerSheet> {
  late int _selectedYear;
  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () => setState(() => _selectedYear--),
                ),
                Text(
                  '$_selectedYear',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () => setState(() => _selectedYear++),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.5,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final isSelected =
                    widget.initialDate.year == _selectedYear &&
                    widget.initialDate.month == month;
                return GestureDetector(
                  onTap: () =>
                      Navigator.pop(context, DateTime(_selectedYear, month, 1)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.primaryColor
                          : (isDark ? Colors.white10 : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      DateFormat('MMMM').format(DateTime(_selectedYear, month)),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
