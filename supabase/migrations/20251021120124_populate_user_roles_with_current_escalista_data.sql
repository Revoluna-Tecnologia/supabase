-- Migration: Populate user_roles with current escalista data
-- Created: 2025-10-21
-- Description: Migra todos os escalistas existentes para a tabela houston.user_roles

-- Temporariamente desabilitar RLS para esta migration
SET row_security = off;

-- Inserir todos os escalistas na tabela houston.user_roles
INSERT INTO houston.user_roles (
    user_id,
    role,
    group_ids,
    hospital_ids,
    setor_ids
)
SELECT 
    e.id as user_id,
    'escalista'::houston.app_role as role,
    CASE 
        WHEN e.grupo_id IS NOT NULL THEN ARRAY[e.grupo_id]
        ELSE ARRAY[]::uuid[]
    END as group_ids,
    ARRAY[]::uuid[] as hospital_ids,
    ARRAY[]::uuid[] as setor_ids
FROM public.escalistas e
WHERE e.escalista_status = 'ativo'
  AND NOT EXISTS (
    -- Evitar duplicatas caso a migração seja executada novamente
    SELECT 1 FROM houston.user_roles ur 
    WHERE ur.user_id = e.id AND ur.role = 'escalista'
  );

-- Reabilitar RLS
SET row_security = on;

