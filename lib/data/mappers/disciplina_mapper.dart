import '../../domain/entities/disciplina.dart';
import '../../services/auth_service.dart';
import '../models/disciplina_dto.dart';

class DisciplinaMapper {
  static Disciplina toEntity(DisciplinaDto dto) {
    return Disciplina(
      id: dto.id,
      nome: dto.nome,
      professor: dto.professor,
      periodo: dto.periodo,
      descricao: dto.descricao,
      cor: dto.cor,
      dataCriacao: DateTime.parse(dto.dataCriacao),
    );
  }

  static DisciplinaDto toDto(Disciplina entity) {
    return DisciplinaDto(
      id: entity.id,
      userId: AuthService.currentUserId, // Incluir user_id do usuário autenticado
      nome: entity.nome,
      professor: entity.professor,
      periodo: entity.periodo,
      descricao: entity.descricao,
      cor: entity.cor,
      dataCriacao: entity.dataCriacao.toIso8601String(),
    );
  }
}

