import '../../config/supabase_config.dart';
import '../models/tarefa_dto.dart';

abstract class TarefaRemoteDataSource {
  Future<List<TarefaDto>> getAll();
  Future<TarefaDto?> getById(String id);
  Future<void> save(TarefaDto dto);
  Future<void> update(TarefaDto dto);
  Future<void> delete(String id);
}

class TarefaRemoteDataSourceImpl implements TarefaRemoteDataSource {
  static const String _tableName = 'tarefas';

  @override
  Future<List<TarefaDto>> getAll() async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .order('dataCriacao', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      if (data.isEmpty) {
        return [];
      }

      return data
          .map((json) => TarefaDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar tarefas: $e');
    }
  }

  @override
  Future<TarefaDto?> getById(String id) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return TarefaDto.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar tarefa por ID: $e');
    }
  }

  @override
  Future<void> save(TarefaDto dto) async {
    try {
      await SupabaseConfig.client.from(_tableName).insert(dto.toJson());
    } catch (e) {
      throw Exception('Erro ao salvar tarefa: $e');
    }
  }

  @override
  Future<void> update(TarefaDto dto) async {
    try {
      await SupabaseConfig.client
          .from(_tableName)
          .update(dto.toJson())
          .eq('id', dto.id);
    } catch (e) {
      throw Exception('Erro ao atualizar tarefa: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await SupabaseConfig.client.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar tarefa: $e');
    }
  }
}

