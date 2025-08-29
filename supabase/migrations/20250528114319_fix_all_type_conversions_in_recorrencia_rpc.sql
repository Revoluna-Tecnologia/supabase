-- Corrigir todas as conversões de tipos na função criar_recorrencia_com_vagas
CREATE OR REPLACE FUNCTION public.criar_recorrencia_com_vagas(
  p_data_inicio date,
  p_data_fim date,
  p_dias_semana integer[],
  p_vaga_base jsonb,
  p_created_by uuid,
  p_medico_id uuid DEFAULT NULL,
  p_observacoes text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  nova_recorrencia_id uuid;
  nova_vaga_id uuid;
BEGIN
  -- Cria a recorrência
  INSERT INTO public.vagas_recorrencia (
    data_inicio, data_fim, dias_semana, observacoes, created_by
  ) VALUES (
    p_data_inicio, p_data_fim, p_dias_semana, p_observacoes, p_created_by
  ) RETURNING recorrencia_id INTO nova_recorrencia_id;

  -- Cria a vaga base (primeira vaga) com conversão explícita de todos os tipos
  INSERT INTO public.vagas (
    vagas_createdate, vagas_hospital, vagas_data, vagas_periodo, vagas_horainicio, vagas_horafim, vagas_valor,
    vagas_datapagamento, vagas_formarecebimento, vagas_tipo, vagas_setor, vagas_escalista, vagas_updateat, vagas_status,
    vagas_updateby, vaga_especialidade, grupo_id, vagas_observacoes, vagas_totalcandidaturas, recorrencia_id
  ) VALUES (
    now(),
    (p_vaga_base->>'vagas_hospital')::uuid,
    (p_vaga_base->>'vagas_data')::date,
    (p_vaga_base->>'vagas_periodo')::uuid,
    (p_vaga_base->>'vagas_horainicio')::time,
    (p_vaga_base->>'vagas_horafim')::time,
    (p_vaga_base->>'vagas_valor')::integer,
    CASE 
      WHEN p_vaga_base->>'vagas_datapagamento' IS NOT NULL 
      THEN (p_vaga_base->>'vagas_datapagamento')::date 
      ELSE NULL 
    END,
    CASE 
      WHEN p_vaga_base->>'vagas_formarecebimento' IS NOT NULL 
      THEN (p_vaga_base->>'vagas_formarecebimento')::uuid 
      ELSE NULL 
    END,
    (p_vaga_base->>'vagas_tipo')::uuid,
    (p_vaga_base->>'vagas_setor')::uuid,
    (p_vaga_base->>'vagas_escalista')::uuid,
    now(),
    CASE WHEN p_medico_id IS NOT NULL THEN 'fechada' ELSE 'aberta' END,
    (p_vaga_base->>'vagas_updateby')::uuid,  -- Conversão explícita para uuid
    (p_vaga_base->>'vaga_especialidade')::uuid,
    (p_vaga_base->>'grupo_id')::uuid,
    p_vaga_base->>'vagas_observacoes',  -- text/varchar não precisa conversão
    0,
    nova_recorrencia_id
  ) RETURNING vagas_id INTO nova_vaga_id;

  -- Gera as demais vagas recorrentes
  PERFORM public.gerar_vagas_recorrentes(nova_recorrencia_id, nova_vaga_id, p_medico_id);

  RETURN nova_recorrencia_id;
END;
$$;;
