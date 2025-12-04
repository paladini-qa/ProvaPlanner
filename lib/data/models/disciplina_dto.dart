class DisciplinaDto {
  final String id;
  final String? userId; // UUID do usuário no Supabase
  final String nome;
  final String professor;
  final String periodo;
  final String descricao;
  final int cor; // ARGB32 como int
  final String dataCriacao; // ISO8601 string
  final String? deletedAt; // ISO8601 string ou null para soft delete

  DisciplinaDto({
    required this.id,
    this.userId,
    required this.nome,
    required this.professor,
    required this.periodo,
    this.descricao = '',
    required this.cor,
    required this.dataCriacao,
    this.deletedAt,
  });

  factory DisciplinaDto.fromJson(Map<String, dynamic> json) {
    return DisciplinaDto(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      nome: json['nome'] as String,
      professor: json['professor'] as String,
      periodo: json['periodo'] as String,
      descricao: (json['descricao'] as String?) ?? '',
      cor: json['cor'] as int,
      dataCriacao: json['dataCriacao'] as String,
      deletedAt: json['deleted_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'nome': nome,
      'professor': professor,
      'periodo': periodo,
      'descricao': descricao,
      'cor': cor,
      'dataCriacao': dataCriacao,
    };
    // Incluir user_id apenas se não for null
    final userIdValue = userId;
    if (userIdValue != null) {
      json['user_id'] = userIdValue;
    }
    return json;
  }
}

