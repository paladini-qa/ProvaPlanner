class Disciplina {
  final String id;
  final String nome;
  final String professor;
  final String periodo;
  final String descricao;
  final int cor; // ARGB32 como int
  final DateTime dataCriacao;

  Disciplina({
    required this.id,
    required this.nome,
    required this.professor,
    required this.periodo,
    this.descricao = '',
    required this.cor,
    required this.dataCriacao,
  });

  Disciplina copyWith({
    String? id,
    String? nome,
    String? professor,
    String? periodo,
    String? descricao,
    int? cor,
    DateTime? dataCriacao,
  }) {
    return Disciplina(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      professor: professor ?? this.professor,
      periodo: periodo ?? this.periodo,
      descricao: descricao ?? this.descricao,
      cor: cor ?? this.cor,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }
}

