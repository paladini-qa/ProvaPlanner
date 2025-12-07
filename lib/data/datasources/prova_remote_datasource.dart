import '../../config/supabase_config.dart';
import '../../services/auth_service.dart';
import '../models/prova_dto.dart';

abstract class ProvaRemoteDataSource {
  Future<List<ProvaDto>> getAll();
  Future<ProvaDto?> getById(String id);
  Future<void> save(ProvaDto dto);
  Future<void> update(ProvaDto dto);
  Future<void> delete(String id);
}

class ProvaRemoteDataSourceImpl implements ProvaRemoteDataSource {
  static const String _tableName = 'exams';

  @override
  Future<List<ProvaDto>> getAll() async {
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
          .order('dataProva', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      if (data.isEmpty) {
        return [];
      }

      return data
          .map((json) => ProvaDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar provas: $e');
    }
  }

  @override
  Future<ProvaDto?> getById(String id) async {
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

      return ProvaDto.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar prova por ID: $e');
    }
  }

  @override
  Future<void> save(ProvaDto dto) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final json = dto.toJson();
      json['user_id'] = userId; // Garantir que user_id está presente
      await SupabaseConfig.client.from(_tableName).insert(json);
    } catch (e) {
      throw Exception('Erro ao salvar prova: $e');
    }
  }

  @override
  Future<void> update(ProvaDto dto) async {
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
      throw Exception('Erro ao atualizar prova: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final userId = AuthService.currentUserId;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      // Verifica se a prova existe no remoto (incluindo soft-deleted)
      final existingResponse = await SupabaseConfig.client
          .from(_tableName)
          .select('id, user_id')
          .eq('id', id)
          .maybeSingle();

      // Se não existe no remoto, não há nada para deletar
      if (existingResponse == null) {
        return; // Prova só existia localmente, nada a fazer no remoto
      }

      // Verifica se pertence ao usuário atual
      if (existingResponse['user_id'] != userId) {
        throw Exception('Prova não pertence ao usuário atual');
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
      throw Exception('Erro ao deletar prova: $e');
    }
  }
}

