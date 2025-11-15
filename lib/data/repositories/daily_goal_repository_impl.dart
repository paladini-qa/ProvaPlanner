import '../../domain/entities/daily_goal.dart';
import '../../domain/repositories/daily_goal_repository.dart';
import '../datasources/daily_goal_local_datasource.dart';
import '../mappers/daily_goal_mapper.dart';

class DailyGoalRepositoryImpl implements DailyGoalRepository {
  final DailyGoalLocalDataSource dataSource;

  DailyGoalRepositoryImpl(this.dataSource);

  @override
  Future<List<DailyGoal>> getAll() async {
    final dtos = await dataSource.getAll();
    return dtos.map((dto) => DailyGoalMapper.toEntity(dto)).toList();
  }

  @override
  Future<List<DailyGoal>> getByDate(DateTime date) async {
    final allGoals = await getAll();
    return allGoals.where((goal) {
      return goal.data.year == date.year &&
          goal.data.month == date.month &&
          goal.data.day == date.day;
    }).toList();
  }

  @override
  Future<List<DailyGoal>> getNext7Days() async {
    final hoje = DateTime.now();
    final fimSemana = hoje.add(const Duration(days: 7));
    final allGoals = await getAll();
    return allGoals.where((goal) {
      return goal.data.isAfter(hoje.subtract(const Duration(days: 1))) &&
          goal.data.isBefore(fimSemana.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<void> save(DailyGoal goal) async {
    final goals = await getAll();
    goals.add(goal);
    await saveAll(goals);
  }

  @override
  Future<void> update(DailyGoal goal) async {
    final goals = await getAll();
    final index = goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      goals[index] = goal;
      await saveAll(goals);
    }
  }

  @override
  Future<void> delete(String id) async {
    final goals = await getAll();
    goals.removeWhere((g) => g.id == id);
    await saveAll(goals);
  }

  @override
  Future<void> saveAll(List<DailyGoal> goals) async {
    final dtos = goals.map((goal) => DailyGoalMapper.toDto(goal)).toList();
    await dataSource.saveAll(dtos);
  }
}

