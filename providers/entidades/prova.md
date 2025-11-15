# Prompt: Construção da Entidade Prova

## Contexto

A entidade `Prova` representa uma prova/exame acadêmico no ProvaPlanner. Ela possui uma entidade aninhada `Revisao` que representa as revisões programadas antes da prova. Atualmente está na estrutura antiga (`lib/models/`) e precisa ser migrada para Clean Architecture.

## Localização Atual

- **Entity**: `lib/models/prova.dart` (contém `Prova` e `Revisao`)

## Estrutura Atual da Entidade

### Prova - Campos Obrigatórios
- `id` (String): Identificador único da prova
- `nome` (String): Nome da prova
- `disciplinaId` (String): ID da disciplina associada
- `disciplinaNome` (String): Nome da disciplina (para exibição)
- `dataProva` (DateTime): Data e hora da prova
- `revisoes` (List<Revisao>): Lista de revisões programadas

### Prova - Campos Opcionais
- `descricao` (String): Descrição da prova (padrão: `''`)
- `cor` (Color): Cor para identificação visual (padrão: `Colors.blue`)

### Revisao - Campos Obrigatórios
- `id` (String): Identificador único da revisão
- `data` (DateTime): Data da revisão
- `concluida` (bool): Status de conclusão
- `descricao` (String): Descrição da revisão

### Métodos Especiais
- `Prova.gerarRevisoes(DateTime dataProva)`: Método estático que gera automaticamente 3 revisões distribuídas nos 7 dias anteriores à prova

## Problemas da Estrutura Atual

1. ⚠️ **Dependência do Flutter**: Usa `Color` do Flutter
2. ⚠️ **Serialização na Entity**: Métodos `toJson`/`fromJson` devem estar no DTO
3. ⚠️ **Lógica de Negócio na Entity**: `gerarRevisoes` pode ser um Use Case
4. ⚠️ **Estrutura Antiga**: Não segue Clean Architecture

## Regras de Construção (Estrutura Atual)

### 1. Entity Atual - Prova

```dart
// lib/models/prova.dart
import 'package:flutter/material.dart';

class Prova {
  final String id;
  final String nome;
  final String disciplinaId;
  final String disciplinaNome;
  final DateTime dataProva;
  final String descricao;
  final List<Revisao> revisoes;
  final Color cor;  // ⚠️ Dependência do Flutter

  Prova({...});

  // ⚠️ Lógica de negócio na Entity
  static List<Revisao> gerarRevisoes(DateTime dataProva) { ... }

  // ⚠️ Serialização na Entity
  Map<String, dynamic> toJson() { ... }
  factory Prova.fromJson(Map<String, dynamic> json) { ... }
}
```

### 2. Entity Atual - Revisao

```dart
class Revisao {
  final String id;
  final DateTime data;
  final bool concluida;
  final String descricao;

  Revisao({...});

  // ⚠️ Serialização na Entity
  Map<String, dynamic> toJson() { ... }
  factory Revisao.fromJson(Map<String, dynamic> json) { ... }

  Revisao copyWith({...});
}
```

## Migração para Clean Architecture

### 1. Entity - Prova (Domain Layer)

```dart
// lib/domain/entities/prova.dart
class Prova {
  final String id;
  final String nome;
  final String disciplinaId;
  final String disciplinaNome;
  final DateTime dataProva;
  final String descricao;
  final List<Revisao> revisoes;
  final int cor;  // ARGB32 como int

  Prova({
    required this.id,
    required this.nome,
    required this.disciplinaId,
    required this.disciplinaNome,
    required this.dataProva,
    this.descricao = '',
    required this.revisoes,
    required this.cor,
  });

  Prova copyWith({
    String? id,
    String? nome,
    String? disciplinaId,
    String? disciplinaNome,
    DateTime? dataProva,
    String? descricao,
    List<Revisao>? revisoes,
    int? cor,
  }) {
    return Prova(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      disciplinaId: disciplinaId ?? this.disciplinaId,
      disciplinaNome: disciplinaNome ?? this.disciplinaNome,
      dataProva: dataProva ?? this.dataProva,
      descricao: descricao ?? this.descricao,
      revisoes: revisoes ?? this.revisoes,
      cor: cor ?? this.cor,
    );
  }
}
```

**Mudanças:**
- ✅ Remover dependência do Flutter (`Color` → `int`)
- ✅ Remover `toJson`/`fromJson`
- ✅ Remover `gerarRevisoes` (vai para Use Case)

### 2. Entity - Revisao (Domain Layer)

```dart
// lib/domain/entities/revisao.dart
class Revisao {
  final String id;
  final DateTime data;
  final bool concluida;
  final String descricao;

  Revisao({
    required this.id,
    required this.data,
    required this.concluida,
    required this.descricao,
  });

  Revisao copyWith({
    String? id,
    DateTime? data,
    bool? concluida,
    String? descricao,
  }) {
    return Revisao(
      id: id ?? this.id,
      data: data ?? this.data,
      concluida: concluida ?? this.concluida,
      descricao: descricao ?? this.descricao,
    );
  }
}
```

**Mudanças:**
- ✅ Remover `toJson`/`fromJson` (vai para DTO)
- ✅ Manter `copyWith()` (padrão do projeto)

### 3. DTO - Prova (Data Layer)

```dart
// lib/data/models/prova_dto.dart
class ProvaDto {
  final String id;
  final String nome;
  final String disciplinaId;
  final String disciplinaNome;
  final String dataProva;  // ISO8601 string
  final String descricao;
  final List<RevisaoDto> revisoes;
  final int cor;  // ARGB32

  ProvaDto({...});

  factory ProvaDto.fromJson(Map<String, dynamic> json) {
    return ProvaDto(
      id: json['id'],
      nome: json['nome'],
      disciplinaId: json['disciplinaId'] ?? json['disciplina'] ?? '',
      disciplinaNome: json['disciplinaNome'] ?? json['disciplina'] ?? '',
      dataProva: json['dataProva'],
      descricao: json['descricao'] ?? '',
      revisoes: (json['revisoes'] as List)
          .map((r) => RevisaoDto.fromJson(r))
          .toList(),
      cor: json['cor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'disciplinaId': disciplinaId,
      'disciplinaNome': disciplinaNome,
      'dataProva': dataProva,
      'descricao': descricao,
      'revisoes': revisoes.map((r) => r.toJson()).toList(),
      'cor': cor,
    };
  }
}
```

### 4. DTO - Revisao (Data Layer)

```dart
// lib/data/models/revisao_dto.dart
class RevisaoDto {
  final String id;
  final String data;  // ISO8601 string
  final bool concluida;
  final String descricao;

  RevisaoDto({...});

  factory RevisaoDto.fromJson(Map<String, dynamic> json) {
    return RevisaoDto(
      id: json['id'],
      data: json['data'],
      concluida: json['concluida'],
      descricao: json['descricao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
      'concluida': concluida,
      'descricao': descricao,
    };
  }
}
```

### 5. Mapper - Prova (Data Layer)

```dart
// lib/data/mappers/prova_mapper.dart
import '../../domain/entities/prova.dart';
import '../../domain/entities/revisao.dart';
import '../models/prova_dto.dart';
import '../models/revisao_dto.dart';

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
```

### 6. Mapper - Revisao (Data Layer)

```dart
// lib/data/mappers/revisao_mapper.dart
import '../../domain/entities/revisao.dart';
import '../models/revisao_dto.dart';

class RevisaoMapper {
  static Revisao toEntity(RevisaoDto dto) {
    return Revisao(
      id: dto.id,
      data: DateTime.parse(dto.data),
      concluida: dto.concluida,
      descricao: dto.descricao,
    );
  }

  static RevisaoDto toDto(Revisao entity) {
    return RevisaoDto(
      id: entity.id,
      data: entity.data.toIso8601String(),
      concluida: entity.concluida,
      descricao: entity.descricao,
    );
  }
}
```

### 7. Use Case - Gerar Revisoes

```dart
// lib/domain/usecases/gerar_revisoes_prova.dart
import '../entities/revisao.dart';

class GerarRevisoesProva {
  List<Revisao> call(DateTime dataProva) {
    final revisoes = <Revisao>[];
    final hoje = DateTime.now();
    final diasRestantes = dataProva.difference(hoje).inDays;

    if (diasRestantes >= 7) {
      // Distribui nos últimos 7 dias
      final dataInicio = dataProva.subtract(const Duration(days: 7));
      revisoes.add(Revisao(
        id: '${dataProva.millisecondsSinceEpoch}_1',
        data: dataInicio.add(const Duration(days: 1)),
        concluida: false,
        descricao: 'Primeira revisão - Conceitos básicos',
      ));
      // ... outras revisões
    } else if (diasRestantes >= 3) {
      // Distribui nos dias restantes
      // ... lógica
    } else {
      // Revisões para os dias restantes
      // ... lógica
    }

    return revisoes;
  }
}
```

### 8. Extension para UI (Presentation Layer)

```dart
// lib/presentation/extensions/prova_extension.dart
import 'package:flutter/material.dart';
import '../../domain/entities/prova.dart';

extension ProvaExtension on Prova {
  Color get color {
    return Color(cor);
  }

  Color get colorWithOpacity {
    return Color(cor).withOpacity(0.1);
  }
}
```

### 9. Repository Interface (Domain Layer)

```dart
// lib/domain/repositories/prova_repository.dart
abstract class ProvaRepository {
  Future<List<Prova>> getAllProvas();
  Future<Prova?> getProvaById(String id);
  Future<List<Prova>> getProvasByDate(DateTime date);
  Future<void> addProva(Prova prova);
  Future<void> updateProva(Prova prova);
  Future<void> deleteProva(String id);
  Future<void> updateRevisao(String provaId, Revisao revisao);
}
```

## Checklist de Migração

- [ ] Criar Entity `Prova` em `lib/domain/entities/prova.dart` sem Flutter
- [ ] Criar Entity `Revisao` em `lib/domain/entities/revisao.dart`
- [ ] Converter `Color` para `int` (ARGB32) na Entity Prova
- [ ] Criar DTOs em `lib/data/models/` (prova_dto.dart, revisao_dto.dart)
- [ ] Mover `toJson`/`fromJson` para os DTOs
- [ ] Criar Mappers em `lib/data/mappers/` (prova_mapper.dart, revisao_mapper.dart)
- [ ] Criar Use Case `GerarRevisoesProva` em `lib/domain/usecases/`
- [ ] Criar Extension em `lib/presentation/extensions/prova_extension.dart` para Color
- [ ] Criar Repository interface em `lib/domain/repositories/`
- [ ] Criar Repository implementation em `lib/data/repositories/`
- [ ] Criar Data source em `lib/data/datasources/`
- [ ] Criar Use cases adicionais em `lib/domain/usecases/`
- [ ] Atualizar todos os imports no projeto
- [ ] Atualizar código que usa `Color` para usar extension
- [ ] Atualizar código que usa `gerarRevisoes` para usar Use Case
- [ ] Testes atualizados

## Exemplo de Uso Completo

```dart
// Gerar revisões usando Use Case
final gerarRevisoes = GerarRevisoesProva();
final revisoes = gerarRevisoes.call(dataProva);

// Criar prova
final prova = Prova(
  id: '1',
  nome: 'Prova Final',
  disciplinaId: 'disc1',
  disciplinaNome: 'Matemática',
  dataProva: DateTime(2024, 12, 15),
  descricao: 'Prova de cálculo',
  revisoes: revisoes,
  cor: Colors.blue.value,  // Converter Color para int
);

// Usar na UI (com extension)
Container(
  color: prova.color,  // Extension converte int para Color
  child: Text(prova.nome),
)

// Atualizar revisão
final revisaoAtualizada = prova.revisoes[0].copyWith(concluida: true);
final provaAtualizada = prova.copyWith(
  revisoes: [
    revisaoAtualizada,
    ...prova.revisoes.skip(1),
  ],
);
```

## Referências

- Padrão de referência: `DailyGoal` (estrutura nova)
- Arquitetura: Clean Architecture
- Padrão: Repository Pattern + Extension Pattern para UI
- Lógica de negócio: Use Cases separados

