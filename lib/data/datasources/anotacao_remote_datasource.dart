import '../../config/supabase_config.dart';
import '../models/anotacao_dto.dart';

abstract class AnotacaoRemoteDataSource {
  Future<List<AnotacaoDto>> getAll();
  Future<AnotacaoDto?> getById(String id);
  Future<void> save(AnotacaoDto dto);
  Future<void> update(AnotacaoDto dto);
  Future<void> delete(String id);
}

class AnotacaoRemoteDataSourceImpl implements AnotacaoRemoteDataSource {
  static const String _tableName = 'anotacoes';

  @override
  Future<List<AnotacaoDto>> getAll() async {
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
          .map((json) => AnotacaoDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar anotações: $e');
    }
  }

  @override
  Future<AnotacaoDto?> getById(String id) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return AnotacaoDto.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar anotação por ID: $e');
    }
  }

  @override
  Future<void> save(AnotacaoDto dto) async {
    try {
      await SupabaseConfig.client.from(_tableName).insert(dto.toJson());
    } catch (e) {
      throw Exception('Erro ao salvar anotação: $e');
    }
  }

  @override
  Future<void> update(AnotacaoDto dto) async {
    try {
      await SupabaseConfig.client
          .from(_tableName)
          .update(dto.toJson())
          .eq('id', dto.id);
    } catch (e) {
      throw Exception('Erro ao atualizar anotação: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await SupabaseConfig.client.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar anotação: $e');
    }
  }
}

