import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../../../../features/calendar/presentation/bloc/calendar_bloc.dart';
import '../../../../features/calendar/presentation/bloc/calendar_event.dart';
import '../../../../features/calendar/data/models/event_model.dart';
import '../../../../services/birthday_service.dart';
import '../../../calendar/presentation/screens/recycle_bin_screen.dart';
import 'permissions_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final settings = state.settings;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final sectionHeaderColor = theme.primaryColor;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: theme.appBarTheme.backgroundColor,
            foregroundColor: theme.appBarTheme.titleTextStyle?.color,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            children: [
              _buildSectionHeader(
                context,
                'Display & Accessibility',
                sectionHeaderColor,
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: theme.cardColor,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.text_fields,
                        color: isDark ? Colors.white : Colors.black54,
                      ),
                      title: const Text('Font Size'),
                      subtitle: Text(_getFontSizeLabel(settings.fontSize)),
                      onTap: () =>
                          _showFontSizeDialog(context, settings.fontSize),
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: theme.dividerColor.withValues(alpha: 0.1),
                    ),
                    SwitchListTile(
                      secondary: Icon(
                        Icons.contrast,
                        color: isDark ? Colors.white : Colors.black54,
                      ),
                      title: const Text('High Contrast Mode'),
                      subtitle: const Text('Increase color contrast'),
                      value: settings.highContrastMode,
                      activeThumbColor: theme.colorScheme.primary,
                      onChanged: (value) => context.read<SettingsBloc>().add(
                        UpdateHighContrast(value),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: theme.dividerColor.withValues(alpha: 0.1),
                    ),
                    SwitchListTile(
                      secondary: Icon(
                        Icons.dark_mode,
                        color: isDark ? Colors.white : Colors.black54,
                      ),
                      title: const Text('True Black Mode'),
                      subtitle: const Text(
                        'Pure black background in dark mode',
                      ),
                      value: settings.trueBlackMode,
                      activeThumbColor: theme.colorScheme.primary,
                      onChanged: (value) => context.read<SettingsBloc>().add(
                        UpdateTrueBlackMode(value),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: theme.dividerColor.withValues(alpha: 0.1),
                    ),
                    SwitchListTile(
                      secondary: Icon(
                        Icons.motion_photos_off,
                        color: isDark ? Colors.white : Colors.black54,
                      ),
                      title: const Text('Reduce Motion'),
                      subtitle: const Text('Minimize animations'),
                      value: settings.reduceMotion,
                      activeThumbColor: theme.colorScheme.primary,
                      onChanged: (value) => context.read<SettingsBloc>().add(
                        UpdateReduceMotion(value),
                      ),
                    ),
                  ],
                ),
              ),
              _buildSectionHeader(context, 'Notifications', sectionHeaderColor),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: theme.cardColor,
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: Icon(
                        Icons.notifications_active,
                        color: isDark ? Colors.white : Colors.black54,
                      ),
                      title: const Text('Enable Notifications'),
                      value: settings.notificationsEnabled,
                      activeThumbColor: theme.colorScheme.primary,
                      onChanged: (value) => context.read<SettingsBloc>().add(
                        UpdateNotificationsEnabled(value),
                      ),
                    ),
                    if (settings.notificationsEnabled) ...[
                      Divider(
                        height: 1,
                        indent: 56,
                        color: theme.dividerColor.withValues(alpha: 0.1),
                      ),
                      SwitchListTile(
                        secondary: Icon(
                          Icons.vibration,
                          color: isDark ? Colors.white : Colors.black54,
                        ),
                        title: const Text('Vibration'),
                        value: settings.vibrationEnabled,
                        activeThumbColor: theme.colorScheme.primary,
                        onChanged: (value) => context.read<SettingsBloc>().add(
                          UpdateVibrationEnabled(value),
                        ),
                      ),
                      Divider(
                        height: 1,
                        indent: 56,
                        color: theme.dividerColor.withValues(alpha: 0.1),
                      ),
                      SwitchListTile(
                        secondary: Icon(
                          Icons.do_not_disturb_on,
                          color: isDark ? Colors.white : Colors.black54,
                        ),
                        title: const Text('Alert in Silent Mode'),
                        value: settings.alertInSilentMode,
                        activeThumbColor: theme.colorScheme.primary,
                        onChanged: (value) => context.read<SettingsBloc>().add(
                          UpdateAlertInSilentMode(value),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _buildSectionHeader(
                context,
                'Calendar Settings',
                sectionHeaderColor,
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: theme.cardColor,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.palette_outlined,
                        color: isDark ? Colors.white : Colors.black54,
                      ),
                      title: const Text('Theme'),
                      subtitle: Text(_getThemeLabel(settings.themeMode)),
                      onTap: () =>
                          _showThemeDialog(context, settings.themeMode),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.calendar_today,
                        color: isDark ? Colors.white : Colors.black54,
                      ),
                      title: const Text('Start Week On'),
                      subtitle: Text(
                        _getStartDayLabel(settings.firstDayOfWeek),
                      ),
                      onTap: () =>
                          _showStartDayDialog(context, settings.firstDayOfWeek),
                    ),
                  ],
                ),
              ),
              _buildSectionHeader(
                context,
                'Holidays & Birthdays',
                sectionHeaderColor,
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: theme.cardColor,
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: Icon(
                        Icons.event_available,
                        color: isDark ? Colors.white : Colors.black54,
                      ),
                      title: const Text('Public Holidays'),
                      value: settings.showPublicHolidays,
                      activeThumbColor: theme.colorScheme.primary,
                      onChanged: (value) => context.read<SettingsBloc>().add(
                        UpdateShowPublicHolidays(value),
                      ),
                    ),
                    if (settings.showPublicHolidays) ...[
                      Divider(
                        height: 1,
                        indent: 56,
                        color: theme.dividerColor.withValues(alpha: 0.1),
                      ),
                      ListTile(
                        leading: const SizedBox(width: 24),
                        title: const Text('Holiday Country'),
                        subtitle: Text(
                          _getCountryLabel(settings.holidayCountry),
                        ),
                        onTap: () => _showCountryDialog(
                          context,
                          settings.holidayCountry,
                        ),
                      ),
                    ],
                    Divider(
                      height: 1,
                      indent: 56,
                      color: theme.dividerColor.withValues(alpha: 0.1),
                    ),
                    SwitchListTile(
                      secondary: Icon(
                        Icons.temple_hindu,
                        color: isDark ? Colors.white : Colors.black54,
                      ),
                      title: const Text('Religious Holidays'),
                      value: settings.showReligiousHolidays,
                      activeThumbColor: theme.colorScheme.primary,
                      onChanged: (value) => context.read<SettingsBloc>().add(
                        UpdateShowReligiousHolidays(value),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: theme.dividerColor.withValues(alpha: 0.1),
                    ),
                    SwitchListTile(
                      secondary: Icon(
                        Icons.school,
                        color: isDark ? Colors.white : Colors.black54,
                      ),
                      title: const Text('School Holidays'),
                      value: settings.showSchoolHolidays,
                      activeThumbColor: theme.colorScheme.primary,
                      onChanged: (value) => context.read<SettingsBloc>().add(
                        UpdateShowSchoolHolidays(value),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: theme.dividerColor.withValues(alpha: 0.1),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.cake,
                        color: isDark ? Colors.white : Colors.black54,
                      ),
                      title: const Text('Sync Birthdays'),
                      subtitle: const Text('Fetch birthdays from contacts'),
                      onTap: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Syncing birthdays...')),
                        );
                        final birthdayService = BirthdayService();
                        final List<EventModel> birthdays =
                            (await birthdayService.fetchBirthdays())
                                .map(
                                  (e) => EventModel(
                                    id: e.id,
                                    title: e.title,
                                    startTime: e.startTime,
                                    endTime: e.endTime,
                                    isAllDay: e.isAllDay,
                                    color: EventColor.values[e.color.index],
                                    notes: e.notes,
                                    recurrence: RecurrenceRule(
                                      type: RecurrenceType
                                          .values[e.recurrence.type.index],
                                    ),
                                  ),
                                )
                                .toList();

                        if (birthdays.isNotEmpty) {
                          context.read<CalendarBloc>().add(
                            SyncBirthdays(birthdays),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Synced ${birthdays.length} birthdays',
                                ),
                              ),
                            );
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No birthdays found or permission denied',
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              _buildSectionHeader(
                context,
                'Data Management',
                sectionHeaderColor,
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: theme.cardColor,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.delete_sweep_outlined,
                        color: isDark ? Colors.white : Colors.black54,
                      ),
                      title: const Text('Recycle Bin'),
                      subtitle: const Text('Restore deleted events'),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecycleBinScreen(),
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: theme.dividerColor.withValues(alpha: 0.1),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.help_outline,
                        color: isDark ? Colors.white : Colors.black54,
                      ),
                      title: const Text('Troubleshoot Sync'),
                      subtitle: const Text('Missing Google Events?'),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Sync Help'),
                            content: const Text(
                              'To sync Google Calendar, you must sign in via your device settings:\n\n'
                              '1. Open your device Settings.\n'
                              '2. Go to "Passwords & Accounts" or "Accounts".\n'
                              '3. Select "Add Account" if you are not signed in.\n'
                              '4. Select your Google account.\n'
                              '5. Ensure "Calendar" sync is switched ON.\n'
                              '6. Come back here and tap "Force Device Sync".',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Got it'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Divider(
                      height: 1,
                      indent: 56,
                      color: theme.dividerColor.withValues(alpha: 0.1),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.sync,
                        color: isDark ? Colors.white : Colors.black54,
                      ),
                      title: const Text('Force Device Sync'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Syncing...'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        context.read<CalendarBloc>().add(FetchDeviceEvents());
                      },
                    ),
                  ],
                ),
              ),
              _buildSectionHeader(
                context,
                'Privacy & Security',
                sectionHeaderColor,
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: theme.cardColor,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.security_outlined,
                        color: isDark ? Colors.white : Colors.black54,
                      ),
                      title: const Text('App Permissions'),
                      subtitle: const Text(
                        'Manage calendar, location, and other access',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PermissionsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(color: theme.disabledColor, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.9)
              : color,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  String _getFontSizeLabel(double size) {
    if (size <= 0.85) return 'Small';
    if (size <= 1.05) return 'Normal';
    if (size <= 1.25) return 'Large';
    return 'Extra Large';
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  String _getStartDayLabel(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Monday';
    }
  }

  void _showFontSizeDialog(BuildContext context, double currentSize) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Font Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _fontSizeOption(ctx, 'Small', 0.8, currentSize, theme),
            _fontSizeOption(ctx, 'Normal', 1.0, currentSize, theme),
            _fontSizeOption(ctx, 'Large', 1.2, currentSize, theme),
            _fontSizeOption(ctx, 'Extra Large', 1.4, currentSize, theme),
          ],
        ),
      ),
    );
  }

  Widget _fontSizeOption(
    BuildContext context,
    String label,
    double value,
    double current,
    ThemeData theme,
  ) {
    return RadioListTile<double>(
      title: Text(label),
      value: value,
      groupValue: current,
      activeColor: theme.colorScheme.primary,
      onChanged: (val) {
        if (val != null) {
          context.read<SettingsBloc>().add(UpdateFontSize(val));
          Navigator.pop(context);
        }
      },
    );
  }

  void _showThemeDialog(BuildContext context, ThemeMode currentMode) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _themeOption(ctx, 'Light', ThemeMode.light, currentMode, theme),
            _themeOption(ctx, 'Dark', ThemeMode.dark, currentMode, theme),
            _themeOption(
              ctx,
              'System Default',
              ThemeMode.system,
              currentMode,
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeOption(
    BuildContext context,
    String label,
    ThemeMode value,
    ThemeMode current,
    ThemeData theme,
  ) {
    return RadioListTile<ThemeMode>(
      title: Text(label),
      value: value,
      groupValue: current,
      activeColor: theme.colorScheme.primary,
      onChanged: (val) {
        if (val != null) {
          context.read<SettingsBloc>().add(UpdateThemeMode(val));
          Navigator.pop(context);
        }
      },
    );
  }

  String _getCountryLabel(String code) {
    switch (code) {
      case 'IN':
        return 'India';
      case 'US':
        return 'United States';
      case 'GB':
        return 'United Kingdom';
      default:
        return code;
    }
  }

  void _showCountryDialog(BuildContext context, String currentCode) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Holiday Country'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _countryOption(ctx, 'India', 'IN', currentCode, theme),
            _countryOption(ctx, 'United States', 'US', currentCode, theme),
            _countryOption(ctx, 'United Kingdom', 'GB', currentCode, theme),
          ],
        ),
      ),
    );
  }

  Widget _countryOption(
    BuildContext context,
    String label,
    String value,
    String current,
    ThemeData theme,
  ) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: current,
      activeColor: theme.colorScheme.primary,
      onChanged: (val) {
        if (val != null) {
          context.read<SettingsBloc>().add(UpdateHolidayCountry(val));
          Navigator.pop(context);
        }
      },
    );
  }

  void _showStartDayDialog(BuildContext context, int currentDay) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Start Week On'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dayOption(ctx, 'Monday', 1, currentDay, theme),
              _dayOption(ctx, 'Tuesday', 2, currentDay, theme),
              _dayOption(ctx, 'Wednesday', 3, currentDay, theme),
              _dayOption(ctx, 'Thursday', 4, currentDay, theme),
              _dayOption(ctx, 'Friday', 5, currentDay, theme),
              _dayOption(ctx, 'Saturday', 6, currentDay, theme),
              _dayOption(ctx, 'Sunday', 7, currentDay, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dayOption(
    BuildContext context,
    String label,
    int value,
    int current,
    ThemeData theme,
  ) {
    return RadioListTile<int>(
      title: Text(label),
      value: value,
      groupValue: current,
      activeColor: theme.colorScheme.primary,
      onChanged: (val) {
        if (val != null) {
          context.read<SettingsBloc>().add(UpdateFirstDayOfWeek(val));
          Navigator.pop(context);
        }
      },
    );
  }
}
