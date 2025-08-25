-- Simplificar a política RLS da tabela vagas_recorrencia
-- Usar uma abordagem mais direta que funcione melhor na criação

DROP POLICY IF EXISTS "vagas_recorrencia_escalista_policy" ON public.vagas_recorrencia;

CREATE POLICY "vagas_recorrencia_escalista_policy" ON public.vagas_recorrencia
FOR ALL 
TO authenticated
USING (
  -- Para leitura: astronautas veem tudo, escalistas veem suas próprias recorrências ou relacionadas ao grupo
  EXISTS (SELECT 1 FROM user_profile WHERE id = auth.uid() AND role = 'astronauta') OR
  created_by = auth.uid() OR
  EXISTS (
    SELECT 1 FROM vagas v 
    JOIN escalista e ON e.grupo_id = v.grupo_id 
    WHERE v.recorrencia_id = vagas_recorrencia.recorrencia_id 
    AND e.escalista_auth_id = auth.uid()
  )
)
WITH CHECK (
  -- Para criação: astronautas podem criar tudo, escalistas só podem criar suas próprias
  EXISTS (SELECT 1 FROM user_profile WHERE id = auth.uid() AND role = 'astronauta') OR
  created_by = auth.uid()
);;
