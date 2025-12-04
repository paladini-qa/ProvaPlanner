-- Script para verificar e deletar um usuário específico
-- Execute este script no SQL Editor do Supabase

-- ============================================
-- 1. Verificar se o usuário existe em auth.users
-- ============================================
SELECT 
  id,
  email,
  created_at,
  last_sign_in_at,
  email_confirmed_at,
  confirmed_at,
  deleted_at
FROM auth.users
WHERE email = 'paladinivitor.vp@gmail.com';

-- ============================================
-- 2. Verificar se existe perfil para este usuário
-- ============================================
SELECT 
  id,
  email,
  name,
  onboarding_completed,
  created_at
FROM profiles
WHERE email = 'paladinivitor.vp@gmail.com';

-- ============================================
-- 3. Verificar usuários com email similar (pode ter variação)
-- ============================================
SELECT 
  id,
  email,
  created_at
FROM auth.users
WHERE email LIKE '%paladinivitor%';

-- ============================================
-- 4. DELETAR o usuário específico (CUIDADO!)
-- ============================================
-- Descomente as linhas abaixo para deletar o usuário
-- Isso vai deletar o usuário de auth.users e o perfil (se existir) devido ao CASCADE
/*
DELETE FROM auth.users
WHERE email = 'paladinivitor.vp@gmail.com';
*/

-- ============================================
-- 5. Verificar todos os usuários (para debug)
-- ============================================
SELECT 
  id,
  email,
  created_at,
  last_sign_in_at,
  CASE 
    WHEN deleted_at IS NOT NULL THEN 'DELETADO'
    WHEN email_confirmed_at IS NULL THEN 'NÃO CONFIRMADO'
    ELSE 'ATIVO'
  END as status
FROM auth.users
ORDER BY created_at DESC
LIMIT 20;

