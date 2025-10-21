/*
  Migração: Policies baseadas em houston.role_permissions via houston.authorize
  Objetivo: Centralizar controle de permissões (vagas, medicos, medicos_precadastro) usando RBAC atual.
  Escopo: Apenas permissões globais por papel. NÃO inclui ainda escopos (grupo/hospital/setor) nem overrides.
  Assunções:
    - Função houston.authorize(requested_permission houston.app_permission) já existe e retorna boolean.
    - Token JWT contém claim user_role compatível com houston.app_role.
    - Policies existentes potencialmente conflituosas serão removidas/dropped aqui por nome específico antes da criação.

  Futuras extensões:
    - Substituir permissões globais por checagens contextuais (authorize_vaga / escopos).
    - Adicionar policies de membros e overrides dinâmicos.
*/

-- =============================
-- Helpers: Drop de policies antigas (se existirem)
-- =============================
DO $$
BEGIN
  -- VAGAS
  -- APAGAR AS ANTIGAS POLITICAS
  DROP POLICY IF EXISTS "vagas_delete_policy" ON public.vagas;
  DROP POLICY IF EXISTS "vagas_insert_policy" ON public.vagas;
  DROP POLICY IF EXISTS "vagas_select_policy" ON public.vagas;
  DROP POLICY IF EXISTS "vagas_update_policy" ON public.vagas;
  -- MEDICOS
  -- APAGAR POLITICAS ANTIGAS
  DROP POLICY IF EXISTS "Enable medicos users to view their own data only" ON public.medicos;
  DROP POLICY IF EXISTS "Enable medico users update their own data only" ON public.medicos;
  DROP POLICY IF EXISTS "Enable medicos users insert their own data only" ON public.medicos;
  DROP POLICY IF EXISTS "Enable escalista and astronauta users update medicos data" ON public.medicos;
  DROP POLICY IF EXISTS "Enable escalista users read all data" ON public.medicos;

END$$;

-- =============================
-- Policies para public.vagas
-- Permissões mapeadas: view -> SELECT, create -> INSERT, edit -> UPDATE, delete -> DELETE
-- =============================

CREATE POLICY vagas_select_rbac
ON public.vagas
FOR SELECT
TO authenticated
USING (
  houston.scheduler_belongs_can_access('vagas.view',vagas.hospital_id,vagas.setor_id, vagas.grupo_id )
);

CREATE POLICY vagas_insert_rbac
ON public.vagas
FOR INSERT
TO authenticated
WITH CHECK (houston.authorize('vagas.create'));

CREATE POLICY vagas_update_rbac
ON public.vagas
FOR UPDATE
TO authenticated
USING (houston.authorize('vagas.edit'))
WITH CHECK (houston.authorize('vagas.edit'));

CREATE POLICY vagas_delete_rbac
ON public.vagas
FOR DELETE
TO authenticated
USING (houston.authorize('vagas.delete'));

-- =============================
-- Policies para public.medicos (cadastro ativo)
-- Permissões: medicos.view / add / edit / remove
-- Nota: DELETE raramente é permitido; manter por consistência.
-- =============================

CREATE POLICY medicos_select_rbac
ON public.medicos
FOR SELECT
TO authenticated
USING (houston.authorize('medicos.view'));

CREATE POLICY medicos_insert_rbac
ON public.medicos
FOR INSERT
TO authenticated
WITH CHECK (houston.authorize('medicos.add'));

CREATE POLICY medicos_update_rbac
ON public.medicos
FOR UPDATE
TO authenticated
USING (houston.authorize('medicos.edit'))
WITH CHECK (houston.authorize('medicos.edit'));

CREATE POLICY medicos_delete_rbac
ON public.medicos
FOR DELETE
TO authenticated
USING (houston.authorize('medicos.remove'));

