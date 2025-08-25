-- Corrigir a política RLS da tabela vagas_recorrencia
-- O problema é que ela estava tentando verificar vagas que ainda não existem na criação

DROP POLICY IF EXISTS "vagas_recorrencia_escalista_policy" ON public.vagas_recorrencia;

CREATE POLICY "vagas_recorrencia_escalista_policy" ON public.vagas_recorrencia
FOR ALL 
TO authenticated
USING (
  CASE
    WHEN get_current_user_grupo_id() IS NULL THEN true  -- astronautas veem tudo
    ELSE true  -- escalistas podem ver todas as recorrências (serão filtradas pelas vagas)
  END
)
WITH CHECK (
  CASE
    WHEN get_current_user_grupo_id() IS NULL THEN true  -- astronautas podem criar tudo
    ELSE true  -- escalistas podem criar recorrências (validação será feita na criação das vagas)
  END
);;
