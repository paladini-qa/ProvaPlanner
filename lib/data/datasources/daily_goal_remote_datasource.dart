import '../../config/supabase_config.dart';
import '../../data/models/daily_goal_dto.dart';

abstract class DailyGoalRemoteDataSource {
  Future<List<DailyGoalDto>> getAll();
  Future<DailyGoalDto?> getById(String id);
  Future<void> save(DailyGoalDto dto);
  Future<void> update(DailyGoalDto dto);
  Future<void> delete(String id);
  Future<List<DailyGoalDto>> getByDate(DateTime date);
}

class DailyGoalRemoteDataSourceImpl implements DailyGoalRemoteDataSource {
  static const String _tableName = 'daily_goals';

  @override
  Future<List<DailyGoalDto>> getAll() async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .order('data', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      if (data.isEmpty) {
        return [];
      }

      return data
          .map((json) => DailyGoalDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar metas diárias: $e');
    }
  }

  @override
  Future<DailyGoalDto?> getById(String id) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return DailyGoalDto.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar meta diária por ID: $e');
    }
  }

  @override
  Future<void> save(DailyGoalDto dto) async {
    try {
      await SupabaseConfig.client.from(_tableName).insert(dto.toJson());
    } catch (e) {
      throw Exception('Erro ao salvar meta diária: $e');
    }
  }

  @override
  Future<void> update(DailyGoalDto dto) async {
    try {
      await SupabaseConfig.client
          .from(_tableName)
          .update(dto.toJson())
          .eq('id', dto.id);
    } catch (e) {
      throw Exception('Erro ao atualizar meta diária: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await SupabaseConfig.client.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar meta diária: $e');
    }
  }

  @override
  Future<List<DailyGoalDto>> getByDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .gte('data', startOfDay.toIso8601String())
          .lt('data', endOfDay.toIso8601String())
          .order('data', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      if (data.isEmpty) {
        return [];
      }

      return data
          .map((json) => DailyGoalDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar metas diárias por data: $e');
    }
  }
}

