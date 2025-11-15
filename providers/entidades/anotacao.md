# Prompt: Construção da Entidade Anotacao

## Contexto

A entidade `Anotacao` representa uma anotação/nota do estudante no ProvaPlanner. Atualmente está na estrutura antiga (`lib/models/`) e precisa ser migrada para a Clean Architecture seguindo o padrão da entidade `DailyGoal`.

## Localização Atual

- **Entity**: `lib/models/entities/anotacao.dart`
- **DTO**: `lib/models/dtos/anotacao_dto.dart`
- **Mapper**: `lib/models/mappers/anotacao_mapper.dart`

## Estrutura Atual da Entidade

### Campos Obrigatórios
- `id` (String): Identificador único da anotação
- `titulo` (String): Título da anotação
- `descricao` (String): Conteúdo da anotação
- `dataCriacao` (DateTime): Data de criação da anotação

## Regras de Construção (Estrutura Atual)

### 1. Entity

```dart
// lib/models/entities/anotacao.dart
class Anotacao {
  final String id;
  final String titulo;
  final String descricao;
  final DateTime dataCriacao;

  Anotacao({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.dataCriacao,
  });
}
```

**Observações:**
- ⚠️ Falta implementar `copyWith()` (padrão do projeto)
- ✅ Todos os campos são `final` (imutável)
- ✅ Sem dependências do Flutter

### 2. DTO

```dart
// lib/models/dtos/anotacao_dto.dart
class AnotacaoDto {
  final String id;
  final String titulo;
  final String descricao;
  final String dataCriacao;  // ISO8601 string

  AnotacaoDto({...});

  factory AnotacaoDto.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
}
```

### 3. Mapper

```dart
// lib/models/mappers/anotacao_mapper.dart
class AnotacaoMapper {
  static Anotacao toEntity(AnotacaoDto dto) {
    return Anotacao(
      id: dto.id,
      titulo: dto.titulo,
      descricao: dto.descricao,
      dataCriacao: DateTime.parse(dto.dataCriacao),
    );
  }

  static AnotacaoDto toDto(Anotacao entity) {
    return AnotacaoDto(
      id: entity.id,
      titulo: entity.titulo,
      descricao: entity.descricao,
      dataCriacao: entity.dataCriacao.toIso8601String(),
    );
  }
}
```

## Melhorias Necessárias

### 1. Adicionar `copyWith()` à Entity

```dart
Anotacao copyWith({
  String? id,
  String? titulo,
  String? descricao,
  DateTime? dataCriacao,
}) {
  return Anotacao(
    id: id ?? this.id,
    titulo: titulo ?? this.titulo,
    descricao: descricao ?? this.descricao,
    dataCriacao: dataCriacao ?? this.dataCriacao,
  );
}
```

### 2. Campos Opcionais (Considerar)

Dependendo do uso, considerar:
- `dataModificacao` (DateTime?): Data da última modificação
- `tags` (List<String>): Tags para categorização
- `cor` (int?): Cor para identificação visual

## Migração para Clean Architecture

### 1. Mover Entity
```
lib/models/entities/anotacao.dart
  → lib/domain/entities/anotacao.dart
```

### 2. Mover DTO
```
lib/models/dtos/anotacao_dto.dart
  → lib/data/models/anotacao_dto.dart
```

### 3. Mover Mapper
```
lib/models/mappers/anotacao_mapper.dart
  → lib/data/mappers/anotacao_mapper.dart
```

### 4. Criar Repository Interface

```dart
// lib/domain/repositories/anotacao_repository.dart
abstract class AnotacaoRepository {
  Future<List<Anotacao>> getAllAnotacoes();
  Future<Anotacao?> getAnotacaoById(String id);
  Future<List<Anotacao>> getAnotacoesByDate(DateTime date);
  Future<void> addAnotacao(Anotacao anotacao);
  Future<void> updateAnotacao(Anotacao anotacao);
  Future<void> deleteAnotacao(String id);
}
```

### 5. Criar Repository Implementation

```dart
// lib/data/repositories/anotacao_repository_impl.dart
class AnotacaoRepositoryImpl implements AnotacaoRepository {
  final AnotacaoLocalDataSource dataSource;

  AnotacaoRepositoryImpl(this.dataSource);

  @override
  Future<List<Anotacao>> getAllAnotacoes() async {
    final dtos = await dataSource.getAllAnotacoes();
    return dtos.map((dto) => AnotacaoMapper.toEntity(dto)).toList();
  }
  // ... outros métodos
}
```

### 6. Criar Data Source

```dart
// lib/data/datasources/anotacao_local_datasource.dart
abstract class AnotacaoLocalDataSource {
  Future<List<AnotacaoDto>> getAllAnotacoes();
  Future<AnotacaoDto?> getAnotacaoById(String id);
  Future<List<AnotacaoDto>> getAnotacoesByDate(DateTime date);
  Future<void> addAnotacao(AnotacaoDto dto);
  Future<void> updateAnotacao(AnotacaoDto dto);
  Future<void> deleteAnotacao(String id);
}
```

### 7. Criar Use Cases

```dart
// lib/domain/usecases/get_all_anotacoes.dart
class GetAllAnotacoes {
  final AnotacaoRepository repository;

  GetAllAnotacoes(this.repository);

  Future<List<Anotacao>> call() {
    return repository.getAllAnotacoes();
  }
}

// lib/domain/usecases/add_anotacao.dart
class AddAnotacao {
  final AnotacaoRepository repository;

  AddAnotacao(this.repository);

  Future<void> call(Anotacao anotacao) {
    return repository.addAnotacao(anotacao);
  }
}

// lib/domain/usecases/update_anotacao.dart
class UpdateAnotacao {
  final AnotacaoRepository repository;

  UpdateAnotacao(this.repository);

  Future<void> call(Anotacao anotacao) {
    return repository.updateAnotacao(anotacao);
  }
}

// lib/domain/usecases/delete_anotacao.dart
class DeleteAnotacao {
  final AnotacaoRepository repository;

  DeleteAnotacao(this.repository);

  Future<void> call(String id) {
    return repository.deleteAnotacao(id);
  }
}

// lib/domain/usecases/get_anotacoes_by_date.dart
class GetAnotacoesByDate {
  final AnotacaoRepository repository;

  GetAnotacoesByDate(this.repository);

  Future<List<Anotacao>> call(DateTime date) {
    return repository.getAnotacoesByDate(date);
  }
}
```

## Checklist de Implementação

### Estrutura Atual
- [ ] Entity tem todos os campos necessários
- [ ] Entity implementa `copyWith()` (adicionar se faltar)
- [ ] DTO tem serialização JSON completa
- [ ] Mapper converte corretamente entre Entity e DTO
- [ ] Imports não incluem `/lib` no caminho

### Migração para Clean Architecture
- [ ] Entity movida para `lib/domain/entities/`
- [ ] DTO movido para `lib/data/models/`
- [ ] Mapper movido para `lib/data/mappers/`
- [ ] Repository interface criada em `lib/domain/repositories/`
- [ ] Repository implementation criada em `lib/data/repositories/`
- [ ] Data source criado em `lib/data/datasources/`
- [ ] Use cases criados em `lib/domain/usecases/`
- [ ] Todos os imports atualizados no projeto
- [ ] Testes atualizados com novos imports

## Exemplo de Uso

```dart
// Criar anotação
final anotacao = Anotacao(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  titulo: 'Conceitos importantes',
  descricao: 'Fórmula de Bhaskara: x = (-b ± √Δ) / 2a',
  dataCriacao: DateTime.now(),
);

// Atualizar usando copyWith (após implementar)
final anotacaoAtualizada = anotacao.copyWith(
  descricao: 'Fórmula de Bhaskara: x = (-b ± √Δ) / 2a\n\nOnde Δ = b² - 4ac',
);

// Serializar para JSON
final dto = AnotacaoMapper.toDto(anotacao);
final json = dto.toJson();

// Desserializar de JSON
final dtoFromJson = AnotacaoDto.fromJson(json);
final anotacaoFromJson = AnotacaoMapper.toEntity(dtoFromJson);
```

## Referências

- Padrão de referência: `DailyGoal` (estrutura nova completa)
- Arquitetura alvo: Clean Architecture
- Padrão: Repository Pattern

