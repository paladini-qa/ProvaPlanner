# PRD - ProvaPlanner

## Product Requirements Document

### 1. Visão Geral do Produto

**Nome do Produto:** ProvaPlanner  
**Versão:** 1.0.0  
**Data:** Outubro 2025  
**Tipo:** Aplicativo Mobile Flutter

**Descrição:** O ProvaPlanner é um aplicativo mobile desenvolvido em Flutter para organização acadêmica, permitindo que estudantes gerenciem suas provas e criem cronogramas de estudos personalizados com revisões automáticas.

### 2. Objetivos do Produto

**Objetivo Principal:** Facilitar a organização acadêmica de estudantes através de um sistema de calendário integrado com planejamento de revisões automáticas.

**Objetivos Secundários:**

- Reduzir o estresse acadêmico através de planejamento antecipado
- Aumentar a eficiência nos estudos através de revisões programadas
- Proporcionar visibilidade clara do cronograma acadêmico
- Garantir conformidade com LGPD e acessibilidade

### 3. Público-Alvo

**Usuários Primários:** Estudantes do ensino médio e superior  
**Idade:** 16-25 anos  
**Perfil:** Usuários que precisam organizar múltiplas provas e disciplinas  
**Tecnologia:** Usuários confortáveis com aplicativos mobile

### 4. Funcionalidades Principais

#### 4.1 Gestão de Provas

- **Adicionar Prova:** Formulário para cadastro de provas com nome, disciplina, data e descrição
- **Visualização em Calendário:** Interface de calendário com marcadores visuais para provas
- **Detalhes da Prova:** Modal com informações completas e lista de revisões associadas

#### 4.2 Sistema de Revisões Automáticas

- **Geração Automática:** Criação automática de 3 revisões distribuídas nos 7 dias anteriores à prova
- **Distribuição Inteligente:** Adaptação do cronograma baseado no tempo restante
- **Controle de Progresso:** Marcação de revisões como concluídas
- **Visualização por Data:** Filtro de revisões por data selecionada

#### 4.3 Interface de Usuário

- **Splash Screen:** Tela inicial com animações e roteamento inteligente
- **Onboarding:** 4 telas explicativas sobre funcionalidades principais
- **Políticas e Consentimento:** Conformidade com LGPD e termos de uso
- **Home Screen:** Tela principal com calendário e lista de eventos

### 5. Requisitos Técnicos

#### 5.1 Plataforma

- **Framework:** Flutter 3.0+
- **Linguagem:** Dart
- **Arquitetura:** Material Design 3
- **Compatibilidade:** Android e iOS

#### 5.2 Dependências Principais

- `shared_preferences`: Armazenamento local de preferências
- `intl`: Internacionalização e formatação de datas
- `table_calendar`: Widget de calendário
- `flutter_svg`: Suporte a ícones SVG

#### 5.3 Armazenamento

- **Local:** SharedPreferences para configurações e estado do usuário
- **Dados:** Armazenamento local das provas e revisões
- **Backup:** Não implementado na versão atual

### 6. Requisitos de Acessibilidade (A11Y)

#### 6.1 Conformidade WCAG 2.1 AA

- **Contraste:** Mínimo 4.5:1 para texto normal, 3:1 para texto grande
- **Tamanho de Toque:** Mínimo 48dp para elementos interativos
- **Navegação:** Suporte completo a leitores de tela
- **Estados Visuais:** Indicação clara de elementos desabilitados

#### 6.2 Implementações Atuais

- Semântica adequada em botões e elementos interativos
- Suporte a navegação por teclado
- Indicadores visuais de progresso
- Textos alternativos para ícones

### 7. Conformidade Legal (LGPD)

#### 7.1 Coleta de Dados

- **Dados Coletados:** Informações de provas, preferências de notificação, dados de uso
- **Base Legal:** Consentimento explícito do usuário
- **Finalidade:** Fornecimento do serviço de organização acadêmica

#### 7.2 Direitos do Usuário

- **Acesso:** Visualização de dados coletados
- **Correção:** Edição de informações incorretas
- **Exclusão:** Remoção de dados pessoais
- **Portabilidade:** Exportação de dados (não implementado)

#### 7.3 Implementações Atuais

- Tela de consentimento com checkboxes específicos
- Política de privacidade integrada
- Termos de uso claros
- Opção de revogação de consentimento

### 8. Fluxo de Navegação

#### 8.1 Primeira Execução

1. **Splash Screen** (3s) → Verificação de estado
2. **Onboarding** (4 telas) → Apresentação das funcionalidades
3. **Políticas** → Consentimento LGPD e termos
4. **Home Screen** → Tela principal

#### 8.2 Execuções Subsequentes

1. **Splash Screen** (3s) → Verificação de estado
2. **Home Screen** → Acesso direto (se políticas aceitas)

#### 8.3 Navegação Principal

- **Home** ↔ **Adicionar Prova** (via FAB)
- **Calendário** → Seleção de data → Visualização de eventos
- **Detalhes da Prova** → Modal com informações completas

### 9. Design System

#### 9.1 Paleta de Cores

- **Primária:** Indigo (#4F46E5)
- **Secundária:** Amber (#F59E0B)
- **Neutras:** Slate (#1F2937), Slate Light (#374151), Slate Lighter (#6B7280)
- **Superfície:** Branco (#FFFFFF)

#### 9.2 Componentes

- **App Icon:** Ícone personalizado com animações
- **Prova Card:** Card para exibição de provas
- **Revisão Card:** Card para exibição de revisões
- **Calendário:** Widget de calendário com marcadores

#### 9.3 Tipografia

- **Headlines:** FontWeight.bold, cores slate
- **Body:** Cores slate/slateLight
- **Tamanhos:** Responsivos e acessíveis

### 10. Critérios de Aceitação

#### 10.1 Funcionalidades Core

- [ ] Usuário pode adicionar nova prova com todos os campos obrigatórios
- [ ] Calendário exibe provas com marcadores visuais
- [ ] Sistema gera automaticamente 3 revisões para cada prova
- [ ] Usuário pode marcar revisões como concluídas
- [ ] Dados persistem entre sessões do aplicativo

#### 10.2 Acessibilidade

- [ ] Todos os elementos interativos têm mínimo 48dp
- [ ] Contraste de texto atende WCAG 2.1 AA
- [ ] Navegação funciona com leitores de tela
- [ ] Estados desabilitados são claramente visíveis

#### 10.3 Conformidade Legal

- [ ] Usuário deve aceitar termos e política de privacidade
- [ ] Consentimento LGPD é obtido explicitamente
- [ ] Opção de revogação de consentimento está disponível
- [ ] Versão das políticas é registrada

#### 10.4 UX/UI

- [ ] Onboarding explica claramente as funcionalidades
- [ ] Navegação é intuitiva e consistente
- [ ] Animações são suaves e não causam desconforto
- [ ] Interface é responsiva em diferentes tamanhos de tela

### 11. Métricas de Sucesso

#### 11.1 Métricas de Engajamento

- **Retenção:** 70% dos usuários retornam após 7 dias
- **Frequência:** 80% dos usuários usam o app pelo menos 3x por semana
- **Completude:** 90% das provas cadastradas têm revisões geradas

#### 11.2 Métricas de Qualidade

- **Acessibilidade:** 100% dos elementos passam em testes de acessibilidade
- **Performance:** Tempo de carregamento < 3 segundos
- **Estabilidade:** Taxa de crash < 1%

### 12. Roadmap Futuro

#### 12.1 Versão 1.1 (Q1 2025)

- Notificações push para lembretes
- Sincronização em nuvem
- Modo escuro
- Exportação de dados

#### 12.2 Versão 1.2 (Q2 2025)

- Estatísticas de progresso
- Compartilhamento de cronogramas
- Integração com calendários do sistema
- Backup automático

### 13. Riscos e Mitigações

#### 13.1 Riscos Técnicos

- **Risco:** Perda de dados locais
- **Mitigação:** Implementar backup em nuvem na próxima versão

#### 13.2 Riscos Legais

- **Risco:** Não conformidade com LGPD
- **Mitigação:** Revisão legal regular e atualizações de políticas

#### 13.3 Riscos de UX

- **Risco:** Complexidade excessiva do onboarding
- **Mitigação:** Testes de usabilidade e iteração baseada em feedback

### 14. Definição de Pronto (DoD)

#### 14.1 Desenvolvimento

- [ ] Código revisado e aprovado
- [ ] Testes unitários passando
- [ ] Testes de integração passando
- [ ] Documentação atualizada

#### 14.2 Qualidade

- [ ] Testes de acessibilidade passando
- [ ] Testes de performance aprovados
- [ ] Revisão de segurança concluída
- [ ] Testes em dispositivos reais

#### 14.3 Conformidade

- [ ] Revisão legal das políticas
- [ ] Testes de conformidade LGPD
- [ ] Validação de acessibilidade
- [ ] Aprovação final do produto

---

**Documento criado em:** Dezembro 2024  
**Última atualização:** Dezembro 2024  
**Próxima revisão:** Janeiro 2025  
**Responsável:** Equipe de Desenvolvimento ProvaPlanner
