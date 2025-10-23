-- =============================================================================
-- MIGRATION: Update Policies for Vagas, Grupo and Escalista Tables
-- =============================================================================
-- Created: 2025-10-23
-- Author: System
-- Description: Atualiza as políticas das tabelas vagas, grupo e escalista 
--              para usar a função houston.authorize com verificação contextual
-- Version: 1.0
-- 
-- Esta migration contém:
-- 1. Atualização das políticas da tabela vagas
-- 2. Atualização das políticas da tabela grupo  
-- 3. Atualização das políticas da tabela escalista
-- 4. Uso da função houston.authorize com contexto apropriado
-- =============================================================================

-- =============================================================================
-- 1. ATUALIZAÇÃO DAS POLÍTICAS DA TABELA VAGAS
-- =============================================================================
-- Propósito: Usar houston.authorize com verificação contextual completa
-- Contexto: hospital_id, setor_id, grupo_id extraídos dos campos da vaga
-- =============================================================================

DO $$
BEGIN
  -- Remover políticas antigas da tabela vagas
  DROP POLICY IF EXISTS "vagas_select_rbac" ON public.vagas;
  DROP POLICY IF EXISTS "vagas_insert_rbac" ON public.vagas;
  DROP POLICY IF EXISTS "vagas_update_rbac" ON public.vagas;
  DROP POLICY IF EXISTS "vagas_delete_rbac" ON public.vagas;
  DROP POLICY IF EXISTS "vagas_delete_policy" ON public.vagas;
  DROP POLICY IF EXISTS "vagas_insert_policy" ON public.vagas;
  DROP POLICY IF EXISTS "vagas_select_policy" ON public.vagas;
  DROP POLICY IF EXISTS "vagas_update_policy" ON public.vagas;
END $$;

-- Política de SELECT para vagas com verificação contextual
CREATE POLICY vagas_select_houston_rbac
ON public.vagas
FOR SELECT
TO authenticated
USING (
  houston.authorize(
    'vagas.view'::houston.app_permission,
    vagas_hospital,    -- hospital_id
    vagas_setor,       -- setor_id
    grupo_id           -- group_id
  )
);

-- Política de INSERT para vagas
CREATE POLICY vagas_insert_houston_rbac
ON public.vagas
FOR INSERT
TO authenticated
WITH CHECK (
  houston.authorize(
    'vagas.create'::houston.app_permission,
    vagas_hospital,    -- hospital_id
    vagas_setor,       -- setor_id
    grupo_id           -- group_id
  )
);

-- Política de UPDATE para vagas
CREATE POLICY vagas_update_houston_rbac
ON public.vagas
FOR UPDATE
TO authenticated
USING (
  houston.authorize(
    'vagas.edit'::houston.app_permission,
    vagas_hospital,    -- hospital_id
    vagas_setor,       -- setor_id
    grupo_id           -- group_id
  )
)
WITH CHECK (
  houston.authorize(
    'vagas.edit'::houston.app_permission,
    vagas_hospital,    -- hospital_id
    vagas_setor,       -- setor_id
    grupo_id           -- group_id
  )
);

-- Política de DELETE para vagas
CREATE POLICY vagas_delete_houston_rbac
ON public.vagas
FOR DELETE
TO authenticated
USING (
  houston.authorize(
    'vagas.delete'::houston.app_permission,
    vagas_hospital,    -- hospital_id
    vagas_setor,       -- setor_id
    grupo_id           -- group_id
  )
);

-- =============================================================================
-- 2. ATUALIZAÇÃO DAS POLÍTICAS DA TABELA GRUPO
-- =============================================================================
-- Propósito: Atualizar políticas para usar houston.authorize com contexto grupo
-- Formato: houston.authorize(permission, NULL, NULL, grupo_id)
-- =============================================================================

DO $$
BEGIN
  -- Remover políticas antigas da tabela grupo
  DROP POLICY IF EXISTS "grupo_read_all" ON public.grupos;
  DROP POLICY IF EXISTS "grupo_insert_own" ON public.grupos;
  DROP POLICY IF EXISTS "grupo_update_own" ON public.grupos;
  DROP POLICY IF EXISTS "grupo_delete_own" ON public.grupos;
  DROP POLICY IF EXISTS "Enable full acess to astronauta user" ON public.grupos;
  DROP POLICY IF EXISTS "Enable read to medico users" ON public.grupos;
END $$;

-- Política de SELECT para grupo com verificação contextual
CREATE POLICY grupo_select_houston_rbac
ON public.grupos
FOR SELECT
TO authenticated
USING (
  houston.authorize(
    'grupos.view'::houston.app_permission,
    NULL::uuid,        -- hospital_id (não aplicável para grupo)
    NULL::uuid,        -- setor_id (não aplicável para grupo)
    grupo_id           -- group_id
  )
);

-- Política de INSERT para grupo
CREATE POLICY grupo_insert_houston_rbac
ON public.grupo
FOR INSERT
TO authenticated
WITH CHECK (
  houston.authorize(
    'grupos.add'::houston.app_permission,
    NULL::uuid,        -- hospital_id (não aplicável para grupo)
    NULL::uuid,        -- setor_id (não aplicável para grupo)
    grupo_id           -- group_id
  )
);

-- Política de UPDATE para grupo
CREATE POLICY grupo_update_houston_rbac
ON public.grupos
FOR UPDATE
TO authenticated
USING (
  houston.authorize(
    'grupos.edit'::houston.app_permission,
    NULL::uuid,        -- hospital_id (não aplicável para grupo)
    NULL::uuid,        -- setor_id (não aplicável para grupo)
    grupo_id           -- group_id
  )
)
WITH CHECK (
  houston.authorize(
    'grupos.edit'::houston.app_permission,
    NULL::uuid,        -- hospital_id (não aplicável para grupo)
    NULL::uuid,        -- setor_id (não aplicável para grupo)
    grupo_id           -- group_id
  )
);

-- Política de DELETE para grupo
CREATE POLICY grupo_delete_houston_rbac
ON public.grupos
FOR DELETE
TO authenticated
USING (
  houston.authorize(
    'grupos.remove'::houston.app_permission,
    NULL::uuid,        -- hospital_id (não aplicável para grupo)
    NULL::uuid,        -- setor_id (não aplicável para grupo)
    grupo_id           -- group_id
  )
);

-- =============================================================================
-- 3. ATUALIZAÇÃO DAS POLÍTICAS DA TABELA ESCALISTA
-- =============================================================================
-- Propósito: Atualizar políticas para usar houston.authorize com contexto grupo
-- Formato: houston.authorize(permission, NULL, NULL, grupo_id)
-- =============================================================================

DO $$
BEGIN
  -- Remover políticas antigas da tabela escalista
  DROP POLICY IF EXISTS "escalista_read_all" ON public.escalistas;
  DROP POLICY IF EXISTS "escalista_insert_own" ON public.escalistas;
  DROP POLICY IF EXISTS "escalista_update_own" ON public.escalistas;
  DROP POLICY IF EXISTS "escalista_delete_own" ON public.escalistas;
  DROP POLICY IF EXISTS "Enable full access to astronauta user" ON public.escalistas;
  DROP POLICY IF EXISTS "Enable read access for all authenticated users" ON public.escalistas;
  DROP POLICY IF EXISTS "escalista_policy" ON public.escalistas;
END $$;

-- Política de SELECT para escalista com verificação contextual
CREATE POLICY escalista_select_houston_rbac
ON public.escalistas
FOR SELECT
TO authenticated
USING (
  houston.authorize(
    'membros.view'::houston.app_permission,
    NULL::uuid,        -- hospital_id (não aplicável para escalista)
    NULL::uuid,        -- setor_id (não aplicável para escalista)
    grupo_id           -- group_id
  )
);

-- Política de INSERT para escalista
CREATE POLICY escalista_insert_houston_rbac
ON public.escalistas
FOR INSERT
TO authenticated
WITH CHECK (
  houston.authorize(
    'membros.add'::houston.app_permission,
    NULL::uuid,        -- hospital_id (não aplicável para escalista)
    NULL::uuid,        -- setor_id (não aplicável para escalista)
    grupo_id           -- group_id
  )
);

-- Política de UPDATE para escalista
CREATE POLICY escalista_update_houston_rbac
ON public.escalistas
FOR UPDATE
TO authenticated
USING (
  houston.authorize(
    'membros.edit'::houston.app_permission,
    NULL::uuid,        -- hospital_id (não aplicável para escalista)
    NULL::uuid,        -- setor_id (não aplicável para escalista)
    grupo_id           -- group_id
  )
)
WITH CHECK (
  houston.authorize(
    'membros.edit'::houston.app_permission,
    NULL::uuid,        -- hospital_id (não aplicável para escalista)
    NULL::uuid,        -- setor_id (não aplicável para escalista)
    grupo_id           -- group_id
  )
);

-- Política de DELETE para escalista
CREATE POLICY escalista_delete_houston_rbac
ON public.escalistas
FOR DELETE
TO authenticated
USING (
  houston.authorize(
    'membros.remove'::houston.app_permission,
    NULL::uuid,        -- hospital_id (não aplicável para escalista)
    NULL::uuid,        -- setor_id (não aplicável para escalista)
    grupo_id           -- group_id
  )
);

-- =============================================================================
-- 4. COMENTÁRIOS E DOCUMENTAÇÃO DAS POLÍTICAS
-- =============================================================================

-- Comentários sobre as políticas de vagas
COMMENT ON POLICY vagas_select_houston_rbac ON public.vagas 
IS 'Política de SELECT para vagas usando houston.authorize com verificação contextual completa (hospital, setor, grupo)';

COMMENT ON POLICY vagas_insert_houston_rbac ON public.vagas 
IS 'Política de INSERT para vagas usando houston.authorize com verificação contextual completa (hospital, setor, grupo)';

COMMENT ON POLICY vagas_update_houston_rbac ON public.vagas 
IS 'Política de UPDATE para vagas usando houston.authorize com verificação contextual completa (hospital, setor, grupo)';

COMMENT ON POLICY vagas_delete_houston_rbac ON public.vagas 
IS 'Política de DELETE para vagas usando houston.authorize com verificação contextual completa (hospital, setor, grupo)';

-- Comentários sobre as políticas de grupo
COMMENT ON POLICY grupo_select_houston_rbac ON public.grupos 
IS 'Política de SELECT para grupo usando houston.authorize com verificação de contexto grupo específico';

COMMENT ON POLICY grupo_insert_houston_rbac ON public.grupos 
IS 'Política de INSERT para grupo usando houston.authorize com verificação de contexto grupo específico';

COMMENT ON POLICY grupo_update_houston_rbac ON public.grupos 
IS 'Política de UPDATE para grupo usando houston.authorize com verificação de contexto grupo específico';

COMMENT ON POLICY grupo_delete_houston_rbac ON public.grupos
IS 'Política de DELETE para grupo usando houston.authorize com verificação de contexto grupo específico';

-- Comentários sobre as políticas de escalista
COMMENT ON POLICY escalista_select_houston_rbac ON public.escalistas 
IS 'Política de SELECT para escalista usando houston.authorize com verificação de contexto grupo (permissões de membros)';

COMMENT ON POLICY escalista_insert_houston_rbac ON public.escalistas 
IS 'Política de INSERT para escalista usando houston.authorize com verificação de contexto grupo (permissões de membros)';

COMMENT ON POLICY escalista_update_houston_rbac ON public.escalistas 
IS 'Política de UPDATE para escalista usando houston.authorize com verificação de contexto grupo (permissões de membros)';

COMMENT ON POLICY escalista_delete_houston_rbac ON public.escalistas 
IS 'Política de DELETE para escalista usando houston.authorize com verificação de contexto grupo (permissões de membros)';

-- =============================================================================
-- 5. VERIFICAÇÃO DE INTEGRIDADE
-- =============================================================================
-- Verificar se as funções houston necessárias existem

DO $$
BEGIN
  -- Verificar se a função houston.authorize existe
  IF NOT EXISTS (
    SELECT 1 FROM pg_proc p 
    JOIN pg_namespace n ON p.pronamespace = n.oid 
    WHERE n.nspname = 'houston' AND p.proname = 'authorize'
  ) THEN
    RAISE EXCEPTION 'Função houston.authorize não encontrada. Execute primeiro a migration das funções Houston.';
  END IF;
  
  RAISE NOTICE 'Verificação de integridade concluída com sucesso.';
END $$;

-- =============================================================================
-- FIM DA MIGRATION
-- =============================================================================
-- 
-- RESUMO DAS ATUALIZAÇÕES:
-- 
-- 1. TABELA VAGAS:
--    - Políticas atualizadas para usar houston.authorize com contexto completo
--    - Verificação de hospital_id, setor_id e grupo_id em todas as operações
--    - Nomes das políticas atualizados para refletir o uso do Houston RBAC
-- 
-- 2. TABELA GRUPO:
--    - Políticas atualizadas para usar houston.authorize com contexto grupo
--    - Formato: houston.authorize(permission::houston.app_permission, NULL, NULL, grupo_id)
--    - Verificação de acesso baseada no grupo_id específico
-- 
-- 3. TABELA ESCALISTA:
--    - Políticas atualizadas para usar houston.authorize com contexto grupo
--    - Formato: houston.authorize(permission::houston.app_permission, NULL, NULL, grupo_id)
--    - Permissões de membros: membros.view, membros.add, membros.edit, membros.remove
--    - Verificação de acesso baseada no grupo_id específico
-- 
-- COMO FUNCIONA:
-- 
-- - Admin/Gestor: Acesso total sempre (bypass de todas as verificações)
-- - Outros roles: Verificam permissão + contexto (hospital, setor, grupo)
-- - Arrays vazios no usuário = sem restrição para aquele contexto
-- - Cada operação verifica se o usuário tem acesso ao contexto específico
-- 
-- EXEMPLO DE USO:
-- 
-- -- Usuário com permissão vagas.view e acesso ao hospital/setor/grupo da vaga
-- SELECT * FROM vagas WHERE vagas_id = 'some-uuid';
-- 
-- -- Usuário sem acesso ao contexto da vaga = sem resultados
-- SELECT * FROM vagas; -- Retorna apenas vagas dos seus contextos
-- 
-- =============================================================================


