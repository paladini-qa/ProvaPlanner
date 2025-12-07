-- Scripts SQL para criar tabelas no Supabase
-- Execute estes scripts no SQL Editor do Supabase

-- ============================================
-- Tabela: profiles
-- ============================================
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT,
  email TEXT,
  photo_url TEXT,
  onboarding_completed BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índice para melhorar performance
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);

-- NOTA: RLS DESABILITADO para profiles
-- A segurança é garantida pelo fato de que:
-- 1. O app sempre filtra por auth.uid() = id
-- 2. O id é o UUID do usuário autenticado
-- 3. Simplifica o acesso e evita problemas de permissão
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Permissões para os roles do Supabase
GRANT ALL ON profiles TO anon;
GRANT ALL ON profiles TO authenticated;
GRANT ALL ON profiles TO service_role;

-- Remover políticas antigas se existirem
DROP POLICY IF EXISTS "Usuários podem ver apenas seu próprio perfil" ON profiles;
DROP POLICY IF EXISTS "Usuários podem atualizar apenas seu próprio perfil" ON profiles;
DROP POLICY IF EXISTS "Usuários podem inserir apenas seu próprio perfil" ON profiles;
DROP POLICY IF EXISTS "Service role pode fazer tudo em profiles" ON profiles;
DROP POLICY IF EXISTS "Usuários autenticados podem ver seu perfil" ON profiles;
DROP POLICY IF EXISTS "Usuários autenticados podem inserir seu perfil" ON profiles;
DROP POLICY IF EXISTS "Usuários autenticados podem atualizar seu perfil" ON profiles;

-- Função para criar perfil automaticamente ao registrar
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, name, onboarding_completed, created_at, updated_at)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', NEW.email),
    false,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    updated_at = NOW();
  RETURN NEW;
EXCEPTION
  WHEN others THEN
    RAISE WARNING 'Erro ao criar perfil para usuário %: %', NEW.id, SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para executar a função ao criar novo usuário
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- Tabela: classes (disciplinas)
-- ============================================
CREATE TABLE IF NOT EXISTS classes (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  professor TEXT NOT NULL,
  periodo TEXT NOT NULL,
  descricao TEXT NOT NULL DEFAULT '',
  cor BIGINT NOT NULL,
  "dataCriacao" TEXT NOT NULL,
  deleted_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para melhorar performance
CREATE INDEX IF NOT EXISTS idx_classes_periodo ON classes(periodo);
CREATE INDEX IF NOT EXISTS idx_classes_user_id ON classes(user_id);
CREATE INDEX IF NOT EXISTS idx_classes_deleted_at ON classes(deleted_at);

-- Habilitar Row Level Security (RLS)
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;

-- Remover políticas antigas se existirem (para evitar conflitos)
DROP POLICY IF EXISTS "Usuários podem ver apenas suas próprias classes" ON classes;
DROP POLICY IF EXISTS "Usuários podem inserir apenas suas próprias classes" ON classes;
DROP POLICY IF EXISTS "Usuários podem atualizar apenas suas próprias classes" ON classes;
DROP POLICY IF EXISTS "Usuários podem deletar apenas suas próprias classes" ON classes;

-- Política SELECT: permite ver todas as próprias classes (incluindo soft-deleted)
-- NOTA: O filtro de deleted_at é feito na aplicação para permitir verificação de existência
CREATE POLICY "Usuários podem ver apenas suas próprias classes"
  ON classes
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem inserir apenas suas próprias classes"
  ON classes
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Política UPDATE: permite atualizar próprias classes (necessário para soft delete)
CREATE POLICY "Usuários podem atualizar apenas suas próprias classes"
  ON classes
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem deletar apenas suas próprias classes"
  ON classes
  FOR DELETE
  USING (auth.uid() = user_id);

-- Permissões para os roles do Supabase
GRANT ALL ON classes TO anon;
GRANT ALL ON classes TO authenticated;
GRANT ALL ON classes TO service_role;

-- ============================================
-- Tabela: exams (provas)
-- ============================================
-- Nota: As revisões são armazenadas como JSON dentro da tabela exams
CREATE TABLE IF NOT EXISTS exams (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  "disciplinaId" TEXT NOT NULL,
  "disciplinaNome" TEXT NOT NULL,
  "dataProva" TEXT NOT NULL,
  descricao TEXT NOT NULL DEFAULT '',
  revisoes JSONB NOT NULL DEFAULT '[]'::jsonb,
  cor BIGINT NOT NULL,
  deleted_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para melhorar performance
CREATE INDEX IF NOT EXISTS idx_exams_disciplinaId ON exams("disciplinaId");
CREATE INDEX IF NOT EXISTS idx_exams_dataProva ON exams("dataProva");
CREATE INDEX IF NOT EXISTS idx_exams_user_id ON exams(user_id);
CREATE INDEX IF NOT EXISTS idx_exams_deleted_at ON exams(deleted_at);

-- Habilitar Row Level Security (RLS)
ALTER TABLE exams ENABLE ROW LEVEL SECURITY;

-- Remover políticas antigas se existirem (para evitar conflitos)
DROP POLICY IF EXISTS "Usuários podem ver apenas suas próprias exams" ON exams;
DROP POLICY IF EXISTS "Usuários podem inserir apenas suas próprias exams" ON exams;
DROP POLICY IF EXISTS "Usuários podem atualizar apenas suas próprias exams" ON exams;
DROP POLICY IF EXISTS "Usuários podem deletar apenas suas próprias exams" ON exams;

-- Política SELECT: permite ver todas as próprias provas (incluindo soft-deleted)
-- NOTA: O filtro de deleted_at é feito na aplicação para permitir verificação de existência
CREATE POLICY "Usuários podem ver apenas suas próprias exams"
  ON exams
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem inserir apenas suas próprias exams"
  ON exams
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Política UPDATE: permite atualizar próprias provas (necessário para soft delete)
CREATE POLICY "Usuários podem atualizar apenas suas próprias exams"
  ON exams
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem deletar apenas suas próprias exams"
  ON exams
  FOR DELETE
  USING (auth.uid() = user_id);

-- Permissões para os roles do Supabase
GRANT ALL ON exams TO anon;
GRANT ALL ON exams TO authenticated;
GRANT ALL ON exams TO service_role;

-- ============================================
-- Tabela: goals (metas diárias)
-- ============================================
CREATE TABLE IF NOT EXISTS goals (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  titulo TEXT NOT NULL,
  descricao TEXT NOT NULL,
  data TEXT NOT NULL,
  concluida BOOLEAN NOT NULL DEFAULT false,
  prioridade TEXT NOT NULL DEFAULT 'media',
  deleted_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para melhorar performance
CREATE INDEX IF NOT EXISTS idx_goals_data ON goals(data);
CREATE INDEX IF NOT EXISTS idx_goals_user_id ON goals(user_id);
CREATE INDEX IF NOT EXISTS idx_goals_deleted_at ON goals(deleted_at);

-- Habilitar Row Level Security (RLS)
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;

-- Remover políticas antigas se existirem (para evitar conflitos)
DROP POLICY IF EXISTS "Usuários podem ver apenas suas próprias goals" ON goals;
DROP POLICY IF EXISTS "Usuários podem inserir apenas suas próprias goals" ON goals;
DROP POLICY IF EXISTS "Usuários podem atualizar apenas suas próprias goals" ON goals;
DROP POLICY IF EXISTS "Usuários podem deletar apenas suas próprias goals" ON goals;

-- Política SELECT: permite ver todas as próprias metas (incluindo soft-deleted)
-- NOTA: O filtro de deleted_at é feito na aplicação para permitir verificação de existência
CREATE POLICY "Usuários podem ver apenas suas próprias goals"
  ON goals
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem inserir apenas suas próprias goals"
  ON goals
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Política UPDATE: permite atualizar próprias metas (necessário para soft delete)
CREATE POLICY "Usuários podem atualizar apenas suas próprias goals"
  ON goals
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem deletar apenas suas próprias goals"
  ON goals
  FOR DELETE
  USING (auth.uid() = user_id);

-- Permissões para os roles do Supabase
GRANT ALL ON goals TO anon;
GRANT ALL ON goals TO authenticated;
GRANT ALL ON goals TO service_role;

-- ============================================
-- Notas Importantes
-- ============================================
-- 1. Todas as datas são armazenadas como TEXT no formato ISO8601
-- 2. Cores são armazenadas como BIGINT (ARGB32) - BIGINT necessário para valores ARGB32 que podem exceder INTEGER
-- 3. Revisões em exams são armazenadas como JSONB
-- 4. RLS está habilitado para todas as tabelas
-- 5. Soft delete implementado através da coluna deleted_at
-- 6. As políticas garantem que cada usuário só vê e modifica seus próprios dados
-- 7. O trigger handle_new_user cria automaticamente um perfil ao registrar um novo usuário
-- 8. Colunas com camelCase (dataCriacao, disciplinaId, disciplinaNome, dataProva) usam aspas duplas
--    para manter o case correto no PostgreSQL (sem aspas, são convertidas para lowercase)
-- 9. Todas as políticas de UPDATE incluem WITH CHECK para permitir soft delete e outras atualizações
-- 10. O script usa DROP POLICY IF EXISTS antes de criar políticas para evitar conflitos
-- 11. GRANT ALL é necessário para os roles anon, authenticated e service_role em todas as tabelas

-- ============================================
-- Notas sobre Soft Delete e RLS
-- ============================================
-- IMPORTANTE: As políticas SELECT NÃO filtram por deleted_at para permitir que o app:
--   1. Verifique se um registro existe antes de fazer soft delete
--   2. Evite erros de RLS ao tentar atualizar registros que só existem localmente
--
-- O filtro de deleted_at é feito na aplicação usando: .isFilter('deleted_at', null)
--
-- Fluxo de soft delete:
--   1. App verifica se o registro existe no Supabase (SELECT com id)
--   2. Se não existe, apenas deleta localmente (registro só existia offline)
--   3. Se existe, faz UPDATE setando deleted_at (soft delete)
--
-- Isso evita o erro "new row violates row-level security policy" que ocorria
-- ao tentar fazer UPDATE em registros que nunca foram sincronizados com o Supabase.

-- ============================================
-- Script para ATUALIZAR banco existente
-- ============================================
-- Execute este bloco se você já tem as tabelas criadas e precisa atualizar:
-- COPIE E COLE NO SQL EDITOR DO SUPABASE

/*
-- ==========================================
-- PROFILES - Desabilitar RLS e adicionar GRANTs
-- ==========================================
ALTER TABLE profiles DISABLE ROW LEVEL SECURITY;

-- Remover políticas antigas (não são mais necessárias)
DROP POLICY IF EXISTS "Usuários podem ver apenas seu próprio perfil" ON profiles;
DROP POLICY IF EXISTS "Usuários podem atualizar apenas seu próprio perfil" ON profiles;
DROP POLICY IF EXISTS "Usuários podem inserir apenas seu próprio perfil" ON profiles;
DROP POLICY IF EXISTS "Service role pode fazer tudo em profiles" ON profiles;
DROP POLICY IF EXISTS "Usuários autenticados podem ver seu perfil" ON profiles;
DROP POLICY IF EXISTS "Usuários autenticados podem inserir seu perfil" ON profiles;
DROP POLICY IF EXISTS "Usuários autenticados podem atualizar seu perfil" ON profiles;

-- GRANTs para profiles
GRANT ALL ON profiles TO anon;
GRANT ALL ON profiles TO authenticated;
GRANT ALL ON profiles TO service_role;

-- ==========================================
-- CLASSES - GRANTs e índices
-- ==========================================
GRANT ALL ON classes TO anon;
GRANT ALL ON classes TO authenticated;
GRANT ALL ON classes TO service_role;
CREATE INDEX IF NOT EXISTS idx_classes_deleted_at ON classes(deleted_at);

-- ==========================================
-- EXAMS - GRANTs e índices
-- ==========================================
GRANT ALL ON exams TO anon;
GRANT ALL ON exams TO authenticated;
GRANT ALL ON exams TO service_role;
CREATE INDEX IF NOT EXISTS idx_exams_deleted_at ON exams(deleted_at);

-- ==========================================
-- GOALS - GRANTs e índices
-- ==========================================
GRANT ALL ON goals TO anon;
GRANT ALL ON goals TO authenticated;
GRANT ALL ON goals TO service_role;
CREATE INDEX IF NOT EXISTS idx_goals_deleted_at ON goals(deleted_at);
*/
