# Prompt: Construção da Entidade Tarefa

## Contexto

A entidade `Tarefa` representa uma tarefa/atividade do estudante no ProvaPlanner. Atualmente está na estrutura antiga (`lib/models/`) e precisa ser migrada para a Clean Architecture seguindo o padrão da entidade `DailyGoal`.

## Localização Atual

- **Entity**: `lib/models/entities/tarefa.dart`
- **DTO**: `lib/models/dtos/tarefa_dto.dart`
- **Mapper**: `lib/models/mappers/tarefa_mapper.dart`

## Estrutura Atual da Entidade

### Campos Obrigatórios
- `id` (String): Identificador único da tarefa
- `titulo` (String): Título da tarefa
- `descricao` (String): Descrição da tarefa
- `concluida` (bool): Status de conclusão
- `dataCriacao` (DateTime): Data de criação
- `dataConclusao` (DateTime): Data de conclusão

## Observações Importantes

⚠️ **Problema de Design**: A entidade atual exige `dataConclusao` mesmo quando a tarefa não está concluída. Isso pode ser melhorado.

## Regras de Construção (Estrutura Atual)

### 1. Entity

```dart
// lib/models/entities/tarefa.dart
class Tarefa {
  final String id;
  final String titulo;
  final String descricao;
  final bool concluida;
  final DateTime dataCriacao;
  final DateTime dataConclusao;  // ⚠️ Sempre obrigatória

  Tarefa({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.concluida,
    required this.dataCriacao,
    required this.dataConclusao,
  });
}
```

**Observações:**
- ⚠️ Falta implementar `copyWith()` (padrão do projeto)
- ⚠️ `dataConclusao` deveria ser opcional (nullable)
- ✅ Todos os campos são `final` (imutável)
- ✅ Sem dependências do Flutter

### 2. DTO

```dart
// lib/models/dtos/tarefa_dto.dart
class TarefaDto {
  final String id;
  final String titulo;
  final String descricao;
  final bool concluida;
  final String dataCriacao;  // ISO8601 string
  final String dataConclusao;  // ISO8601 string

  TarefaDto({...});

  factory TarefaDto.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
}
```

### 3. Mapper

```dart
// lib/models/mappers/tarefa_mapper.dart
class TarefaMapper {
  static Tarefa toEntity(TarefaDto dto) {
    return Tarefa(
      id: dto.id,
      titulo: dto.titulo,
      descricao: dto.descricao,
      concluida: dto.concluida,
      dataCriacao: DateTime.parse(dto.dataCriacao),
      dataConclusao: DateTime.parse(dto.dataConclusao),
    );
  }

  static TarefaDto toDto(Tarefa entity) {
    return TarefaDto(
      id: entity.id,
      titulo: entity.titulo,
      descricao: entity.descricao,
      concluida: entity.concluida,
      dataCriacao: entity.dataCriacao.toIso8601String(),
      dataConclusao: entity.dataConclusao.toIso8601String(),
    );
  }
}
```

## Melhorias Necessárias

### 1. Adicionar `copyWith()` à Entity

```dart
Tarefa copyWith({
  String? id,
  String? titulo,
  String? descricao,
  bool? concluida,
  DateTime? dataCriacao,
  DateTime? dataConclusao,
}) {
  return Tarefa(
    id: id ?? this.id,
    titulo: titulo ?? this.titulo,
    descricao: descricao ?? this.descricao,
    concluida: concluida ?? this.concluida,
    dataCriacao: dataCriacao ?? this.dataCriacao,
    dataConclusao: dataConclusao ?? this.dataConclusao,
  );
}
```

### 2. Tornar `dataConclusao` Opcional (Recomendado)

```dart
// Versão melhorada
class Tarefa {
  final String id;
  final String titulo;
  final String descricao;
  final bool concluida;
  final DateTime dataCriacao;
  final DateTime? dataConclusao;  // Nullable

  Tarefa({
    required this.id,
    required this.titulo,
    required this.descricao,
    this.concluida = false,
    required this.dataCriacao,
    this.dataConclusao,  // Opcional
  });

  Tarefa copyWith({
    String? id,
    String? titulo,
    String? descricao,
    bool? concluida,
    DateTime? dataCriacao,
    DateTime? dataConclusao,
  }) {
    return Tarefa(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      concluida: concluida ?? this.concluida,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataConclusao: dataConclusao ?? this.dataConclusao,
    );
  }

  // Método helper para marcar como concluída
  Tarefa marcarComoConcluida() {
    return copyWith(
      concluida: true,
      dataConclusao: DateTime.now(),
    );
  }

  // Método helper para marcar como não concluída
  Tarefa marcarComoNaoConcluida() {
    return copyWith(
      concluida: false,
      dataConclusao: null,
    );
  }
}
```

### 3. Atualizar DTO para Suportar Nullable

```dart
class TarefaDto {
  final String id;
  final String titulo;
  final String descricao;
  final bool concluida;
  final String dataCriacao;
  final String? dataConclusao;  // Nullable

  TarefaDto({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.concluida,
    required this.dataCriacao,
    this.dataConclusao,  // Opcional
  });

  factory TarefaDto.fromJson(Map<String, dynamic> json) {
    return TarefaDto(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      concluida: json['concluida'] ?? false,
      dataCriacao: json['dataCriacao'],
      dataConclusao: json['dataConclusao'],  // Pode ser null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'concluida': concluida,
      'dataCriacao': dataCriacao,
      'dataConclusao': dataConclusao,  // Pode ser null
    };
  }
}
```

### 4. Atualizar Mapper

```dart
class TarefaMapper {
  static Tarefa toEntity(TarefaDto dto) {
    return Tarefa(
      id: dto.id,
      titulo: dto.titulo,
      descricao: dto.descricao,
      concluida: dto.concluida,
      dataCriacao: DateTime.parse(dto.dataCriacao),
      dataConclusao: dto.dataConclusao != null
          ? DateTime.parse(dto.dataConclusao!)
          : null,
    );
  }

  static TarefaDto toDto(Tarefa entity) {
    return TarefaDto(
      id: entity.id,
      titulo: entity.titulo,
      descricao: entity.descricao,
      concluida: entity.concluida,
      dataCriacao: entity.dataCriacao.toIso8601String(),
      dataConclusao: entity.dataConclusao?.toIso8601String(),
    );
  }
}
```

## Migração para Clean Architecture

Seguir o mesmo padrão das outras entidades:

1. Mover Entity para `lib/domain/entities/tarefa.dart`
2. Mover DTO para `lib/data/models/tarefa_dto.dart`
3. Mover Mapper para `lib/data/mappers/tarefa_mapper.dart`
4. Criar Repository interface em `lib/domain/repositories/tarefa_repository.dart`
5. Criar Repository implementation em `lib/data/repositories/tarefa_repository_impl.dart`
6. Criar Data source em `lib/data/datasources/tarefa_local_datasource.dart`
7. Criar Use cases em `lib/domain/usecases/`

## Use Cases Sugeridos

```dart
// lib/domain/usecases/marcar_tarefa_concluida.dart
class MarcarTarefaConcluida {
  final TarefaRepository repository;

  MarcarTarefaConcluida(this.repository);

  Future<void> call(String id) async {
    final tarefa = await repository.getTarefaById(id);
    if (tarefa != null) {
      final atualizada = tarefa.marcarComoConcluida();
      await repository.updateTarefa(atualizada);
    }
  }
}

// lib/domain/usecases/marcar_tarefa_nao_concluida.dart
class MarcarTarefaNaoConcluida {
  final TarefaRepository repository;

  MarcarTarefaNaoConcluida(this.repository);

  Future<void> call(String id) async {
    final tarefa = await repository.getTarefaById(id);
    if (tarefa != null) {
      final atualizada = tarefa.marcarComoNaoConcluida();
      await repository.updateTarefa(atualizada);
    }
  }
}
```

## Checklist de Implementação

### Estrutura Atual
- [ ] Entity tem todos os campos necessários
- [ ] Entity implementa `copyWith()` (adicionar se faltar)
- [ ] Considerar tornar `dataConclusao` nullable
- [ ] Adicionar métodos helper (`marcarComoConcluida`, etc.)
- [ ] DTO tem serialização JSON completa
- [ ] Mapper trata valores nullable corretamente
- [ ] Imports não incluem `/lib` no caminho

### Migração para Clean Architecture
- [ ] Entity movida para `lib/domain/entities/`
- [ ] DTO movido para `lib/data/models/`
- [ ] Mapper movido para `lib/data/mappers/`
- [ ] Repository interface criada
- [ ] Repository implementation criada
- [ ] Data source criado
- [ ] Use cases criados (incluindo marcar como concluída/não concluída)
- [ ] Todos os imports atualizados
- [ ] Testes atualizados

## Exemplo de Uso

```dart
// Criar tarefa
final tarefa = Tarefa(
  id: '1',
  titulo: 'Fazer exercícios',
  descricao: 'Resolver exercícios do capítulo 3',
  concluida: false,
  dataCriacao: DateTime.now(),
  dataConclusao: null,  // Ainda não concluída
);

// Marcar como concluída (com método helper)
final tarefaConcluida = tarefa.marcarComoConcluida();
// Agora dataConclusao será preenchida automaticamente

// Atualizar descrição
final atualizada = tarefa.copyWith(
  descricao: 'Resolver exercícios do capítulo 3 e 4',
);
```

## Referências

- Padrão de referência: `DailyGoal` (estrutura nova completa)
- Arquitetura alvo: Clean Architecture
- Padrão: Repository Pattern
- Melhoria: Campos nullable quando apropriado

