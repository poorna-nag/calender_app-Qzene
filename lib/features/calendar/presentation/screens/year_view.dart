import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/date_bloc.dart';
import '../bloc/date_event.dart';
import '../bloc/date_state.dart';
import '../../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_state.dart';
import '../bloc/calendar_bloc.dart';
import '../bloc/calendar_state.dart';
import '../../data/models/event_model.dart';

class YearView extends StatefulWidget {
  final Function(int year, int month)? onMonthSelected;
  final Function(int year)? onYearChanged;
  const YearView({super.key, this.onMonthSelected, this.onYearChanged});
  @override
  State<YearView> createState() => YearViewState();
}

class YearViewState extends State<YearView> {
  late PageController _pageController;
  late int _focusedYear;
  final int _initialYear = DateTime.now().year;
  final int _basePage = 5000;

  @override
  void initState() {
    super.initState();
    _focusedYear = context.read<DateBloc>().state.selectedDate.year;
    _pageController = PageController(
      initialPage: _basePage + (_focusedYear - _initialYear),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onMonthTap(int year, int month) {
    context.read<DateBloc>().add(SetSelectedDate(DateTime(year, month, 1)));
    if (widget.onMonthSelected != null) widget.onMonthSelected!(year, month);
  }

  void selectYear() async {
    final int? selectedYear = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _YearPickerSheet(initialYear: _focusedYear),
    );
    if (selectedYear != null && selectedYear != _focusedYear)
      _pageController.jumpToPage(_basePage + (selectedYear - _initialYear));
  }

  void nextYear() => _pageController.nextPage(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );
  void previousYear() => _pageController.previousPage(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() => _focusedYear = _initialYear + (page - _basePage));
              if (widget.onYearChanged != null)
                widget.onYearChanged!(_focusedYear);
            },
            itemBuilder: (context, pageIndex) {
              final year = _initialYear + (pageIndex - _basePage);
              return _YearGrid(
                year: year,
                onMonthTap: (month) => _onMonthTap(year, month),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _YearPickerSheet extends StatefulWidget {
  final int initialYear;
  const _YearPickerSheet({required this.initialYear});
  @override
  State<_YearPickerSheet> createState() => _YearPickerSheetState();
}

class _YearPickerSheetState extends State<_YearPickerSheet> {
  late int _startYear;
  late int _selectedYear;
  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
    _startYear = ((_selectedYear - 1) ~/ 12) * 12 + 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.grey),
                    onPressed: () => setState(() => _startYear -= 12),
                  ),
                  Text(
                    '$_startYear - ${_startYear + 11}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.grey),
                    onPressed: () => setState(() => _startYear += 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 16,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final year = _startYear + index;
                  final isSelected = year == _selectedYear;
                  return GestureDetector(
                    onTap: () => Navigator.pop(context, year),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? theme.primaryColor
                            : Colors.transparent,
                        border: isSelected
                            ? null
                            : Border.all(
                                color: Colors.grey.withValues(alpha: 0.3),
                              ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$year',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w400,
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface,
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
}

class _YearGrid extends StatelessWidget {
  final int year;
  final Function(int) onMonthTap;
  const _YearGrid({required this.year, required this.onMonthTap});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = MediaQuery.of(context).size.height < 700;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: isCompact ? 0.85 : 0.95,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        return InkWell(
          onTap: () => onMonthTap(month),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 6),
                child: BlocBuilder<DateBloc, DateState>(
                  builder: (context, dateState) {
                    final isActive =
                        dateState.selectedDate.year == year &&
                        dateState.selectedDate.month == month;
                    return BlocBuilder<SettingsBloc, SettingsState>(
                      builder: (context, settingsState) => Text(
                        DateFormat('MMM').format(DateTime(year, month)),
                        style: TextStyle(
                          fontWeight: isActive
                              ? FontWeight.w900
                              : FontWeight.w600,
                          fontSize: 15 * settingsState.settings.fontSize,
                          color: theme.primaryColor.withValues(
                            alpha: isActive ? 1.0 : 0.8,
                          ),
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: _MonthPreview(year: year, month: month),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MonthPreview extends StatelessWidget {
  final int year;
  final int month;
  const _MonthPreview({required this.year, required this.month});
  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final daysInMonth = lastDay.day;
    final theme = Theme.of(context);
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final firstDayOfWeek = settingsState.settings.firstDayOfWeek;
        final fs = settingsState.settings.fontSize;
        return BlocBuilder<CalendarBloc, CalendarState>(
          builder: (context, calendarState) {
            final events = calendarState is CalendarLoaded
                ? calendarState.events
                : <DateTime, List<EventModel>>{};
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _getWeekDayHeaders(firstDayOfWeek)
                      .map(
                        (d) => Text(
                          d,
                          style: TextStyle(
                            fontSize: 9 * fs,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodySmall?.color?.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 7,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(42, (index) {
                      final dayIndex =
                          index - ((firstDay.weekday - firstDayOfWeek + 7) % 7);
                      final day = dayIndex + 1;
                      if (dayIndex < 0 || day > daysInMonth)
                        return const SizedBox();
                      final date = DateTime(year, month, day);
                      final hasEvents =
                          events.containsKey(date) && events[date]!.isNotEmpty;
                      final isToday =
                          DateTime.now().year == year &&
                          DateTime.now().month == month &&
                          DateTime.now().day == day;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: isToday
                                ? BoxDecoration(
                                    color: theme.brightness == Brightness.dark
                                        ? Colors.white
                                        : theme.primaryColor,
                                    shape: BoxShape.circle,
                                  )
                                : (hasEvents
                                      ? BoxDecoration(
                                          color: theme.primaryColor.withValues(
                                            alpha: 0.08,
                                          ),
                                          shape: BoxShape.circle,
                                        )
                                      : null),
                            child: Center(
                              child: MediaQuery.withNoTextScaling(
                                child: Text(
                                  '$day',
                                  style: TextStyle(
                                    fontSize: 10 * fs,
                                    color: isToday
                                        ? (theme.brightness == Brightness.dark
                                              ? Colors.black
                                              : Colors.white)
                                        : (date.weekday == DateTime.sunday
                                              ? theme.colorScheme.error
                                              : theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color),
                                    fontWeight:
                                        (isToday ||
                                            date.weekday == DateTime.sunday)
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (hasEvents && !isToday)
                            Positioned(
                              bottom: 2,
                              child: Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<String> _getWeekDayHeaders(int firstDay) {
    const all = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    if (firstDay == 1) return ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    if (firstDay == 6) return ['S', 'S', 'M', 'T', 'W', 'T', 'F'];
    return all;
  }
}
