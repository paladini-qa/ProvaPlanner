import 'ai_service.dart';

class AIServiceMock implements AIService {
  @override
  Future<String> gerarResumoDiario({
    required List<String> provas,
    required List<String> revisoes,
    required List<String> metas,
  }) async {
    // Simular delay de rede
    await Future.delayed(const Duration(seconds: 1));

    final temAtividades = provas.isNotEmpty || revisoes.isNotEmpty || metas.isNotEmpty;

    if (!temAtividades) {
      return '''Título: Um Dia para Organizar seus Estudos

Hoje é um ótimo dia para planejar e organizar seus estudos! Sem atividades urgentes agendadas, você pode aproveitar para revisar conteúdos anteriores, organizar suas anotações ou até mesmo adiantar estudos para provas futuras.

Considere criar algumas metas diárias para manter o ritmo de estudos. Mesmo sem atividades obrigatórias, manter uma rotina de estudos é fundamental para o sucesso acadêmico.

Use este tempo para fortalecer seus conhecimentos e se preparar melhor para os desafios que virão!''';
    }

    final buffer = StringBuffer();
    buffer.writeln('Título: Seu Dia de Estudos');

    buffer.writeln();
    buffer.writeln('Você tem um dia produtivo pela frente! ');

    if (provas.isNotEmpty) {
      buffer.writeln('Você tem ${provas.length} prova(s) agendada(s) para hoje. Certifique-se de estar bem preparado e revisar os principais pontos antes do horário da prova.');
    }

    if (revisoes.isNotEmpty) {
      buffer.writeln('Existem ${revisoes.length} revisão(ões) pendente(s) para hoje. Dedique tempo para completá-las e reforçar seu aprendizado.');
    }

    if (metas.isNotEmpty) {
      buffer.writeln('Você definiu ${metas.length} meta(s) para hoje. Foque em completá-las uma a uma para manter sua produtividade.');
    }

    buffer.writeln();
    buffer.writeln('Lembre-se: organização e foco são essenciais para o sucesso. Boa sorte com seus estudos!');

    return buffer.toString();
  }

  @override
  Future<List<Map<String, String>>> sugerirMetas({
    required List<String> provasProximas,
    required List<String> revisoesPendentes,
  }) async {
    // Simular delay de rede
    await Future.delayed(const Duration(seconds: 1));

    final sugestoes = <Map<String, String>>[];

    if (provasProximas.isNotEmpty) {
      sugestoes.add({
        'titulo': 'Revisar conteúdo da próxima prova',
        'descricao': 'Dedique 1-2 horas para revisar os principais tópicos que serão cobrados',
      });
      sugestoes.add({
        'titulo': 'Resolver exercícios práticos',
        'descricao': 'Pratique com exercícios similares aos que podem aparecer na prova',
      });
    }

    if (revisoesPendentes.isNotEmpty) {
      sugestoes.add({
        'titulo': 'Completar revisões agendadas',
        'descricao': 'Foque nas revisões pendentes para manter o conteúdo atualizado',
      });
    }

    if (sugestoes.isEmpty) {
      sugestoes.add({
        'titulo': 'Revisar matérias estudadas recentemente',
        'descricao': 'Mantenha o conteúdo fresco na memória com uma revisão rápida',
      });
      sugestoes.add({
        'titulo': 'Organizar anotações e materiais',
        'descricao': 'Dedique tempo para organizar seus materiais de estudo',
      });
      sugestoes.add({
        'titulo': 'Praticar exercícios de fixação',
        'descricao': 'Resolva exercícios para reforçar o aprendizado',
      });
    }

    return sugestoes;
  }
}

