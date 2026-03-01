import '../models/mood_model.dart';

abstract class MoodRepository {
  Future<Map<String, MoodModel>> loadMoods();
  Future<void> saveMood(DateTime date, MoodModel mood);
}
