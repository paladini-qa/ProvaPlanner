import '../entities/daily_goal.dart';
import '../repositories/daily_goal_repository.dart';

class UpdateDailyGoal {
  final DailyGoalRepository repository;

  UpdateDailyGoal(this.repository);

  Future<void> call(DailyGoal goal) async {
    return await repository.update(goal);
  }
}

