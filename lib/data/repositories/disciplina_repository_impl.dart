import '../../domain/entities/disciplina.dart';
import '../../domain/repositories/disciplina_repository.dart';
import '../datasources/disciplina_local_datasource.dart';
import '../datasources/disciplina_remote_datasource.dart';
import '../mappers/disciplina_mapper.dart';
import '../models/disciplina_dto.dart';

class DisciplinaRepositoryImpl implements DisciplinaRepository {
  final DisciplinaLocalDataSource localDataSource;
  final DisciplinaRemoteDataSource? remoteDataSource;

  DisciplinaRepositoryImpl(
    this.localDataSource, {
    this.remoteDataSource,
  });

  @override
  Future<List<Disciplina>> getAll() async {
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
              .map((dto) => DisciplinaMapper.toEntity(dto))
              .toList();
        } catch (e) {
          // Se falhar, usa o local
        }
      }
      
      // Fallback para local
      return localDtos.map((dto) => DisciplinaMapper.toEntity(dto)).toList();
    } catch (e) {
      // Último fallback: retorna lista vazia
      return [];
    }
  }

  /// Sincroniza dados locais que não estão no remoto
  Future<void> _syncLocalToRemote(
    List<DisciplinaDto> localDtos,
    List<DisciplinaDto> remoteDtos,
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
  Future<Disciplina?> getById(String id) async {
    final disciplinas = await getAll();
    try {
      return disciplinas.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> save(Disciplina disciplina) async {
    final dto = DisciplinaMapper.toDto(disciplina);

    // Salva localmente primeiro (offline-first)
    final disciplinas = await localDataSource.getAll();
    disciplinas.add(dto);
    await localDataSource.saveAll(disciplinas);

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
  Future<void> update(Disciplina disciplina) async {
    final dto = DisciplinaMapper.toDto(disciplina);

    // Atualiza localmente primeiro
    final disciplinas = await localDataSource.getAll();
    final index = disciplinas.indexWhere((d) => d.id == disciplina.id);
    if (index != -1) {
      disciplinas[index] = dto;
      await localDataSource.saveAll(disciplinas);
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
    final disciplinas = await localDataSource.getAll();
    disciplinas.removeWhere((d) => d.id == id);
    await localDataSource.saveAll(disciplinas);

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

