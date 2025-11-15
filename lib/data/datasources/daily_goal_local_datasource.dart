import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/daily_goal_dto.dart';

abstract class DailyGoalLocalDataSource {
  Future<List<DailyGoalDto>> getAll();
  Future<void> saveAll(List<DailyGoalDto> goals);
}

class DailyGoalLocalDataSourceImpl implements DailyGoalLocalDataSource {
  static const String _key = 'daily_goals';

  @override
  Future<List<DailyGoalDto>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsString = prefs.getString(_key);

    if (goalsString == null) {
      return [];
    }

    try {
      final List<dynamic> goalsJson = jsonDecode(goalsString) as List<dynamic>;
      return goalsJson
          .map((json) => DailyGoalDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveAll(List<DailyGoalDto> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = goals.map((dto) => dto.toJson()).toList();
    await prefs.setString(_key, jsonEncode(goalsJson));
  }
}

