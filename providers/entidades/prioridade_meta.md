# Prompt: Construção do Enum PrioridadeMeta

## Contexto

O enum `PrioridadeMeta` representa os níveis de prioridade para metas diárias no ProvaPlanner. É uma entidade simples que faz parte da nova arquitetura Clean Architecture.

## Localização

- **Enum**: `lib/domain/entities/prioridade_meta.dart`
- **Uso**: Utilizado pela entidade `DailyGoal`

## Estrutura do Enum

```dart
enum PrioridadeMeta {
  baixa,
  media,
  alta,
}
```

## Regras de Construção

### 1. Definição do Enum

```dart
// lib/domain/entities/prioridade_meta.dart
enum PrioridadeMeta {
  baixa,
  media,
  alta,
}
```

**Regras:**
- ✅ Deve estar em `lib/domain/entities/` (sem dependências do Flutter)
- ✅ Valores devem ser em minúsculas (convenção Dart)
- ✅ Nomes devem ser descritivos e claros
- ✅ Não deve ter dependências externas

### 2. Conversão para String

A conversão para string é feita na entidade que usa o enum ou no mapper:

```dart
// Exemplo na entidade DailyGoal
String get prioridadeTexto {
  switch (prioridade) {
    case PrioridadeMeta.alta:
      return 'Alta';
    case PrioridadeMeta.media:
      return 'Média';
    case PrioridadeMeta.baixa:
      return 'Baixa';
  }
}

// Exemplo no mapper
static String _prioridadeToString(PrioridadeMeta prioridade) {
  switch (prioridade) {
    case PrioridadeMeta.alta:
      return 'alta';
    case PrioridadeMeta.media:
      return 'media';
    case PrioridadeMeta.baixa:
      return 'baixa';
  }
}
```

**Regras:**
- ✅ Conversão para string deve ser feita no mapper quando serializando
- ✅ Conversão para exibição pode ser feita na entidade ou extension
- ✅ Valores padrão devem ser tratados na conversão de string para enum

### 3. Conversão de String para Enum

```dart
// Exemplo no mapper
static PrioridadeMeta _prioridadeFromString(String prioridade) {
  switch (prioridade.toLowerCase()) {
    case 'alta':
      return PrioridadeMeta.alta;
    case 'baixa':
      return PrioridadeMeta.baixa;
    default:
      return PrioridadeMeta.media;  // Valor padrão
  }
}
```

**Regras:**
- ✅ Sempre usar `toLowerCase()` para comparação case-insensitive
- ✅ Sempre ter um valor padrão (default case)
- ✅ Tratar valores inválidos retornando o valor padrão

## Exemplo de Uso

```dart
// Criar meta com prioridade
final goal = DailyGoal(
  id: '1',
  titulo: 'Estudar',
  descricao: 'Revisar capítulo',
  data: DateTime.now(),
  prioridade: PrioridadeMeta.alta,  // Uso direto do enum
);

// Verificar prioridade
if (goal.prioridade == PrioridadeMeta.alta) {
  // Lógica para prioridade alta
}

// Obter texto da prioridade
final texto = goal.prioridadeTexto;  // 'Alta'
```

## Checklist de Implementação

Ao criar ou modificar o enum PrioridadeMeta, verifique:

- [ ] Enum está em `lib/domain/entities/`
- [ ] Valores estão em minúsculas
- [ ] Nomes são descritivos
- [ ] Conversão para string está implementada (no mapper ou entidade)
- [ ] Conversão de string para enum trata valores inválidos
- [ ] Valor padrão está definido para conversões
- [ ] Não há dependências do Flutter

## Extensões Futuras

Se precisar adicionar novos valores ao enum:

1. Adicionar o novo valor ao enum
2. Atualizar todas as conversões (string para enum e enum para string)
3. Atualizar valores padrão se necessário
4. Atualizar testes
5. Verificar compatibilidade com dados existentes (migração)

## Referências

- Padrão: Enum simples do Dart
- Serialização: Via string no DTO
- Conversão: No mapper entre Entity e DTO

