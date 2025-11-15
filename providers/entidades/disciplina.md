# Prompt: Construção da Entidade Disciplina

## Contexto

A entidade `Disciplina` representa uma matéria/disciplina acadêmica no ProvaPlanner. Atualmente está na estrutura antiga (`lib/models/`) e possui métodos de serialização JSON integrados, o que não segue o padrão Clean Architecture.

## Localização Atual

- **Entity**: `lib/models/disciplina.dart`

## Estrutura Atual da Entidade

### Campos Obrigatórios
- `id` (String): Identificador único da disciplina
- `nome` (String): Nome da disciplina
- `professor` (String): Nome do professor
- `periodo` (String): Período letivo
- `dataCriacao` (DateTime): Data de criação

### Campos Opcionais (com valores padrão)
- `descricao` (String): Descrição da disciplina (padrão: `''`)
- `cor` (Color): Cor para identificação visual (padrão: `Colors.blue`)

### Métodos Atuais
- `toJson()`: Serialização para JSON
- `fromJson()`: Desserialização de JSON
- `copyWith()`: Cria cópia com campos modificados

## Problemas da Estrutura Atual

1. ⚠️ **Dependência do Flutter**: A entidade usa `Color` do Flutter, violando a regra de que entidades do domínio devem ser puras
2. ⚠️ **Serialização na Entity**: Métodos `toJson`/`fromJson` devem estar no DTO, não na Entity
3. ⚠️ **Estrutura Antiga**: Não segue Clean Architecture

## Regras de Construção (Estrutura Atual)

### 1. Entity Atual

```dart
// lib/models/disciplina.dart
import 'package:flutter/material.dart';

class Disciplina {
  final String id;
  final String nome;
  final String professor;
  final String periodo;
  final String descricao;
  final Color cor;  // ⚠️ Dependência do Flutter
  final DateTime dataCriacao;

  Disciplina({...});

  // ⚠️ Serialização na Entity (deveria estar no DTO)
  Map<String, dynamic> toJson() { ... }
  factory Disciplina.fromJson(Map<String, dynamic> json) { ... }

  Disciplina copyWith({...});
}
```

## Migração para Clean Architecture

### 1. Entity (Domain Layer) - Sem Flutter

```dart
// lib/domain/entities/disciplina.dart
class Disciplina {
  final String id;
  final String nome;
  final String professor;
  final String periodo;
  final String descricao;
  final int cor;  // ARGB32 como int, não Color
  final DateTime dataCriacao;

  Disciplina({
    required this.id,
    required this.nome,
    required this.professor,
    required this.periodo,
    this.descricao = '',
    required this.cor,  // int ARGB32
    required this.dataCriacao,
  });

  Disciplina copyWith({
    String? id,
    String? nome,
    String? professor,
    String? periodo,
    String? descricao,
    int? cor,
    DateTime? dataCriacao,
  }) {
    return Disciplina(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      professor: professor ?? this.professor,
      periodo: periodo ?? this.periodo,
      descricao: descricao ?? this.descricao,
      cor: cor ?? this.cor,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }
}
```

**Mudanças:**
- ✅ Remover dependência do Flutter
- ✅ `Color` → `int` (ARGB32)
- ✅ Remover `toJson`/`fromJson` (vai para DTO)

### 2. DTO (Data Layer)

```dart
// lib/data/models/disciplina_dto.dart
class DisciplinaDto {
  final String id;
  final String nome;
  final String professor;
  final String periodo;
  final String descricao;
  final int cor;  // ARGB32 como int
  final String dataCriacao;  // ISO8601 string

  DisciplinaDto({
    required this.id,
    required this.nome,
    required this.professor,
    required this.periodo,
    this.descricao = '',
    required this.cor,
    required this.dataCriacao,
  });

  factory DisciplinaDto.fromJson(Map<String, dynamic> json) {
    return DisciplinaDto(
      id: json['id'],
      nome: json['nome'],
      professor: json['professor'],
      periodo: json['periodo'],
      descricao: json['descricao'] ?? '',
      cor: json['cor'],
      dataCriacao: json['dataCriacao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'professor': professor,
      'periodo': periodo,
      'descricao': descricao,
      'cor': cor,
      'dataCriacao': dataCriacao,
    };
  }
}
```

### 3. Mapper (Data Layer)

```dart
// lib/data/mappers/disciplina_mapper.dart
import '../../domain/entities/disciplina.dart';
import '../models/disciplina_dto.dart';

class DisciplinaMapper {
  static Disciplina toEntity(DisciplinaDto dto) {
    return Disciplina(
      id: dto.id,
      nome: dto.nome,
      professor: dto.professor,
      periodo: dto.periodo,
      descricao: dto.descricao,
      cor: dto.cor,
      dataCriacao: DateTime.parse(dto.dataCriacao),
    );
  }

  static DisciplinaDto toDto(Disciplina entity) {
    return DisciplinaDto(
      id: entity.id,
      nome: entity.nome,
      professor: entity.professor,
      periodo: entity.periodo,
      descricao: entity.descricao,
      cor: entity.cor,
      dataCriacao: entity.dataCriacao.toIso8601String(),
    );
  }
}
```

### 4. Extension para UI (Presentation Layer)

```dart
// lib/presentation/extensions/disciplina_extension.dart
import 'package:flutter/material.dart';
import '../../domain/entities/disciplina.dart';

extension DisciplinaExtension on Disciplina {
  Color get color {
    return Color(cor);
  }

  Color get colorWithOpacity {
    return Color(cor).withOpacity(0.1);
  }
}
```

**Uso na UI:**
```dart
// Na tela/widget
final disciplina = Disciplina(...);
Container(
  color: disciplina.color,  // Usa a extension
  child: Text(disciplina.nome),
)
```

### 5. Repository Interface (Domain Layer)

```dart
// lib/domain/repositories/disciplina_repository.dart
abstract class DisciplinaRepository {
  Future<List<Disciplina>> getAllDisciplinas();
  Future<Disciplina?> getDisciplinaById(String id);
  Future<void> addDisciplina(Disciplina disciplina);
  Future<void> updateDisciplina(Disciplina disciplina);
  Future<void> deleteDisciplina(String id);
}
```

### 6. Repository Implementation (Data Layer)

```dart
// lib/data/repositories/disciplina_repository_impl.dart
class DisciplinaRepositoryImpl implements DisciplinaRepository {
  final DisciplinaLocalDataSource dataSource;

  DisciplinaRepositoryImpl(this.dataSource);

  @override
  Future<List<Disciplina>> getAllDisciplinas() async {
    final dtos = await dataSource.getAllDisciplinas();
    return dtos.map((dto) => DisciplinaMapper.toEntity(dto)).toList();
  }
  // ... outros métodos
}
```

### 7. Data Source (Data Layer)

```dart
// lib/data/datasources/disciplina_local_datasource.dart
abstract class DisciplinaLocalDataSource {
  Future<List<DisciplinaDto>> getAllDisciplinas();
  Future<DisciplinaDto?> getDisciplinaById(String id);
  Future<void> addDisciplina(DisciplinaDto dto);
  Future<void> updateDisciplina(DisciplinaDto dto);
  Future<void> deleteDisciplina(String id);
}
```

### 8. Use Cases (Domain Layer)

```dart
// lib/domain/usecases/get_all_disciplinas.dart
class GetAllDisciplinas {
  final DisciplinaRepository repository;

  GetAllDisciplinas(this.repository);

  Future<List<Disciplina>> call() {
    return repository.getAllDisciplinas();
  }
}

// lib/domain/usecases/add_disciplina.dart
class AddDisciplina {
  final DisciplinaRepository repository;

  AddDisciplina(this.repository);

  Future<void> call(Disciplina disciplina) {
    return repository.addDisciplina(disciplina);
  }
}

// ... outros use cases
```

## Conversão de Color para int

### Na Entity (Domain)
```dart
// Armazenar como int
final cor = Colors.blue.value;  // ARGB32
```

### Na Extension (Presentation)
```dart
// Converter de int para Color
Color get color => Color(cor);
```

## Checklist de Migração

- [ ] Criar Entity em `lib/domain/entities/disciplina.dart` sem Flutter
- [ ] Converter `Color` para `int` (ARGB32) na Entity
- [ ] Criar DTO em `lib/data/models/disciplina_dto.dart`
- [ ] Mover `toJson`/`fromJson` para o DTO
- [ ] Criar Mapper em `lib/data/mappers/disciplina_mapper.dart`
- [ ] Criar Extension em `lib/presentation/extensions/disciplina_extension.dart` para Color
- [ ] Criar Repository interface em `lib/domain/repositories/`
- [ ] Criar Repository implementation em `lib/data/repositories/`
- [ ] Criar Data source em `lib/data/datasources/`
- [ ] Criar Use cases em `lib/domain/usecases/`
- [ ] Atualizar todos os imports no projeto
- [ ] Atualizar código que usa `Color` para usar extension
- [ ] Testes atualizados

## Exemplo de Uso Completo

```dart
// Criar disciplina (sem Flutter na Entity)
final disciplina = Disciplina(
  id: '1',
  nome: 'Matemática',
  professor: 'Prof. Silva',
  periodo: '2024.1',
  descricao: 'Álgebra Linear',
  cor: Colors.blue.value,  // Converter Color para int
  dataCriacao: DateTime.now(),
);

// Usar na UI (com extension)
Container(
  color: disciplina.color,  // Extension converte int para Color
  child: Text(disciplina.nome),
)

// Atualizar
final atualizada = disciplina.copyWith(
  cor: Colors.red.value,
);
```

## Referências

- Padrão de referência: `DailyGoal` (estrutura nova)
- Arquitetura: Clean Architecture
- Padrão: Repository Pattern + Extension Pattern para UI

