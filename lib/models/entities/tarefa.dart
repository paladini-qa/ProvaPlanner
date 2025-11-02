class Tarefa {
  final String id;
  final String titulo;
  final String descricao;
  final bool concluida;
  final DateTime dataCriacao;
  final DateTime dataConclusao;

  Tarefa({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.concluida,
    required this.dataCriacao,
    required this.dataConclusao,
  });
}
