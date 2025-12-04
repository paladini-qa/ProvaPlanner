class AnotacaoDto {
  final String id;
  final String titulo;
  final String descricao;
  final String dataCriacao; // ISO8601 string

  AnotacaoDto({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.dataCriacao,
  });

  factory AnotacaoDto.fromJson(Map<String, dynamic> json) {
    return AnotacaoDto(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String,
      dataCriacao: json['dataCriacao'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'dataCriacao': dataCriacao,
    };
  }
}

