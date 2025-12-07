# 📚 ProvaPlanner

Organizador de provas e estudos para estudantes, desenvolvido em Flutter.

## 📖 Sobre

O ProvaPlanner é um aplicativo multiplataforma que ajuda estudantes a organizar suas provas, disciplinas, tarefas e metas de estudo diárias. Com integração de IA (Google Gemini), o app oferece sugestões inteligentes para otimizar sua rotina de estudos.

## ✨ Funcionalidades

- 📅 **Gerenciamento de Provas**: Cadastre e acompanhe suas provas com datas e revisões
- 📖 **Disciplinas**: Organize suas matérias e cursos
- ✅ **Tarefas**: Controle suas atividades pendentes
- 🎯 **Metas Diárias**: Defina e acompanhe objetivos de estudo
- 📝 **Anotações**: Faça anotações vinculadas às disciplinas
- 🤖 **Sugestões com IA**: Receba sugestões inteligentes de metas usando Google Gemini
- 📆 **Calendário**: Visualize suas provas e revisões em um calendário interativo
- 👤 **Perfil do Aluno**: Gerencie múltiplos perfis de estudantes
- 🌙 **Tema Claro/Escuro**: Interface adaptável às suas preferências

## 🏗️ Arquitetura

O projeto segue os princípios da **Clean Architecture**:

```
lib/
├── config/          # Configurações (env, Supabase)
├── data/            # Camada de dados
│   ├── datasources/ # Fontes de dados (local, remoto)
│   ├── mappers/     # Conversores Entity <-> DTO
│   └── models/      # DTOs para serialização
├── domain/          # Camada de domínio
│   ├── entities/    # Entidades de negócio
│   ├── repositories/# Interfaces de repositórios
│   └── usecases/    # Casos de uso
├── features/        # Features por módulo
│   ├── alunos/
│   ├── anotacoes/
│   ├── cursos/
│   ├── disciplinas/
│   └── tarefas/
├── presentation/    # Camada de apresentação
│   ├── extensions/  # Extensões para UI
│   ├── pages/       # Telas principais
│   ├── services/    # Serviços de apresentação
│   └── widgets/     # Widgets reutilizáveis
├── services/        # Serviços da aplicação
└── theme/           # Temas e estilos
```

## 🚀 Tecnologias

- **Flutter** ^3.0.0 - Framework UI multiplataforma
- **Supabase** - Backend as a Service (autenticação e banco de dados)
- **Google Generative AI** - Integração com Gemini para sugestões inteligentes
- **Syncfusion Calendar** - Calendário interativo
- **SharedPreferences** - Armazenamento local

## 📋 Pré-requisitos

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Conta no [Supabase](https://supabase.com)
- Chave de API do [Google AI Studio](https://aistudio.google.com)

## ⚙️ Configuração

1. **Clone o repositório**

   ```bash
   git clone https://github.com/seu-usuario/ProvaPlanner.git
   cd ProvaPlanner
   ```

2. **Configure as variáveis de ambiente**

   ```bash
   cp .env.example .env
   ```

   Edite o arquivo `.env` com suas credenciais:

   ```env
   SUPABASE_URL=sua_url_do_supabase
   SUPABASE_ANON_KEY=sua_chave_anonima
   GEMINI_API_KEY=sua_chave_do_gemini
   ```

3. **Instale as dependências**

   ```bash
   flutter pub get
   ```

4. **Configure o banco de dados**

   Execute o script SQL em `docs/supabase_tables.sql` no seu projeto Supabase.

5. **Execute o app**
   ```bash
   flutter run
   ```

## 🧪 Testes

```bash
# Executar todos os testes
flutter test

# Executar com cobertura
flutter test --coverage
```

## 📱 Plataformas Suportadas

- ✅ Android
- ✅ iOS
- ✅ Web
- ⬜ Windows (não testado)
- ⬜ macOS (não testado)
- ⬜ Linux (não testado)

## 📄 Licença

Este projeto está sob licença privada. Todos os direitos reservados.

## 👨‍💻 Autor

Desenvolvido com ❤️ para ajudar estudantes a se organizarem melhor.
