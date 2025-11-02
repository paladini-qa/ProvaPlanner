import 'package:flutter_test/flutter_test.dart';
import 'package:prova_planner/lib/models/dtos/tarefa_dto.dart';
import 'package:prova_planner/lib/models/entities/tarefa.dart';
import 'package:prova_planner/lib/models/mappers/tarefa_mapper.dart';

void main() {
  group('TarefaMapper', () {
    test('toEntity', () {
      final dto = TarefaDto(
        id: '1',
        titulo: 'Tarefa 1',
        descricao: 'Descrição da Tarefa 1',
        concluida: false,
        dataCriacao: '2023-01-01T00:00:00.000Z',
        dataConclusao: '2023-01-02T00:00:00.000Z',
      );

      final entity = TarefaMapper.toEntity(dto);

      expect(entity.id, '1');
      expect(entity.titulo, 'Tarefa 1');
      expect(entity.descricao, 'Descrição da Tarefa 1');
      expect(entity.concluida, false);
      expect(entity.dataCriacao, DateTime.parse('2023-01-01T00:00:00.000Z'));
      expect(entity.dataConclusao, DateTime.parse('2023-01-02T00:00:00.000Z'));
    });

    test('toDto', () {
      final entity = Tarefa(
        id: '1',
        titulo: 'Tarefa 1',
        descricao: 'Descrição da Tarefa 1',
        concluida: false,
        dataCriacao: DateTime.parse('2023-01-01T00:00:00.000Z'),
        dataConclusao: DateTime.parse('2023-01-02T00:00:00.000Z'),
      );

      final dto = TarefaMapper.toDto(entity);

      expect(dto.id, '1');
      expect(dto.titulo, 'Tarefa 1');
      expect(dto.descricao, 'Descrição da Tarefa 1');
      expect(dto.concluida, false);
      expect(dto.dataCriacao, '2023-01-01T00:00:00.000Z');
      expect(dto.dataConclusao, '2023-01-02T00:00:00.000Z');
    });
  });
}
