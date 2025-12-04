import '../entities/anotacao.dart';

abstract class AnotacaoRepository {
  Future<List<Anotacao>> getAll();
  Future<Anotacao?> getById(String id);
  Future<void> save(Anotacao anotacao);
  Future<void> update(Anotacao anotacao);
  Future<void> delete(String id);
}

