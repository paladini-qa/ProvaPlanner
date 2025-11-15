class DailyGoalDto {
  final String id;
  final String titulo;
  final String descricao;
  final String data;
  final bool concluida;
  final String prioridade;

  DailyGoalDto({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.data,
    required this.concluida,
    required this.prioridade,
  });

  factory DailyGoalDto.fromJson(Map<String, dynamic> json) {
    return DailyGoalDto(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String,
      data: json['data'] as String,
      concluida: (json['concluida'] as bool?) ?? false,
      prioridade: (json['prioridade'] as String?) ?? 'media',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'data': data,
      'concluida': concluida,
      'prioridade': prioridade,
    };
  }
}

