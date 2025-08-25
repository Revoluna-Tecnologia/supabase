-- Adicionar políticas RLS para escalistas nas tabelas que estão faltando

-- 1. Política para vagas_recorrencia (escalistas só podem ver/criar recorrências do seu grupo)
CREATE POLICY "vagas_recorrencia_escalista_policy" ON public.vagas_recorrencia
FOR ALL 
TO authenticated
USING (
  CASE
    WHEN get_current_user_grupo_id() IS NULL THEN true  -- astronautas veem tudo
    ELSE EXISTS (
      SELECT 1 FROM vagas v 
      WHERE v.recorrencia_id = vagas_recorrencia.recorrencia_id 
      AND v.grupo_id = get_current_user_grupo_id()
    )
  END
)
WITH CHECK (
  CASE
    WHEN get_current_user_grupo_id() IS NULL THEN true  -- astronautas podem criar tudo
    ELSE true  -- escalistas podem criar (será validado pela vaga)
  END
);

-- 2. Política para candidaturas (escalistas só podem ver candidaturas de vagas do seu grupo)
CREATE POLICY "candidaturas_escalista_policy" ON public.candidaturas
FOR ALL 
TO authenticated
USING (
  CASE
    WHEN get_current_user_grupo_id() IS NULL THEN true  -- astronautas veem tudo
    ELSE EXISTS (
      SELECT 1 FROM vagas v 
      WHERE v.vagas_id = candidaturas.vagas_id 
      AND v.grupo_id = get_current_user_grupo_id()
    )
  END
)
WITH CHECK (
  CASE
    WHEN get_current_user_grupo_id() IS NULL THEN true  -- astronautas podem criar tudo
    ELSE EXISTS (
      SELECT 1 FROM vagas v 
      WHERE v.vagas_id = candidaturas.vagas_id 
      AND v.grupo_id = get_current_user_grupo_id()
    )
  END
);;
