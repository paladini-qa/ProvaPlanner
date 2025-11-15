import '../entities/daily_goal.dart';
import '../repositories/daily_goal_repository.dart';

class GetDailyGoals {
  final DailyGoalRepository repository;

  GetDailyGoals(this.repository);

  Future<List<DailyGoal>> call() async {
    return await repository.getAll();
  }
}

