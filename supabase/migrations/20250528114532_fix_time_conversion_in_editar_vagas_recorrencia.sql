-- Corrigir conversões de tipos na função editar_vagas_recorrencia
CREATE OR REPLACE FUNCTION public.editar_vagas_recorrencia(
  p_recorrencia_id uuid,
  p_update jsonb,
  p_updateby uuid
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  now_brasil timestamp := (now() at time zone 'America/Sao_Paulo');
  vaga RECORD;
BEGIN
  FOR vaga IN SELECT * FROM public.vagas WHERE recorrencia_id = p_recorrencia_id LOOP
    UPDATE public.vagas SET
      vagas_hospital = COALESCE((p_update->>'vagas_hospital')::uuid, vagas_hospital),
      vagas_data = COALESCE((p_update->>'vagas_data')::date, vagas_data),
      vagas_periodo = COALESCE((p_update->>'vagas_periodo')::uuid, vagas_periodo),
      vagas_horainicio = COALESCE((p_update->>'vagas_horainicio')::time, vagas_horainicio),  -- Conversão para time
      vagas_horafim = COALESCE((p_update->>'vagas_horafim')::time, vagas_horafim),          -- Conversão para time
      vagas_valor = COALESCE((p_update->>'vagas_valor')::integer, vagas_valor),
      vagas_datapagamento = COALESCE((p_update->>'vagas_datapagamento')::date, vagas_datapagamento),
      vagas_formarecebimento = COALESCE((p_update->>'vagas_formarecebimento')::uuid, vagas_formarecebimento),
      vagas_tipo = COALESCE((p_update->>'vagas_tipo')::uuid, vagas_tipo),
      vagas_observacoes = COALESCE((p_update->>'vagas_observacoes'), vagas_observacoes),
      vagas_setor = COALESCE((p_update->>'vagas_setor')::uuid, vagas_setor),
      vagas_escalista = COALESCE((p_update->>'vagas_escalista')::uuid, vagas_escalista),
      vagas_updateat = now_brasil,
      vagas_updateby = p_updateby,
      vaga_especialidade = COALESCE((p_update->>'vaga_especialidade')::uuid, vaga_especialidade),
      grupo_id = COALESCE((p_update->>'grupo_id')::uuid, grupo_id)
    WHERE vagas_id = vaga.vagas_id;
    
    -- Atualizar candidaturas aprovadas, se houver médico designado
    IF (p_update ? 'medico_id') AND (p_update->>'medico_id') IS NOT NULL THEN
      UPDATE public.candidaturas SET
        medicos_id = (p_update->>'medico_id')::uuid,
        candidatura_status = 'APROVADO',
        candidaturas_updateat = now_brasil,
        candidaturas_updateby = p_updateby
      WHERE vagas_id = vaga.vagas_id AND candidatura_status = 'APROVADO';
    END IF;
  END LOOP;
END;
$$;;
