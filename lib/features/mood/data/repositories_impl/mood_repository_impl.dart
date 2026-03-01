import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_model.dart';
import '../repositories/mood_repository.dart';

class MoodRepositoryImpl implements MoodRepository {
  @override
  Future<Map<String, MoodModel>> loadMoods() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString('moods_cache');
    if (cachedData == null) return {};

    try {
      final Map<String, dynamic> jsonMap = jsonDecode(cachedData);
      return jsonMap.map(
        (key, value) => MapEntry(key, MoodModel.fromJson(value)),
      );
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> saveMood(DateTime date, MoodModel mood) async {
    final prefs = await SharedPreferences.getInstance();
    final moods = await loadMoods();
    final key = "${date.year}-${date.month}-${date.day}";
    moods[key] = mood;
    await prefs.setString(
      'moods_cache',
      jsonEncode(moods.map((k, v) => MapEntry(k, v.toJson()))),
    );
  }
}
