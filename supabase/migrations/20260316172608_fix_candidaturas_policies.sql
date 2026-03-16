-- Migration: fix candidaturas RLS policies
-- Objetivo:
-- 1. Restaurar leitura das proprias candidaturas para usuarios mobile.
-- 2. Manter leitura de candidaturas de colegas apenas via regra controlada.
-- 3. Restringir UPDATE para impedir targeting de linhas de terceiros.

DROP POLICY IF EXISTS "candidaturas_select_policy" ON public.candidaturas;
DROP POLICY IF EXISTS "candidaturas_update_policy" ON public.candidaturas;

CREATE POLICY "candidaturas_select_policy" ON public.candidaturas
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.user_profile
      WHERE user_profile.id = (SELECT auth.uid())
    )
    AND (
      (SELECT auth.uid()) IN (medico_id, medico_precadastro_id)
      OR public.pode_ver_candidatura_colega(id)
    )
  );

CREATE POLICY "candidaturas_update_policy" ON public.candidaturas
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.user_profile
      WHERE user_profile.id = (SELECT auth.uid())
    )
    AND (SELECT auth.uid()) IN (medico_id, medico_precadastro_id)
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM public.user_profile
      WHERE user_profile.id = (SELECT auth.uid())
    )
    AND (SELECT auth.uid()) IN (medico_id, medico_precadastro_id)
  );
