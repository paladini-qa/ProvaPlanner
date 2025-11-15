import '../../domain/entities/daily_goal.dart';
import '../../domain/repositories/daily_goal_repository.dart';
import '../datasources/daily_goal_local_datasource.dart';
import '../datasources/daily_goal_remote_datasource.dart';
import '../mappers/daily_goal_mapper.dart';
import '../models/daily_goal_dto.dart';

class DailyGoalRepositoryImpl implements DailyGoalRepository {
  final DailyGoalLocalDataSource localDataSource;
  final DailyGoalRemoteDataSource? remoteDataSource;

  DailyGoalRepositoryImpl(
    this.localDataSource, {
    this.remoteDataSource,
  });

  @override
  Future<List<DailyGoal>> getAll() async {
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
              .map((dto) => DailyGoalMapper.toEntity(dto))
              .toList();
        } catch (e) {
          // Se falhar, usa o local
        }
      }
      
      // Fallback para local
      return localDtos.map((dto) => DailyGoalMapper.toEntity(dto)).toList();
    } catch (e) {
      // Último fallback: retorna lista vazia
      return [];
    }
  }

  /// Sincroniza dados locais que não estão no remoto
  Future<void> _syncLocalToRemote(
    List<DailyGoalDto> localDtos,
    List<DailyGoalDto> remoteDtos,
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
  Future<List<DailyGoal>> getByDate(DateTime date) async {
    try {
      // Tenta buscar do remoto primeiro
      if (remoteDataSource != null) {
        try {
          final remoteDtos = await remoteDataSource!.getByDate(date);
          return remoteDtos
              .map((dto) => DailyGoalMapper.toEntity(dto))
              .toList();
        } catch (e) {
          // Se falhar, usa o local
        }
      }
      // Fallback para local
      final allGoals = await getAll();
      return allGoals.where((goal) {
        return goal.data.year == date.year &&
            goal.data.month == date.month &&
            goal.data.day == date.day;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<DailyGoal>> getNext7Days() async {
    final hoje = DateTime.now();
    final fimSemana = hoje.add(const Duration(days: 7));
    final allGoals = await getAll();
    return allGoals.where((goal) {
      return goal.data.isAfter(hoje.subtract(const Duration(days: 1))) &&
          goal.data.isBefore(fimSemana.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<void> save(DailyGoal goal) async {
    final dto = DailyGoalMapper.toDto(goal);
    
    // Salva localmente primeiro (offline-first)
    final goals = await localDataSource.getAll();
    goals.add(dto);
    await localDataSource.saveAll(goals);
    
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
  Future<void> update(DailyGoal goal) async {
    final dto = DailyGoalMapper.toDto(goal);
    
    // Atualiza localmente primeiro
    final goals = await localDataSource.getAll();
    final index = goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      goals[index] = dto;
      await localDataSource.saveAll(goals);
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
    final goals = await localDataSource.getAll();
    goals.removeWhere((g) => g.id == id);
    await localDataSource.saveAll(goals);
    
    // Tenta deletar no remoto (sincronização em background)
    if (remoteDataSource != null) {
      try {
        await remoteDataSource!.delete(id);
      } catch (e) {
        // Se falhar, mantém apenas no local (será sincronizado no próximo getAll)
      }
    }
  }

  @override
  Future<void> saveAll(List<DailyGoal> goals) async {
    final dtos = goals.map((goal) => DailyGoalMapper.toDto(goal)).toList();
    
    // Salva localmente primeiro
    await localDataSource.saveAll(dtos);
    
    // Tenta salvar no remoto
    if (remoteDataSource != null) {
      try {
        for (final dto in dtos) {
          try {
            final existing = await remoteDataSource!.getById(dto.id);
            if (existing != null) {
              await remoteDataSource!.update(dto);
            } else {
              await remoteDataSource!.save(dto);
            }
          } catch (e) {
            // Continua com os próximos mesmo se um falhar
          }
        }
      } catch (e) {
        // Se falhar, mantém apenas no local
      }
    }
  }
}

