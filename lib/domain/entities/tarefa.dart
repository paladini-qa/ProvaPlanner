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

  Tarefa copyWith({
    String? id,
    String? titulo,
    String? descricao,
    bool? concluida,
    DateTime? dataCriacao,
    DateTime? dataConclusao,
  }) {
    return Tarefa(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      concluida: concluida ?? this.concluida,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataConclusao: dataConclusao ?? this.dataConclusao,
    );
  }
}

