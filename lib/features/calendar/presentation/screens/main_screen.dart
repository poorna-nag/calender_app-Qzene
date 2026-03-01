import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'month_view.dart';
import 'week_view.dart';
import 'day_view.dart';
import 'agenda_view.dart';
import '../../../../features/settings/presentation/screens/settings_screen.dart';
import 'recycle_bin_screen.dart';
import 'year_view.dart';
import 'search_screen.dart';
import '../bloc/date_bloc.dart';
import '../bloc/date_event.dart';
import '../bloc/date_state.dart';
import '../bloc/calendar_bloc.dart';
import '../bloc/calendar_event.dart';
import '../../../../widgets/responsive_scaffold.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // Default to Month View
  int _currentYearViewYear = DateTime.now().year;
  final GlobalKey<YearViewState> _yearViewKey = GlobalKey<YearViewState>();

  final List<String> _titles = ['Year', 'Month', 'Week', 'Day', 'Agenda'];

  Future<void> _onDestinationSelected(int index) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showExitBottomSheet() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
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
              const SizedBox(height: 20),
              Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.ads_click,
                        color: theme.primaryColor.withValues(alpha: 0.5),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ADVERTISEMENT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Icon(
                Icons.logout_rounded,
                size: 48,
                color: const Color(0xFFDC2626).withValues(alpha: 0.8),
              ),
              const SizedBox(height: 16),
              Text(
                'Exit ClearDay?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Are you sure you want to close the app?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: theme.dividerColor),
                          ),
                        ),
                        child: Text(
                          'Stay',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => exit(0),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Exit App',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DateBloc, DateState>(
      builder: (context, dateState) {
        final selectedDate = dateState.selectedDate;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        final List<Widget> screens = [
          YearView(
            key: _yearViewKey,
            onMonthSelected: (year, month) {
              context.read<DateBloc>().add(
                SetSelectedDate(DateTime(year, month)),
              );
              setState(() => _currentIndex = 1);
            },
            onYearChanged: (year) =>
                setState(() => _currentYearViewYear = year),
          ),
          const MonthView(),
          const WeekView(), // To be migrated
          const DayView(), // To be migrated
          const AgendaView(), // To be migrated
        ];

        String titleText = _titles[_currentIndex];
        Widget? customTitle;

        if (_currentIndex == 0) {
          customTitle = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: theme.textTheme.titleLarge?.color,
                ),
                onPressed: () => _yearViewKey.currentState?.previousYear(),
              ),
              Flexible(
                child: InkWell(
                  onTap: () => _yearViewKey.currentState?.selectYear(),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: Text(
                        '$_currentYearViewYear',
                        key: ValueKey(_currentYearViewYear),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: theme.textTheme.titleLarge?.color,
                ),
                onPressed: () => _yearViewKey.currentState?.nextYear(),
              ),
            ],
          );
        } else if (_currentIndex == 1) {
          customTitle = MediaQuery.withNoTextScaling(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 20,
                  letterSpacing: 1.5,
                  color: theme.textTheme.titleLarge?.color,
                  fontFamily: theme.textTheme.titleLarge?.fontFamily,
                ),
                children: [
                  TextSpan(
                    text: DateFormat('MMM').format(selectedDate).toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: theme.primaryColor,
                    ),
                  ),
                  TextSpan(
                    text: ' ${selectedDate.year}',
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          );
          titleText = '';
        } else if (_currentIndex == 2 || _currentIndex == 3) {
          titleText = '';
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _showExitBottomSheet();
          },
          child: ResponsiveScaffold(
            title: titleText,
            titleWidget: customTitle != null
                ? GestureDetector(
                    onTap: () {
                      if (_currentIndex == 1) {
                        // _showMonthYearPicker(context, selectedDate);
                      }
                    },
                    child: customTitle,
                  )
                : null,
            actions: [
              IconButton(
                tooltip: 'Go to Today',
                icon: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.onSurface,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${DateTime.now().day}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                onPressed: () {
                  context.read<DateBloc>().add(SetSelectedDate(DateTime.now()));
                  if (_currentIndex == 0) setState(() => _currentIndex = 1);
                },
              ),
              IconButton(
                tooltip: 'Search events',
                icon: Icon(Icons.search, color: theme.colorScheme.onSurface),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                ),
              ),
              const SizedBox(width: 8),
            ],
            drawer: _buildDrawer(context, isDark),
            bottomNavigationBar: NavigationBarTheme(
              data: NavigationBarThemeData(
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected))
                    return TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.5,
                    );
                  return TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white54 : Colors.grey[500],
                  );
                }),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected))
                    return IconThemeData(
                      size: 28,
                      color: theme.colorScheme.primary,
                    );
                  return IconThemeData(
                    size: 24,
                    color: isDark ? Colors.white54 : Colors.grey[500],
                  );
                }),
                indicatorColor: theme.colorScheme.primary.withValues(
                  alpha: isDark ? 0.25 : 0.15,
                ),
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: NavigationBar(
                height: 65,
                elevation: 0,
                selectedIndex: _currentIndex,
                onDestinationSelected: _onDestinationSelected,
                backgroundColor: theme.scaffoldBackgroundColor,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.calendar_view_day_outlined),
                    selectedIcon: Icon(Icons.calendar_view_day),
                    label: 'Year',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.calendar_month_outlined),
                    selectedIcon: Icon(Icons.calendar_month),
                    label: 'Month',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.calendar_view_week_outlined),
                    selectedIcon: Icon(Icons.calendar_view_week),
                    label: 'Week',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.calendar_view_day_rounded),
                    selectedIcon: Icon(Icons.calendar_view_day),
                    label: 'Day',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.view_agenda_outlined),
                    selectedIcon: Icon(Icons.view_agenda),
                    label: 'Schedule',
                  ),
                ],
              ),
            ),
            body: IndexedStack(index: _currentIndex, children: screens),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40, right: 16),
              child: Row(
                children: [
                  const Spacer(),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, size: 28),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(indent: 16, endIndent: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildDrawerItem(
                    icon: Icons.calendar_view_month_outlined,
                    label: 'Year',
                    index: 0,
                  ),
                  _buildDrawerItem(
                    icon: Icons.calendar_month_outlined,
                    label: 'Month',
                    index: 1,
                  ),
                  _buildDrawerItem(
                    icon: Icons.calendar_view_week_outlined,
                    label: 'Week',
                    index: 2,
                  ),
                  _buildDrawerItem(
                    icon: Icons.calendar_view_day_outlined,
                    label: 'Day',
                    index: 3,
                  ),
                  _buildDrawerItem(
                    icon: Icons.view_agenda_outlined,
                    label: 'Schedule',
                    index: 4,
                  ),
                  const Divider(indent: 8, endIndent: 8, height: 32),
                  _buildDrawerItem(
                    icon: Icons.delete_outline_outlined,
                    label: 'Trash',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecycleBinScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.sync,
                    label: 'Sync now',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Syncing...')),
                      );
                      context.read<CalendarBloc>().add(FetchDeviceEvents());
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    int? index,
    VoidCallback? onTap,
  }) {
    final isSelected = index != null && _currentIndex == index;
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap:
            onTap ??
            (index != null
                ? () {
                    Navigator.pop(context);
                    _onDestinationSelected(index);
                  }
                : null),
        leading: Icon(
          icon,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 15,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dense: true,
      ),
    );
  }
}
