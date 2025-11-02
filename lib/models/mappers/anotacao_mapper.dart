import '../dtos/anotacao_dto.dart';
import '../entities/anotacao.dart';

class AnotacaoMapper {
  static Anotacao toEntity(AnotacaoDto dto) {
    return Anotacao(
      id: dto.id,
      titulo: dto.titulo,
      descricao: dto.descricao,
      dataCriacao: DateTime.parse(dto.dataCriacao),
    );
  }

  static AnotacaoDto toDto(Anotacao entity) {
    return AnotacaoDto(
      id: entity.id,
      titulo: entity.titulo,
      descricao: entity.descricao,
      dataCriacao: entity.dataCriacao.toIso8601String(),
    );
  }
}
