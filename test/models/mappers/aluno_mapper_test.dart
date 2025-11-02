import 'package:flutter_test/flutter_test.dart';
import 'package:prova_planner/lib/models/dtos/aluno_dto.dart';
import 'package:prova_planner/lib/models/entities/aluno.dart';
import 'package:prova_planner/lib/models/mappers/aluno_mapper.dart';

void main() {
  group('AlunoMapper', () {
    test('toEntity', () {
      final dto = AlunoDto(
        id: '1',
        nome: 'João da Silva',
        matricula: '2021001',
        email: 'joao.silva@teste.com',
        dataCriacao: '2023-01-01T00:00:00.000Z',
      );

      final entity = AlunoMapper.toEntity(dto);

      expect(entity.id, '1');
      expect(entity.nome, 'João da Silva');
      expect(entity.matricula, '2021001');
      expect(entity.email, 'joao.silva@teste.com');
      expect(entity.dataCriacao, DateTime.parse('2023-01-01T00:00:00.000Z'));
    });

    test('toDto', () {
      final entity = Aluno(
        id: '1',
        nome: 'João da Silva',
        matricula: '2021001',
        email: 'joao.silva@teste.com',
        dataCriacao: DateTime.parse('2023-01-01T00:00:00.000Z'),
      );

      final dto = AlunoMapper.toDto(entity);

      expect(dto.id, '1');
      expect(dto.nome, 'João da Silva');
      expect(dto.matricula, '2021001');
      expect(dto.email, 'joao.silva@teste.com');
      expect(dto.dataCriacao, '2023-01-01T00:00:00.000Z');
    });
  });
}
