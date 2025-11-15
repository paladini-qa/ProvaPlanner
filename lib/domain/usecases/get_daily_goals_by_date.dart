import '../entities/daily_goal.dart';
import '../repositories/daily_goal_repository.dart';

class GetDailyGoalsByDate {
  final DailyGoalRepository repository;

  GetDailyGoalsByDate(this.repository);

  Future<List<DailyGoal>> call(DateTime date) async {
    return await repository.getByDate(date);
  }
}

