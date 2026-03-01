import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';
import '../repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  @override
  Future<SettingsModel> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsModel(
      fontSize: prefs.getDouble('font_size') ?? 1.0,
      highContrastMode: prefs.getBool('high_contrast') ?? false,
      reduceMotion: prefs.getBool('reduce_motion') ?? false,
      themeMode: ThemeMode
          .values[prefs.getInt('theme_mode') ?? ThemeMode.system.index],
      firstDayOfWeek: prefs.getInt('first_day_of_week') ?? 1,
      notificationsEnabled: prefs.getBool('notifications_enabled') ?? true,
      notificationSound: prefs.getString('notification_sound'),
      vibrationEnabled: prefs.getBool('vibration_enabled') ?? true,
      alertInSilentMode: prefs.getBool('alert_silent_mode') ?? false,
      trueBlackMode: prefs.getBool('true_black_mode') ?? false,
      showPublicHolidays: prefs.getBool('show_public_holidays') ?? true,
      showReligiousHolidays: prefs.getBool('show_religious_holidays') ?? false,
      showSchoolHolidays: prefs.getBool('show_school_holidays') ?? false,
      isOnboardingCompleted: prefs.getBool('onboarding_completed') ?? false,
      holidayCountry: prefs.getString('holiday_country') ?? 'IN',
    );
  }

  @override
  Future<void> saveFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size', size);
  }

  @override
  Future<void> saveHighContrast(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('high_contrast', enabled);
  }

  @override
  Future<void> saveReduceMotion(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reduce_motion', enabled);
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }

  @override
  Future<void> saveFirstDayOfWeek(int day) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('first_day_of_week', day);
  }

  @override
  Future<void> saveNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  @override
  Future<void> saveNotificationSound(String? sound) async {
    final prefs = await SharedPreferences.getInstance();
    if (sound == null) {
      await prefs.remove('notification_sound');
    } else {
      await prefs.setString('notification_sound', sound);
    }
  }

  @override
  Future<void> saveVibrationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibration_enabled', enabled);
  }

  @override
  Future<void> saveAlertInSilentMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alert_silent_mode', enabled);
  }

  @override
  Future<void> saveTrueBlackMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('true_black_mode', enabled);
  }

  @override
  Future<void> saveShowPublicHolidays(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_public_holidays', enabled);
  }

  @override
  Future<void> saveShowReligiousHolidays(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_religious_holidays', enabled);
  }

  @override
  Future<void> saveShowSchoolHolidays(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_school_holidays', enabled);
  }

  @override
  Future<void> saveOnboardingCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', completed);
  }

  @override
  Future<void> saveHolidayCountry(String country) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('holiday_country', country);
  }
}
