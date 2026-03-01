import 'package:equatable/equatable.dart';
import '../../data/models/settings_model.dart';

abstract class SettingsState extends Equatable {
  final SettingsModel settings;
  const SettingsState(this.settings);

  @override
  List<Object?> get props => [settings];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial() : super(const SettingsModel());
}

class SettingsLoaded extends SettingsState {
  const SettingsLoaded(super.settings);
}
