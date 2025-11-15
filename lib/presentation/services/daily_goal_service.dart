import '../../domain/entities/daily_goal.dart';
import '../../domain/repositories/daily_goal_repository.dart';
import '../../domain/usecases/get_daily_goals.dart';
import '../../domain/usecases/get_daily_goals_by_date.dart';
import '../../domain/usecases/get_daily_goals_next_7_days.dart';
import '../../domain/usecases/add_daily_goal.dart';
import '../../domain/usecases/update_daily_goal.dart';
import '../../domain/usecases/delete_daily_goal.dart';
import '../../data/repositories/daily_goal_repository_impl.dart';
import '../../data/datasources/daily_goal_local_datasource.dart';
import '../../data/datasources/daily_goal_remote_datasource.dart';
import '../../config/supabase_config.dart';

/// Service wrapper para facilitar o uso dos casos de uso
/// Mantém interface estática para compatibilidade com código existente
class DailyGoalService {
  static DailyGoalRepository? _repository;
  static GetDailyGoals? _getDailyGoals;
  static GetDailyGoalsByDate? _getDailyGoalsByDate;
  static GetDailyGoalsNext7Days? _getDailyGoalsNext7Days;
  static AddDailyGoal? _addDailyGoal;
  static UpdateDailyGoal? _updateDailyGoal;
  static DeleteDailyGoal? _deleteDailyGoal;

  static DailyGoalRepository get _instance {
    _repository ??= DailyGoalRepositoryImpl(
      DailyGoalLocalDataSourceImpl(),
      remoteDataSource: SupabaseConfig.isInitialized
          ? DailyGoalRemoteDataSourceImpl()
          : null,
    );
    return _repository!;
  }

  static void _initialize() {
    if (_getDailyGoals == null) {
      _getDailyGoals = GetDailyGoals(_instance);
      _getDailyGoalsByDate = GetDailyGoalsByDate(_instance);
      _getDailyGoalsNext7Days = GetDailyGoalsNext7Days(_instance);
      _addDailyGoal = AddDailyGoal(_instance);
      _updateDailyGoal = UpdateDailyGoal(_instance);
      _deleteDailyGoal = DeleteDailyGoal(_instance);
    }
  }

  static Future<List<DailyGoal>> carregarGoals() {
    _initialize();
    return _getDailyGoals!();
  }

  static Future<List<DailyGoal>> obterGoalsPorData(DateTime data) {
    _initialize();
    return _getDailyGoalsByDate!(data);
  }

  static Future<List<DailyGoal>> obterGoalsProximos7Dias() {
    _initialize();
    return _getDailyGoalsNext7Days!();
  }

  static Future<void> adicionarGoal(DailyGoal goal) {
    _initialize();
    return _addDailyGoal!(goal);
  }

  static Future<void> atualizarGoal(DailyGoal goal) {
    _initialize();
    return _updateDailyGoal!(goal);
  }

  static Future<void> removerGoal(String id) {
    _initialize();
    return _deleteDailyGoal!(id);
  }
}

