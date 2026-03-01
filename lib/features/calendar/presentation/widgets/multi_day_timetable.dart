import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/event_model.dart';
import '../screens/event_detail_screen.dart';

class MultiDayTimetable extends StatefulWidget {
  final DateTime initialDate;
  final int numberOfDays;
  final List<EventModel> events;
  final double hourHeight;
  final Function(DateTime)? onDateTap;
  final bool showHeader;
  final double fontSizeFactor;

  const MultiDayTimetable({
    super.key,
    required this.initialDate,
    required this.events,
    this.numberOfDays = 1,
    this.hourHeight = 60.0,
    this.onDateTap,
    this.showHeader = true,
    this.fontSizeFactor = 1.0,
  });

  @override
  State<MultiDayTimetable> createState() => _MultiDayTimetableState();
}

class _MultiDayTimetableState extends State<MultiDayTimetable> {
  final ScrollController _scrollController = ScrollController();
  final double _timeColumnWidth = 50.0;
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final double scrollOffset =
            (_currentTime.hour * widget.hourHeight) +
            (_currentTime.minute / 60.0 * widget.hourHeight) -
            (widget.hourHeight * 2);
        _scrollController.jumpTo(
          scrollOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<EventModel> _getEventsForDay(DateTime day, {bool allDayOnly = false}) {
    return widget.events.where((e) {
      if (allDayOnly) return e.isAllDay && _isSameDay(e.startTime, day);
      return !e.isAllDay && _isSameDay(e.startTime, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        if (widget.showHeader) _buildHeader(theme),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: SizedBox(
              height: 24 * widget.hourHeight,
              child: Row(
                children: [
                  _buildTimeColumn(theme),
                  ...List.generate(widget.numberOfDays, (index) {
                    final day = widget.initialDate.add(Duration(days: index));
                    return Expanded(child: _buildDayColumn(day, theme));
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: _timeColumnWidth),
          ...List.generate(widget.numberOfDays, (index) {
            final day = widget.initialDate.add(Duration(days: index));
            final isToday = _isSameDay(day, DateTime.now());
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(day).toUpperCase(),
                    style: TextStyle(
                      fontSize: 11 * widget.fontSizeFactor,
                      color: isToday ? theme.primaryColor : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: isToday
                        ? BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          )
                        : null,
                    child: Text(
                      day.day.toString(),
                      style: TextStyle(
                        fontSize: 16 * widget.fontSizeFactor,
                        fontWeight: FontWeight.bold,
                        color: isToday
                            ? Colors.white
                            : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(ThemeData theme) {
    return SizedBox(
      width: _timeColumnWidth,
      child: Column(
        children: List.generate(
          24,
          (i) => SizedBox(
            height: widget.hourHeight,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: Text(
                i == 0
                    ? ''
                    : DateFormat(
                        'ha',
                      ).format(DateTime(2024, 1, 1, i)).toLowerCase(),
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 11 * widget.fontSizeFactor,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayColumn(DateTime day, ThemeData theme) {
    final dayEvents = _getEventsForDay(day);
    return Stack(
      children: [
        GestureDetector(
          onTapUp: (details) {
            if (widget.onDateTap != null) {
              final hour = details.localPosition.dy / widget.hourHeight;
              widget.onDateTap!(day.add(Duration(hours: hour.toInt())));
            }
          },
          child: Column(
            children: List.generate(
              24,
              (i) => Container(
                height: widget.hourHeight,
                decoration: BoxDecoration(
                  border: Border(
                    left: const BorderSide(color: Colors.grey, width: 0.1),
                    bottom: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.1),
                      width: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        ..._buildEventWidgets(dayEvents, theme),
        if (_isSameDay(day, DateTime.now())) _buildCurrentTimeLine(theme),
      ],
    );
  }

  List<Widget> _buildEventWidgets(List<EventModel> dayEvents, ThemeData theme) {
    if (dayEvents.isEmpty) return [];
    dayEvents.sort((a, b) => a.startTime.compareTo(b.startTime));
    List<Widget> eventWidgets = [];
    for (var event in dayEvents) {
      final top =
          (event.startTime.hour * widget.hourHeight) +
          (event.startTime.minute / 60.0 * widget.hourHeight);
      final height =
          (event.endTime.difference(event.startTime).inMinutes /
                  60.0 *
                  widget.hourHeight)
              .clamp(15.0, double.infinity);
      eventWidgets.add(
        Positioned(
          top: top,
          left: 2,
          right: 2,
          height: height,
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EventDetailScreen(event: event),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: (event.customColor ?? event.color.color).withValues(
                  alpha: 0.8,
                ),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white24, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 12 * widget.fontSizeFactor,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (height > 30)
                    Text(
                      DateFormat('h:mm a').format(event.startTime),
                      style: TextStyle(
                        fontSize: 10 * widget.fontSizeFactor,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return eventWidgets;
  }

  Widget _buildCurrentTimeLine(ThemeData theme) {
    final top =
        (_currentTime.hour * widget.hourHeight) +
        (_currentTime.minute / 60.0 * widget.hourHeight);
    return Positioned(
      top: top - 1,
      left: 0,
      right: 0,
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.red),
          Expanded(child: Divider(color: Colors.red, thickness: 1.5)),
        ],
      ),
    );
  }
}
