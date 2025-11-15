import '../repositories/daily_goal_repository.dart';

class DeleteDailyGoal {
  final DailyGoalRepository repository;

  DeleteDailyGoal(this.repository);

  Future<void> call(String id) async {
    return await repository.delete(id);
  }
}

