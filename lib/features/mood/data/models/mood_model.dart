import 'package:equatable/equatable.dart';

class MoodModel extends Equatable {
  final String emoji;
  final String label;

  const MoodModel({required this.emoji, required this.label});

  @override
  List<Object?> get props => [emoji, label];

  Map<String, dynamic> toJson() => {'emoji': emoji, 'label': label};
  factory MoodModel.fromJson(Map<String, dynamic> json) =>
      MoodModel(emoji: json['emoji'], label: json['label']);

  static const List<MoodModel> availableMoods = [
    MoodModel(emoji: '🤩', label: 'Excited'),
    MoodModel(emoji: '😊', label: 'Happy'),
    MoodModel(emoji: '🥰', label: 'Loved'),
    MoodModel(emoji: '😎', label: 'Cool'),
    MoodModel(emoji: '💪', label: 'Productive'),
    MoodModel(emoji: '🧘', label: 'Calm'),
    MoodModel(emoji: '✨', label: 'Inspired'),
    MoodModel(emoji: '🥳', label: 'Party'),
    MoodModel(emoji: '🤔', label: 'Thinking'),
    MoodModel(emoji: '😐', label: 'Neutral'),
    MoodModel(emoji: '😴', label: 'Tired'),
    MoodModel(emoji: '🥱', label: 'Bored'),
    MoodModel(emoji: '😔', label: 'Sad'),
    MoodModel(emoji: '😭', label: 'Crying'),
    MoodModel(emoji: '🥺', label: 'Lonely'),
    MoodModel(emoji: '🤯', label: 'Stressed'),
    MoodModel(emoji: '😠', label: 'Angry'),
    MoodModel(emoji: '😱', label: 'Scared'),
    MoodModel(emoji: '🤒', label: 'Sick'),
    MoodModel(emoji: '🤕', label: 'Hurt'),
  ];
}
