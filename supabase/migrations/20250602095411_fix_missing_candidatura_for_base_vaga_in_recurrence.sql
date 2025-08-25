-- Corrigir função criar_recorrencia_com_vagas para criar candidatura na vaga base
CREATE OR REPLACE FUNCTION public.criar_recorrencia_com_vagas(
    p_data_inicio date, 
    p_data_fim date, 
    p_dias_semana integer[], 
    p_vaga_base jsonb, 
    p_created_by uuid, 
    p_medico_id uuid DEFAULT NULL::uuid, 
    p_observacoes text DEFAULT NULL::text, 
    p_beneficios text[] DEFAULT ARRAY[]::text[], 
    p_requisitos text[] DEFAULT ARRAY[]::text[]
) RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  nova_recorrencia_id uuid;
  nova_vaga_id uuid;
  beneficio_id text;
  requisito_id text;
  now_brasil timestamp := (now() at time zone 'America/Sao_Paulo');
BEGIN
  -- Log do início da operação
  RAISE NOTICE 'Criando recorrência de % até % com médico designado: %', p_data_inicio, p_data_fim, p_medico_id;

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
    now_brasil,
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
    now_brasil,
    CASE WHEN p_medico_id IS NOT NULL THEN 'fechada' ELSE 'aberta' END,
    p_created_by,
    (p_vaga_base->>'vaga_especialidade')::uuid,
    (p_vaga_base->>'grupo_id')::uuid,
    p_vaga_base->>'vagas_observacoes',
    0,
    nova_recorrencia_id
  ) RETURNING vagas_id INTO nova_vaga_id;

  -- Inserir benefícios da vaga base
  IF p_beneficios IS NOT NULL AND array_length(p_beneficios, 1) > 0 THEN
    FOR beneficio_id IN SELECT unnest(p_beneficios) LOOP
      INSERT INTO public.vagas_beneficio (vagas_id, beneficio_id)
      VALUES (nova_vaga_id, beneficio_id::uuid);
    END LOOP;
  END IF;

  -- Inserir requisitos da vaga base
  IF p_requisitos IS NOT NULL AND array_length(p_requisitos, 1) > 0 THEN
    FOR requisito_id IN SELECT unnest(p_requisitos) LOOP
      INSERT INTO public.vagas_requisito (vagas_id, requisito_id)
      VALUES (nova_vaga_id, requisito_id::uuid);
    END LOOP;
  END IF;

  -- CORREÇÃO: Criar candidatura aprovada para a vaga base se há médico designado
  IF p_medico_id IS NOT NULL THEN
    INSERT INTO public.candidaturas (
      medico_id, vagas_id, candidatura_status, candidatos_createdate, candidaturas_updateat, candidaturas_updateby, vagas_valor
    ) VALUES (
      p_medico_id, nova_vaga_id, 'APROVADO', now_brasil, now_brasil, p_created_by::text, (p_vaga_base->>'vagas_valor')::integer
    );
    
    RAISE NOTICE 'Candidatura aprovada criada para vaga base: % (médico: %)', nova_vaga_id, p_medico_id;
  END IF;

  -- Gera as demais vagas recorrentes
  PERFORM public.gerar_vagas_recorrentes(nova_recorrencia_id, nova_vaga_id, p_medico_id, p_created_by, p_beneficios, p_requisitos);

  RAISE NOTICE 'Recorrência criada com sucesso: % (vaga base: %)', nova_recorrencia_id, nova_vaga_id;
  
  RETURN nova_recorrencia_id;
END;
$$;;
