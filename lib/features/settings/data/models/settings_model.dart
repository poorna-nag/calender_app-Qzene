import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class SettingsModel extends Equatable {
  final double fontSize;
  final bool highContrastMode;
  final bool reduceMotion;
  final ThemeMode themeMode;
  final int firstDayOfWeek;
  final bool notificationsEnabled;
  final String? notificationSound;
  final bool vibrationEnabled;
  final bool alertInSilentMode;
  final bool trueBlackMode;
  final bool showPublicHolidays;
  final bool showReligiousHolidays;
  final bool showSchoolHolidays;
  final bool isOnboardingCompleted;
  final String holidayCountry;

  double get fontSizeFactor => fontSize;

  const SettingsModel({
    this.fontSize = 1.0,
    this.highContrastMode = false,
    this.reduceMotion = false,
    this.themeMode = ThemeMode.system,
    this.firstDayOfWeek = 1,
    this.notificationsEnabled = true,
    this.notificationSound,
    this.vibrationEnabled = true,
    this.alertInSilentMode = false,
    this.trueBlackMode = false,
    this.showPublicHolidays = true,
    this.showReligiousHolidays = false,
    this.showSchoolHolidays = false,
    this.isOnboardingCompleted = false,
    this.holidayCountry = 'IN',
  });

  SettingsModel copyWith({
    double? fontSize,
    bool? highContrastMode,
    bool? reduceMotion,
    ThemeMode? themeMode,
    int? firstDayOfWeek,
    bool? notificationsEnabled,
    String? notificationSound,
    bool? vibrationEnabled,
    bool? alertInSilentMode,
    bool? trueBlackMode,
    bool? showPublicHolidays,
    bool? showReligiousHolidays,
    bool? showSchoolHolidays,
    bool? isOnboardingCompleted,
    String? holidayCountry,
  }) {
    return SettingsModel(
      fontSize: fontSize ?? this.fontSize,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      themeMode: themeMode ?? this.themeMode,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationSound: notificationSound ?? this.notificationSound,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      alertInSilentMode: alertInSilentMode ?? this.alertInSilentMode,
      trueBlackMode: trueBlackMode ?? this.trueBlackMode,
      showPublicHolidays: showPublicHolidays ?? this.showPublicHolidays,
      showReligiousHolidays:
          showReligiousHolidays ?? this.showReligiousHolidays,
      showSchoolHolidays: showSchoolHolidays ?? this.showSchoolHolidays,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      holidayCountry: holidayCountry ?? this.holidayCountry,
    );
  }

  @override
  List<Object?> get props => [
    fontSize,
    highContrastMode,
    reduceMotion,
    themeMode,
    firstDayOfWeek,
    notificationsEnabled,
    notificationSound,
    vibrationEnabled,
    alertInSilentMode,
    trueBlackMode,
    showPublicHolidays,
    showReligiousHolidays,
    showSchoolHolidays,
    isOnboardingCompleted,
    holidayCountry,
  ];
}
