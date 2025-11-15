import '../entities/daily_goal.dart';
import '../repositories/daily_goal_repository.dart';

class AddDailyGoal {
  final DailyGoalRepository repository;

  AddDailyGoal(this.repository);

  Future<void> call(DailyGoal goal) async {
    return await repository.save(goal);
  }
}

