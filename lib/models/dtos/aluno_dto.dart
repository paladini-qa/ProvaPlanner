class AlunoDto {
  final String id;
  final String nome;
  final String matricula;
  final String email;
  final String dataCriacao;

  AlunoDto({
    required this.id,
    required this.nome,
    required this.matricula,
    required this.email,
    required this.dataCriacao,
  });

  factory AlunoDto.fromJson(Map<String, dynamic> json) {
    return AlunoDto(
      id: json['id'] as String,
      nome: json['nome'] as String,
      matricula: json['matricula'] as String,
      email: json['email'] as String,
      dataCriacao: json['dataCriacao'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'matricula': matricula,
      'email': email,
      'dataCriacao': dataCriacao,
    };
  }
}
