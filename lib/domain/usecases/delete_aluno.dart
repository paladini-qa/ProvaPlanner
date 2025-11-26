import '../repositories/aluno_repository.dart';

class DeleteAluno {
  final AlunoRepository repository;

  DeleteAluno(this.repository);

  Future<void> call(String id) async {
    await repository.delete(id);
  }
}

