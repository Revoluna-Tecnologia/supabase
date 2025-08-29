-- Função para deletar todas as vagas de uma recorrência, incluindo candidaturas e benefícios
CREATE OR REPLACE FUNCTION public.deletar_vagas_recorrencia(
  p_recorrencia_id uuid,
  p_updateby uuid
) RETURNS void AS $$
DECLARE
  vaga RECORD;
BEGIN
  FOR vaga IN SELECT vagas_id FROM public.vagas WHERE recorrencia_id = p_recorrencia_id LOOP
    -- Deleta benefícios
    DELETE FROM public.vagas_beneficio WHERE vaga_id = vaga.vagas_id;
    -- Deleta candidaturas
    DELETE FROM public.candidaturas WHERE vagas_id = vaga.vagas_id;
    -- Deleta a vaga
    DELETE FROM public.vagas WHERE vagas_id = vaga.vagas_id;
  END LOOP;
  -- Opcional: deletar a recorrência
  DELETE FROM public.vagas_recorrencia WHERE recorrencia_id = p_recorrencia_id;
END;
$$ LANGUAGE plpgsql;;
