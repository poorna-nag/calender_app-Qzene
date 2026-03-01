import 'package:flutter/material.dart';
import '../models/settings_model.dart';

abstract class SettingsRepository {
  Future<SettingsModel> loadSettings();
  Future<void> saveFontSize(double size);
  Future<void> saveHighContrast(bool enabled);
  Future<void> saveReduceMotion(bool enabled);
  Future<void> saveThemeMode(ThemeMode mode);
  Future<void> saveFirstDayOfWeek(int day);
  Future<void> saveNotificationsEnabled(bool enabled);
  Future<void> saveNotificationSound(String? sound);
  Future<void> saveVibrationEnabled(bool enabled);
  Future<void> saveAlertInSilentMode(bool enabled);
  Future<void> saveTrueBlackMode(bool enabled);
  Future<void> saveShowPublicHolidays(bool enabled);
  Future<void> saveShowReligiousHolidays(bool enabled);
  Future<void> saveShowSchoolHolidays(bool enabled);
  Future<void> saveOnboardingCompleted(bool completed);
  Future<void> saveHolidayCountry(String country);
}
