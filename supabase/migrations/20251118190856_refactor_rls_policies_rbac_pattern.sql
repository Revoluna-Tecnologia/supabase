-- Migration: Refactor RLS policies to follow RBAC pattern
-- Data: 2025-11-18 19:08:56
-- Descrição: Reescreve políticas RLS para seguir padrão RBAC consistente

-- ============================================================================
-- TABELA: medicos
-- ============================================================================
DROP POLICY IF EXISTS "medicos_delete_policy" ON public.medicos;
DROP POLICY IF EXISTS "medicos_insert_policy" ON public.medicos;
DROP POLICY IF EXISTS "medicos_select_policy" ON public.medicos;
DROP POLICY IF EXISTS "medicos_update_policy" ON public.medicos;

CREATE POLICY "medicos_delete_policy" ON public.medicos
  FOR DELETE TO authenticated
  USING (
    (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
    AND auth.uid() = id
  );

CREATE POLICY "medicos_insert_policy" ON public.medicos
  FOR INSERT TO authenticated
  WITH CHECK (
    (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
    AND auth.uid() = id
  );

CREATE POLICY "medicos_select_policy" ON public.medicos
  FOR SELECT TO authenticated
  USING (
    (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
    OR houston.authorize_simple('medicos.select'::houston.app_permission)
  );

CREATE POLICY "medicos_update_policy" ON public.medicos
  FOR UPDATE TO authenticated
  USING (
    (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
    AND auth.uid() = id
  )
  WITH CHECK (
    (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
    AND auth.uid() = id
  );

-- ============================================================================
-- TABELA: medicos_precadastro
-- ============================================================================
DROP POLICY IF EXISTS "medicos_precadastro_delete_policy" ON public.medicos_precadastro;
DROP POLICY IF EXISTS "medicos_precadastro_insert_policy" ON public.medicos_precadastro;
DROP POLICY IF EXISTS "medicos_precadastro_select_policy" ON public.medicos_precadastro;
DROP POLICY IF EXISTS "medicos_precadastro_update_policy" ON public.medicos_precadastro;

-- Unificando permissões: medicos_precadastro agora usa permissões 'medicos.*'
CREATE POLICY "medicos_precadastro_delete_policy" ON public.medicos_precadastro
  FOR DELETE TO authenticated
  USING (
    houston.authorize_simple('medicos.delete'::houston.app_permission)
  );

CREATE POLICY "medicos_precadastro_insert_policy" ON public.medicos_precadastro
  FOR INSERT TO authenticated
  WITH CHECK (
    houston.authorize_simple('medicos.insert'::houston.app_permission)
  );

CREATE POLICY "medicos_precadastro_select_policy" ON public.medicos_precadastro
  FOR SELECT TO authenticated
  USING (
    (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
    OR houston.authorize_simple('medicos.select'::houston.app_permission)
  );

CREATE POLICY "medicos_precadastro_update_policy" ON public.medicos_precadastro
  FOR UPDATE TO authenticated
  USING (
    houston.authorize_simple('medicos.update'::houston.app_permission)
  )
  WITH CHECK (
    houston.authorize_simple('medicos.update'::houston.app_permission)
  );

-- ============================================================================
-- TABELA: equipes_medicos
-- ============================================================================
DROP POLICY IF EXISTS "Delete policy" ON public.equipes_medicos;
DROP POLICY IF EXISTS "Insert policy" ON public.equipes_medicos;
DROP POLICY IF EXISTS "Read policy" ON public.equipes_medicos;
DROP POLICY IF EXISTS "Update policy" ON public.equipes_medicos;

CREATE POLICY "equipes_medicos_delete_policy" ON public.equipes_medicos
  FOR DELETE TO authenticated
  USING (
    houston.authorize('medicos.delete'::houston.app_permission, NULL, NULL, grupo_id)
  );

CREATE POLICY "equipes_medicos_insert_policy" ON public.equipes_medicos
  FOR INSERT TO authenticated
  WITH CHECK (
    houston.authorize('medicos.insert'::houston.app_permission, NULL, NULL, grupo_id)
  );

CREATE POLICY "equipes_medicos_select_policy" ON public.equipes_medicos
  FOR SELECT TO authenticated
  USING (
    houston.authorize('medicos.select'::houston.app_permission, NULL, NULL, grupo_id)
  );

CREATE POLICY "equipes_medicos_update_policy" ON public.equipes_medicos
  FOR UPDATE TO authenticated
  USING (
    houston.authorize('medicos.update'::houston.app_permission, NULL, NULL, grupo_id)
  )
  WITH CHECK (
    houston.authorize('medicos.update'::houston.app_permission, NULL, NULL, grupo_id)
  );

-- ============================================================================
-- TABELA: hospitais
-- ============================================================================
DROP POLICY IF EXISTS "Enable full acess to astronauta users" ON public.hospitais;
DROP POLICY IF EXISTS "Enable insert to escalista users" ON public.hospitais;
DROP POLICY IF EXISTS "Enable read access for authenticated users" ON public.hospitais;
DROP POLICY IF EXISTS "Enable update to escalista users" ON public.hospitais;

CREATE POLICY "hospitais_delete_policy" ON public.hospitais
  FOR DELETE TO authenticated
  USING (
    houston.authorize('hospitais.update'::houston.app_permission, id, NULL, NULL)
  );

CREATE POLICY "hospitais_insert_policy" ON public.hospitais
  FOR INSERT TO authenticated
  WITH CHECK (
    houston.authorize('hospitais.update'::houston.app_permission, id, NULL, NULL)
  );

CREATE POLICY "hospitais_select_policy" ON public.hospitais
  FOR SELECT TO authenticated
  USING (
    (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
    OR houston.authorize('hospitais.update'::houston.app_permission, id, NULL, NULL)
  );

CREATE POLICY "hospitais_update_policy" ON public.hospitais
  FOR UPDATE TO authenticated
  USING (
    houston.authorize('hospitais.update'::houston.app_permission, id, NULL, NULL)
  )
  WITH CHECK (
    houston.authorize('hospitais.update'::houston.app_permission, id, NULL, NULL)
  );

-- ============================================================================
-- TABELA: checkin_checkout
-- ============================================================================
DROP POLICY IF EXISTS "Enable medico users full access to their own data" ON public.checkin_checkout;
DROP POLICY IF EXISTS "Enable read access to escalista users" ON public.checkin_checkout;

CREATE POLICY "checkin_checkout_delete_policy" ON public.checkin_checkout
  FOR DELETE TO authenticated
  USING (
    (
      (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
      AND auth.uid() = medico_id
    )
    OR (
      EXISTS (
        SELECT 1 FROM public.vagas v
        WHERE v.id = checkin_checkout.vaga_id
          AND houston.authorize('relatorios.delete'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
      )
    )
  );

CREATE POLICY "checkin_checkout_insert_policy" ON public.checkin_checkout
  FOR INSERT TO authenticated
  WITH CHECK (
    (
      (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
      AND auth.uid() = medico_id
    )
    OR (
      EXISTS (
        SELECT 1 FROM public.vagas v
        WHERE v.id = checkin_checkout.vaga_id
          AND houston.authorize('relatorios.insert'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
      )
    )
  );

CREATE POLICY "checkin_checkout_select_policy" ON public.checkin_checkout
  FOR SELECT TO authenticated
  USING (
    (
      (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
      AND auth.uid() = medico_id
    )
    OR (
      EXISTS (
        SELECT 1 FROM public.vagas v
        WHERE v.id = checkin_checkout.vaga_id
          AND houston.authorize('relatorios.select'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
      )
    )
  );

CREATE POLICY "checkin_checkout_update_policy" ON public.checkin_checkout
  FOR UPDATE TO authenticated
  USING (
    (
      (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
      AND auth.uid() = medico_id
    )
    OR (
      EXISTS (
        SELECT 1 FROM public.vagas v
        WHERE v.id = checkin_checkout.vaga_id
          AND houston.authorize('relatorios.update'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
      )
    )
  )
  WITH CHECK (
    (
      (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
      AND auth.uid() = medico_id
    )
    OR (
      EXISTS (
        SELECT 1 FROM public.vagas v
        WHERE v.id = checkin_checkout.vaga_id
          AND houston.authorize('relatorios.update'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
      )
    )
  );

-- ============================================================================
-- TABELA: grades
-- ============================================================================
DROP POLICY IF EXISTS "astronauts_can_delete_grades" ON public.grades;
DROP POLICY IF EXISTS "astronauts_can_insert_grades" ON public.grades;
DROP POLICY IF EXISTS "astronauts_can_select_grades" ON public.grades;
DROP POLICY IF EXISTS "astronauts_can_update_grades" ON public.grades;
DROP POLICY IF EXISTS "grades_delete_by_group" ON public.grades;
DROP POLICY IF EXISTS "grades_insert_by_group" ON public.grades;
DROP POLICY IF EXISTS "grades_select_by_group" ON public.grades;
DROP POLICY IF EXISTS "grades_update_by_group" ON public.grades;

CREATE POLICY "grades_delete_policy" ON public.grades
  FOR DELETE TO authenticated
  USING (
    houston.authorize('vagas.delete'::houston.app_permission, hospital_id, setor_id, grupo_id)
  );

CREATE POLICY "grades_insert_policy" ON public.grades
  FOR INSERT TO authenticated
  WITH CHECK (
    houston.authorize('vagas.insert'::houston.app_permission, hospital_id, setor_id, grupo_id)
  );

CREATE POLICY "grades_select_policy" ON public.grades
  FOR SELECT TO authenticated
  USING (
    (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
    OR houston.authorize('vagas.select'::houston.app_permission, hospital_id, setor_id, grupo_id)
  );

CREATE POLICY "grades_update_policy" ON public.grades
  FOR UPDATE TO authenticated
  USING (
    houston.authorize('vagas.update'::houston.app_permission, hospital_id, setor_id, grupo_id)
  )
  WITH CHECK (
    houston.authorize('vagas.update'::houston.app_permission, hospital_id, setor_id, grupo_id)
  );

-- ============================================================================
-- TABELA: pagamentos
-- ============================================================================
DROP POLICY IF EXISTS "Enable medico user full access to their own data" ON public.pagamentos;
DROP POLICY IF EXISTS "pagamentos_escalista_policy" ON public.pagamentos;

CREATE POLICY "pagamentos_delete_policy" ON public.pagamentos
  FOR DELETE TO authenticated
  USING (
    (
      (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
      AND (auth.uid() = medico_id OR auth.uid() = medicos_id)
    )
    OR (
      EXISTS (
        SELECT 1 FROM public.vagas v
        WHERE v.id = pagamentos.vaga_id
          AND houston.authorize('relatorios.delete'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
      )
    )
  );

CREATE POLICY "pagamentos_insert_policy" ON public.pagamentos
  FOR INSERT TO authenticated
  WITH CHECK (
    (
      (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
      AND (auth.uid() = medico_id OR auth.uid() = medicos_id)
    )
    OR (
      EXISTS (
        SELECT 1 FROM public.vagas v
        WHERE v.id = pagamentos.vaga_id
          AND houston.authorize('relatorios.insert'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
      )
    )
  );

CREATE POLICY "pagamentos_select_policy" ON public.pagamentos
  FOR SELECT TO authenticated
  USING (
    (
      (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
      AND (auth.uid() = medico_id OR auth.uid() = medicos_id)
    )
    OR (
      EXISTS (
        SELECT 1 FROM public.vagas v
        WHERE v.id = pagamentos.vaga_id
          AND houston.authorize('relatorios.select'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
      )
    )
  );

CREATE POLICY "pagamentos_update_policy" ON public.pagamentos
  FOR UPDATE TO authenticated
  USING (
    (
      (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
      AND (auth.uid() = medico_id OR auth.uid() = medicos_id)
    )
    OR (
      EXISTS (
        SELECT 1 FROM public.vagas v
        WHERE v.id = pagamentos.vaga_id
          AND houston.authorize('relatorios.update'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
      )
    )
  )
  WITH CHECK (
    (
      (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
      AND (auth.uid() = medico_id OR auth.uid() = medicos_id)
    )
    OR (
      EXISTS (
        SELECT 1 FROM public.vagas v
        WHERE v.id = pagamentos.vaga_id
          AND houston.authorize('relatorios.update'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
      )
    )
  );

-- ============================================================================
-- TABELA: vagas_beneficios
-- ============================================================================
DROP POLICY IF EXISTS "Enable full access to astronauta users" ON public.vagas_beneficios;
DROP POLICY IF EXISTS "Enable read access for all users" ON public.vagas_beneficios;
DROP POLICY IF EXISTS "vagas_beneficio_escalista_policy" ON public.vagas_beneficios;

CREATE POLICY "vagas_beneficios_delete_policy" ON public.vagas_beneficios
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.vagas v
      WHERE v.id = vagas_beneficios.vaga_id
        AND houston.authorize('vagas.delete'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
    )
  );

CREATE POLICY "vagas_beneficios_insert_policy" ON public.vagas_beneficios
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.vagas v
      WHERE v.id = vagas_beneficios.vaga_id
        AND houston.authorize('vagas.insert'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
    )
  );

CREATE POLICY "vagas_beneficios_select_policy" ON public.vagas_beneficios
  FOR SELECT TO authenticated
  USING (
    (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
    OR EXISTS (
      SELECT 1 FROM public.vagas v
      WHERE v.id = vagas_beneficios.vaga_id
        AND houston.authorize('vagas.select'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
    )
  );

CREATE POLICY "vagas_beneficios_update_policy" ON public.vagas_beneficios
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.vagas v
      WHERE v.id = vagas_beneficios.vaga_id
        AND houston.authorize('vagas.update'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.vagas v
      WHERE v.id = vagas_beneficios.vaga_id
        AND houston.authorize('vagas.update'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
    )
  );

-- ============================================================================
-- TABELA: vagas_recorrencias
-- ============================================================================
DROP POLICY IF EXISTS "Enable full access to astronauta users" ON public.vagas_recorrencias;
DROP POLICY IF EXISTS "vagas_recorrencia_escalista_policy" ON public.vagas_recorrencias;

-- Nota: vagas_recorrencias não tem referência direta a vaga
-- Usaremos a relação inversa (vagas tem recorrencia_id)
CREATE POLICY "vagas_recorrencias_delete_policy" ON public.vagas_recorrencias
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.vagas v
      WHERE v.recorrencia_id = vagas_recorrencias.id
        AND houston.authorize('vagas.delete'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
      LIMIT 1
    )
  );

CREATE POLICY "vagas_recorrencias_insert_policy" ON public.vagas_recorrencias
  FOR INSERT TO authenticated
  WITH CHECK (
    houston.authorize_simple('vagas.insert'::houston.app_permission)
  );

CREATE POLICY "vagas_recorrencias_select_policy" ON public.vagas_recorrencias
  FOR SELECT TO authenticated
  USING (
    (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
    OR EXISTS (
      SELECT 1 FROM public.vagas v
      WHERE v.recorrencia_id = vagas_recorrencias.id
        AND houston.authorize('vagas.select'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
      LIMIT 1
    )
  );

CREATE POLICY "vagas_recorrencias_update_policy" ON public.vagas_recorrencias
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.vagas v
      WHERE v.recorrencia_id = vagas_recorrencias.id
        AND houston.authorize('vagas.update'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
      LIMIT 1
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.vagas v
      WHERE v.recorrencia_id = vagas_recorrencias.id
        AND houston.authorize('vagas.update'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
      LIMIT 1
    )
  );

-- ============================================================================
-- TABELA: vagas_requisitos
-- ============================================================================
DROP POLICY IF EXISTS "Enable full access to astronauta users" ON public.vagas_requisitos;
DROP POLICY IF EXISTS "Enable read for authenticated users" ON public.vagas_requisitos;
DROP POLICY IF EXISTS "vagas_requisito_escalista_policy" ON public.vagas_requisitos;

CREATE POLICY "vagas_requisitos_delete_policy" ON public.vagas_requisitos
  FOR DELETE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.vagas v
      WHERE v.id = vagas_requisitos.vaga_id
        AND houston.authorize('vagas.delete'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
    )
  );

CREATE POLICY "vagas_requisitos_insert_policy" ON public.vagas_requisitos
  FOR INSERT TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.vagas v
      WHERE v.id = vagas_requisitos.vaga_id
        AND houston.authorize('vagas.insert'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
    )
  );

CREATE POLICY "vagas_requisitos_select_policy" ON public.vagas_requisitos
  FOR SELECT TO authenticated
  USING (
    (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
    OR EXISTS (
      SELECT 1 FROM public.vagas v
      WHERE v.id = vagas_requisitos.vaga_id
        AND houston.authorize('vagas.select'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
    )
  );

CREATE POLICY "vagas_requisitos_update_policy" ON public.vagas_requisitos
  FOR UPDATE TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.vagas v
      WHERE v.id = vagas_requisitos.vaga_id
        AND houston.authorize('vagas.update'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.vagas v
      WHERE v.id = vagas_requisitos.vaga_id
        AND houston.authorize('vagas.update'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
    )
  );

-- ============================================================================
-- TABELA: vagas_salvas
-- ============================================================================
DROP POLICY IF EXISTS "Enable medico users full access to their own data" ON public.vagas_salvas;
DROP POLICY IF EXISTS "Enable read to astronauta and escalista users" ON public.vagas_salvas;

CREATE POLICY "vagas_salvas_delete_policy" ON public.vagas_salvas
  FOR DELETE TO authenticated
  USING (
    (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
    AND auth.uid() = medico_id
  );

CREATE POLICY "vagas_salvas_insert_policy" ON public.vagas_salvas
  FOR INSERT TO authenticated
  WITH CHECK (
    (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
    AND auth.uid() = medico_id
  );

CREATE POLICY "vagas_salvas_select_policy" ON public.vagas_salvas
  FOR SELECT TO authenticated
  USING (
    (
      (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
      AND auth.uid() = medico_id
    )
    OR (
      EXISTS (
        SELECT 1 FROM public.vagas v
        WHERE v.id = vagas_salvas.vaga_id
          AND houston.authorize('vagas.select'::houston.app_permission, v.hospital_id, v.setor_id, v.grupo_id)
      )
    )
  );

CREATE POLICY "vagas_salvas_update_policy" ON public.vagas_salvas
  FOR UPDATE TO authenticated
  USING (
    (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
    AND auth.uid() = medico_id
  )
  WITH CHECK (
    (EXISTS (SELECT 1 FROM public.user_profile WHERE user_profile.id = auth.uid()))
    AND auth.uid() = medico_id
  );

-- ============================================================================
-- LIMPEZA: Migrar permissões medicos_precadastro.* para medicos.*
-- ============================================================================

-- Remover as permissões antigas 'medicos_precadastro.*' da tabela role_permissions
DELETE FROM houston.role_permissions
WHERE permission::text IN (
  'medicos_precadastro.delete',
  'medicos_precadastro.insert',
  'medicos_precadastro.select',
  'medicos_precadastro.update'
);

-- ============================================================================
-- NOTA: Enums obsoletos 'medicos_precadastro.*'
-- ============================================================================

-- Os valores do enum 'medicos_precadastro.*' não são mais utilizados após esta migração.
-- PostgreSQL não permite remover valores de enum dentro de uma transação (que é o caso
-- das migrations do Supabase), então os valores permanecerão no enum mas não serão usados.
--
-- Valores obsoletos (não causam problemas, apenas ficam no enum sem uso):
--   - medicos_precadastro.delete
--   - medicos_precadastro.insert
--   - medicos_precadastro.select
--   - medicos_precadastro.update
--
-- Caso queira removê-los manualmente no futuro (fora de uma migration):
--   ALTER TYPE houston.app_permission DROP VALUE 'medicos_precadastro.delete';
--   ALTER TYPE houston.app_permission DROP VALUE 'medicos_precadastro.insert';
--   ALTER TYPE houston.app_permission DROP VALUE 'medicos_precadastro.select';
--   ALTER TYPE houston.app_permission DROP VALUE 'medicos_precadastro.update';
