class RevisaoDto {
  final String id;
  final String data; // ISO8601 string
  final bool concluida;
  final String descricao;

  RevisaoDto({
    required this.id,
    required this.data,
    required this.concluida,
    required this.descricao,
  });

  factory RevisaoDto.fromJson(Map<String, dynamic> json) {
    return RevisaoDto(
      id: json['id'] as String,
      data: json['data'] as String,
      concluida: (json['concluida'] as bool?) ?? false,
      descricao: json['descricao'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
      'concluida': concluida,
      'descricao': descricao,
    };
  }
}

