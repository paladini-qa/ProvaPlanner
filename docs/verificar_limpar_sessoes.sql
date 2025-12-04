-- Script para verificar e limpar sessões/usuários órfãos
-- Execute este script no SQL Editor do Supabase

-- ============================================
-- 1. Verificar usuários na tabela auth.users
-- ============================================
SELECT 
  id,
  email,
  created_at,
  last_sign_in_at,
  CASE 
    WHEN last_sign_in_at IS NULL THEN 'Nunca fez login'
    WHEN last_sign_in_at < NOW() - INTERVAL '30 days' THEN 'Inativo há mais de 30 dias'
    ELSE 'Ativo'
  END as status
FROM auth.users
ORDER BY created_at DESC;

-- ============================================
-- 2. Verificar perfis na tabela profiles
-- ============================================
SELECT 
  id,
  email,
  name,
  onboarding_completed,
  created_at
FROM profiles
ORDER BY created_at DESC;

-- ============================================
-- 3. Verificar usuários sem perfil
-- ============================================
SELECT 
  u.id,
  u.email,
  u.created_at,
  'SEM PERFIL' as problema
FROM auth.users u
LEFT JOIN public.profiles p ON u.id = p.id
WHERE p.id IS NULL;

-- ============================================
-- 4. Verificar perfis sem usuário (não deveria acontecer devido ao CASCADE)
-- ============================================
SELECT 
  p.id,
  p.email,
  p.name,
  'SEM USUÁRIO' as problema
FROM public.profiles p
LEFT JOIN auth.users u ON p.id = u.id
WHERE u.id IS NULL;

-- ============================================
-- 5. DELETAR usuários órfãos (CUIDADO: Isso deleta permanentemente!)
-- ============================================
-- Descomente apenas se quiser deletar usuários sem perfil
/*
DELETE FROM auth.users
WHERE id NOT IN (SELECT id FROM public.profiles);
*/

-- ============================================
-- 6. Limpar sessões expiradas (se necessário)
-- ============================================
-- Nota: O Supabase gerencia sessões automaticamente
-- Este script é apenas para verificação

