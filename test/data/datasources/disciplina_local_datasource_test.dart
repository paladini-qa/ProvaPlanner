import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prova_planner/data/datasources/disciplina_local_datasource.dart';
import 'package:prova_planner/data/models/disciplina_dto.dart';

void main() {
  group('DisciplinaLocalDataSource', () {
    late DisciplinaLocalDataSourceImpl dataSource;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      dataSource = DisciplinaLocalDataSourceImpl();
    });

    test('deve salvar e recuperar disciplinas', () async {
      final dto = DisciplinaDto(
        id: '1',
        nome: 'Matemática',
        periodo: '1º Período',
        professor: 'João Silva',
        cor: 0xFF0000FF,
        dataCriacao: '2024-01-01T00:00:00.000Z',
        userId: 'user1',
      );

      await dataSource.save(dto);
      final result = await dataSource.getAll();

      expect(result.length, 1);
      expect(result[0].nome, 'Matemática');
      expect(result[0].periodo, '1º Período');
    });

    test('deve retornar lista vazia quando não há disciplinas', () async {
      final result = await dataSource.getAll();
      expect(result, isEmpty);
    });

    test('deve salvar múltiplas disciplinas', () async {
      final dto1 = DisciplinaDto(
        id: '1',
        nome: 'Matemática',
        periodo: '1º Período',
        professor: 'João Silva',
        cor: 0xFF0000FF,
        dataCriacao: '2024-01-01T00:00:00.000Z',
        userId: 'user1',
      );

      final dto2 = DisciplinaDto(
        id: '2',
        nome: 'Física',
        periodo: '2º Período',
        professor: 'Maria Santos',
        cor: 0xFF00FF00,
        dataCriacao: '2024-01-01T00:00:00.000Z',
        userId: 'user1',
      );

      await dataSource.save(dto1);
      await dataSource.save(dto2);

      final result = await dataSource.getAll();

      expect(result.length, 2);
      expect(result.any((d) => d.nome == 'Matemática'), isTrue);
      expect(result.any((d) => d.nome == 'Física'), isTrue);
    });

    test('deve deletar uma disciplina', () async {
      final dto = DisciplinaDto(
        id: '1',
        nome: 'Matemática',
        periodo: '1º Período',
        professor: 'João Silva',
        cor: 0xFF0000FF,
        dataCriacao: '2024-01-01T00:00:00.000Z',
        userId: 'user1',
      );

      await dataSource.save(dto);
      await dataSource.delete('1');

      final result = await dataSource.getAll();
      expect(result.length, 0);
    });
  });
}

