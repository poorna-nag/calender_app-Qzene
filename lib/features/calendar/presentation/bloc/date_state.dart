import 'package:equatable/equatable.dart';

class DateState extends Equatable {
  final DateTime selectedDate;
  const DateState(this.selectedDate);
  @override
  List<Object?> get props => [selectedDate];
}
