import '../entities/curso.dart';

abstract class CursoRepository {
  Future<List<Curso>> getAll();
  Future<Curso?> getById(String id);
  Future<void> save(Curso curso);
  Future<void> update(Curso curso);
  Future<void> delete(String id);
}

