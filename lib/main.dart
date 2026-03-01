import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'theme/app_theme.dart';
import 'features/settings/data/repositories/settings_repository.dart';
import 'features/settings/data/repositories_impl/settings_repository_impl.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/settings/presentation/bloc/settings_state.dart';

import 'features/calendar/data/repositories/calendar_repository.dart';
import 'features/calendar/data/repositories_impl/calendar_repository_impl.dart';
import 'features/calendar/presentation/bloc/calendar_bloc.dart';
import 'features/calendar/presentation/bloc/calendar_event.dart';
import 'features/calendar/presentation/bloc/date_bloc.dart';
import 'features/calendar/presentation/bloc/recycle_bin_bloc.dart';

import 'features/mood/data/repositories/mood_repository.dart';
import 'features/mood/data/repositories_impl/mood_repository_impl.dart';
import 'features/mood/presentation/bloc/mood_bloc.dart';

import 'features/settings/presentation/screens/onboarding_screen.dart'; // To be moved
import 'features/calendar/presentation/screens/main_screen.dart'; // To be moved

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await MobileAds.instance.initialize();

  // Repositories
  final settingsRepository = SettingsRepositoryImpl();
  final calendarRepository = CalendarRepositoryImpl();
  final moodRepository = MoodRepositoryImpl();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SettingsRepository>(
          create: (_) => settingsRepository,
        ),
        RepositoryProvider<CalendarRepository>(
          create: (_) => calendarRepository,
        ),
        RepositoryProvider<MoodRepository>(create: (_) => moodRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsBloc>(
            create: (context) =>
                SettingsBloc(repository: context.read<SettingsRepository>())
                  ..add(LoadSettings()),
          ),
          BlocProvider<CalendarBloc>(
            create: (context) =>
                CalendarBloc(repository: context.read<CalendarRepository>())
                  ..add(LoadCalendarEvents()),
          ),
          BlocProvider<DateBloc>(create: (context) => DateBloc()),
          BlocProvider<MoodBloc>(
            create: (context) =>
                MoodBloc(repository: context.read<MoodRepository>())
                  ..add(LoadMoods()),
          ),
          BlocProvider<RecycleBinBloc>(
            create: (context) =>
                RecycleBinBloc(repository: context.read<CalendarRepository>())
                  ..add(LoadDeletedEvents()),
          ),
        ],
        child: const CalendarApp(),
      ),
    ),
  );
}

class CalendarApp extends StatelessWidget {
  const CalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final settings = state.settings;
        return MaterialApp(
          title: 'Calendar 2026',
          debugShowCheckedModeBanner: false,
          theme: settings.highContrastMode
              ? AppTheme.highContrastLightTheme(settings.fontSize)
              : AppTheme.lightTheme(settings.fontSize),
          darkTheme: settings.highContrastMode
              ? AppTheme.highContrastDarkTheme(
                  settings.fontSize,
                  settings.trueBlackMode,
                )
              : AppTheme.darkTheme(settings.fontSize, settings.trueBlackMode),
          themeMode: settings.themeMode,
          home: settings.isOnboardingCompleted
              ? const MainScreen()
              : const OnboardingScreen(),
        );
      },
    );
  }
}
