import '../dtos/daily_goal_dto.dart';
import '../daily_goal.dart';

class DailyGoalMapper {
  static DailyGoal toEntity(DailyGoalDto dto) {
    return DailyGoal(
      id: dto.id,
      titulo: dto.titulo,
      descricao: dto.descricao,
      data: DateTime.parse(dto.data),
      concluida: dto.concluida,
      prioridade: _prioridadeFromString(dto.prioridade),
    );
  }

  static DailyGoalDto toDto(DailyGoal entity) {
    return DailyGoalDto(
      id: entity.id,
      titulo: entity.titulo,
      descricao: entity.descricao,
      data: entity.data.toIso8601String(),
      concluida: entity.concluida,
      prioridade: _prioridadeToString(entity.prioridade),
    );
  }

  static PrioridadeMeta _prioridadeFromString(String prioridade) {
    switch (prioridade.toLowerCase()) {
      case 'alta':
        return PrioridadeMeta.alta;
      case 'baixa':
        return PrioridadeMeta.baixa;
      default:
        return PrioridadeMeta.media;
    }
  }

  static String _prioridadeToString(PrioridadeMeta prioridade) {
    switch (prioridade) {
      case PrioridadeMeta.alta:
        return 'alta';
      case PrioridadeMeta.media:
        return 'media';
      case PrioridadeMeta.baixa:
        return 'baixa';
    }
  }
}

