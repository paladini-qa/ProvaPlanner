import '../../domain/entities/curso.dart';
import '../../domain/repositories/curso_repository.dart';
import '../datasources/curso_local_datasource.dart';
import '../datasources/curso_remote_datasource.dart';
import '../mappers/curso_mapper.dart';
import '../models/curso_dto.dart';

class CursoRepositoryImpl implements CursoRepository {
  final CursoLocalDataSource localDataSource;
  final CursoRemoteDataSource? remoteDataSource;

  CursoRepositoryImpl(
    this.localDataSource, {
    this.remoteDataSource,
  });

  @override
  Future<List<Curso>> getAll() async {
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
              .map((dto) => CursoMapper.toEntity(dto))
              .toList();
        } catch (e) {
          // Se falhar, usa o local
        }
      }

      // Fallback para local
      return localDtos.map((dto) => CursoMapper.toEntity(dto)).toList();
    } catch (e) {
      // Último fallback: retorna lista vazia
      return [];
    }
  }

  /// Sincroniza dados locais que não estão no remoto
  Future<void> _syncLocalToRemote(
    List<CursoDto> localDtos,
    List<CursoDto> remoteDtos,
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
  Future<Curso?> getById(String id) async {
    final cursos = await getAll();
    try {
      return cursos.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> save(Curso curso) async {
    final dto = CursoMapper.toDto(curso);

    // Salva localmente primeiro (offline-first)
    final cursos = await localDataSource.getAll();
    cursos.add(dto);
    await localDataSource.saveAll(cursos);

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
  Future<void> update(Curso curso) async {
    final dto = CursoMapper.toDto(curso);

    // Atualiza localmente primeiro
    final cursos = await localDataSource.getAll();
    final index = cursos.indexWhere((c) => c.id == curso.id);
    if (index != -1) {
      cursos[index] = dto;
      await localDataSource.saveAll(cursos);
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
    final cursos = await localDataSource.getAll();
    cursos.removeWhere((c) => c.id == id);
    await localDataSource.saveAll(cursos);

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

