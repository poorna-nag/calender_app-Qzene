import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/calendar_repository.dart';

abstract class RecycleBinEvent extends Equatable {
  const RecycleBinEvent();
  @override
  List<Object?> get props => [];
}

class LoadDeletedEvents extends RecycleBinEvent {}

class PermanentlyDeleteEvent extends RecycleBinEvent {
  final String eventId;
  const PermanentlyDeleteEvent(this.eventId);
  @override
  List<Object?> get props => [eventId];
}

class EmptyBin extends RecycleBinEvent {}

abstract class RecycleBinState extends Equatable {
  final List<EventModel> deletedEvents;
  const RecycleBinState(this.deletedEvents);
  @override
  List<Object?> get props => [deletedEvents];
}

class RecycleBinInitial extends RecycleBinState {
  const RecycleBinInitial() : super(const []);
}

class RecycleBinLoaded extends RecycleBinState {
  const RecycleBinLoaded(super.deletedEvents);
}

class RecycleBinBloc extends Bloc<RecycleBinEvent, RecycleBinState> {
  final CalendarRepository repository;

  RecycleBinBloc({required this.repository})
    : super(const RecycleBinInitial()) {
    on<LoadDeletedEvents>((event, emit) async {
      final events = await repository.loadDeletedEvents();
      emit(RecycleBinLoaded(events));
    });

    on<PermanentlyDeleteEvent>((event, emit) async {
      await repository.permanentlyDeleteEvent(event.eventId);
      add(LoadDeletedEvents());
    });

    on<EmptyBin>((event, emit) async {
      await repository.emptyRecycleBin();
      emit(const RecycleBinLoaded([]));
    });
  }
}
