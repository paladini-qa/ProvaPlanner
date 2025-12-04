class Anotacao {
  final String id;
  final String titulo;
  final String descricao;
  final DateTime dataCriacao;

  Anotacao({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.dataCriacao,
  });

  Anotacao copyWith({
    String? id,
    String? titulo,
    String? descricao,
    DateTime? dataCriacao,
  }) {
    return Anotacao(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }
}

