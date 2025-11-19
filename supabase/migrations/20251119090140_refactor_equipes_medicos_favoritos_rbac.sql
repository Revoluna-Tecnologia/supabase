-- Migration: Refactor RLS policies for equipes and medicos_favoritos to follow RBAC pattern
-- Data: 2025-11-19 09:01:40
-- Descrição: Padroniza políticas RLS das tabelas equipes e medicos_favoritos para seguir padrão RBAC

-- ============================================================================
-- TABELA: equipes
-- ============================================================================
DROP POLICY IF EXISTS "Delete policy" ON public.equipes;
DROP POLICY IF EXISTS "Insert policy" ON public.equipes;
DROP POLICY IF EXISTS "Read policy" ON public.equipes;
DROP POLICY IF EXISTS "Update policy" ON public.equipes;

CREATE POLICY "equipes_delete_policy" ON public.equipes
  FOR DELETE TO authenticated
  USING (
    houston.authorize('medicos.delete'::houston.app_permission, NULL, NULL, grupo_id)
  );

CREATE POLICY "equipes_insert_policy" ON public.equipes
  FOR INSERT TO authenticated
  WITH CHECK (
    houston.authorize('medicos.insert'::houston.app_permission, NULL, NULL, grupo_id)
  );

CREATE POLICY "equipes_select_policy" ON public.equipes
  FOR SELECT TO authenticated
  USING (
    houston.authorize('medicos.select'::houston.app_permission, NULL, NULL, grupo_id)
  );

CREATE POLICY "equipes_update_policy" ON public.equipes
  FOR UPDATE TO authenticated
  USING (
    houston.authorize('medicos.update'::houston.app_permission, NULL, NULL, grupo_id)
  )
  WITH CHECK (
    houston.authorize('medicos.update'::houston.app_permission, NULL, NULL, grupo_id)
  );

-- ============================================================================
-- TABELA: medicos_favoritos
-- ============================================================================
DROP POLICY IF EXISTS "medicos_favoritos_grupo_policy" ON public.medicos_favoritos;

CREATE POLICY "medicos_favoritos_delete_policy" ON public.medicos_favoritos
  FOR DELETE TO authenticated
  USING (
    houston.authorize('medicos.delete'::houston.app_permission, NULL, NULL, grupo_id)
  );

CREATE POLICY "medicos_favoritos_insert_policy" ON public.medicos_favoritos
  FOR INSERT TO authenticated
  WITH CHECK (
    houston.authorize('medicos.insert'::houston.app_permission, NULL, NULL, grupo_id)
  );

CREATE POLICY "medicos_favoritos_select_policy" ON public.medicos_favoritos
  FOR SELECT TO authenticated
  USING ((EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
    OR
    houston.authorize('medicos.select'::houston.app_permission, NULL, NULL, grupo_id)
  );

CREATE POLICY "medicos_favoritos_update_policy" ON public.medicos_favoritos
  FOR UPDATE TO authenticated
  USING (
    houston.authorize('medicos.update'::houston.app_permission, NULL, NULL, grupo_id)
  )
  WITH CHECK (
    houston.authorize('medicos.update'::houston.app_permission, NULL, NULL, grupo_id)
  );
