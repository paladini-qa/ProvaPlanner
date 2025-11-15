import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/env.dart';
import 'ai_service.dart';

class GeminiService implements AIService {
  late final GenerativeModel _model;

  GeminiService() {
    final apiKey = Env.geminiApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
          'GEMINI_API_KEY não configurada. Verifique o arquivo .env',
      );
    }
    // Usar gemini-2.0-flash que é o modelo mais recente e disponível
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
    );
  }

  @override
  Future<String> gerarResumoDiario({
    required List<String> provas,
    required List<String> revisoes,
    required List<String> metas,
  }) async {
    final prompt = '''
Você é um assistente de estudos motivacional e organizado. Gere um resumo diário personalizado e encorajador para o estudante baseado nas seguintes informações:

PROVAS AGENDADAS PARA HOJE:
${provas.isEmpty ? 'Nenhuma prova agendada para hoje.' : provas.join('\n')}

REVISÕES PENDENTES PARA HOJE:
${revisoes.isEmpty ? 'Nenhuma revisão pendente para hoje.' : revisoes.join('\n')}

METAS DIÁRIAS:
${metas.isEmpty ? 'Nenhuma meta definida para hoje.' : metas.join('\n')}

INSTRUÇÕES:
- Crie um título motivacional e positivo
- Escreva 2-3 parágrafos com dicas práticas e encorajamento
- Seja específico e acionável
- Use tom amigável e motivacional
- Destaque os pontos mais importantes do dia
- Se não houver atividades, sugira formas de aproveitar o dia para estudos

FORMATO DE SAÍDA:
Título: [título aqui]

[parágrafo 1]

[parágrafo 2]

[parágrafo 3 - opcional]
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Resposta vazia do Gemini');
      }
      return text;
    } catch (e) {
      // Se o erro for sobre modelo não encontrado, sugerir verificar a chave da API
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('not found') || errorMsg.contains('not supported') || errorMsg.contains('permission denied')) {
        throw Exception(
          'Modelo não disponível. Verifique se sua chave da API tem acesso ao modelo gemini-2.0-flash. '
          'Você pode precisar atualizar sua chave da API no Google AI Studio (https://aistudio.google.com/).',
        );
      }
      
      if (errorMsg.contains('quota') || errorMsg.contains('limit')) {
        throw Exception(
          'Limite de quota da API excedido. Verifique seu uso no Google AI Studio ou aguarde alguns minutos.',
        );
      }
      
      if (errorMsg.contains('api key') || errorMsg.contains('authentication')) {
        throw Exception(
          'Chave da API inválida. Verifique se a GEMINI_API_KEY está correta no arquivo .env.',
        );
      }
      
      rethrow;
    }
  }

  @override
  Future<List<Map<String, String>>> sugerirMetas({
    required List<String> provasProximas,
    required List<String> revisoesPendentes,
  }) async {
    final prompt = '''
Você é um assistente de estudos especializado em planejamento acadêmico. Baseado nas provas e revisões do estudante, sugira 3-5 metas diárias de estudo específicas, acionáveis e realistas.

PROVAS PRÓXIMAS (próximos 7 dias):
${provasProximas.isEmpty ? 'Nenhuma prova nos próximos 7 dias.' : provasProximas.join('\n')}

REVISÕES PENDENTES:
${revisoesPendentes.isEmpty ? 'Nenhuma revisão pendente.' : revisoesPendentes.join('\n')}

INSTRUÇÕES:
- Crie 3-5 metas específicas e mensuráveis
- Cada meta deve ser relacionada às provas ou revisões
- Seja realista e considere o tempo disponível
- Use verbos de ação (ex: "Revisar", "Resolver", "Estudar")
- Inclua a disciplina ou assunto quando relevante

FORMATO DE SAÍDA (JSON array):
[
  {"titulo": "Revisar capítulo 5 de Matemática", "descricao": "Focar em equações quadráticas para a prova de quinta-feira"},
  {"titulo": "Resolver 10 exercícios de Física", "descricao": "Praticar mecânica para reforçar conceitos"},
  ...
]

IMPORTANTE: Retorne APENAS o JSON array, sem texto adicional antes ou depois.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final texto = response.text ?? '[]';

      // Limpar o texto para extrair apenas o JSON
      final textoLimpo = texto
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // Tentar fazer parse do JSON
      try {
        List<dynamic> jsonList = [];
        
        // Tentar parse direto primeiro
        try {
          jsonList = jsonDecode(textoLimpo) as List<dynamic>;
        } catch (e) {
          // Se falhar, tentar parser customizado
          jsonList = _parseJsonArray(textoLimpo);
        }

        return jsonList.map((item) {
          if (item is Map<String, dynamic>) {
            return {
              'titulo': item['titulo']?.toString() ?? '',
              'descricao': item['descricao']?.toString() ?? '',
            };
          }
          return {'titulo': '', 'descricao': ''};
        }).where((map) => map['titulo']!.isNotEmpty).toList();
      } catch (e) {
        // Se falhar o parse, criar sugestões genéricas
        return _criarSugestoesGenericas(provasProximas, revisoesPendentes);
      }
    } catch (e) {
      throw Exception('Erro ao gerar sugestões com Gemini: $e');
    }
  }

  List<dynamic> _parseJsonArray(String jsonString) {
    // Parser simples para JSON array
    final List<dynamic> result = [];
    final regex = RegExp(r'\{[^}]+\}');
    final matches = regex.allMatches(jsonString);

    for (final match in matches) {
      final objStr = match.group(0)!;
      final tituloMatch = RegExp(r'"titulo"\s*:\s*"([^"]+)"').firstMatch(objStr);
      final descricaoMatch = RegExp(r'"descricao"\s*:\s*"([^"]+)"').firstMatch(objStr);

      if (tituloMatch != null) {
        result.add({
          'titulo': tituloMatch.group(1) ?? '',
          'descricao': descricaoMatch?.group(1) ?? '',
        });
      }
    }

    return result;
  }

  List<Map<String, String>> _criarSugestoesGenericas(
    List<String> provasProximas,
    List<String> revisoesPendentes,
  ) {
    final sugestoes = <Map<String, String>>[];

    if (provasProximas.isNotEmpty) {
      sugestoes.add({
        'titulo': 'Revisar conteúdo da próxima prova',
        'descricao': 'Dedique tempo para revisar os principais tópicos',
      });
    }

    if (revisoesPendentes.isNotEmpty) {
      sugestoes.add({
        'titulo': 'Completar revisões pendentes',
        'descricao': 'Foque nas revisões agendadas para hoje',
      });
    }

    if (sugestoes.isEmpty) {
      sugestoes.add({
        'titulo': 'Revisar matérias estudadas recentemente',
        'descricao': 'Mantenha o conteúdo fresco na memória',
      });
    }

    return sugestoes;
  }
}

