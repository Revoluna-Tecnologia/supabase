-- Melhorar a política RLS da tabela vagas_recorrencia
-- Usar uma abordagem mais segura baseada no created_by

DROP POLICY IF EXISTS "vagas_recorrencia_escalista_policy" ON public.vagas_recorrencia;

CREATE POLICY "vagas_recorrencia_escalista_policy" ON public.vagas_recorrencia
FOR ALL 
TO authenticated
USING (
  CASE
    WHEN get_current_user_grupo_id() IS NULL THEN true  -- astronautas veem tudo
    ELSE (
      -- Para escalistas: verificar se a recorrência foi criada por eles OU 
      -- se existe pelo menos uma vaga relacionada do seu grupo
      created_by = auth.uid() OR
      EXISTS (
        SELECT 1 FROM vagas v 
        WHERE v.recorrencia_id = vagas_recorrencia.recorrencia_id 
        AND v.grupo_id = get_current_user_grupo_id()
      )
    )
  END
)
WITH CHECK (
  CASE
    WHEN get_current_user_grupo_id() IS NULL THEN true  -- astronautas podem criar tudo
    ELSE created_by = auth.uid()  -- escalistas só podem criar suas próprias recorrências
  END
);;
