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
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
EXCEPTION
  WHEN others THEN
    -- Log do erro mas não falha o registro do usuário
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
  cor INTEGER NOT NULL,
  "dataCriacao" TEXT NOT NULL,
  deleted_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para melhorar performance
CREATE INDEX IF NOT EXISTS idx_classes_periodo ON classes(periodo);
CREATE INDEX IF NOT EXISTS idx_classes_user_id ON classes(user_id);

-- Habilitar Row Level Security (RLS)
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;

-- Política para permitir acesso apenas aos próprios dados (excluindo deletados)
CREATE POLICY "Usuários podem ver apenas suas próprias classes"
  ON classes
  FOR SELECT
  USING (auth.uid() = user_id AND deleted_at IS NULL);

CREATE POLICY "Usuários podem inserir apenas suas próprias classes"
  ON classes
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar apenas suas próprias classes"
  ON classes
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem deletar apenas suas próprias classes"
  ON classes
  FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- Tabela: exams (provas)
-- ============================================
-- Nota: As revisões são armazenadas como JSON dentro da tabela exams
CREATE TABLE IF NOT EXISTS exams (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  disciplinaId TEXT NOT NULL,
  disciplinaNome TEXT NOT NULL,
  dataProva TEXT NOT NULL,
  descricao TEXT NOT NULL DEFAULT '',
  revisoes JSONB NOT NULL DEFAULT '[]'::jsonb,
  cor INTEGER NOT NULL,
  deleted_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para melhorar performance
CREATE INDEX IF NOT EXISTS idx_exams_disciplinaId ON exams(disciplinaId);
CREATE INDEX IF NOT EXISTS idx_exams_dataProva ON exams(dataProva);
CREATE INDEX IF NOT EXISTS idx_exams_user_id ON exams(user_id);

-- Habilitar Row Level Security (RLS)
ALTER TABLE exams ENABLE ROW LEVEL SECURITY;

-- Política para permitir acesso apenas aos próprios dados (excluindo deletados)
CREATE POLICY "Usuários podem ver apenas suas próprias exams"
  ON exams
  FOR SELECT
  USING (auth.uid() = user_id AND deleted_at IS NULL);

CREATE POLICY "Usuários podem inserir apenas suas próprias exams"
  ON exams
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar apenas suas próprias exams"
  ON exams
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem deletar apenas suas próprias exams"
  ON exams
  FOR DELETE
  USING (auth.uid() = user_id);

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

-- Habilitar Row Level Security (RLS)
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;

-- Política para permitir acesso apenas aos próprios dados (excluindo deletados)
CREATE POLICY "Usuários podem ver apenas suas próprias goals"
  ON goals
  FOR SELECT
  USING (auth.uid() = user_id AND deleted_at IS NULL);

CREATE POLICY "Usuários podem inserir apenas suas próprias goals"
  ON goals
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar apenas suas próprias goals"
  ON goals
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem deletar apenas suas próprias goals"
  ON goals
  FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- Notas Importantes
-- ============================================
-- 1. Todas as datas são armazenadas como TEXT no formato ISO8601
-- 2. Cores são armazenadas como INTEGER (ARGB32)
-- 3. Revisões em exams são armazenadas como JSONB
-- 4. RLS está habilitado para todas as tabelas
-- 5. Soft delete implementado através da coluna deleted_at
-- 6. As políticas garantem que cada usuário só vê e modifica seus próprios dados
-- 7. O trigger handle_new_user cria automaticamente um perfil ao registrar um novo usuário
