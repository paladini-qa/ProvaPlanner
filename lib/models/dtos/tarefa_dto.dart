class TarefaDto {
  final String id;
  final String titulo;
  final String descricao;
  final bool concluida;
  final String dataCriacao;
  final String dataConclusao;

  TarefaDto({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.concluida,
    required this.dataCriacao,
    required this.dataConclusao,
  });

  factory TarefaDto.fromJson(Map<String, dynamic> json) {
    return TarefaDto(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String,
      concluida: (json['concluida'] as bool?) ?? false,
      dataCriacao: json['dataCriacao'] as String,
      dataConclusao: json['dataConclusao'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'concluida': concluida,
      'dataCriacao': dataCriacao,
      'dataConclusao': dataConclusao,
    };
  }
}
