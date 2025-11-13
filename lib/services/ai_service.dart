abstract class AIService {
  Future<String> gerarResumoDiario({
    required List<String> provas,
    required List<String> revisoes,
    required List<String> metas,
  });

  Future<List<Map<String, String>>> sugerirMetas({
    required List<String> provasProximas,
    required List<String> revisoesPendentes,
  });
}

