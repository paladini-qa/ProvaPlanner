import '../entities/disciplina.dart';

abstract class DisciplinaRepository {
  Future<List<Disciplina>> getAll();
  Future<Disciplina?> getById(String id);
  Future<void> save(Disciplina disciplina);
  Future<void> update(Disciplina disciplina);
  Future<void> delete(String id);
}

