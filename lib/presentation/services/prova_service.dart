import '../../domain/entities/prova.dart';
import '../../domain/entities/revisao.dart';
import '../../domain/repositories/prova_repository.dart';
import '../../data/repositories/prova_repository_impl.dart';
import '../../data/datasources/prova_local_datasource.dart';
import '../../data/datasources/prova_remote_datasource.dart';
import '../../config/supabase_config.dart';

/// Service wrapper para facilitar o uso dos repositories
/// Mantém interface estática para compatibilidade com código existente
class ProvaService {
  static ProvaRepository? _repository;

  static ProvaRepository get _instance {
    _repository ??= ProvaRepositoryImpl(
      ProvaLocalDataSourceImpl(),
      remoteDataSource: SupabaseConfig.isInitialized
          ? ProvaRemoteDataSourceImpl()
          : null,
    );
    return _repository!;
  }

  // Carrega a lista de provas
  static Future<List<Prova>> carregarProvas() async {
    return await _instance.getAll();
  }

  // Adiciona uma nova prova
  static Future<void> adicionarProva(Prova prova) async {
    await _instance.save(prova);
  }

  // Atualiza uma prova existente
  static Future<void> atualizarProva(Prova prova) async {
    await _instance.update(prova);
  }

  // Remove uma prova
  static Future<void> removerProva(String id) async {
    await _instance.delete(id);
  }

  // Marca uma revisão como concluída
  static Future<void> marcarRevisaoConcluida(
      String provaId, String revisaoId) async {
    final prova = await _instance.getById(provaId);
    if (prova != null) {
      final revisoes = prova.revisoes.map((r) {
        if (r.id == revisaoId) {
          return r.copyWith(concluida: true);
        }
        return r;
      }).toList();

      final provaAtualizada = prova.copyWith(revisoes: revisoes);
      await _instance.update(provaAtualizada);
    }
  }

  // Obtém provas para uma data específica
  static Future<List<Prova>> obterProvasPorData(DateTime data) async {
    final provas = await _instance.getAll();
    return provas.where((p) {
      return p.dataProva.year == data.year &&
          p.dataProva.month == data.month &&
          p.dataProva.day == data.day;
    }).toList();
  }

  // Obtém revisões para uma data específica
  static Future<List<Revisao>> obterRevisoesPorData(DateTime data) async {
    final provas = await _instance.getAll();
    final revisoes = <Revisao>[];

    for (final prova in provas) {
      for (final revisao in prova.revisoes) {
        if (revisao.data.year == data.year &&
            revisao.data.month == data.month &&
            revisao.data.day == data.day) {
          revisoes.add(revisao);
        }
      }
    }

    return revisoes;
  }
}



