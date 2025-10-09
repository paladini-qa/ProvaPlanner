import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/disciplina.dart';

class DisciplinaService {
  static const String _disciplinasKey = 'disciplinas';

  // Salvar disciplinas
  static Future<void> salvarDisciplinas(List<Disciplina> disciplinas) async {
    final prefs = await SharedPreferences.getInstance();
    final disciplinasJson = disciplinas.map((d) => d.toJson()).toList();
    await prefs.setString(_disciplinasKey, jsonEncode(disciplinasJson));
  }

  // Carregar disciplinas
  static Future<List<Disciplina>> carregarDisciplinas() async {
    final prefs = await SharedPreferences.getInstance();
    final disciplinasString = prefs.getString(_disciplinasKey);
    
    if (disciplinasString == null) {
      return [];
    }
    
    final List<dynamic> disciplinasJson = jsonDecode(disciplinasString);
    return disciplinasJson.map((json) => Disciplina.fromJson(json)).toList();
  }

  // Adicionar disciplina
  static Future<void> adicionarDisciplina(Disciplina disciplina) async {
    final disciplinas = await carregarDisciplinas();
    disciplinas.add(disciplina);
    await salvarDisciplinas(disciplinas);
  }

  // Atualizar disciplina
  static Future<void> atualizarDisciplina(Disciplina disciplina) async {
    final disciplinas = await carregarDisciplinas();
    final index = disciplinas.indexWhere((d) => d.id == disciplina.id);
    if (index != -1) {
      disciplinas[index] = disciplina;
      await salvarDisciplinas(disciplinas);
    }
  }

  // Remover disciplina
  static Future<void> removerDisciplina(String disciplinaId) async {
    final disciplinas = await carregarDisciplinas();
    disciplinas.removeWhere((d) => d.id == disciplinaId);
    await salvarDisciplinas(disciplinas);
  }

  // Buscar disciplina por ID
  static Future<Disciplina?> buscarDisciplinaPorId(String id) async {
    final disciplinas = await carregarDisciplinas();
    try {
      return disciplinas.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  // Buscar disciplinas por período
  static Future<List<Disciplina>> buscarDisciplinasPorPeriodo(String periodo) async {
    final disciplinas = await carregarDisciplinas();
    return disciplinas.where((d) => d.periodo == periodo).toList();
  }
}
