import '../dtos/aluno_dto.dart';
import '../entities/aluno.dart';

class AlunoMapper {
  static Aluno toEntity(AlunoDto dto) {
    return Aluno(
      id: dto.id,
      nome: dto.nome,
      matricula: dto.matricula,
      email: dto.email,
      dataCriacao: DateTime.parse(dto.dataCriacao),
    );
  }

  static AlunoDto toDto(Aluno entity) {
    return AlunoDto(
      id: entity.id,
      nome: entity.nome,
      matricula: entity.matricula,
      email: entity.email,
      dataCriacao: entity.dataCriacao.toIso8601String(),
    );
  }
}
