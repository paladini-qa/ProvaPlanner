import '../entities/daily_goal.dart';
import '../repositories/daily_goal_repository.dart';

class GetDailyGoalsNext7Days {
  final DailyGoalRepository repository;

  GetDailyGoalsNext7Days(this.repository);

  Future<List<DailyGoal>> call() async {
    return await repository.getNext7Days();
  }
}

