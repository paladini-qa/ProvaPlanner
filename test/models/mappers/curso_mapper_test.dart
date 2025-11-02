import 'package:flutter_test/flutter_test.dart';
import 'package:prova_planner/lib/models/dtos/curso_dto.dart';
import 'package:prova_planner/lib/models/entities/curso.dart';
import 'package:prova_planner/lib/models/mappers/curso_mapper.dart';

void main() {
  group('CursoMapper', () {
    test('toEntity', () {
      final dto = CursoDto(
        id: '1',
        nome: 'Engenharia de Software',
        descricao: 'Curso de Engenharia de Software',
        cargaHoraria: 3600,
        dataCriacao: '2023-01-01T00:00:00.000Z',
      );

      final entity = CursoMapper.toEntity(dto);

      expect(entity.id, '1');
      expect(entity.nome, 'Engenharia de Software');
      expect(entity.descricao, 'Curso de Engenharia de Software');
      expect(entity.cargaHoraria, 3600);
      expect(entity.dataCriacao, DateTime.parse('2023-01-01T00:00:00.000Z'));
    });

    test('toDto', () {
      final entity = Curso(
        id: '1',
        nome: 'Engenharia de Software',
        descricao: 'Curso de Engenharia de Software',
        cargaHoraria: 3600,
        dataCriacao: DateTime.parse('2023-01-01T00:00:00.000Z'),
      );

      final dto = CursoMapper.toDto(entity);

      expect(dto.id, '1');
      expect(dto.nome, 'Engenharia de Software');
      expect(dto.descricao, 'Curso de Engenharia de Software');
      expect(dto.cargaHoraria, 3600);
      expect(dto.dataCriacao, '2023-01-01T00:00:00.000Z');
    });
  });
}
