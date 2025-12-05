import 'package:flutter_test/flutter_test.dart';
import 'package:prova_planner/domain/entities/disciplina.dart';

void main() {
  group('Disciplina Entity', () {
    test('deve criar uma disciplina com todos os campos', () {
      final dataCriacao = DateTime.now();
      final disciplina = Disciplina(
        id: '1',
        nome: 'Matemática',
        periodo: '1º Período',
        professor: 'João Silva',
        cor: 0xFF0000FF,
        dataCriacao: dataCriacao,
      );

      expect(disciplina.id, '1');
      expect(disciplina.nome, 'Matemática');
      expect(disciplina.periodo, '1º Período');
      expect(disciplina.professor, 'João Silva');
      expect(disciplina.cor, 0xFF0000FF);
      expect(disciplina.dataCriacao, dataCriacao);
    });

    test('deve criar uma disciplina com descricao padrão', () {
      final dataCriacao = DateTime.now();
      final disciplina = Disciplina(
        id: '2',
        nome: 'Física',
        periodo: '2º Período',
        professor: 'Maria Santos',
        cor: 0xFF00FF00,
        dataCriacao: dataCriacao,
      );

      expect(disciplina.id, '2');
      expect(disciplina.nome, 'Física');
      expect(disciplina.periodo, '2º Período');
      expect(disciplina.descricao, '');
    });

    test('deve usar copyWith corretamente', () {
      final dataCriacao = DateTime.now();
      final disciplina1 = Disciplina(
        id: '1',
        nome: 'Matemática',
        periodo: '1º Período',
        professor: 'João Silva',
        cor: 0xFF0000FF,
        dataCriacao: dataCriacao,
      );

      final disciplina2 = disciplina1.copyWith(nome: 'Matemática Avançada');

      expect(disciplina2.id, '1');
      expect(disciplina2.nome, 'Matemática Avançada');
      expect(disciplina2.periodo, '1º Período');
    });
  });
}

