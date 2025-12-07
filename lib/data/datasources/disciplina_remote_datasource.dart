import '../../config/supabase_config.dart';
import '../../services/auth_service.dart';
import '../models/disciplina_dto.dart';

abstract class DisciplinaRemoteDataSource {
  Future<List<DisciplinaDto>> getAll();
  Future<DisciplinaDto?> getById(String id);
  Future<void> save(DisciplinaDto dto);
  Future<void> update(DisciplinaDto dto);
  Future<void> delete(String id);
}

class DisciplinaRemoteDataSourceImpl implements DisciplinaRemoteDataSource {
  static const String _tableName = 'classes';

  @override
  Future<List<DisciplinaDto>> getAll() async {
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
          .order('"dataCriacao"', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      if (data.isEmpty) {
        return [];
      }

      return data
          .map((json) => DisciplinaDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar disciplinas: $e');
    }
  }

  @override
  Future<DisciplinaDto?> getById(String id) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .eq('user_id', userId) // Filtrar por user_id também
          .isFilter('deleted_at', null) // Excluir deletados
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return DisciplinaDto.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar disciplina por ID: $e');
    }
  }

  @override
  Future<void> save(DisciplinaDto dto) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final json = dto.toJson();
      json['user_id'] = userId; // Garantir que user_id está presente
      await SupabaseConfig.client.from(_tableName).insert(json);
    } catch (e) {
      throw Exception('Erro ao salvar disciplina: $e');
    }
  }

  @override
  Future<void> update(DisciplinaDto dto) async {
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
      throw Exception('Erro ao atualizar disciplina: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      // Verifica se a disciplina existe no remoto (incluindo soft-deleted)
      final existingResponse = await SupabaseConfig.client
          .from(_tableName)
          .select('id, user_id')
          .eq('id', id)
          .maybeSingle();

      // Se não existe no remoto, não há nada para deletar
      if (existingResponse == null) {
        return; // Disciplina só existia localmente, nada a fazer no remoto
      }

      // Verifica se pertence ao usuário atual
      if (existingResponse['user_id'] != userId) {
        throw Exception('Disciplina não pertence ao usuário atual');
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
      throw Exception('Erro ao deletar disciplina: $e');
    }
  }
}

