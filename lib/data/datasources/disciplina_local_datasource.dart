import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/disciplina_dto.dart';

abstract class DisciplinaLocalDataSource {
  Future<List<DisciplinaDto>> getAll();
  Future<void> save(DisciplinaDto disciplina);
  Future<void> saveAll(List<DisciplinaDto> disciplinas);
  Future<void> delete(String id);
}

class DisciplinaLocalDataSourceImpl implements DisciplinaLocalDataSource {
  static const String _key = 'disciplinas';

  @override
  Future<List<DisciplinaDto>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final disciplinasString = prefs.getString(_key);

    if (disciplinasString == null) {
      return [];
    }

    try {
      final List<dynamic> disciplinasJson =
          jsonDecode(disciplinasString) as List<dynamic>;
      return disciplinasJson
          .map((json) => DisciplinaDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> save(DisciplinaDto disciplina) async {
    final disciplinas = await getAll();
    final index = disciplinas.indexWhere((d) => d.id == disciplina.id);

    if (index >= 0) {
      disciplinas[index] = disciplina;
    } else {
      disciplinas.add(disciplina);
    }

    await saveAll(disciplinas);
  }

  @override
  Future<void> saveAll(List<DisciplinaDto> disciplinas) async {
    final prefs = await SharedPreferences.getInstance();
    final disciplinasJson = disciplinas.map((dto) => dto.toJson()).toList();
    await prefs.setString(_key, jsonEncode(disciplinasJson));
  }

  @override
  Future<void> delete(String id) async {
    final disciplinas = await getAll();
    disciplinas.removeWhere((d) => d.id == id);
    await saveAll(disciplinas);
  }
}

