import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prova.dart';

class ProvaService {
  static const String _key = 'provas';

  // Salva a lista de provas no SharedPreferences
  static Future<void> salvarProvas(List<Prova> provas) async {
    final prefs = await SharedPreferences.getInstance();
    final provasJson = provas.map((p) => p.toJson()).toList();
    await prefs.setString(_key, jsonEncode(provasJson));
  }

  // Carrega a lista de provas do SharedPreferences
  static Future<List<Prova>> carregarProvas() async {
    final prefs = await SharedPreferences.getInstance();
    final provasString = prefs.getString(_key);
    
    if (provasString == null) {
      return [];
    }
    
    try {
      final List<dynamic> provasJson = jsonDecode(provasString);
      return provasJson.map((json) => Prova.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Adiciona uma nova prova
  static Future<void> adicionarProva(Prova prova) async {
    final provas = await carregarProvas();
    provas.add(prova);
    await salvarProvas(provas);
  }

  // Atualiza uma prova existente
  static Future<void> atualizarProva(Prova prova) async {
    final provas = await carregarProvas();
    final index = provas.indexWhere((p) => p.id == prova.id);
    if (index != -1) {
      provas[index] = prova;
      await salvarProvas(provas);
    }
  }

  // Remove uma prova
  static Future<void> removerProva(String id) async {
    final provas = await carregarProvas();
    provas.removeWhere((p) => p.id == id);
    await salvarProvas(provas);
  }

  // Marca uma revisão como concluída
  static Future<void> marcarRevisaoConcluida(String provaId, String revisaoId) async {
    final provas = await carregarProvas();
    final provaIndex = provas.indexWhere((p) => p.id == provaId);
    
    if (provaIndex != -1) {
      final prova = provas[provaIndex];
      final revisoes = prova.revisoes.map((r) {
        if (r.id == revisaoId) {
          return r.copyWith(concluida: true);
        }
        return r;
      }).toList();
      
      final provaAtualizada = Prova(
        id: prova.id,
        nome: prova.nome,
        disciplinaId: prova.disciplinaId,
        disciplinaNome: prova.disciplinaNome,
        dataProva: prova.dataProva,
        descricao: prova.descricao,
        revisoes: revisoes,
        cor: prova.cor,
      );
      
      provas[provaIndex] = provaAtualizada;
      await salvarProvas(provas);
    }
  }

  // Obtém provas para uma data específica
  static Future<List<Prova>> obterProvasPorData(DateTime data) async {
    final provas = await carregarProvas();
    return provas.where((p) {
      return p.dataProva.year == data.year &&
             p.dataProva.month == data.month &&
             p.dataProva.day == data.day;
    }).toList();
  }

  // Obtém revisões para uma data específica
  static Future<List<Revisao>> obterRevisoesPorData(DateTime data) async {
    final provas = await carregarProvas();
    final revisoes = <Revisao>[];
    
    for (final prova in provas) {
      for (final revisao in prova.revisoes) {
        if (revisao.data.year == data.year &&
            revisao.data.month == data.month &&
            revisao.data.day == data.day) {
          revisoes.add(revisao);
        }
      }
    }
    
    return revisoes;
  }
}

