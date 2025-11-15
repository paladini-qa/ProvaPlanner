# Configuração do Supabase

Este documento descreve como configurar o Supabase para o ProvaPlanner.

## 1. Criar Projeto no Supabase

1. Acesse [https://supabase.com](https://supabase.com)
2. Crie uma conta ou faça login
3. Crie um novo projeto
4. Anote a **URL do projeto** e a **chave anônima (anon key)**

## 2. Configurar Variáveis de Ambiente

Adicione as seguintes variáveis ao arquivo `.env` na raiz do projeto:

```env
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua-chave-anon-key-aqui
```

## 3. Criar Tabela no Supabase

Execute o seguinte SQL no SQL Editor do Supabase:

```sql
-- Criar tabela daily_goals
CREATE TABLE IF NOT EXISTS daily_goals (
  id TEXT PRIMARY KEY,
  titulo TEXT NOT NULL,
  descricao TEXT NOT NULL,
  data TEXT NOT NULL,
  concluida BOOLEAN NOT NULL DEFAULT false,
  prioridade TEXT NOT NULL DEFAULT 'media',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Criar índice para melhorar performance nas consultas por data
CREATE INDEX IF NOT EXISTS idx_daily_goals_data ON daily_goals(data);

-- Habilitar Row Level Security (RLS)
ALTER TABLE daily_goals ENABLE ROW LEVEL SECURITY;

-- Política para permitir leitura e escrita para usuários autenticados
-- (Ajuste conforme sua estratégia de autenticação)
CREATE POLICY "Permitir acesso completo para usuários autenticados"
  ON daily_goals
  FOR ALL
  USING (auth.role() = 'authenticated');

-- Política alternativa: permitir acesso público (apenas para desenvolvimento)
-- ATENÇÃO: Remova esta política em produção!
CREATE POLICY "Permitir acesso público"
  ON daily_goals
  FOR ALL
  USING (true);
```

## 4. Estrutura da Tabela

| Coluna       | Tipo      | Descrição                                                        |
| ------------ | --------- | ---------------------------------------------------------------- |
| `id`         | TEXT      | Identificador único da meta (chave primária)                     |
| `titulo`     | TEXT      | Título da meta diária                                            |
| `descricao`  | TEXT      | Descrição detalhada da meta                                      |
| `data`       | TEXT      | Data da meta no formato ISO8601                                  |
| `concluida`  | BOOLEAN   | Status de conclusão (padrão: false)                              |
| `prioridade` | TEXT      | Prioridade da meta: 'alta', 'media' ou 'baixa' (padrão: 'media') |
| `created_at` | TIMESTAMP | Data de criação do registro                                      |
| `updated_at` | TIMESTAMP | Data da última atualização                                       |

## 5. Funcionalidades Implementadas

A integração com Supabase fornece:

- ✅ **Sincronização offline-first**: Os dados são salvos localmente primeiro e sincronizados com o Supabase quando possível
- ✅ **Fallback automático**: Se o Supabase não estiver disponível, a aplicação continua funcionando apenas com armazenamento local
- ✅ **Sincronização bidirecional**: Dados do servidor são sincronizados com o armazenamento local
- ✅ **Operações CRUD completas**: Criar, ler, atualizar e deletar metas diárias

## 6. Configurar Autenticação e Perfis de Usuário

### 6.1. Habilitar Autenticação por Email (Sem Confirmação)

1. No dashboard do Supabase, vá em **Authentication** > **Providers**
2. Certifique-se de que **Email** está habilitado
3. **IMPORTANTE**: Desabilite a confirmação de email:
   - Clique em **Email** provider
   - Desmarque a opção **"Confirm email"** ou **"Enable email confirmations"**
   - Isso permite login imediato após registro sem precisar confirmar email
4. Salve as alterações

### 6.2. Criar Tabela de Perfis

Execute o seguinte SQL no SQL Editor do Supabase para criar a tabela de perfis e configurar a criação automática de perfis ao registrar:

```sql
-- Criar tabela de perfis
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT,
  email TEXT,
  photo_url TEXT,
  onboarding_completed BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar Row Level Security (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Política: Usuários podem ver apenas seu próprio perfil
CREATE POLICY "Usuários podem ver apenas seu próprio perfil"
  ON profiles
  FOR SELECT
  USING (auth.uid() = id);

-- Política: Usuários podem atualizar apenas seu próprio perfil
CREATE POLICY "Usuários podem atualizar apenas seu próprio perfil"
  ON profiles
  FOR UPDATE
  USING (auth.uid() = id);

-- Política: Usuários podem inserir apenas seu próprio perfil
-- NOTA: Esta política é principalmente para backup. O trigger handle_new_user
-- usa SECURITY DEFINER e cria o perfil automaticamente, ignorando RLS
CREATE POLICY "Usuários podem inserir apenas seu próprio perfil"
  ON profiles
  FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Função para criar perfil automaticamente ao registrar
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', NEW.email)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para executar a função ao criar novo usuário
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Criar índice para melhorar performance
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
```

### 6.3. Configurar Storage para Fotos de Perfil

1. No dashboard do Supabase, vá em **Storage**
2. Clique em **Create a new bucket**
3. Nome do bucket: `profiles`
4. Marque como **Public bucket** (para permitir acesso às fotos)
5. Clique em **Create bucket**

**IMPORTANTE**: Após criar o bucket, você precisa executar o SQL abaixo para configurar as políticas de segurança (RLS).

**Execute o SQL:**

```sql
-- Criar bucket de storage para perfis
INSERT INTO storage.buckets (id, name, public)
VALUES ('profiles', 'profiles', true)
ON CONFLICT (id) DO NOTHING;

-- Política para permitir upload de fotos (apenas usuários autenticados)
-- O caminho deve ser 'avatars/avatar_<user_id>.jpg'
CREATE POLICY "Usuários autenticados podem fazer upload de fotos"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'profiles' AND
  auth.role() = 'authenticated' AND
  (storage.foldername(name))[1] = 'avatars'
);

-- Política para permitir leitura de fotos públicas
CREATE POLICY "Fotos de perfil são públicas"
ON storage.objects FOR SELECT
USING (bucket_id = 'profiles');

-- Política para permitir atualização (apenas o próprio usuário)
-- Verifica se o nome do arquivo contém o ID do usuário
CREATE POLICY "Usuários podem atualizar suas próprias fotos"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'profiles' AND
  auth.role() = 'authenticated' AND
  (name LIKE '%' || auth.uid()::text || '%')
);

-- Política para permitir exclusão (apenas o próprio usuário)
CREATE POLICY "Usuários podem deletar suas próprias fotos"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'profiles' AND
  auth.role() = 'authenticated' AND
  (name LIKE '%' || auth.uid()::text || '%')
);
```

**Estrutura da tabela `profiles`:**

| Coluna                 | Tipo      | Descrição                               |
| ---------------------- | --------- | --------------------------------------- |
| `id`                   | UUID      | ID do usuário (referência a auth.users) |
| `name`                 | TEXT      | Nome do usuário                         |
| `email`                | TEXT      | Email do usuário                        |
| `photo_url`            | TEXT      | URL da foto de perfil (opcional)        |
| `onboarding_completed` | BOOLEAN   | Se o usuário completou o onboarding     |
| `created_at`           | TIMESTAMP | Data de criação                         |
| `updated_at`           | TIMESTAMP | Data da última atualização              |

**Nota**: Se a tabela `profiles` já existe, adicione a coluna `onboarding_completed`:

```sql
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS onboarding_completed BOOLEAN DEFAULT false;
```

### 6.3. Atualizar Tabelas Existentes para Usar Autenticação

Para associar dados existentes aos usuários, adicione a coluna `user_id`:

```sql
-- Adicionar coluna user_id na tabela daily_goals
ALTER TABLE daily_goals
ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;

-- Atualizar políticas para usar user_id
DROP POLICY IF EXISTS "Permitir acesso completo para usuários autenticados" ON daily_goals;

CREATE POLICY "Usuários podem ver apenas suas próprias metas"
  ON daily_goals FOR SELECT
  USING ((auth.uid())::uuid = user_id);

CREATE POLICY "Usuários podem criar apenas suas próprias metas"
  ON daily_goals FOR INSERT
  WITH CHECK ((auth.uid())::uuid = user_id);

CREATE POLICY "Usuários podem atualizar apenas suas próprias metas"
  ON daily_goals FOR UPDATE
  USING ((auth.uid())::uuid = user_id);

CREATE POLICY "Usuários podem deletar apenas suas próprias metas"
  ON daily_goals FOR DELETE
  USING ((auth.uid())::uuid = user_id);
```

## 7. Troubleshooting

### Erro: "Supabase não inicializado"

- Verifique se as variáveis `SUPABASE_URL` e `SUPABASE_ANON_KEY` estão no arquivo `.env`
- Verifique se o arquivo `.env` está na raiz do projeto
- Verifique se as credenciais estão corretas

### Erro: "Erro ao buscar metas diárias"

- Verifique se a tabela `daily_goals` foi criada no Supabase
- Verifique as políticas RLS (Row Level Security)
- Verifique se a estrutura da tabela corresponde ao esperado

### Dados não sincronizam

- Verifique a conexão com a internet
- Verifique os logs do Supabase no dashboard
- A aplicação continuará funcionando localmente mesmo sem sincronização

### Erro: "new row violates row-level security policy for table profiles"

Este erro ocorre quando o código tenta criar o perfil manualmente. A solução é:

1. **Certifique-se de que o trigger foi criado**: O trigger `on_auth_user_created` cria o perfil automaticamente usando `SECURITY DEFINER`, que ignora RLS
2. **Verifique se a função existe**: Execute no SQL Editor:
   ```sql
   SELECT * FROM pg_proc WHERE proname = 'handle_new_user';
   ```
3. **Verifique se o trigger está ativo**: Execute no SQL Editor:
   ```sql
   SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';
   ```
4. **O código do app não precisa criar manualmente**: O trigger faz isso automaticamente. O código apenas atualiza o nome se fornecido

**Nota**: O código do app foi ajustado para não tentar criar o perfil manualmente, apenas atualizar o nome após o trigger criar o perfil automaticamente.

### Erro: "email not confirmed" ou "Por favor, confirme seu email"

Este erro ocorre quando a confirmação de email está habilitada no Supabase. Para desabilitar:

1. No dashboard do Supabase, vá em **Authentication** > **Providers**
2. Clique em **Email**
3. Desmarque a opção **"Confirm email"** ou **"Enable email confirmations"**
4. Salve as alterações

**Importante**: Com a confirmação desabilitada, os usuários podem fazer login imediatamente após o registro, sem precisar confirmar o email.

### Erro: "new row violates row-level security policy" ao fazer upload de foto

Este erro ocorre quando as políticas RLS do Storage não estão configuradas corretamente. Para corrigir:

1. **Certifique-se de que o bucket `profiles` foi criado** e está marcado como **Public**
2. **Execute o SQL da seção 6.3** para criar as políticas de Storage
3. **Se as políticas já existirem, remova-as e recrie:**

```sql
-- Remover políticas antigas (se existirem)
DROP POLICY IF EXISTS "Usuários podem fazer upload de suas próprias fotos" ON storage.objects;
DROP POLICY IF EXISTS "Usuários autenticados podem fazer upload de fotos" ON storage.objects;
DROP POLICY IF EXISTS "Usuários podem atualizar suas próprias fotos" ON storage.objects;
DROP POLICY IF EXISTS "Usuários podem deletar suas próprias fotos" ON storage.objects;

-- Criar políticas corretas
CREATE POLICY "Usuários autenticados podem fazer upload de fotos"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'profiles' AND
  auth.role() = 'authenticated' AND
  (storage.foldername(name))[1] = 'avatars'
);

CREATE POLICY "Usuários podem atualizar suas próprias fotos"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'profiles' AND
  auth.role() = 'authenticated' AND
  (name LIKE '%' || auth.uid()::text || '%')
);

CREATE POLICY "Usuários podem deletar suas próprias fotos"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'profiles' AND
  auth.role() = 'authenticated' AND
  (name LIKE '%' || auth.uid()::text || '%')
);
```

**Nota**: A política de SELECT já deve existir e permitir leitura pública. Se não existir, adicione:

```sql
CREATE POLICY "Fotos de perfil são públicas"
ON storage.objects FOR SELECT
USING (bucket_id = 'profiles');
```
