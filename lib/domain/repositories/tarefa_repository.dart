import '../entities/tarefa.dart';

abstract class TarefaRepository {
  Future<List<Tarefa>> getAll();
  Future<Tarefa?> getById(String id);
  Future<void> save(Tarefa tarefa);
  Future<void> update(Tarefa tarefa);
  Future<void> delete(String id);
}

