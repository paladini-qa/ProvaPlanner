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
      id: json['id'] as String,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      cargaHoraria: json['cargaHoraria'] as int,
      dataCriacao: json['dataCriacao'] as String,
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
