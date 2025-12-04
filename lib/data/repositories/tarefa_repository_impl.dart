import '../../domain/entities/tarefa.dart';
import '../../domain/repositories/tarefa_repository.dart';
import '../datasources/tarefa_local_datasource.dart';
import '../datasources/tarefa_remote_datasource.dart';
import '../mappers/tarefa_mapper.dart';
import '../models/tarefa_dto.dart';

class TarefaRepositoryImpl implements TarefaRepository {
  final TarefaLocalDataSource localDataSource;
  final TarefaRemoteDataSource? remoteDataSource;

  TarefaRepositoryImpl(
    this.localDataSource, {
    this.remoteDataSource,
  });

  @override
  Future<List<Tarefa>> getAll() async {
    try {
      final localDtos = await localDataSource.getAll();

      // Tenta buscar do remoto e sincronizar
      if (remoteDataSource != null) {
        try {
          final remoteDtos = await remoteDataSource!.getAll();

          // Sincroniza remoto -> local
          await localDataSource.saveAll(remoteDtos);

          // Sincroniza local -> remoto (dados criados offline)
          await _syncLocalToRemote(localDtos, remoteDtos);

          return remoteDtos
              .map((dto) => TarefaMapper.toEntity(dto))
              .toList();
        } catch (e) {
          // Se falhar, usa o local
        }
      }

      // Fallback para local
      return localDtos.map((dto) => TarefaMapper.toEntity(dto)).toList();
    } catch (e) {
      // Último fallback: retorna lista vazia
      return [];
    }
  }

  /// Sincroniza dados locais que não estão no remoto
  Future<void> _syncLocalToRemote(
    List<TarefaDto> localDtos,
    List<TarefaDto> remoteDtos,
  ) async {
    if (remoteDataSource == null) return;

    final remoteIds = remoteDtos.map((dto) => dto.id).toSet();

    for (final localDto in localDtos) {
      // Se o dado local não está no remoto, tenta sincronizar
      if (!remoteIds.contains(localDto.id)) {
        try {
          // Verifica se já existe no remoto (pode ter sido criado por outro dispositivo)
          final existing = await remoteDataSource!.getById(localDto.id);
          if (existing == null) {
            // Não existe no remoto, cria
            await remoteDataSource!.save(localDto);
          } else {
            // Existe no remoto, atualiza com dados locais
            await remoteDataSource!.update(localDto);
          }
        } catch (e) {
          // Falha ao sincronizar este item, continua com os próximos
        }
      }
    }
  }

  @override
  Future<Tarefa?> getById(String id) async {
    final tarefas = await getAll();
    try {
      return tarefas.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> save(Tarefa tarefa) async {
    final dto = TarefaMapper.toDto(tarefa);

    // Salva localmente primeiro (offline-first)
    final tarefas = await localDataSource.getAll();
    tarefas.add(dto);
    await localDataSource.saveAll(tarefas);

    // Tenta salvar no remoto (sincronização em background)
    if (remoteDataSource != null) {
      try {
        await remoteDataSource!.save(dto);
      } catch (e) {
        // Se falhar, mantém apenas no local (será sincronizado no próximo getAll)
      }
    }
  }

  @override
  Future<void> update(Tarefa tarefa) async {
    final dto = TarefaMapper.toDto(tarefa);

    // Atualiza localmente primeiro
    final tarefas = await localDataSource.getAll();
    final index = tarefas.indexWhere((t) => t.id == tarefa.id);
    if (index != -1) {
      tarefas[index] = dto;
      await localDataSource.saveAll(tarefas);
    }

    // Tenta atualizar no remoto (sincronização em background)
    if (remoteDataSource != null) {
      try {
        await remoteDataSource!.update(dto);
      } catch (e) {
        // Se falhar, mantém apenas no local (será sincronizado no próximo getAll)
      }
    }
  }

  @override
  Future<void> delete(String id) async {
    // Deleta localmente primeiro
    final tarefas = await localDataSource.getAll();
    tarefas.removeWhere((t) => t.id == id);
    await localDataSource.saveAll(tarefas);

    // Tenta deletar no remoto (sincronização em background)
    if (remoteDataSource != null) {
      try {
        await remoteDataSource!.delete(id);
      } catch (e) {
        // Se falhar, mantém apenas no local (será sincronizado no próximo getAll)
      }
    }
  }
}

