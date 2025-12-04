import '../../domain/entities/prova.dart';
import '../../domain/repositories/prova_repository.dart';
import '../datasources/prova_local_datasource.dart';
import '../datasources/prova_remote_datasource.dart';
import '../mappers/prova_mapper.dart';
import '../models/prova_dto.dart';

class ProvaRepositoryImpl implements ProvaRepository {
  final ProvaLocalDataSource localDataSource;
  final ProvaRemoteDataSource? remoteDataSource;

  ProvaRepositoryImpl(
    this.localDataSource, {
    this.remoteDataSource,
  });

  @override
  Future<List<Prova>> getAll() async {
    try {
      final localDtos = await localDataSource.getAll();
      
      // Tenta buscar do remoto e sincronizar
      if (remoteDataSource != null) {
        try {
          final remoteDtos = await remoteDataSource!.getAll();
          
          // Sincroniza remoto -> local (igual a metas)
          await localDataSource.saveAll(remoteDtos);
          
          // Sincroniza local -> remoto (dados criados offline)
          await _syncLocalToRemote(localDtos, remoteDtos);
          
          return remoteDtos
              .map((dto) => ProvaMapper.toEntity(dto))
              .toList();
        } catch (e) {
          // Se falhar, usa o local
        }
      }
      
      // Fallback para local
      return localDtos.map((dto) => ProvaMapper.toEntity(dto)).toList();
    } catch (e) {
      // Último fallback: retorna lista vazia
      return [];
    }
  }

  /// Sincroniza dados locais que não estão no remoto
  Future<void> _syncLocalToRemote(
    List<ProvaDto> localDtos,
    List<ProvaDto> remoteDtos,
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
  Future<Prova?> getById(String id) async {
    final provas = await getAll();
    try {
      return provas.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> save(Prova prova) async {
    final dto = ProvaMapper.toDto(prova);

    // Salva localmente primeiro (offline-first)
    final provas = await localDataSource.getAll();
    provas.add(dto);
    await localDataSource.saveAll(provas);

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
  Future<void> update(Prova prova) async {
    final dto = ProvaMapper.toDto(prova);

    // Atualiza localmente primeiro
    final provas = await localDataSource.getAll();
    final index = provas.indexWhere((p) => p.id == prova.id);
    if (index != -1) {
      provas[index] = dto;
      await localDataSource.saveAll(provas);
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
    final provas = await localDataSource.getAll();
    provas.removeWhere((p) => p.id == id);
    await localDataSource.saveAll(provas);

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

