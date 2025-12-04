class Revisao {
  final String id;
  final DateTime data;
  final bool concluida;
  final String descricao;

  Revisao({
    required this.id,
    required this.data,
    required this.concluida,
    required this.descricao,
  });

  Revisao copyWith({
    String? id,
    DateTime? data,
    bool? concluida,
    String? descricao,
  }) {
    return Revisao(
      id: id ?? this.id,
      data: data ?? this.data,
      concluida: concluida ?? this.concluida,
      descricao: descricao ?? this.descricao,
    );
  }
}

