import '../../domain/entities/disciplina.dart';
import '../../domain/repositories/disciplina_repository.dart';
import '../../data/repositories/disciplina_repository_impl.dart';
import '../../data/datasources/disciplina_local_datasource.dart';
import '../../data/datasources/disciplina_remote_datasource.dart';
import '../../config/supabase_config.dart';

/// Service wrapper para facilitar o uso dos repositories
/// Mantém interface estática para compatibilidade com código existente
class DisciplinaService {
  static DisciplinaRepository? _repository;

  static DisciplinaRepository get _instance {
    _repository ??= DisciplinaRepositoryImpl(
      DisciplinaLocalDataSourceImpl(),
      remoteDataSource: SupabaseConfig.isInitialized
          ? DisciplinaRemoteDataSourceImpl()
          : null,
    );
    return _repository!;
  }

  // Carregar disciplinas
  static Future<List<Disciplina>> carregarDisciplinas() async {
    return await _instance.getAll();
  }

  // Adicionar disciplina
  static Future<void> adicionarDisciplina(Disciplina disciplina) async {
    await _instance.save(disciplina);
  }

  // Atualizar disciplina
  static Future<void> atualizarDisciplina(Disciplina disciplina) async {
    await _instance.update(disciplina);
  }

  // Remover disciplina
  static Future<void> removerDisciplina(String disciplinaId) async {
    await _instance.delete(disciplinaId);
  }

  // Buscar disciplina por ID
  static Future<Disciplina?> buscarDisciplinaPorId(String id) async {
    return await _instance.getById(id);
  }

  // Buscar disciplinas por período
  static Future<List<Disciplina>> buscarDisciplinasPorPeriodo(
      String periodo) async {
    final disciplinas = await _instance.getAll();
    return disciplinas.where((d) => d.periodo == periodo).toList();
  }
}

