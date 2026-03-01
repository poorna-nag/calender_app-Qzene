import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository repository;

  SettingsBloc({required this.repository}) : super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateFontSize>(_onUpdateFontSize);
    on<UpdateHighContrast>(_onUpdateHighContrast);
    on<UpdateReduceMotion>(_onUpdateReduceMotion);
    on<UpdateThemeMode>(_onUpdateThemeMode);
    on<UpdateFirstDayOfWeek>(_onUpdateFirstDayOfWeek);
    on<UpdateNotificationsEnabled>(_onUpdateNotificationsEnabled);
    on<UpdateNotificationSound>(_onUpdateNotificationSound);
    on<UpdateVibrationEnabled>(_onUpdateVibrationEnabled);
    on<UpdateAlertInSilentMode>(_onUpdateAlertInSilentMode);
    on<UpdateTrueBlackMode>(_onUpdateTrueBlackMode);
    on<UpdateShowPublicHolidays>(_onUpdateShowPublicHolidays);
    on<UpdateShowReligiousHolidays>(_onUpdateShowReligiousHolidays);
    on<UpdateShowSchoolHolidays>(_onUpdateShowSchoolHolidays);
    on<UpdateOnboardingCompleted>(_onUpdateOnboardingCompleted);
    on<UpdateHolidayCountry>(_onUpdateHolidayCountry);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final settings = await repository.loadSettings();
    emit(SettingsLoaded(settings));
  }

  Future<void> _onUpdateFontSize(
    UpdateFontSize event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.saveFontSize(event.fontSize);
    emit(SettingsLoaded(state.settings.copyWith(fontSize: event.fontSize)));
  }

  Future<void> _onUpdateHighContrast(
    UpdateHighContrast event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.saveHighContrast(event.enabled);
    emit(
      SettingsLoaded(state.settings.copyWith(highContrastMode: event.enabled)),
    );
  }

  Future<void> _onUpdateReduceMotion(
    UpdateReduceMotion event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.saveReduceMotion(event.enabled);
    emit(SettingsLoaded(state.settings.copyWith(reduceMotion: event.enabled)));
  }

  Future<void> _onUpdateThemeMode(
    UpdateThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.saveThemeMode(event.themeMode);
    emit(SettingsLoaded(state.settings.copyWith(themeMode: event.themeMode)));
  }

  Future<void> _onUpdateFirstDayOfWeek(
    UpdateFirstDayOfWeek event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.saveFirstDayOfWeek(event.day);
    emit(SettingsLoaded(state.settings.copyWith(firstDayOfWeek: event.day)));
  }

  Future<void> _onUpdateNotificationsEnabled(
    UpdateNotificationsEnabled event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.saveNotificationsEnabled(event.enabled);
    emit(
      SettingsLoaded(
        state.settings.copyWith(notificationsEnabled: event.enabled),
      ),
    );
  }

  Future<void> _onUpdateNotificationSound(
    UpdateNotificationSound event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.saveNotificationSound(event.sound);
    emit(
      SettingsLoaded(state.settings.copyWith(notificationSound: event.sound)),
    );
  }

  Future<void> _onUpdateVibrationEnabled(
    UpdateVibrationEnabled event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.saveVibrationEnabled(event.enabled);
    emit(
      SettingsLoaded(state.settings.copyWith(vibrationEnabled: event.enabled)),
    );
  }

  Future<void> _onUpdateAlertInSilentMode(
    UpdateAlertInSilentMode event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.saveAlertInSilentMode(event.enabled);
    emit(
      SettingsLoaded(state.settings.copyWith(alertInSilentMode: event.enabled)),
    );
  }

  Future<void> _onUpdateTrueBlackMode(
    UpdateTrueBlackMode event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.saveTrueBlackMode(event.enabled);
    emit(SettingsLoaded(state.settings.copyWith(trueBlackMode: event.enabled)));
  }

  Future<void> _onUpdateShowPublicHolidays(
    UpdateShowPublicHolidays event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.saveShowPublicHolidays(event.enabled);
    emit(
      SettingsLoaded(
        state.settings.copyWith(showPublicHolidays: event.enabled),
      ),
    );
  }

  Future<void> _onUpdateShowReligiousHolidays(
    UpdateShowReligiousHolidays event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.saveShowReligiousHolidays(event.enabled);
    emit(
      SettingsLoaded(
        state.settings.copyWith(showReligiousHolidays: event.enabled),
      ),
    );
  }

  Future<void> _onUpdateShowSchoolHolidays(
    UpdateShowSchoolHolidays event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.saveShowSchoolHolidays(event.enabled);
    emit(
      SettingsLoaded(
        state.settings.copyWith(showSchoolHolidays: event.enabled),
      ),
    );
  }

  Future<void> _onUpdateOnboardingCompleted(
    UpdateOnboardingCompleted event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.saveOnboardingCompleted(event.completed);
    emit(
      SettingsLoaded(
        state.settings.copyWith(isOnboardingCompleted: event.completed),
      ),
    );
  }

  Future<void> _onUpdateHolidayCountry(
    UpdateHolidayCountry event,
    Emitter<SettingsState> emit,
  ) async {
    await repository.saveHolidayCountry(event.country);
    emit(
      SettingsLoaded(state.settings.copyWith(holidayCountry: event.country)),
    );
  }
}
