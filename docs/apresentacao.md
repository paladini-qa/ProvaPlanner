# Apresentação - Daily Goals com IA

## 1. Sumário Executivo

Este projeto implementa um sistema completo de **Metas Diárias de Estudo** para o aplicativo ProvaPlanner, com duas features principais apoiadas por Inteligência Artificial:

1. **Resumo Diário com IA**: Gera automaticamente um resumo motivacional e organizado do dia do estudante, baseado em provas agendadas, revisões pendentes e metas definidas.

2. **Sugestão Automática de Metas**: Utiliza IA para analisar as provas e revisões do estudante e sugerir metas diárias de estudo personalizadas e acionáveis.

### Resultados

- ✅ Sistema completo de metas diárias implementado
- ✅ Integração com Google Gemini API para geração de conteúdo inteligente
- ✅ Modo mock disponível para avaliação offline
- ✅ Interface intuitiva com animações e tutoriais
- ✅ Persistência local funcional
- ✅ Integração completa com o sistema existente de provas e revisões

### Tecnologias Utilizadas

- **Flutter/Dart**: Framework de desenvolvimento
- **Google Gemini API**: Serviço de IA para geração de conteúdo
- **SharedPreferences**: Persistência local
- **flutter_dotenv**: Gerenciamento de variáveis de ambiente

---

## 2. Arquitetura e Fluxo de Dados

### Diagrama de Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                    DailyGoalsScreen                         │
│  (Tela Principal - Listagem, FAB, Tutorial, Tip Bubble)     │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ├─────────────────┐
                 │                 │
        ┌────────▼────────┐  ┌────▼──────────────────┐
        │ DailyGoalService │  │ ProvaService           │
        │ (Persistência)   │  │ (Dados de Provas)     │
        └──────────────────┘  └───────────────────────┘
                 │
                 │
        ┌────────▼──────────────────────────┐
        │   GoalSuggestionService            │
        │   (Orquestra sugestões de metas)  │
        └────────┬───────────────────────────┘
                 │
        ┌────────▼────────┐
        │   AIService      │
        │   (Interface)    │
        └────────┬─────────┘
                 │
        ┌────────┴─────────┐
        │                  │
┌───────▼────────┐  ┌──────▼──────────┐
│ GeminiService  │  │ AIServiceMock    │
│ (API Real)     │  │ (Modo Offline)   │
└────────────────┘  └─────────────────┘
```

### Fluxo de Dados - Resumo Diário

```
1. Usuário abre tela de Daily Goals (data = hoje)
   ↓
2. Sistema coleta dados:
   - Provas do dia (via ProvaService)
   - Revisões do dia (via ProvaService)
   - Metas do dia (via DailyGoalService)
   ↓
3. Dados são formatados em texto
   ↓
4. Envio para AIService (Gemini ou Mock)
   ↓
5. IA processa e gera resumo formatado
   ↓
6. Resumo exibido em DailySummaryCard
```

### Fluxo de Dados - Sugestão de Metas

```
1. Usuário clica em "Sugerir Metas" (ícone de IA)
   ↓
2. GoalSuggestionService coleta:
   - Provas dos próximos 7 dias
   - Revisões pendentes
   ↓
3. Dados formatados e enviados para AIService
   ↓
4. IA gera 3-5 sugestões de metas
   ↓
5. Sugestões exibidas em dialog interativo
   ↓
6. Usuário seleciona metas desejadas
   ↓
7. Metas selecionadas são salvas via DailyGoalService
```

### Onde a IA Entra no Fluxo

A IA é utilizada em dois pontos principais:

1. **Geração de Resumo Diário**: 
   - **Input**: Lista de provas, revisões e metas do dia
   - **Processamento**: Gemini API analisa e gera texto motivacional
   - **Output**: Resumo formatado com título e parágrafos

2. **Sugestão de Metas**:
   - **Input**: Provas próximas e revisões pendentes
   - **Processamento**: Gemini API analisa contexto e sugere metas
   - **Output**: Lista de metas estruturadas (título + descrição)

---

## 3. Feature 1: Resumo Diário com IA

### Objetivo

Fornecer ao estudante um resumo diário personalizado e motivacional das suas atividades acadêmicas, ajudando-o a visualizar o dia de forma organizada e encorajadora.

### Prompt Usado

```
Você é um assistente de estudos motivacional e organizado. Gere um resumo diário personalizado e encorajador para o estudante baseado nas seguintes informações:

PROVAS AGENDADAS PARA HOJE:
[lista de provas]

REVISÕES PENDENTES PARA HOJE:
[lista de revisões]

METAS DIÁRIAS:
[lista de metas]

INSTRUÇÕES:
- Crie um título motivacional e positivo
- Escreva 2-3 parágrafos com dicas práticas e encorajamento
- Seja específico e acionável
- Use tom amigável e motivacional
- Destaque os pontos mais importantes do dia
- Se não houver atividades, sugira formas de aproveitar o dia para estudos

FORMATO DE SAÍDA:
Título: [título aqui]

[parágrafo 1]

[parágrafo 2]

[parágrafo 3 - opcional]
```

### Comentários sobre o Prompt

- **Tom motivacional**: Escolhido para encorajar o estudante, não apenas informar
- **Estrutura clara**: Título + parágrafos facilita a leitura
- **Acionável**: Foca em dicas práticas, não apenas descrições
- **Tratamento de casos vazios**: Inclui sugestões quando não há atividades

### Exemplos de Entrada e Saída

#### Exemplo 1: Dia com Provas e Revisões

**Entrada:**
- Provas: "Prova de Matemática - Cálculo Diferencial"
- Revisões: "Primeira revisão - Conceitos básicos", "Segunda revisão - Exercícios práticos"
- Metas: "Revisar capítulo 5", "Resolver 10 exercícios"

**Saída:**
```
Título: Um Dia Desafiador e Produtivo pela Frente!

Você tem uma prova importante de Matemática hoje! Certifique-se de revisar os principais conceitos de Cálculo Diferencial e estar bem preparado. As revisões agendadas são uma ótima oportunidade para reforçar seu aprendizado.

Suas metas diárias estão alinhadas com suas atividades. Foque em completar a revisão do capítulo 5 e resolver os exercícios práticos para consolidar o conhecimento antes da prova.

Lembre-se: organização e foco são essenciais. Boa sorte com sua prova!
```

#### Exemplo 2: Dia sem Atividades

**Entrada:**
- Provas: (vazio)
- Revisões: (vazio)
- Metas: (vazio)

**Saída:**
```
Título: Um Dia para Organizar seus Estudos

Hoje é um ótimo dia para planejar e organizar seus estudos! Sem atividades urgentes agendadas, você pode aproveitar para revisar conteúdos anteriores, organizar suas anotações ou até mesmo adiantar estudos para provas futuras.

Considere criar algumas metas diárias para manter o ritmo de estudos. Mesmo sem atividades obrigatórias, manter uma rotina de estudos é fundamental para o sucesso acadêmico.

Use este tempo para fortalecer seus conhecimentos e se preparar melhor para os desafios que virão!
```

#### Exemplo 3: Dia com Múltiplas Atividades

**Entrada:**
- Provas: "Prova de Física - Mecânica", "Prova de Química - Orgânica"
- Revisões: "Revisão de Física", "Revisão de Química"
- Metas: "Revisar fórmulas de Física", "Estudar reações orgânicas", "Fazer resumo de Química"

**Saída:**
```
Título: Um Dia Intenso de Provas - Você Está Preparado!

Hoje você tem duas provas importantes: Física e Química. É um dia desafiador, mas você já se preparou com as revisões agendadas. Foque em manter a calma e aplicar todo o conhecimento que você construiu.

Suas metas estão bem alinhadas com as provas. Priorize revisar as fórmulas de Física e as reações orgânicas de Química. O resumo que você vai fazer será útil para uma última revisão rápida antes das provas.

Respire fundo, confie no seu preparo e dê o seu melhor!
```

### Como Testar Localmente

1. **Configurar API (opcional)**:
   - Criar arquivo `.env` na raiz do projeto
   - Adicionar `GEMINI_API_KEY=sua_chave_aqui`
   - Ou usar modo mock: `USE_MOCK_AI=true`

2. **Executar o aplicativo**:
   ```bash
   flutter pub get
   flutter run
   ```

3. **Testar resumo diário**:
   - Navegar para a tela "Metas Diárias" (ícone de bandeira)
   - O resumo será gerado automaticamente se a data selecionada for hoje
   - Verificar se o resumo aparece no topo da tela
   - Testar botão de refresh para regenerar

4. **Testar com diferentes cenários**:
   - Criar provas para hoje
   - Criar revisões para hoje
   - Criar metas para hoje
   - Verificar se o resumo reflete as atividades

### Limitações e Riscos

#### Limitações

1. **Dependência de API Externa**: Requer conexão com internet e chave válida do Gemini
2. **Latência**: Pode levar 1-3 segundos para gerar o resumo
3. **Qualidade do Prompt**: A qualidade do resumo depende da qualidade do prompt e dos dados fornecidos
4. **Idioma**: O prompt está em português, mas a IA pode ocasionalmente gerar em inglês

#### Riscos

1. **Privacidade**: Dados acadêmicos são enviados para a API do Google
   - **Mitigação**: Dados são apenas informações acadêmicas não sensíveis (nomes de provas, disciplinas)
   - **Transparência**: Usuário é informado sobre o uso de IA

2. **Vieses**: A IA pode ter vieses em suas respostas
   - **Mitigação**: Prompt foi cuidadosamente construído para ser neutro e motivacional
   - **Validação**: Respostas são validadas antes de exibição

3. **Custos**: Uso da API pode gerar custos
   - **Mitigação**: Modo mock disponível para testes
   - **Limites**: API do Gemini tem tier gratuito generoso

### Código Relevante

#### Geração do Resumo (`lib/screens/daily_goals_screen.dart`)

```dart
Future<void> _gerarResumoDiario() async {
  setState(() {
    _isLoadingResumo = true;
  });

  try {
    // Obter dados do dia
    final provasDoDia = await ProvaService.obterProvasPorData(_dataSelecionada);
    final revisoesDoDia = await ProvaService.obterRevisoesPorData(_dataSelecionada);
    final metasDoDia = _goals;

    // Preparar textos
    final provasTexto = provasDoDia.map((p) => '${p.nome} - ${p.disciplinaNome}').toList();
    final revisoesTexto = revisoesDoDia.map((r) => r.descricao).toList();
    final metasTexto = metasDoDia.map((m) => m.titulo).toList();

    // Obter serviço de IA
    AIService aiService;
    if (Env.useMockAi) {
      aiService = AIServiceMock();
    } else {
      try {
        aiService = GeminiService();
      } catch (e) {
        aiService = AIServiceMock();
      }
    }

    // Gerar resumo
    final resumo = await aiService.gerarResumoDiario(
      provas: provasTexto,
      revisoes: revisoesTexto,
      metas: metasTexto,
    );

    setState(() {
      _resumoDiario = resumo;
      _isLoadingResumo = false;
    });
  } catch (e) {
    setState(() {
      _resumoDiario = 'Erro ao gerar resumo: $e';
      _isLoadingResumo = false;
    });
  }
}
```

**Explicação linha a linha:**

- **Linhas 1-4**: Inicia o processo e mostra loading
- **Linhas 6-8**: Coleta dados do dia (provas, revisões, metas)
- **Linhas 10-12**: Formata dados em listas de strings para o prompt
- **Linhas 14-24**: Seleciona serviço de IA (mock ou real) com fallback para mock em caso de erro
- **Linhas 26-31**: Chama a IA para gerar resumo
- **Linhas 33-37**: Atualiza UI com resultado
- **Linhas 38-43**: Trata erros graciosamente

---

## 4. Feature 2: Sugestão Automática de Metas

### Objetivo

Analisar automaticamente as provas e revisões do estudante e sugerir metas diárias de estudo personalizadas e acionáveis, facilitando o planejamento e aumentando a produtividade.

### Prompt Usado

```
Você é um assistente de estudos especializado em planejamento acadêmico. Baseado nas provas e revisões do estudante, sugira 3-5 metas diárias de estudo específicas, acionáveis e realistas.

PROVAS PRÓXIMAS (próximos 7 dias):
[lista de provas]

REVISÕES PENDENTES:
[lista de revisões]

INSTRUÇÕES:
- Crie 3-5 metas específicas e mensuráveis
- Cada meta deve ser relacionada às provas ou revisões
- Seja realista e considere o tempo disponível
- Use verbos de ação (ex: "Revisar", "Resolver", "Estudar")
- Inclua a disciplina ou assunto quando relevante

FORMATO DE SAÍDA (JSON array):
[
  {"titulo": "Revisar capítulo 5 de Matemática", "descricao": "Focar em equações quadráticas para a prova de quinta-feira"},
  {"titulo": "Resolver 10 exercícios de Física", "descricao": "Praticar mecânica para reforçar conceitos"},
  ...
]

IMPORTANTE: Retorne APENAS o JSON array, sem texto adicional antes ou depois.
```

### Comentários sobre o Prompt

- **Formato JSON**: Escolhido para facilitar parsing, mas requer tratamento de erros robusto
- **Especificidade**: Enfatiza metas acionáveis e mensuráveis
- **Contexto**: Relaciona metas diretamente com provas e revisões
- **Realismo**: Considera tempo disponível do estudante

### Exemplos de Entrada e Saída

#### Exemplo 1: Prova Próxima

**Entrada:**
- Provas: "Prova de Matemática (Cálculo) - 3 dias"
- Revisões: "Revisão: Conceitos básicos", "Revisão: Exercícios práticos"

**Saída:**
```json
[
  {"titulo": "Revisar capítulo 5 de Cálculo", "descricao": "Focar em derivadas e integrais para a prova de quinta-feira"},
  {"titulo": "Resolver 15 exercícios de Cálculo", "descricao": "Praticar problemas similares aos que podem aparecer na prova"},
  {"titulo": "Revisar fórmulas principais", "descricao": "Criar um resumo com as fórmulas mais importantes"}
]
```

#### Exemplo 2: Múltiplas Provas

**Entrada:**
- Provas: "Prova de Física - 2 dias", "Prova de Química - 5 dias"
- Revisões: "Revisão de Física: Mecânica", "Revisão de Química: Orgânica"

**Saída:**
```json
[
  {"titulo": "Priorizar estudo de Física", "descricao": "Focar em mecânica para a prova de amanhã"},
  {"titulo": "Revisar reações orgânicas", "descricao": "Preparar para a prova de Química da próxima semana"},
  {"titulo": "Resolver exercícios de Física", "descricao": "Praticar problemas de mecânica"},
  {"titulo": "Fazer resumo de Química", "descricao": "Organizar principais conceitos de química orgânica"}
]
```

#### Exemplo 3: Sem Provas Próximas

**Entrada:**
- Provas: (nenhuma nos próximos 7 dias)
- Revisões: "Revisão: História do Brasil", "Revisão: Literatura"

**Saída:**
```json
[
  {"titulo": "Completar revisões pendentes", "descricao": "Focar nas revisões de História e Literatura agendadas"},
  {"titulo": "Revisar matérias estudadas recentemente", "descricao": "Manter o conteúdo fresco na memória"},
  {"titulo": "Organizar anotações", "descricao": "Dedique tempo para organizar seus materiais de estudo"}
]
```

### Como Testar Localmente

1. **Configurar API** (mesmo processo da Feature 1)

2. **Criar dados de teste**:
   - Adicionar provas para os próximos 7 dias
   - Criar revisões pendentes

3. **Testar sugestões**:
   - Navegar para "Metas Diárias"
   - Clicar no ícone de IA (auto_awesome) na AppBar
   - Aguardar geração das sugestões
   - Verificar dialog com sugestões
   - Selecionar metas desejadas
   - Confirmar e verificar se foram adicionadas

4. **Testar diferentes cenários**:
   - Com provas próximas
   - Sem provas próximas
   - Com muitas revisões pendentes
   - Sem atividades

### Limitações e Riscos

#### Limitações

1. **Parsing de JSON**: A IA pode retornar JSON mal formatado
   - **Mitigação**: Parser robusto com fallback para sugestões genéricas

2. **Quantidade de Sugestões**: Pode gerar mais ou menos que o esperado
   - **Mitigação**: Validação e filtragem de sugestões vazias

3. **Relevância**: Sugestões podem não ser sempre relevantes
   - **Mitigação**: Usuário pode aceitar/rejeitar cada sugestão

#### Riscos

1. **Privacidade**: Mesmos riscos da Feature 1
2. **Qualidade**: Sugestões podem não ser ideais
   - **Mitigação**: Usuário tem controle total sobre aceitação

### Código Relevante

#### Geração de Sugestões (`lib/services/goal_suggestion_service.dart`)

```dart
static Future<List<DailyGoal>> gerarSugestoes() async {
  final hoje = DateTime.now();
  final fimSemana = hoje.add(const Duration(days: 7));

  // Obter provas dos próximos 7 dias
  final todasProvas = await ProvaService.carregarProvas();
  final provasProximas = todasProvas.where((prova) {
    return prova.dataProva.isAfter(hoje.subtract(const Duration(days: 1))) &&
        prova.dataProva.isBefore(fimSemana.add(const Duration(days: 1)));
  }).toList();

  // Obter revisões pendentes
  final todasRevisoes = <Revisao>[];
  for (final prova in todasProvas) {
    todasRevisoes.addAll(prova.revisoes.where((r) => !r.concluida));
  }

  // Preparar dados para IA
  final provasTexto = provasProximas.map((p) {
    final diasRestantes = p.dataProva.difference(hoje).inDays;
    return '${p.nome} (${p.disciplinaNome}) - ${diasRestantes} dia(s)';
  }).toList();

  final revisoesTexto = todasRevisoes.map((r) {
    return 'Revisão: ${r.descricao}';
  }).toList();

  // Gerar sugestões com IA
  final sugestoesIA = await _aiService.sugerirMetas(
    provasProximas: provasTexto,
    revisoesPendentes: revisoesTexto,
  );

  // Converter sugestões em DailyGoals
  final goals = sugestoesIA.map((sugestao) {
    return DailyGoal(
      id: DateTime.now().millisecondsSinceEpoch.toString() +
          '_sug_${sugestoesIA.indexOf(sugestao)}',
      titulo: sugestao['titulo'] ?? '',
      descricao: sugestao['descricao'] ?? '',
      data: hoje,
      prioridade: _determinarPrioridade(provasProximas),
    );
  }).toList();

  return goals;
}
```

**Explicação linha a linha:**

- **Linhas 1-5**: Define período de análise (próximos 7 dias)
- **Linhas 7-12**: Filtra provas dos próximos 7 dias
- **Linhas 14-17**: Coleta todas as revisões pendentes
- **Linhas 19-25**: Formata dados para o prompt da IA
- **Linhas 27-31**: Chama IA para gerar sugestões
- **Linhas 33-42**: Converte sugestões em objetos DailyGoal com prioridade calculada

---

## 5. Roteiro de Apresentação Oral

### Introdução (2 min)

- Apresentar o projeto: Sistema de Metas Diárias com IA para ProvaPlanner
- Contexto: Melhorar experiência do estudante com planejamento acadêmico
- Duas features principais implementadas

### Como a IA Foi Usada (3 min)

1. **Google Gemini API**: Escolhida por ser gratuita e fácil de integrar
2. **Modo Mock**: Implementado para avaliação offline
3. **Prompts Estruturados**: Desenvolvidos iterativamente para melhor qualidade
4. **Validação**: Sempre validar e normalizar respostas da IA

### Decisões de Design (3 min)

1. **Arquitetura Modular**: Separação clara entre UI, serviços e IA
2. **Fallback Robusto**: Sempre ter modo mock disponível
3. **UX Intuitiva**: Tutorial, tip bubble, animações
4. **Persistência Local**: Dados salvos localmente para privacidade

### Por Que a Solução é Segura/Ética (2 min)

1. **Privacidade**: 
   - Apenas dados acadêmicos não sensíveis são enviados
   - Dados são armazenados localmente
   - Usuário tem controle total

2. **Transparência**:
   - Usuário sabe quando IA está sendo usada
   - Modo mock disponível para quem não quer usar API

3. **Validação**:
   - Sempre validar respostas da IA
   - Usuário pode aceitar/rejeitar sugestões

### Testes Realizados (2 min)

1. **Testes Manuais**:
   - Diferentes cenários de dados
   - Com e sem API configurada
   - Validação de UI e fluxos

2. **Testes de Integração**:
   - Fluxo completo de criação de metas
   - Geração de resumo
   - Sugestões automáticas

3. **Testes de Edge Cases**:
   - Sem dados
   - Muitos dados
   - Erros de API

### Demonstração (3 min)

1. Mostrar tela de Daily Goals
2. Demonstrar resumo diário
3. Demonstrar sugestões automáticas
4. Mostrar criação manual de metas

### Limitações e Melhorias Futuras (2 min)

1. **Limitações Atuais**:
   - Dependência de API externa
   - Qualidade depende do prompt

2. **Melhorias Futuras**:
   - Cache de respostas da IA
   - Aprendizado com preferências do usuário
   - Mais opções de personalização

---

## 6. Política de Branches e Commits

### Estrutura de Branches

O desenvolvimento foi organizado em branches separadas para cada feature:

1. **`feature/base-daily-goals`**: 
   - Modelos (DailyGoal, DTO, Mapper)
   - Serviço de persistência (DailyGoalService)
   - Tela de listagem base
   - Dialog de criação/edição

2. **`feature/ai-daily-summary`**:
   - Serviços de IA (AIService, GeminiService, AIServiceMock)
   - Widget DailySummaryCard
   - Integração na tela de daily goals

3. **`feature/ai-goal-suggestions`**:
   - GoalSuggestionService
   - Dialog de sugestões
   - Integração na tela

4. **`feature/documentation`**:
   - Documentação completa
   - Guias de configuração
   - Arquivos de exemplo

### Convenção de Commits

Cada commit segue o padrão:

```
<tipo>: <descrição curta>

<descrição detalhada (opcional)>
```

**Tipos utilizados:**
- `feat`: Nova funcionalidade
- `fix`: Correção de bug
- `docs`: Documentação
- `refactor`: Refatoração
- `test`: Testes

**Exemplos de commits:**

```
feat: adicionar modelo DailyGoal com prioridades

- Criar entidade DailyGoal
- Implementar enum PrioridadeMeta
- Adicionar métodos copyWith e getters

feat: implementar tela de listagem de metas

- Adicionar DailyGoalsScreen
- Implementar FAB com animação
- Adicionar tip bubble e overlay de tutorial
- Criar estado vazio acolhedor

feat: integrar resumo diário com Gemini API

- Criar GeminiService
- Implementar geração de resumo
- Adicionar widget DailySummaryCard
- Integrar na tela de daily goals

feat: adicionar sugestão automática de metas

- Criar GoalSuggestionService
- Implementar dialog de sugestões
- Adicionar botão na AppBar
- Integrar com Gemini API

docs: criar documentação completa

- Adicionar apresentacao.md
- Criar gemini_setup.md
- Adicionar especificacoes.md
- Criar .env.example
```

### Histórico de Desenvolvimento

1. **Base Implementada**: Estrutura completa de modelos, serviços e UI base
2. **Feature 1 Implementada**: Resumo diário com IA totalmente funcional
3. **Feature 2 Implementada**: Sugestões automáticas funcionando
4. **Integração Completa**: Tudo integrado na navegação principal
5. **Documentação Finalizada**: Todos os documentos criados

---

## 7. Conclusão

Este projeto demonstra a integração bem-sucedida de IA generativa em um aplicativo Flutter, melhorando a experiência do usuário com funcionalidades inteligentes e úteis. A arquitetura modular permite fácil manutenção e extensão, enquanto o modo mock garante que o projeto possa ser avaliado mesmo sem acesso à API.

### Principais Conquistas

- ✅ Sistema completo de metas diárias
- ✅ Duas features com IA funcionais
- ✅ Interface intuitiva e polida
- ✅ Documentação completa
- ✅ Código limpo e bem organizado

### Aprendizados

- Integração com APIs de IA requer tratamento robusto de erros
- Prompts bem estruturados são essenciais para qualidade
- Modo mock é crucial para desenvolvimento e avaliação
- Validação de dados da IA é sempre necessária

---

**Desenvolvido para**: ProvaPlanner  
**Data**: 2024  
**Tecnologias**: Flutter, Dart, Google Gemini API

