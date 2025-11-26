import '../entities/aluno.dart';
import '../repositories/aluno_repository.dart';

class AddAluno {
  final AlunoRepository repository;

  AddAluno(this.repository);

  Future<void> call(Aluno aluno) async {
    await repository.save(aluno);
  }
}

