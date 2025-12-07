import '../../config/supabase_config.dart';
import '../../services/auth_service.dart';
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
  static const String _tableName = 'goals';

  @override
  Future<List<DailyGoalDto>> getAll() async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .isFilter('deleted_at', null)
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
      final userId = AuthService.currentUserId;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .eq('user_id', userId)
          .isFilter('deleted_at', null)
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
      final userId = AuthService.currentUserId;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final json = dto.toJson();
      json['user_id'] = userId; // Garantir que user_id está presente
      await SupabaseConfig.client.from(_tableName).insert(json);
    } catch (e) {
      throw Exception('Erro ao salvar meta diária: $e');
    }
  }

  @override
  Future<void> update(DailyGoalDto dto) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final json = dto.toJson();
      json['user_id'] = userId; // Garantir que user_id está presente
      await SupabaseConfig.client
          .from(_tableName)
          .update(json)
          .eq('id', dto.id)
          .eq('user_id', userId); // Garantir que só atualiza se for do usuário
    } catch (e) {
      throw Exception('Erro ao atualizar meta diária: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      // Verifica se a meta existe no remoto (incluindo soft-deleted)
      // Usa consulta direta sem filtro de deleted_at para verificar existência real
      final existingResponse = await SupabaseConfig.client
          .from(_tableName)
          .select('id, user_id')
          .eq('id', id)
          .maybeSingle();

      // Se não existe no remoto, não há nada para deletar
      if (existingResponse == null) {
        return; // Meta só existia localmente, nada a fazer no remoto
      }

      // Verifica se pertence ao usuário atual
      if (existingResponse['user_id'] != userId) {
        throw Exception('Meta não pertence ao usuário atual');
      }

      // Soft delete: atualizar deleted_at em vez de deletar
      await SupabaseConfig.client
          .from(_tableName)
          .update({
            'deleted_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', userId); // Garantir que só deleta se for do usuário
    } catch (e) {
      throw Exception('Erro ao deletar meta diária: $e');
    }
  }

  @override
  Future<List<DailyGoalDto>> getByDate(DateTime date) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .isFilter('deleted_at', null)
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

