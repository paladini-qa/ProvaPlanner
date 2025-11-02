class CursoDto {
  final String id;
  final String nome;
  final String descricao;
  final int cargaHoraria;
  final String dataCriacao;

  CursoDto({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.cargaHoraria,
    required this.dataCriacao,
  });

  factory CursoDto.fromJson(Map<String, dynamic> json) {
    return CursoDto(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      cargaHoraria: json['cargaHoraria'],
      dataCriacao: json['dataCriacao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'cargaHoraria': cargaHoraria,
      'dataCriacao': dataCriacao,
    };
  }
}
