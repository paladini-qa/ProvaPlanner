import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/curso_dto.dart';

abstract class CursoLocalDataSource {
  Future<List<CursoDto>> getAll();
  Future<void> save(CursoDto curso);
  Future<void> saveAll(List<CursoDto> cursos);
  Future<void> delete(String id);
}

class CursoLocalDataSourceImpl implements CursoLocalDataSource {
  static const String _key = 'cursos';

  @override
  Future<List<CursoDto>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final cursosString = prefs.getString(_key);

    if (cursosString == null) {
      return [];
    }

    try {
      final List<dynamic> cursosJson =
          jsonDecode(cursosString) as List<dynamic>;
      return cursosJson
          .map((json) => CursoDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> save(CursoDto curso) async {
    final cursos = await getAll();
    final index = cursos.indexWhere((c) => c.id == curso.id);

    if (index >= 0) {
      cursos[index] = curso;
    } else {
      cursos.add(curso);
    }

    await saveAll(cursos);
  }

  @override
  Future<void> saveAll(List<CursoDto> cursos) async {
    final prefs = await SharedPreferences.getInstance();
    final cursosJson = cursos.map((dto) => dto.toJson()).toList();
    await prefs.setString(_key, jsonEncode(cursosJson));
  }

  @override
  Future<void> delete(String id) async {
    final cursos = await getAll();
    cursos.removeWhere((c) => c.id == id);
    await saveAll(cursos);
  }
}

