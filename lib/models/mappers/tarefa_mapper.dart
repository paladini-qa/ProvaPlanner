import '../dtos/tarefa_dto.dart';
import '../entities/tarefa.dart';

class TarefaMapper {
  static Tarefa toEntity(TarefaDto dto) {
    return Tarefa(
      id: dto.id,
      titulo: dto.titulo,
      descricao: dto.descricao,
      concluida: dto.concluida,
      dataCriacao: DateTime.parse(dto.dataCriacao),
      dataConclusao: DateTime.parse(dto.dataConclusao),
    );
  }

  static TarefaDto toDto(Tarefa entity) {
    return TarefaDto(
      id: entity.id,
      titulo: entity.titulo,
      descricao: entity.descricao,
      concluida: entity.concluida,
      dataCriacao: entity.dataCriacao.toIso8601String(),
      dataConclusao: entity.dataConclusao.toIso8601String(),
    );
  }
}
