import '../entities/aluno.dart';
import '../repositories/aluno_repository.dart';

class UpdateAluno {
  final AlunoRepository repository;

  UpdateAluno(this.repository);

  Future<void> call(Aluno aluno) async {
    await repository.update(aluno);
  }
}

