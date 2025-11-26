import '../entities/aluno.dart';
import '../repositories/aluno_repository.dart';

class GetAlunos {
  final AlunoRepository repository;

  GetAlunos(this.repository);

  Future<List<Aluno>> call() async {
    return await repository.getAll();
  }
}

