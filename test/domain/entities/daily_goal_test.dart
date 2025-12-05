import 'package:flutter_test/flutter_test.dart';
import 'package:prova_planner/domain/entities/daily_goal.dart';
import 'package:prova_planner/domain/entities/prioridade_meta.dart';

void main() {
  group('DailyGoal Entity', () {
    test('deve criar uma meta diária com todos os campos', () {
      final data = DateTime(2024, 1, 1);
      final goal = DailyGoal(
        id: '1',
        titulo: 'Estudar matemática',
        descricao: 'Revisar capítulo 5',
        data: data,
        concluida: false,
        prioridade: PrioridadeMeta.alta,
      );

      expect(goal.id, '1');
      expect(goal.titulo, 'Estudar matemática');
      expect(goal.descricao, 'Revisar capítulo 5');
      expect(goal.data, data);
      expect(goal.concluida, false);
      expect(goal.prioridade, PrioridadeMeta.alta);
    });

    test('deve criar uma meta diária com valores padrão', () {
      final data = DateTime(2024, 1, 1);
      final goal = DailyGoal(
        id: '2',
        titulo: 'Revisar física',
        descricao: 'Fazer exercícios',
        data: data,
      );

      expect(goal.id, '2');
      expect(goal.titulo, 'Revisar física');
      expect(goal.descricao, 'Fazer exercícios');
      expect(goal.data, data);
      expect(goal.concluida, false);
      expect(goal.prioridade, PrioridadeMeta.media);
    });

    test('deve retornar texto de prioridade corretamente', () {
      final data = DateTime(2024, 1, 1);
      final goalAlta = DailyGoal(
        id: '1',
        titulo: 'Teste',
        descricao: 'Teste',
        data: data,
        prioridade: PrioridadeMeta.alta,
      );

      expect(goalAlta.prioridadeTexto, 'Alta');
    });
  });
}

