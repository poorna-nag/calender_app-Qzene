import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../bloc/calendar_bloc.dart';
import '../bloc/calendar_event.dart';
import '../../data/models/event_model.dart';
import 'map_picker_screen.dart';
import 'recurrence_screen.dart';

class AddEventScreen extends StatefulWidget {
  final EventModel? event;
  final DateTime? initialDate;
  const AddEventScreen({super.key, this.event, this.initialDate});
  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();
  final _urlController = TextEditingController();
  String _selectedCategory = 'Personal';
  final List<String> _categories = [
    'Work',
    'Personal',
    'Meeting',
    'Health',
    'Study',
    'Custom',
  ];

  final Map<String, Color> _categoryColors = {
    'Work': const Color(0xFF039BE5),
    'Personal': const Color(0xFF8E24AA),
    'Meeting': const Color(0xFFF4511E),
    'Health': const Color(0xFF0B8043),
    'Study': const Color(0xFF3F51B5),
    'Custom': const Color(0xFF616161),
  };

  bool _isAllDay = false;
  late DateTime _startDate;
  late DateTime _endDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  RecurrenceRule _recurrenceRule = const RecurrenceRule(
    type: RecurrenceType.none,
  );
  List<Duration> _reminders = [const Duration(minutes: 10)];
  LatLng? _selectedLocationCoords;
  bool _showMapPreview = false;
  EventColor _selectedColor = EventColor.health;
  Color _customColor = const Color(0xFF1976D2);
  EventAvailability _availability = EventAvailability.busy;
  EventVisibility _visibility = EventVisibility.private;
  String? _attachmentPath;
  String _selectedTimeZone = 'UTC';
  List<String> _attendees = [];

  @override
  void initState() {
    super.initState();
    _initTimeZone();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _locationController.text = widget.event!.location ?? '';
      _notesController.text = widget.event!.notes ?? '';
      _urlController.text = widget.event!.url ?? '';
      _startDate = widget.event!.startTime;
      _endDate = widget.event!.endTime;
      _startTime = TimeOfDay.fromDateTime(_startDate);
      _endTime = TimeOfDay.fromDateTime(_endDate);
      _isAllDay = widget.event!.isAllDay;
      _selectedColor = widget.event!.color;
      _customColor = widget.event!.customColor ?? _customColor;
      _recurrenceRule = widget.event!.recurrence;
      _reminders = List.from(widget.event!.reminders);
      _attendees = List.from(widget.event!.attendees ?? []);
      _availability = widget.event!.availability;
      _visibility = widget.event!.visibility;
      _attachmentPath = widget.event!.photoPath;
      _selectedTimeZone = widget.event!.timeZone ?? 'UTC';
    } else {
      final now = DateTime.now();
      final baseDate = widget.initialDate ?? now;
      _startDate = DateTime(baseDate.year, baseDate.month, baseDate.day);
      _startTime = TimeOfDay(hour: (now.hour + 1) % 24, minute: 0);
      _endDate = _startDate;
      _endTime = TimeOfDay(hour: (now.hour + 2) % 24, minute: 0);
    }
  }

  void _initTimeZone() {
    try {
      _selectedTimeZone = tz.getLocation('Asia/Kolkata').name;
    } catch (_) {
      _selectedTimeZone = 'UTC';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null)
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) _endDate = _startDate;
        } else {
          _endDate = picked;
          if (_startDate.isAfter(_endDate)) _startDate = _endDate;
        }
      });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null)
      setState(() {
        if (isStart) {
          _startTime = picked;
          if (_startDate.isAtSameMomentAs(_endDate)) {
            if ((_endTime.hour * 60 + _endTime.minute) <=
                (_startTime.hour * 60 + _startTime.minute))
              _endTime = TimeOfDay(
                hour: (_startTime.hour + 1) % 24,
                minute: _startTime.minute,
              );
          }
        } else {
          _endTime = picked;
        }
      });
  }

  void _saveEvent() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an event title')),
      );
      return;
    }
    final start = DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _startTime.hour,
      _startTime.minute,
    );
    final end = _isAllDay
        ? DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59)
        : DateTime(
            _endDate.year,
            _endDate.month,
            _endDate.day,
            _endTime.hour,
            _endTime.minute,
          );
    if (end.isBefore(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time cannot be before start time')),
      );
      return;
    }
    final event = EventModel(
      id: widget.event?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      startTime: start,
      endTime: end,
      isAllDay: _isAllDay,
      location: _locationController.text.isNotEmpty
          ? _locationController.text
          : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      url: _urlController.text.isNotEmpty ? _urlController.text : null,
      color: _selectedColor,
      customColor: _customColor,
      recurrence: _recurrenceRule,
      reminders: _reminders,
      attendees: _attendees,
      photoPath: _attachmentPath,
      availability: _availability,
      visibility: _visibility,
      timeZone: _selectedTimeZone,
      emoji: _selectedCategory,
    );
    if (widget.event != null)
      context.read<CalendarBloc>().add(UpdateEvent(event));
    else
      context.read<CalendarBloc>().add(AddEvent(event));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0.5,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: theme.colorScheme.primary, fontSize: 17),
          ),
        ),
        leadingWidth: 80,
        title: Text(
          widget.event == null ? 'New Event' : 'Edit Event',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveEvent,
            child: Text(
              'Save',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('BASIC INFORMATION'),
            _buildGroupedCard(
              cardColor: cardColor,
              isDark: isDark,
              children: [
                _buildTextInputRow(
                  controller: _titleController,
                  hint: 'Enter event title *',
                  maxLength: 100,
                  isDark: isDark,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _buildDivider(isDark),
                _buildTextInputRow(
                  controller: _notesController,
                  hint: 'Description (Optional)',
                  maxLength: 1000,
                  maxLines: 5,
                  minLines: 3,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('CATEGORY'),
            _buildGroupedCard(
              cardColor: cardColor,
              isDark: isDark,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories
                        .map(
                          (c) => FilterChip(
                            label: Text(
                              c,
                              style: TextStyle(
                                color: _selectedCategory == c
                                    ? Colors.white
                                    : null,
                              ),
                            ),
                            selected: _selectedCategory == c,
                            selectedColor: _categoryColors[c],
                            onSelected: (v) =>
                                setState(() => _selectedCategory = c),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('DATE & TIME'),
            _buildGroupedCard(
              cardColor: cardColor,
              isDark: isDark,
              children: [
                _buildRowItem(
                  title: 'All-Day',
                  isDark: isDark,
                  trailing: Switch.adaptive(
                    value: _isAllDay,
                    onChanged: (v) => setState(() => _isAllDay = v),
                    activeColor: theme.colorScheme.primary,
                  ),
                ),
                _buildDivider(isDark),
                _buildDateTimeRow(
                  title: 'Starts',
                  date: _startDate,
                  time: _startTime,
                  isStart: true,
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildDateTimeRow(
                  title: 'Ends',
                  date: _endDate,
                  time: _endTime,
                  isStart: false,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('RECURRENCE'),
            _buildGroupedCard(
              cardColor: cardColor,
              isDark: isDark,
              children: [
                _buildRowItem(
                  title: 'Repeat',
                  valueText: _recurrenceRule.type == RecurrenceType.none
                      ? 'Does not repeat'
                      : _recurrenceRule.type.name.toUpperCase(),
                  isDark: isDark,
                  onTap: () async {
                    final r = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecurrenceScreen(
                          initialRule: _recurrenceRule,
                          startDate: _startDate,
                        ),
                      ),
                    );
                    if (r != null) setState(() => _recurrenceRule = r);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('REMINDERS'),
            _buildGroupedCard(
              cardColor: cardColor,
              isDark: isDark,
              children: [
                _buildRowItem(
                  title: 'Alert',
                  valueText: _reminders.isEmpty
                      ? 'None'
                      : '${_reminders.length} reminder(s)',
                  isDark: isDark,
                  onTap: () => _showReminderPicker(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('LOCATION'),
            _buildGroupedCard(
              cardColor: cardColor,
              isDark: isDark,
              children: [
                _buildTextInputRow(
                  controller: _locationController,
                  hint: 'Location',
                  icon: Icons.location_on_outlined,
                  isDark: isDark,
                  trailing: IconButton(
                    icon: Icon(Icons.map, color: theme.colorScheme.primary),
                    onPressed: () async {
                      final r = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapPickerScreen(
                            initialLocation:
                                _selectedLocationCoords ??
                                const LatLng(17.3850, 78.4867),
                          ),
                        ),
                      );
                      if (r != null)
                        setState(() {
                          _selectedLocationCoords = r['location'];
                          _locationController.text = r['address'];
                          _showMapPreview = true;
                        });
                    },
                  ),
                ),
                if (_selectedLocationCoords != null && _showMapPreview)
                  Container(
                    height: 120,
                    margin: const EdgeInsets.all(16),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: _selectedLocationCoords!,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedLocationCoords!,
                              child: Icon(
                                Icons.location_on,
                                color: _customColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            if (widget.event != null)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        final dup = widget.event!.copyWith(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                        );
                        context.read<CalendarBloc>().add(AddEvent(dup));
                        Navigator.pop(context);
                      },
                      child: const Text('Duplicate Event'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<CalendarBloc>().add(
                          DeleteEvent(widget.event!),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Delete Event'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showReminderPicker() {
    final List<Duration> options = [
      const Duration(minutes: 0),
      const Duration(minutes: 10),
      const Duration(hours: 1),
      const Duration(days: 1),
    ];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((d) {
          final label = d.inMinutes == 0
              ? 'At time of event'
              : d.inMinutes < 60
              ? '${d.inMinutes} mins before'
              : d.inHours < 24
              ? '${d.inHours} hr before'
              : '${d.inDays} day before';
          final selected = _reminders.any((r) => r.inMinutes == d.inMinutes);
          return ListTile(
            title: Text(label),
            trailing: selected
                ? const Icon(Icons.check, color: Colors.blue)
                : null,
            onTap: () {
              setState(() {
                if (selected)
                  _reminders.removeWhere((r) => r.inMinutes == d.inMinutes);
                else
                  _reminders.add(d);
              });
              Navigator.pop(ctx);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(left: 16, bottom: 8),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey[500],
        letterSpacing: 0.5,
      ),
    ),
  );
  Widget _buildGroupedCard({
    required Color cardColor,
    required bool isDark,
    required List<Widget> children,
  }) => Container(
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );
  Widget _buildDivider(bool isDark) => Padding(
    padding: const EdgeInsets.only(left: 16),
    child: Divider(
      height: 1,
      thickness: 0.5,
      color: isDark ? Colors.white10 : Colors.black12,
    ),
  );
  Widget _buildTextInputRow({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int? maxLength,
    int maxLines = 1,
    int minLines = 1,
    required bool isDark,
    TextStyle? textStyle,
    Widget? trailing,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      children: [
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(icon, size: 22),
          ),
        Expanded(
          child: TextField(
            controller: controller,
            maxLength: maxLength,
            maxLines: maxLines,
            minLines: minLines,
            style:
                textStyle ??
                TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              counterText: '',
              isDense: true,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    ),
  );
  Widget _buildRowItem({
    required String title,
    String? valueText,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
  }) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          if (valueText != null)
            Text(
              valueText,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey[600],
              ),
            ),
          if (trailing != null)
            trailing
          else if (onTap != null)
            const Icon(Icons.chevron_right),
        ],
      ),
    ),
  );
  Widget _buildDateTimeRow({
    required String title,
    required DateTime date,
    required TimeOfDay time,
    required bool isStart,
    required bool isDark,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        Row(
          children: [
            GestureDetector(
              onTap: () => _pickDate(isStart: isStart),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(DateFormat('MMM d, yyyy').format(date)),
              ),
            ),
            if (!_isAllDay) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _pickTime(isStart: isStart),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(time.format(context)),
                ),
              ),
            ],
          ],
        ),
      ],
    ),
  );
}
