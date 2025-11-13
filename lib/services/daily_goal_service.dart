import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_goal.dart';
import '../models/dtos/daily_goal_dto.dart';
import '../models/mappers/daily_goal_mapper.dart';

class DailyGoalService {
  static const String _key = 'daily_goals';

  static Future<void> salvarGoals(List<DailyGoal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final goalsDto = goals.map((g) => DailyGoalMapper.toDto(g)).toList();
    final goalsJson = goalsDto.map((dto) => dto.toJson()).toList();
    await prefs.setString(_key, jsonEncode(goalsJson));
  }

  static Future<List<DailyGoal>> carregarGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsString = prefs.getString(_key);

    if (goalsString == null) {
      return [];
    }

    try {
      final List<dynamic> goalsJson = jsonDecode(goalsString);
      final goalsDto = goalsJson
          .map((json) => DailyGoalDto.fromJson(json))
          .toList();
      return goalsDto.map((dto) => DailyGoalMapper.toEntity(dto)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> adicionarGoal(DailyGoal goal) async {
    final goals = await carregarGoals();
    goals.add(goal);
    await salvarGoals(goals);
  }

  static Future<void> atualizarGoal(DailyGoal goal) async {
    final goals = await carregarGoals();
    final index = goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      goals[index] = goal;
      await salvarGoals(goals);
    }
  }

  static Future<void> removerGoal(String id) async {
    final goals = await carregarGoals();
    goals.removeWhere((g) => g.id == id);
    await salvarGoals(goals);
  }

  static Future<List<DailyGoal>> obterGoalsPorData(DateTime data) async {
    final goals = await carregarGoals();
    return goals.where((goal) {
      return goal.data.year == data.year &&
          goal.data.month == data.month &&
          goal.data.day == data.day;
    }).toList();
  }

  static Future<List<DailyGoal>> obterGoalsProximos7Dias() async {
    final hoje = DateTime.now();
    final fimSemana = hoje.add(const Duration(days: 7));
    final goals = await carregarGoals();
    return goals.where((goal) {
      return goal.data.isAfter(hoje.subtract(const Duration(days: 1))) &&
          goal.data.isBefore(fimSemana.add(const Duration(days: 1)));
    }).toList();
  }
}

