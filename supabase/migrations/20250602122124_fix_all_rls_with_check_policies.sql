-- Corrigir todas as políticas RLS para incluir WITH CHECK adequado

-- 1. Corrigir vagas_beneficio
DROP POLICY IF EXISTS "vagas_beneficio_escalista_policy" ON public.vagas_beneficio;
CREATE POLICY "vagas_beneficio_escalista_policy" ON public.vagas_beneficio
FOR ALL 
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM vagas v 
    WHERE v.vagas_id = vagas_beneficio.vagas_id 
    AND CASE
      WHEN get_current_user_grupo_id() IS NULL THEN true
      ELSE v.grupo_id = get_current_user_grupo_id()
    END
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM vagas v 
    WHERE v.vagas_id = vagas_beneficio.vagas_id 
    AND CASE
      WHEN get_current_user_grupo_id() IS NULL THEN true
      ELSE v.grupo_id = get_current_user_grupo_id()
    END
  )
);

-- 2. Corrigir vagas_requisito
DROP POLICY IF EXISTS "vagas_requisito_escalista_policy" ON public.vagas_requisito;
CREATE POLICY "vagas_requisito_escalista_policy" ON public.vagas_requisito
FOR ALL 
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM vagas v 
    WHERE v.vagas_id = vagas_requisito.vagas_id 
    AND CASE
      WHEN get_current_user_grupo_id() IS NULL THEN true
      ELSE v.grupo_id = get_current_user_grupo_id()
    END
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM vagas v 
    WHERE v.vagas_id = vagas_requisito.vagas_id 
    AND CASE
      WHEN get_current_user_grupo_id() IS NULL THEN true
      ELSE v.grupo_id = get_current_user_grupo_id()
    END
  )
);;
