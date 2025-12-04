import '../../config/supabase_config.dart';
import '../models/aluno_dto.dart';

abstract class AlunoRemoteDataSource {
  Future<List<AlunoDto>> getAll();
  Future<AlunoDto?> getById(String id);
  Future<void> save(AlunoDto dto);
  Future<void> update(AlunoDto dto);
  Future<void> delete(String id);
}

class AlunoRemoteDataSourceImpl implements AlunoRemoteDataSource {
  static const String _tableName = 'alunos';

  @override
  Future<List<AlunoDto>> getAll() async {
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
          .map((json) => AlunoDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar alunos: $e');
    }
  }

  @override
  Future<AlunoDto?> getById(String id) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return AlunoDto.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar aluno por ID: $e');
    }
  }

  @override
  Future<void> save(AlunoDto dto) async {
    try {
      await SupabaseConfig.client.from(_tableName).insert(dto.toJson());
    } catch (e) {
      throw Exception('Erro ao salvar aluno: $e');
    }
  }

  @override
  Future<void> update(AlunoDto dto) async {
    try {
      await SupabaseConfig.client
          .from(_tableName)
          .update(dto.toJson())
          .eq('id', dto.id);
    } catch (e) {
      throw Exception('Erro ao atualizar aluno: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await SupabaseConfig.client.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar aluno: $e');
    }
  }
}

