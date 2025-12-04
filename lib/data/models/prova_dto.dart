import 'revisao_dto.dart';

class ProvaDto {
  final String id;
  final String? userId; // UUID do usuário no Supabase
  final String nome;
  final String disciplinaId;
  final String disciplinaNome;
  final String dataProva; // ISO8601 string
  final String descricao;
  final List<RevisaoDto> revisoes;
  final int cor; // ARGB32 como int
  final String? deletedAt; // ISO8601 string ou null para soft delete

  ProvaDto({
    required this.id,
    this.userId,
    required this.nome,
    required this.disciplinaId,
    required this.disciplinaNome,
    required this.dataProva,
    this.descricao = '',
    required this.revisoes,
    required this.cor,
    this.deletedAt,
  });

  factory ProvaDto.fromJson(Map<String, dynamic> json) {
    return ProvaDto(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      nome: json['nome'] as String,
      disciplinaId: json['disciplinaId'] as String,
      disciplinaNome: json['disciplinaNome'] as String,
      dataProva: json['dataProva'] as String,
      descricao: (json['descricao'] as String?) ?? '',
      revisoes: ((json['revisoes'] as List<dynamic>?) ?? [])
          .map((r) => RevisaoDto.fromJson(r as Map<String, dynamic>))
          .toList(),
      cor: json['cor'] as int,
      deletedAt: json['deleted_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'nome': nome,
      'disciplinaId': disciplinaId,
      'disciplinaNome': disciplinaNome,
      'dataProva': dataProva,
      'descricao': descricao,
      'revisoes': revisoes.map((r) => r.toJson()).toList(),
      'cor': cor,
    };
    // Incluir user_id apenas se não for null
    final userIdValue = userId;
    if (userIdValue != null) {
      json['user_id'] = userIdValue;
    }
    return json;
  }
}

