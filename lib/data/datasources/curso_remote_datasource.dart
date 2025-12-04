import '../../config/supabase_config.dart';
import '../models/curso_dto.dart';

abstract class CursoRemoteDataSource {
  Future<List<CursoDto>> getAll();
  Future<CursoDto?> getById(String id);
  Future<void> save(CursoDto dto);
  Future<void> update(CursoDto dto);
  Future<void> delete(String id);
}

class CursoRemoteDataSourceImpl implements CursoRemoteDataSource {
  static const String _tableName = 'cursos';

  @override
  Future<List<CursoDto>> getAll() async {
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
          .map((json) => CursoDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar cursos: $e');
    }
  }

  @override
  Future<CursoDto?> getById(String id) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return CursoDto.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar curso por ID: $e');
    }
  }

  @override
  Future<void> save(CursoDto dto) async {
    try {
      await SupabaseConfig.client.from(_tableName).insert(dto.toJson());
    } catch (e) {
      throw Exception('Erro ao salvar curso: $e');
    }
  }

  @override
  Future<void> update(CursoDto dto) async {
    try {
      await SupabaseConfig.client
          .from(_tableName)
          .update(dto.toJson())
          .eq('id', dto.id);
    } catch (e) {
      throw Exception('Erro ao atualizar curso: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await SupabaseConfig.client.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar curso: $e');
    }
  }
}

