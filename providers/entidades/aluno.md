# Prompt: Construção da Entidade Aluno

## Contexto

A entidade `Aluno` representa um estudante no ProvaPlanner. Atualmente está na estrutura antiga (`lib/models/`) e precisa ser migrada para a Clean Architecture seguindo o padrão da entidade `DailyGoal`.

## Localização Atual

- **Entity**: `lib/models/entities/aluno.dart`
- **DTO**: `lib/models/dtos/aluno_dto.dart`
- **Mapper**: `lib/models/mappers/aluno_mapper.dart`

## Estrutura Atual da Entidade

### Campos Obrigatórios
- `id` (String): Identificador único do aluno
- `nome` (String): Nome completo do aluno
- `matricula` (String): Número de matrícula
- `email` (String): Email do aluno
- `dataCriacao` (DateTime): Data de criação do registro

## Regras de Construção (Estrutura Atual)

### 1. Entity

```dart
// lib/models/entities/aluno.dart
class Aluno {
  final String id;
  final String nome;
  final String matricula;
  final String email;
  final DateTime dataCriacao;

  Aluno({
    required this.id,
    required this.nome,
    required this.matricula,
    required this.email,
    required this.dataCriacao,
  });
}
```

**Observações:**
- ⚠️ Falta implementar `copyWith()` (padrão do projeto)
- ⚠️ Falta getters computados se necessário
- ✅ Todos os campos são `final` (imutável)
- ✅ Sem dependências do Flutter

### 2. DTO

```dart
// lib/models/dtos/aluno_dto.dart
class AlunoDto {
  final String id;
  final String nome;
  final String matricula;
  final String email;
  final String dataCriacao;  // ISO8601 string

  AlunoDto({...});

  factory AlunoDto.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
}
```

**Observações:**
- ✅ Serialização JSON implementada
- ✅ Data convertida para string ISO8601
- ✅ Métodos `fromJson` e `toJson` presentes

### 3. Mapper

```dart
// lib/models/mappers/aluno_mapper.dart
class AlunoMapper {
  static Aluno toEntity(AlunoDto dto) {
    return Aluno(
      id: dto.id,
      nome: dto.nome,
      matricula: dto.matricula,
      email: dto.email,
      dataCriacao: DateTime.parse(dto.dataCriacao),
    );
  }

  static AlunoDto toDto(Aluno entity) {
    return AlunoDto(
      id: entity.id,
      nome: entity.nome,
      matricula: entity.matricula,
      email: entity.email,
      dataCriacao: entity.dataCriacao.toIso8601String(),
    );
  }
}
```

**Observações:**
- ✅ Métodos `static` implementados
- ✅ Conversão de tipos tratada corretamente
- ✅ Padrão seguido corretamente

## Melhorias Necessárias

### 1. Adicionar `copyWith()` à Entity

```dart
Aluno copyWith({
  String? id,
  String? nome,
  String? matricula,
  String? email,
  DateTime? dataCriacao,
}) {
  return Aluno(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    matricula: matricula ?? this.matricula,
    email: email ?? this.email,
    dataCriacao: dataCriacao ?? this.dataCriacao,
  );
}
```

### 2. Validações (Opcional)

Considerar adicionar validações:
- Email válido
- Matrícula não vazia
- Nome não vazio

## Migração para Clean Architecture

Quando migrar para a nova estrutura, seguir este padrão:

### 1. Mover Entity
```
lib/models/entities/aluno.dart
  → lib/domain/entities/aluno.dart
```

### 2. Mover DTO
```
lib/models/dtos/aluno_dto.dart
  → lib/data/models/aluno_dto.dart
```

### 3. Mover Mapper
```
lib/models/mappers/aluno_mapper.dart
  → lib/data/mappers/aluno_mapper.dart
```

### 4. Criar Repository Interface
```dart
// lib/domain/repositories/aluno_repository.dart
abstract class AlunoRepository {
  Future<Aluno?> getAlunoById(String id);
  Future<List<Aluno>> getAllAlunos();
  Future<void> addAluno(Aluno aluno);
  Future<void> updateAluno(Aluno aluno);
  Future<void> deleteAluno(String id);
}
```

### 5. Criar Repository Implementation
```dart
// lib/data/repositories/aluno_repository_impl.dart
class AlunoRepositoryImpl implements AlunoRepository {
  final AlunoLocalDataSource dataSource;

  AlunoRepositoryImpl(this.dataSource);

  @override
  Future<Aluno?> getAlunoById(String id) async {
    final dto = await dataSource.getAlunoById(id);
    return dto != null ? AlunoMapper.toEntity(dto) : null;
  }
  // ... outros métodos
}
```

### 6. Criar Data Source
```dart
// lib/data/datasources/aluno_local_datasource.dart
abstract class AlunoLocalDataSource {
  Future<AlunoDto?> getAlunoById(String id);
  Future<List<AlunoDto>> getAllAlunos();
  Future<void> addAluno(AlunoDto dto);
  Future<void> updateAluno(AlunoDto dto);
  Future<void> deleteAluno(String id);
}
```

### 7. Criar Use Cases
```dart
// lib/domain/usecases/get_aluno_by_id.dart
class GetAlunoById {
  final AlunoRepository repository;

  GetAlunoById(this.repository);

  Future<Aluno?> call(String id) {
    return repository.getAlunoById(id);
  }
}

// lib/domain/usecases/add_aluno.dart
class AddAluno {
  final AlunoRepository repository;

  AddAluno(this.repository);

  Future<void> call(Aluno aluno) {
    return repository.addAluno(aluno);
  }
}

// ... outros use cases conforme necessário
```

## Checklist de Implementação

Ao trabalhar com a entidade Aluno:

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
// Criar aluno
final aluno = Aluno(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  nome: 'João Silva',
  matricula: '2024001',
  email: 'joao.silva@email.com',
  dataCriacao: DateTime.now(),
);

// Atualizar usando copyWith (após implementar)
final alunoAtualizado = aluno.copyWith(
  email: 'joao.silva.novo@email.com',
);

// Serializar para JSON
final dto = AlunoMapper.toDto(aluno);
final json = dto.toJson();

// Desserializar de JSON
final dtoFromJson = AlunoDto.fromJson(json);
final alunoFromJson = AlunoMapper.toEntity(dtoFromJson);
```

## Referências

- Padrão de referência: `DailyGoal` (estrutura nova completa)
- Arquitetura alvo: Clean Architecture
- Padrão: Repository Pattern

