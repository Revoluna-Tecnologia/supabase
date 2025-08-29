-- Corrigir a política RLS da tabela vagas para permitir criação por escalistas
DROP POLICY IF EXISTS "vagas_escalista_policy" ON public.vagas;

CREATE POLICY "vagas_escalista_policy" ON public.vagas
FOR ALL 
TO authenticated
USING (
  CASE
    WHEN get_current_user_grupo_id() IS NULL THEN true  -- astronautas veem tudo
    ELSE grupo_id = get_current_user_grupo_id()         -- escalistas veem apenas seu grupo
  END
)
WITH CHECK (
  CASE
    WHEN get_current_user_grupo_id() IS NULL THEN true  -- astronautas podem criar tudo
    ELSE grupo_id = get_current_user_grupo_id()         -- escalistas só podem criar vagas do seu grupo
  END
);;
