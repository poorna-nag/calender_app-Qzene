import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/calendar_bloc.dart';
import '../bloc/calendar_event.dart';
import '../../data/models/event_model.dart';
import 'add_event_screen.dart';
import '../../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_state.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final fs = settingsState.settings.fontSize;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final mainTextColor = isDark ? Colors.white : Colors.black;
        final hintColor = isDark ? Colors.white60 : Colors.grey;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: mainTextColor),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.copy, color: mainTextColor, size: 20),
                onPressed: () {
                  final newEvent = event.copyWith(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                  );
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 40,
                      ),
                      child: AddEventScreen(event: newEvent),
                    ),
                  );
                },
              ),
              TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 40,
                      ),
                      child: AddEventScreen(event: event),
                    ),
                  );
                },
                child: Text(
                  'Edit',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16 * fs,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionHeader('BASIC INFORMATION', fs),
                      _buildGroupedCard(
                        cardColor: isDark
                            ? const Color(0xFF1C1C1E)
                            : Colors.white,
                        isDark: isDark,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: TextStyle(
                                    fontSize: 22 * fs,
                                    fontWeight: FontWeight.w800,
                                    color: mainTextColor,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                if (event.notes != null &&
                                    event.notes!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    event.notes!,
                                    style: TextStyle(
                                      fontSize: 16 * fs,
                                      color: hintColor,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('DATE & TIME', fs),
                      _buildGroupedCard(
                        cardColor: isDark
                            ? const Color(0xFF1C1C1E)
                            : Colors.white,
                        isDark: isDark,
                        children: [
                          _buildDetailRow(
                            icon: Icons.access_time_rounded,
                            title: event.isAllDay ? 'All Day' : 'Time',
                            value: event.isAllDay
                                ? DateFormat(
                                    'EEEE, MMM d',
                                  ).format(event.startTime)
                                : '${DateFormat('EEEE, MMM d').format(event.startTime)}\n${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}',
                            isDark: isDark,
                            mainTextColor: mainTextColor,
                            fs: fs,
                          ),
                          if (event.recurrence.type != RecurrenceType.none) ...[
                            _buildDivider(isDark),
                            _buildDetailRow(
                              icon: Icons.repeat_rounded,
                              title: 'Repeat',
                              value: event.recurrence.type.name.toUpperCase(),
                              isDark: isDark,
                              mainTextColor: mainTextColor,
                              fs: fs,
                            ),
                          ],
                          if (event.reminders.isNotEmpty) ...[
                            _buildDivider(isDark),
                            _buildDetailRow(
                              icon: Icons.notifications_active_outlined,
                              title: 'Alert',
                              value: event.reminders
                                  .map((r) => _formatReminder(r))
                                  .join(', '),
                              isDark: isDark,
                              mainTextColor: mainTextColor,
                              fs: fs,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),
                      if ((event.location != null &&
                              event.location!.isNotEmpty) ||
                          (event.url != null && event.url!.isNotEmpty)) ...[
                        _buildSectionHeader('LOCATION & ONLINE', fs),
                        _buildGroupedCard(
                          cardColor: isDark
                              ? const Color(0xFF1C1C1E)
                              : Colors.white,
                          isDark: isDark,
                          children: [
                            if (event.location != null &&
                                event.location!.isNotEmpty)
                              _buildDetailRow(
                                icon: Icons.location_on_outlined,
                                title: 'Location',
                                value: event.location!,
                                isDark: isDark,
                                mainTextColor: mainTextColor,
                                fs: fs,
                                trailing: TextButton(
                                  onPressed: () => _launchMaps(event.location!),
                                  child: Text(
                                    'Maps',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14 * fs,
                                    ),
                                  ),
                                ),
                              ),
                            if (event.location != null &&
                                event.location!.isNotEmpty &&
                                event.url != null &&
                                event.url!.isNotEmpty)
                              _buildDivider(isDark),
                            if (event.url != null && event.url!.isNotEmpty)
                              _buildDetailRow(
                                icon: Icons.link_rounded,
                                title: 'Link',
                                value: event.url!,
                                isDark: isDark,
                                mainTextColor: mainTextColor,
                                fs: fs,
                                trailing: TextButton(
                                  onPressed: () => _launchUrl(event.url!),
                                  child: Text(
                                    'Open',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14 * fs,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                      _buildSectionHeader('ADVANCED SETTINGS', fs),
                      _buildGroupedCard(
                        cardColor: isDark
                            ? const Color(0xFF1C1C1E)
                            : Colors.white,
                        isDark: isDark,
                        children: [
                          _buildDetailRow(
                            icon: Icons.circle,
                            title: 'Category',
                            value: event.color.label,
                            isDark: isDark,
                            mainTextColor: mainTextColor,
                            fs: fs,
                            leadingColor:
                                event.customColor ?? event.color.color,
                          ),
                        ],
                      ),
                      if (event.photoPath != null) ...[
                        const SizedBox(height: 24),
                        _buildSectionHeader('ATTACHMENT', fs),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(event.photoPath!),
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stack) => Container(
                              height: 100,
                              color: Colors.grey.withValues(alpha: 0.1),
                              alignment: Alignment.center,
                              child: const Text(
                                'Image not found',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          DateFormat('MMM d, h:mm a').format(event.startTime),
                          style: TextStyle(
                            color: hintColor.withValues(alpha: 0.5),
                            fontSize: 12 * fs,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: TextButton(
                    onPressed: () => _showDeleteDialog(context, event, fs),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      backgroundColor: theme.colorScheme.error.withValues(
                        alpha: 0.1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Delete Event',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16 * fs,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, double fs) => Padding(
    padding: const EdgeInsets.only(left: 16, bottom: 8),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 13 * fs,
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
  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
    required Color mainTextColor,
    required double fs,
    Color? leadingColor,
    Widget? trailing,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: leadingColor ?? (isDark ? Colors.white54 : Colors.black54),
          size: 22,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13 * fs,
                  color: isDark ? Colors.white54 : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(fontSize: 16 * fs, color: mainTextColor),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    ),
  );
  String _formatReminder(Duration d) {
    if (d.inMinutes == 0) return 'At time of event';
    if (d.inMinutes < 60) return '${d.inMinutes} mins before';
    if (d.inHours < 24) return '${d.inHours} hr before';
    return '${d.inDays} day before';
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchMaps(String location) async {
    final query = Uri.encodeComponent(location);
    final url = Platform.isIOS
        ? 'https://maps.apple.com/?q=$query'
        : 'https://www.google.com/maps/search/?api=1&query=$query';
    if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url));
  }

  void _showDeleteDialog(BuildContext context, EventModel event, double fs) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event?'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CalendarBloc>().add(DeleteEvent(event));
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
