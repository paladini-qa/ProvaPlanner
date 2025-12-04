import '../../domain/entities/curso.dart';
import '../models/curso_dto.dart';

class CursoMapper {
  static Curso toEntity(CursoDto dto) {
    return Curso(
      id: dto.id,
      nome: dto.nome,
      descricao: dto.descricao,
      cargaHoraria: dto.cargaHoraria,
      dataCriacao: DateTime.parse(dto.dataCriacao),
    );
  }

  static CursoDto toDto(Curso entity) {
    return CursoDto(
      id: entity.id,
      nome: entity.nome,
      descricao: entity.descricao,
      cargaHoraria: entity.cargaHoraria,
      dataCriacao: entity.dataCriacao.toIso8601String(),
    );
  }
}

