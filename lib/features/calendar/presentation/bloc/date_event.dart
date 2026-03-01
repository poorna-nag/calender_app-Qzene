import 'package:equatable/equatable.dart';

abstract class DateEvent extends Equatable {
  const DateEvent();
  @override
  List<Object?> get props => [];
}

class SetSelectedDate extends DateEvent {
  final DateTime date;
  const SetSelectedDate(this.date);
  @override
  List<Object?> get props => [date];
}
