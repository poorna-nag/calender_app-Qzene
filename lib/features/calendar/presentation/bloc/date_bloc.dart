import 'package:flutter_bloc/flutter_bloc.dart';
import 'date_event.dart';
import 'date_state.dart';

class DateBloc extends Bloc<DateEvent, DateState> {
  DateBloc() : super(DateState(DateTime.now())) {
    on<SetSelectedDate>((event, emit) => emit(DateState(event.date)));
  }
}
