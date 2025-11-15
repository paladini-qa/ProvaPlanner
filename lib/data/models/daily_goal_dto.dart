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
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      data: json['data'],
      concluida: json['concluida'] ?? false,
      prioridade: json['prioridade'] ?? 'media',
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

