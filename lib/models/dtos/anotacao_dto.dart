class AnotacaoDto {
  final String id;
  final String titulo;
  final String descricao;
  final String dataCriacao;

  AnotacaoDto({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.dataCriacao,
  });

  factory AnotacaoDto.fromJson(Map<String, dynamic> json) {
    return AnotacaoDto(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      dataCriacao: json['dataCriacao'],
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
