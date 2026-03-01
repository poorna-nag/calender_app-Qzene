import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/mood_model.dart';
import '../../data/repositories/mood_repository.dart';

abstract class MoodEvent extends Equatable {
  const MoodEvent();
  @override
  List<Object?> get props => [];
}

class LoadMoods extends MoodEvent {}

class SetMood extends MoodEvent {
  final DateTime date;
  final MoodModel mood;
  const SetMood(this.date, this.mood);
  @override
  List<Object?> get props => [date, mood];
}

abstract class MoodState extends Equatable {
  final Map<String, MoodModel> moods;
  const MoodState(this.moods);
  @override
  List<Object?> get props => [moods];
}

class MoodInitial extends MoodState {
  const MoodInitial() : super(const {});
}

class MoodLoaded extends MoodState {
  const MoodLoaded(super.moods);
}

class MoodBloc extends Bloc<MoodEvent, MoodState> {
  final MoodRepository repository;

  MoodBloc({required this.repository}) : super(const MoodInitial()) {
    on<LoadMoods>((event, emit) async {
      final moods = await repository.loadMoods();
      emit(MoodLoaded(moods));
    });

    on<SetMood>((event, emit) async {
      await repository.saveMood(event.date, event.mood);
      final moods = Map<String, MoodModel>.from(state.moods);
      final key = "${event.date.year}-${event.date.month}-${event.date.day}";
      moods[key] = event.mood;
      emit(MoodLoaded(moods));
    });
  }
}
