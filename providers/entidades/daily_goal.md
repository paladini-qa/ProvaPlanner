# Prompt: Construção da Entidade DailyGoal

## Contexto

A entidade `DailyGoal` representa uma meta diária de estudos no ProvaPlanner. Ela faz parte da nova arquitetura Clean Architecture e está completamente implementada seguindo os padrões do projeto.

## Localização

- **Entity**: `lib/domain/entities/daily_goal.dart`
- **DTO**: `lib/data/models/daily_goal_dto.dart`
- **Mapper**: `lib/data/mappers/daily_goal_mapper.dart`
- **Repository Interface**: `lib/domain/repositories/daily_goal_repository.dart`
- **Repository Implementation**: `lib/data/repositories/daily_goal_repository_impl.dart`
- **Data Source**: `lib/data/datasources/daily_goal_local_datasource.dart`
- **Use Cases**: `lib/domain/usecases/` (add, delete, get, get_by_date, get_next_7_days, update)

## Estrutura da Entidade

### Campos Obrigatórios

- `id` (String): Identificador único da meta
- `titulo` (String): Título da meta diária
- `descricao` (String): Descrição detalhada da meta
- `data` (DateTime): Data da meta

### Campos Opcionais (com valores padrão)

- `concluida` (bool): Status de conclusão (padrão: `false`)
- `prioridade` (PrioridadeMeta): Prioridade da meta (padrão: `PrioridadeMeta.media`)

### Métodos

- `copyWith()`: Cria uma cópia da entidade com campos modificados
- `prioridadeTexto` (getter): Retorna a representação textual da prioridade

## Regras de Construção

### 1. Entity (Domain Layer)

```dart
// lib/domain/entities/daily_goal.dart
import 'prioridade_meta.dart';

class DailyGoal {
  final String id;
  final String titulo;
  final String descricao;
  final DateTime data;
  final bool concluida;
  final PrioridadeMeta prioridade;

  DailyGoal({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.data,
    this.concluida = false,
    this.prioridade = PrioridadeMeta.media,
  });

  // Implementar copyWith obrigatoriamente
  DailyGoal copyWith({...});

  // Getters computados quando necessário
  String get prioridadeTexto { ... }
}
```

**Regras:**

- ✅ NÃO deve ter dependências do Flutter (apenas Dart puro)
- ✅ Todos os campos devem ser `final`
- ✅ Campos opcionais devem ter valores padrão explícitos
- ✅ Deve implementar `copyWith()` para imutabilidade
- ✅ Getters computados devem ser simples e sem efeitos colaterais

### 2. DTO (Data Layer)

```dart
// lib/data/models/daily_goal_dto.dart
class DailyGoalDto {
  final String id;
  final String titulo;
  final String descricao;
  final String data;  // ISO8601 string
  final bool concluida;
  final String prioridade;  // String, não enum

  DailyGoalDto({...});

  factory DailyGoalDto.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
}
```

**Regras:**

- ✅ Datas devem ser serializadas como strings ISO8601
- ✅ Enums devem ser serializados como strings
- ✅ Deve ter `fromJson` e `toJson` para serialização
- ✅ Valores padrão devem ser tratados no `fromJson`

### 3. Mapper (Data Layer)

```dart
// lib/data/mappers/daily_goal_mapper.dart
class DailyGoalMapper {
  static DailyGoal toEntity(DailyGoalDto dto) { ... }
  static DailyGoalDto toDto(DailyGoal entity) { ... }

  // Métodos auxiliares privados para conversão de tipos
  static PrioridadeMeta _prioridadeFromString(String prioridade) { ... }
  static String _prioridadeToString(PrioridadeMeta prioridade) { ... }
}
```

**Regras:**

- ✅ Métodos devem ser `static`
- ✅ Conversões de tipos complexos devem ter métodos auxiliares privados
- ✅ Tratamento de valores padrão/inválidos deve ser robusto
- ✅ Nome dos métodos: `toEntity` e `toDto`

### 4. Repository Interface (Domain Layer)

```dart
// lib/domain/repositories/daily_goal_repository.dart
abstract class DailyGoalRepository {
  Future<List<DailyGoal>> getDailyGoals();
  Future<List<DailyGoal>> getDailyGoalsByDate(DateTime date);
  Future<List<DailyGoal>> getDailyGoalsNext7Days();
  Future<void> addDailyGoal(DailyGoal goal);
  Future<void> updateDailyGoal(DailyGoal goal);
  Future<void> deleteDailyGoal(String id);
}
```

**Regras:**

- ✅ Deve ser `abstract class`
- ✅ Retorna apenas entidades do domínio (nunca DTOs)
- ✅ Métodos devem ser `Future` para operações assíncronas
- ✅ Nomes devem ser descritivos e seguir padrão de nomenclatura

### 5. Repository Implementation (Data Layer)

```dart
// lib/data/repositories/daily_goal_repository_impl.dart
class DailyGoalRepositoryImpl implements DailyGoalRepository {
  final DailyGoalLocalDataSource dataSource;

  DailyGoalRepositoryImpl(this.dataSource);

  @override
  Future<List<DailyGoal>> getDailyGoals() async {
    final dtos = await dataSource.getDailyGoals();
    return dtos.map((dto) => DailyGoalMapper.toEntity(dto)).toList();
  }
  // ... outros métodos
}
```

**Regras:**

- ✅ Deve implementar a interface do repositório
- ✅ Deve usar o mapper para converter DTOs em Entities
- ✅ Deve injetar dependências via construtor
- ✅ Não deve conter lógica de negócio (apenas orquestração)

### 6. Data Source (Data Layer)

```dart
// lib/data/datasources/daily_goal_local_datasource.dart
abstract class DailyGoalLocalDataSource {
  Future<List<DailyGoalDto>> getDailyGoals();
  Future<void> addDailyGoal(DailyGoalDto dto);
  // ... outros métodos
}
```

**Regras:**

- ✅ Trabalha apenas com DTOs
- ✅ Abstrai a fonte de dados (SharedPreferences, SQLite, etc.)
- ✅ Deve ser `abstract class` para permitir diferentes implementações

### 7. Use Cases (Domain Layer)

```dart
// lib/domain/usecases/get_daily_goals.dart
class GetDailyGoals {
  final DailyGoalRepository repository;

  GetDailyGoals(this.repository);

  Future<List<DailyGoal>> call() {
    return repository.getDailyGoals();
  }
}
```

**Regras:**

- ✅ Uma classe por caso de uso
- ✅ Método `call()` para execução
- ✅ Injeta dependências via construtor
- ✅ Retorna apenas entidades do domínio

## Exemplo de Uso Completo

```dart
// Criar uma nova meta
final goal = DailyGoal(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  titulo: 'Revisar capítulo 5',
  descricao: 'Ler e fazer exercícios do capítulo 5 de Matemática',
  data: DateTime.now(),
  prioridade: PrioridadeMeta.alta,
);

// Atualizar usando copyWith
final updatedGoal = goal.copyWith(concluida: true);

// Usar no repositório
final repository = DailyGoalRepositoryImpl(dataSource);
await repository.addDailyGoal(goal);
```

## Checklist de Implementação

Ao criar ou modificar a entidade DailyGoal, verifique:

- [ ] Entity está em `lib/domain/entities/` sem dependências do Flutter
- [ ] DTO está em `lib/data/models/` com serialização JSON
- [ ] Mapper está em `lib/data/mappers/` com métodos `toEntity` e `toDto`
- [ ] Repository interface está em `lib/domain/repositories/`
- [ ] Repository implementation está em `lib/data/repositories/`
- [ ] Data source está em `lib/data/datasources/`
- [ ] Use cases estão em `lib/domain/usecases/`
- [ ] Todos os campos opcionais têm valores padrão
- [ ] Entity implementa `copyWith()`
- [ ] DTO tem `fromJson` e `toJson`
- [ ] Mapper trata conversões de tipos complexos
- [ ] Imports não incluem `/lib` no caminho do pacote

## Migração de Estrutura Antiga

Se estiver migrando uma entidade da estrutura antiga (`lib/models/`) para a nova estrutura:

1. Mover entity de `lib/models/entities/` para `lib/domain/entities/`
2. Mover DTO de `lib/models/dtos/` para `lib/data/models/`
3. Mover mapper de `lib/models/mappers/` para `lib/data/mappers/`
4. Criar repository interface em `lib/domain/repositories/`
5. Criar repository implementation em `lib/data/repositories/`
6. Criar data source em `lib/data/datasources/`
7. Criar use cases em `lib/domain/usecases/`
8. Atualizar todos os imports no projeto

## Referências

- Arquitetura: Clean Architecture
- Padrão: Repository Pattern
- Serialização: JSON com ISO8601 para datas
- Imutabilidade: Todas as entidades são imutáveis
