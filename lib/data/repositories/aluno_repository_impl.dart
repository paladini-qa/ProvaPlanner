import '../../domain/entities/aluno.dart';
import '../../domain/repositories/aluno_repository.dart';
import '../datasources/aluno_local_datasource.dart';
import '../mappers/aluno_mapper.dart';

class AlunoRepositoryImpl implements AlunoRepository {
  final AlunoLocalDataSource localDataSource;

  AlunoRepositoryImpl(this.localDataSource);

  @override
  Future<List<Aluno>> getAll() async {
    try {
      final dtos = await localDataSource.getAll();
      return dtos.map((dto) => AlunoMapper.toEntity(dto)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Aluno?> getById(String id) async {
    final alunos = await getAll();
    try {
      return alunos.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> save(Aluno aluno) async {
    final dto = AlunoMapper.toDto(aluno);
    await localDataSource.save(dto);
  }

  @override
  Future<void> update(Aluno aluno) async {
    await save(aluno);
  }

  @override
  Future<void> delete(String id) async {
    await localDataSource.delete(id);
  }
}

