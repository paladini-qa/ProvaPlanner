import '../../domain/entities/revisao.dart';
import '../models/revisao_dto.dart';

class RevisaoMapper {
  static Revisao toEntity(RevisaoDto dto) {
    return Revisao(
      id: dto.id,
      data: DateTime.parse(dto.data),
      concluida: dto.concluida,
      descricao: dto.descricao,
    );
  }

  static RevisaoDto toDto(Revisao entity) {
    return RevisaoDto(
      id: entity.id,
      data: entity.data.toIso8601String(),
      concluida: entity.concluida,
      descricao: entity.descricao,
    );
  }
}

