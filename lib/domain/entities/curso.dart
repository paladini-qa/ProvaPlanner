class Curso {
  final String id;
  final String nome;
  final String descricao;
  final int cargaHoraria;
  final DateTime dataCriacao;

  Curso({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.cargaHoraria,
    required this.dataCriacao,
  });

  Curso copyWith({
    String? id,
    String? nome,
    String? descricao,
    int? cargaHoraria,
    DateTime? dataCriacao,
  }) {
    return Curso(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      cargaHoraria: cargaHoraria ?? this.cargaHoraria,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }
}

