-- Script para corrigir o trigger e verificar usuários
-- Execute este script no SQL Editor do Supabase

-- ============================================
-- 1. Verificar se há usuários sem perfil
-- ============================================
SELECT 
  u.id,
  u.email,
  u.created_at,
  CASE WHEN p.id IS NULL THEN 'SEM PERFIL' ELSE 'COM PERFIL' END as status
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
ORDER BY u.created_at DESC;

-- ============================================
-- 2. Criar perfis para usuários órfãos (se necessário)
-- ============================================
-- Descomente as linhas abaixo se houver usuários sem perfil
/*
INSERT INTO public.profiles (id, email, name, onboarding_completed)
SELECT 
  u.id,
  u.email,
  COALESCE(u.raw_user_meta_data->>'name', u.email) as name,
  false as onboarding_completed
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
WHERE p.id IS NULL
ON CONFLICT (id) DO NOTHING;
*/

-- ============================================
-- 3. Atualizar o trigger para evitar conflitos
-- ============================================
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

-- ============================================
-- 4. Recriar o trigger
-- ============================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- 5. Verificar se o trigger está funcionando
-- ============================================
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE trigger_name = 'on_auth_user_created';

