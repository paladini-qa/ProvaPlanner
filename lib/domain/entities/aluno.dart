class Aluno {
  final String id;
  final String nome;
  final String matricula;
  final String email;
  final DateTime dataCriacao;

  Aluno({
    required this.id,
    required this.nome,
    required this.matricula,
    required this.email,
    required this.dataCriacao,
  });

  Aluno copyWith({
    String? id,
    String? nome,
    String? matricula,
    String? email,
    DateTime? dataCriacao,
  }) {
    return Aluno(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      matricula: matricula ?? this.matricula,
      email: email ?? this.email,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }
}

