# ProvaPlanner 📚

Um aplicativo Flutter para planejamento de provas com metas de revisão, desenvolvido para estudantes com múltiplas disciplinas.

## 🎯 Funcionalidades

- **Calendário Interativo**: Visualize suas provas e revisões em um calendário intuitivo
- **Plano de Revisão Automático**: Cria automaticamente 3 revisões distribuídas nos 7 dias antes de cada prova
- **Gestão de Provas**: Adicione provas com informações detalhadas (nome, disciplina, data, descrição)
- **Acompanhamento de Revisões**: Marque revisões como concluídas e acompanhe seu progresso
- **Interface Moderna**: Design limpo com paleta de cores personalizada (Indigo, Amber, Slate)

## 🎨 Paleta de Cores

- **Indigo**: #4F46E5 (Cor principal)
- **Amber**: #F59E0B (Cor de destaque)
- **Slate**: #1F2937 (Cor de texto)

## 🚀 Como Executar

1. Certifique-se de ter o Flutter instalado em sua máquina
2. Clone este repositório
3. Execute `flutter pub get` para instalar as dependências
4. Execute `flutter run` para iniciar o aplicativo

## 📱 Primeiros Passos

1. **Adicionar Prova**: Toque no botão "+" para adicionar uma nova prova
2. **Preencher Informações**: Insira o nome, disciplina, data e descrição da prova
3. **Revisões Automáticas**: O app criará automaticamente 3 revisões distribuídas nos 7 dias anteriores
4. **Acompanhar Progresso**: Marque as revisões como concluídas conforme você as realiza

## 🛠️ Tecnologias Utilizadas

- **Flutter**: Framework de desenvolvimento
- **Dart**: Linguagem de programação
- **Table Calendar**: Widget de calendário
- **Shared Preferences**: Armazenamento local de dados
- **Intl**: Formatação de datas

## 📦 Dependências

- `table_calendar: ^3.0.9`
- `intl: ^0.18.1`
- `shared_preferences: ^2.2.2`

## 🎯 Foco da Primeira Execução

O aplicativo está configurado para criar automaticamente:

- 1 evento de prova ("Prova A")
- 3 revisões distribuídas nos 7 dias anteriores à prova
- Interface intuitiva para gerenciar o cronograma de estudos

## 📝 Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada da aplicação
├── models/
│   └── prova.dart           # Modelos de dados (Prova e Revisao)
├── services/
│   └── prova_service.dart   # Serviços para gerenciar dados
├── screens/
│   ├── home_screen.dart     # Tela principal com calendário
│   └── adicionar_prova_screen.dart # Tela para adicionar provas
├── widgets/
│   ├── app_icon.dart        # Ícone personalizado do app
│   ├── prova_card.dart      # Widget para exibir provas
│   └── revisao_card.dart    # Widget para exibir revisões
└── theme/
    └── app_theme.dart       # Configurações de tema e cores
```

## 🔮 Próximas Funcionalidades

- Notificações para lembretes de revisões
- Estatísticas de progresso
- Exportação de cronograma
- Sincronização entre dispositivos
- Temas personalizáveis

---

Desenvolvido com ❤️ para estudantes que querem se organizar melhor!
