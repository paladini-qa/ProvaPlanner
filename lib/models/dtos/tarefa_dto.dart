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
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      concluida: json['concluida'],
      dataCriacao: json['dataCriacao'],
      dataConclusao: json['dataConclusao'],
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
