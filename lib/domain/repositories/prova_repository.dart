import '../entities/prova.dart';

abstract class ProvaRepository {
  Future<List<Prova>> getAll();
  Future<Prova?> getById(String id);
  Future<void> save(Prova prova);
  Future<void> update(Prova prova);
  Future<void> delete(String id);
}

