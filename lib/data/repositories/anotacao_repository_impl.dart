import '../../domain/entities/anotacao.dart';
import '../../domain/repositories/anotacao_repository.dart';
import '../datasources/anotacao_local_datasource.dart';
import '../datasources/anotacao_remote_datasource.dart';
import '../mappers/anotacao_mapper.dart';
import '../models/anotacao_dto.dart';

class AnotacaoRepositoryImpl implements AnotacaoRepository {
  final AnotacaoLocalDataSource localDataSource;
  final AnotacaoRemoteDataSource? remoteDataSource;

  AnotacaoRepositoryImpl(
    this.localDataSource, {
    this.remoteDataSource,
  });

  @override
  Future<List<Anotacao>> getAll() async {
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
              .map((dto) => AnotacaoMapper.toEntity(dto))
              .toList();
        } catch (e) {
          // Se falhar, usa o local
        }
      }

      // Fallback para local
      return localDtos.map((dto) => AnotacaoMapper.toEntity(dto)).toList();
    } catch (e) {
      // Último fallback: retorna lista vazia
      return [];
    }
  }

  /// Sincroniza dados locais que não estão no remoto
  Future<void> _syncLocalToRemote(
    List<AnotacaoDto> localDtos,
    List<AnotacaoDto> remoteDtos,
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
  Future<Anotacao?> getById(String id) async {
    final anotacoes = await getAll();
    try {
      return anotacoes.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> save(Anotacao anotacao) async {
    final dto = AnotacaoMapper.toDto(anotacao);

    // Salva localmente primeiro (offline-first)
    final anotacoes = await localDataSource.getAll();
    anotacoes.add(dto);
    await localDataSource.saveAll(anotacoes);

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
  Future<void> update(Anotacao anotacao) async {
    final dto = AnotacaoMapper.toDto(anotacao);

    // Atualiza localmente primeiro
    final anotacoes = await localDataSource.getAll();
    final index = anotacoes.indexWhere((a) => a.id == anotacao.id);
    if (index != -1) {
      anotacoes[index] = dto;
      await localDataSource.saveAll(anotacoes);
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
    final anotacoes = await localDataSource.getAll();
    anotacoes.removeWhere((a) => a.id == id);
    await localDataSource.saveAll(anotacoes);

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

