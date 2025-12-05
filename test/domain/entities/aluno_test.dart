import 'package:flutter_test/flutter_test.dart';
import 'package:prova_planner/domain/entities/aluno.dart';

void main() {
  group('Aluno Entity', () {
    test('deve criar um aluno com todos os campos', () {
      final dataCriacao = DateTime.now();
      final aluno = Aluno(
        id: '1',
        nome: 'João Silva',
        matricula: '2024001',
        email: 'joao@example.com',
        dataCriacao: dataCriacao,
      );

      expect(aluno.id, '1');
      expect(aluno.nome, 'João Silva');
      expect(aluno.matricula, '2024001');
      expect(aluno.email, 'joao@example.com');
      expect(aluno.dataCriacao, dataCriacao);
    });

    test('deve usar copyWith corretamente', () {
      final dataCriacao = DateTime.now();
      final aluno1 = Aluno(
        id: '1',
        nome: 'João Silva',
        matricula: '2024001',
        email: 'joao@example.com',
        dataCriacao: dataCriacao,
      );

      final aluno2 = aluno1.copyWith(nome: 'João Santos');

      expect(aluno2.id, '1');
      expect(aluno2.nome, 'João Santos');
      expect(aluno2.matricula, '2024001');
      expect(aluno2.email, 'joao@example.com');
    });
  });
}

