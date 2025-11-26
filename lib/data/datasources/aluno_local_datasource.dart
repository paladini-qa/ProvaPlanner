import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/aluno_dto.dart';

abstract class AlunoLocalDataSource {
  Future<List<AlunoDto>> getAll();
  Future<void> save(AlunoDto aluno);
  Future<void> saveAll(List<AlunoDto> alunos);
  Future<void> delete(String id);
}

class AlunoLocalDataSourceImpl implements AlunoLocalDataSource {
  static const String _key = 'alunos';

  @override
  Future<List<AlunoDto>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final alunosString = prefs.getString(_key);

    if (alunosString == null) {
      return [];
    }

    try {
      final List<dynamic> alunosJson = jsonDecode(alunosString) as List<dynamic>;
      return alunosJson
          .map((json) => AlunoDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> save(AlunoDto aluno) async {
    final alunos = await getAll();
    final index = alunos.indexWhere((a) => a.id == aluno.id);
    
    if (index >= 0) {
      alunos[index] = aluno;
    } else {
      alunos.add(aluno);
    }
    
    await saveAll(alunos);
  }

  @override
  Future<void> saveAll(List<AlunoDto> alunos) async {
    final prefs = await SharedPreferences.getInstance();
    final alunosJson = alunos.map((dto) => dto.toJson()).toList();
    await prefs.setString(_key, jsonEncode(alunosJson));
  }

  @override
  Future<void> delete(String id) async {
    final alunos = await getAll();
    alunos.removeWhere((a) => a.id == id);
    await saveAll(alunos);
  }
}

