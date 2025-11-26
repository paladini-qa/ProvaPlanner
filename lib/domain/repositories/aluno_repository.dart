import '../entities/aluno.dart';

abstract class AlunoRepository {
  Future<List<Aluno>> getAll();
  Future<Aluno?> getById(String id);
  Future<void> save(Aluno aluno);
  Future<void> update(Aluno aluno);
  Future<void> delete(String id);
}

