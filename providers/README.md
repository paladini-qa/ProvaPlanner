# Providers - Prompts de Construção de Entidades

Esta pasta contém prompts detalhados para a construção e manutenção das entidades do ProvaPlanner.

## Estrutura

- `entidades/` - Prompts específicos para cada entidade do domínio
- `melhorias_futuras.md` - Prompts para implementação de melhorias e novas funcionalidades

## Como Usar

Cada arquivo contém:

- **Contexto**: Informações sobre a entidade e seu propósito
- **Estrutura Atual**: Detalhes da implementação existente
- **Regras de Construção**: Diretrizes para criar/modificar a entidade
- **Exemplos**: Código de referência e padrões a seguir
- **Checklist**: Itens a verificar ao trabalhar com a entidade

## Entidades Disponíveis

### Estrutura Nova (Clean Architecture)

- `daily_goal.md` - Meta diária de estudos
- `prioridade_meta.md` - Enum de prioridade para metas

### Estrutura Antiga (em migração)

- `aluno.md` - Entidade de aluno
- `anotacao.md` - Entidade de anotação
- `curso.md` - Entidade de curso
- `tarefa.md` - Entidade de tarefa
- `disciplina.md` - Entidade de disciplina
- `prova.md` - Entidade de prova (com Revisao)
