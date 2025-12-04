import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tarefa_dto.dart';

abstract class TarefaLocalDataSource {
  Future<List<TarefaDto>> getAll();
  Future<void> save(TarefaDto tarefa);
  Future<void> saveAll(List<TarefaDto> tarefas);
  Future<void> delete(String id);
}

class TarefaLocalDataSourceImpl implements TarefaLocalDataSource {
  static const String _key = 'tarefas';

  @override
  Future<List<TarefaDto>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final tarefasString = prefs.getString(_key);

    if (tarefasString == null) {
      return [];
    }

    try {
      final List<dynamic> tarefasJson =
          jsonDecode(tarefasString) as List<dynamic>;
      return tarefasJson
          .map((json) => TarefaDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> save(TarefaDto tarefa) async {
    final tarefas = await getAll();
    final index = tarefas.indexWhere((t) => t.id == tarefa.id);

    if (index >= 0) {
      tarefas[index] = tarefa;
    } else {
      tarefas.add(tarefa);
    }

    await saveAll(tarefas);
  }

  @override
  Future<void> saveAll(List<TarefaDto> tarefas) async {
    final prefs = await SharedPreferences.getInstance();
    final tarefasJson = tarefas.map((dto) => dto.toJson()).toList();
    await prefs.setString(_key, jsonEncode(tarefasJson));
  }

  @override
  Future<void> delete(String id) async {
    final tarefas = await getAll();
    tarefas.removeWhere((t) => t.id == id);
    await saveAll(tarefas);
  }
}

