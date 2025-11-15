import '../entities/daily_goal.dart';

abstract class DailyGoalRepository {
  Future<List<DailyGoal>> getAll();
  Future<List<DailyGoal>> getByDate(DateTime date);
  Future<List<DailyGoal>> getNext7Days();
  Future<void> save(DailyGoal goal);
  Future<void> update(DailyGoal goal);
  Future<void> delete(String id);
  Future<void> saveAll(List<DailyGoal> goals);
}

