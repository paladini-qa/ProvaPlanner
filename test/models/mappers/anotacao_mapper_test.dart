import 'package:flutter_test/flutter_test.dart';
import 'package:prova_planner/models/dtos/anotacao_dto.dart';
import 'package:prova_planner/models/entities/anotacao.dart';
import 'package:prova_planner/models/mappers/anotacao_mapper.dart';

void main() {
  group('AnotacaoMapper', () {
    test('toEntity', () {
      final dto = AnotacaoDto(
        id: '1',
        titulo: 'Anotação 1',
        descricao: 'Descrição da Anotação 1',
        dataCriacao: '2023-01-01T00:00:00.000Z',
      );

      final entity = AnotacaoMapper.toEntity(dto);

      expect(entity.id, '1');
      expect(entity.titulo, 'Anotação 1');
      expect(entity.descricao, 'Descrição da Anotação 1');
      expect(entity.dataCriacao, DateTime.parse('2023-01-01T00:00:00.000Z'));
    });

    test('toDto', () {
      final entity = Anotacao(
        id: '1',
        titulo: 'Anotação 1',
        descricao: 'Descrição da Anotação 1',
        dataCriacao: DateTime.parse('2023-01-01T00:00:00.000Z'),
      );

      final dto = AnotacaoMapper.toDto(entity);

      expect(dto.id, '1');
      expect(dto.titulo, 'Anotação 1');
      expect(dto.descricao, 'Descrição da Anotação 1');
      expect(dto.dataCriacao, '2023-01-01T00:00:00.000Z');
    });
  });
}
