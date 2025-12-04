import '../../domain/entities/prova.dart';
import '../../domain/entities/revisao.dart';
import '../../services/auth_service.dart';
import '../models/prova_dto.dart';
import '../models/revisao_dto.dart';
import 'revisao_mapper.dart';

class ProvaMapper {
  static Prova toEntity(ProvaDto dto) {
    return Prova(
      id: dto.id,
      nome: dto.nome,
      disciplinaId: dto.disciplinaId,
      disciplinaNome: dto.disciplinaNome,
      dataProva: DateTime.parse(dto.dataProva),
      descricao: dto.descricao,
      revisoes: dto.revisoes.map((r) => RevisaoMapper.toEntity(r)).toList(),
      cor: dto.cor,
    );
  }

  static ProvaDto toDto(Prova entity) {
    return ProvaDto(
      id: entity.id,
      userId: AuthService.currentUserId, // Incluir user_id do usuário autenticado
      nome: entity.nome,
      disciplinaId: entity.disciplinaId,
      disciplinaNome: entity.disciplinaNome,
      dataProva: entity.dataProva.toIso8601String(),
      descricao: entity.descricao,
      revisoes: entity.revisoes.map((r) => RevisaoMapper.toDto(r)).toList(),
      cor: entity.cor,
    );
  }
}

