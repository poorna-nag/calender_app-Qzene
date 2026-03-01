import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateFontSize extends SettingsEvent {
  final double fontSize;
  const UpdateFontSize(this.fontSize);
  @override
  List<Object?> get props => [fontSize];
}

class UpdateHighContrast extends SettingsEvent {
  final bool enabled;
  const UpdateHighContrast(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class UpdateReduceMotion extends SettingsEvent {
  final bool enabled;
  const UpdateReduceMotion(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class UpdateThemeMode extends SettingsEvent {
  final ThemeMode themeMode;
  const UpdateThemeMode(this.themeMode);
  @override
  List<Object?> get props => [themeMode];
}

class UpdateFirstDayOfWeek extends SettingsEvent {
  final int day;
  const UpdateFirstDayOfWeek(this.day);
  @override
  List<Object?> get props => [day];
}

class UpdateNotificationsEnabled extends SettingsEvent {
  final bool enabled;
  const UpdateNotificationsEnabled(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class UpdateNotificationSound extends SettingsEvent {
  final String? sound;
  const UpdateNotificationSound(this.sound);
  @override
  List<Object?> get props => [sound];
}

class UpdateVibrationEnabled extends SettingsEvent {
  final bool enabled;
  const UpdateVibrationEnabled(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class UpdateAlertInSilentMode extends SettingsEvent {
  final bool enabled;
  const UpdateAlertInSilentMode(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class UpdateTrueBlackMode extends SettingsEvent {
  final bool enabled;
  const UpdateTrueBlackMode(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class UpdateShowPublicHolidays extends SettingsEvent {
  final bool enabled;
  const UpdateShowPublicHolidays(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class UpdateShowReligiousHolidays extends SettingsEvent {
  final bool enabled;
  const UpdateShowReligiousHolidays(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class UpdateShowSchoolHolidays extends SettingsEvent {
  final bool enabled;
  const UpdateShowSchoolHolidays(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class UpdateOnboardingCompleted extends SettingsEvent {
  final bool completed;
  const UpdateOnboardingCompleted(this.completed);
  @override
  List<Object?> get props => [completed];
}

class UpdateHolidayCountry extends SettingsEvent {
  final String country;
  const UpdateHolidayCountry(this.country);
  @override
  List<Object?> get props => [country];
}
