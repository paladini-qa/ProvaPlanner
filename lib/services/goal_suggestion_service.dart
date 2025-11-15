import '../models/prova.dart';
import '../domain/entities/daily_goal.dart';
import '../domain/entities/prioridade_meta.dart';
import '../services/prova_service.dart';
import '../config/env.dart';
import 'ai_service.dart';
import 'gemini_service.dart';
import 'ai_service_mock.dart';

class GoalSuggestionService {
  static AIService get _aiService {
    if (Env.useMockAi) {
      return AIServiceMock();
    }
    try {
      return GeminiService();
    } catch (e) {
      // Se falhar ao criar GeminiService, usar mock
      return AIServiceMock();
    }
  }

  static Future<List<DailyGoal>> gerarSugestoes() async {
    final hoje = DateTime.now();
    final fimSemana = hoje.add(const Duration(days: 7));

    // Obter provas dos próximos 7 dias
    final todasProvas = await ProvaService.carregarProvas();
    final provasProximas = todasProvas.where((prova) {
      return prova.dataProva.isAfter(hoje.subtract(const Duration(days: 1))) &&
          prova.dataProva.isBefore(fimSemana.add(const Duration(days: 1)));
    }).toList();

    // Obter revisões pendentes
    final todasRevisoes = <Revisao>[];
    for (final prova in todasProvas) {
      todasRevisoes.addAll(prova.revisoes.where((r) => !r.concluida));
    }

    // Preparar dados para IA
    final provasTexto = provasProximas.map((p) {
      final diasRestantes = p.dataProva.difference(hoje).inDays;
      return '${p.nome} (${p.disciplinaNome}) - ${diasRestantes} dia(s)';
    }).toList();

    final revisoesTexto = todasRevisoes.map((r) {
      return 'Revisão: ${r.descricao}';
    }).toList();

    // Gerar sugestões com IA
    final sugestoesIA = await _aiService.sugerirMetas(
      provasProximas: provasTexto,
      revisoesPendentes: revisoesTexto,
    );

    // Converter sugestões em DailyGoals
    final goals = sugestoesIA.map((sugestao) {
      return DailyGoal(
        id: DateTime.now().millisecondsSinceEpoch.toString() +
            '_sug_${sugestoesIA.indexOf(sugestao)}',
        titulo: sugestao['titulo'] ?? '',
        descricao: sugestao['descricao'] ?? '',
        data: hoje,
        prioridade: _determinarPrioridade(provasProximas),
      );
    }).toList();

    return goals;
  }

  static PrioridadeMeta _determinarPrioridade(List<Prova> provasProximas) {
    if (provasProximas.isEmpty) {
      return PrioridadeMeta.media;
    }

    final hoje = DateTime.now();
    final temProvaHoje = provasProximas.any((p) {
      return p.dataProva.year == hoje.year &&
          p.dataProva.month == hoje.month &&
          p.dataProva.day == hoje.day;
    });

    if (temProvaHoje) {
      return PrioridadeMeta.alta;
    }

    final temProvaAmanha = provasProximas.any((p) {
      final amanha = hoje.add(const Duration(days: 1));
      return p.dataProva.year == amanha.year &&
          p.dataProva.month == amanha.month &&
          p.dataProva.day == amanha.day;
    });

    if (temProvaAmanha) {
      return PrioridadeMeta.alta;
    }

    return PrioridadeMeta.media;
  }
}

