import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/calendar_bloc.dart';
import '../bloc/calendar_state.dart';
import '../bloc/date_bloc.dart';
import '../bloc/date_event.dart';
import '../bloc/date_state.dart';
import '../widgets/multi_day_timetable.dart';
import 'add_event_screen.dart';
import '../../../mood/presentation/bloc/mood_bloc.dart';
import '../../../mood/data/models/mood_model.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../../data/models/event_model.dart';

class DayView extends StatefulWidget {
  const DayView({super.key});
  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  late PageController _pageController;
  final int _basePage = 5000;
  late DateTime _baseDate;

  @override
  void initState() {
    super.initState();
    _baseDate = DateTime.now();
    _pageController = PageController(initialPage: _basePage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    final newDate = _baseDate.add(Duration(days: index - _basePage));
    context.read<DateBloc>().add(SetSelectedDate(newDate));
  }

  void _syncPageController(DateTime selectedDate) {
    if (_pageController.hasClients) {
      final targetPage =
          _basePage +
          selectedDate
              .difference(
                DateTime(_baseDate.year, _baseDate.month, _baseDate.day),
              )
              .inDays;
      if (_pageController.page?.round() != targetPage)
        _pageController.jumpToPage(targetPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final settings = settingsState.settings;
        return BlocBuilder<DateBloc, DateState>(
          builder: (context, dateState) {
            final rawSelectedDate = dateState.selectedDate;
            final selectedDate = DateTime(
              rawSelectedDate.year,
              rawSelectedDate.month,
              rawSelectedDate.day,
            );
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;
            _syncPageController(selectedDate);
            return BlocBuilder<CalendarBloc, CalendarState>(
              builder: (context, calendarState) {
                final Map<DateTime, List<EventModel>> eventsMap =
                    (calendarState is CalendarLoaded)
                    ? calendarState.events
                    : <DateTime, List<EventModel>>{};
                return Scaffold(
                  backgroundColor: theme.scaffoldBackgroundColor,
                  body: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          selectedDate.year == DateTime.now().year
                              ? DateFormat(
                                  'MMM',
                                ).format(selectedDate).toUpperCase()
                              : DateFormat(
                                  'MMM yyyy',
                                ).format(selectedDate).toUpperCase(),
                          style: TextStyle(
                            fontSize: 22 * settings.fontSize,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Row(
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white : Colors.black,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${selectedDate.day}',
                                style: TextStyle(
                                  fontSize: 22 * settings.fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                DateFormat('EEEE').format(selectedDate),
                                style: TextStyle(
                                  fontSize: 20 * settings.fontSize,
                                  fontWeight: FontWeight.w500,
                                  color: theme.textTheme.titleLarge?.color,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _showMoodPicker(
                                context,
                                selectedDate,
                                settings.fontSize,
                              ),
                              child: BlocBuilder<MoodBloc, MoodState>(
                                builder: (context, moodState) {
                                  final dateKey =
                                      "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
                                  final mood = moodState.moods[dateKey];
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (mood != null)
                                        Text(
                                          mood.label,
                                          style: TextStyle(
                                            fontSize: 10 * settings.fontSize,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? Colors.white38
                                                : Colors.grey[400],
                                          ),
                                        ),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: mood != null
                                            ? BoxDecoration(
                                                color: isDark
                                                    ? Colors.white.withValues(
                                                        alpha: 0.05,
                                                      )
                                                    : Colors.grey[100],
                                                shape: BoxShape.circle,
                                              )
                                            : null,
                                        child: mood != null
                                            ? Text(
                                                mood.emoji,
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                ),
                                              )
                                            : Icon(
                                                Icons
                                                    .sentiment_satisfied_alt_outlined,
                                                size: 28,
                                                color: isDark
                                                    ? Colors.white54
                                                    : Colors.grey[600],
                                              ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              onPageChanged: _onPageChanged,
                              itemBuilder: (context, index) {
                                final date = _baseDate.add(
                                  Duration(days: index - _basePage),
                                );
                                final dayKey = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                );
                                final List<EventModel> events =
                                    eventsMap[dayKey] ?? [];
                                return MultiDayTimetable(
                                  initialDate: date,
                                  numberOfDays: 1,
                                  events: events,
                                  hourHeight: 65,
                                  showHeader: false,
                                  fontSizeFactor: settings.fontSize,
                                );
                              },
                            ),
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 20,
                              child: ElevatedButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEventScreen(
                                      initialDate: selectedDate,
                                    ),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_rounded),
                                    SizedBox(width: 8),
                                    Text(
                                      'ADD NEW EVENT',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showMoodPicker(BuildContext context, DateTime date, double fs) {
    const moods = MoodModel.availableMoods;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How are you feeling?',
              style: TextStyle(fontSize: 20 * fs, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: moods
                  .map(
                    (m) => InkWell(
                      onTap: () {
                        context.read<MoodBloc>().add(SetMood(date, m));
                        Navigator.pop(ctx);
                      },
                      child: Column(
                        children: [
                          Text(m.emoji, style: const TextStyle(fontSize: 32)),
                          const SizedBox(height: 8),
                          Text(m.label, style: TextStyle(fontSize: 12 * fs)),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
