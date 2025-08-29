-- Corrigir função de edição em massa para recalcular datas de pagamento
CREATE OR REPLACE FUNCTION public.editar_vagas_recorrencia(
    p_recorrencia_id uuid, 
    p_update jsonb, 
    p_updateby uuid, 
    p_beneficios text[] DEFAULT ARRAY[]::text[], 
    p_requisitos text[] DEFAULT ARRAY[]::text[]
) RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  now_brasil timestamp := (now() at time zone 'America/Sao_Paulo');
  vaga RECORD;
  vagas_atualizadas integer := 0;
  novo_medico_id uuid;
  candidatura_existente RECORD;
  beneficio_id text;
  requisito_id text;
  dias_para_pagamento integer;
  nova_data_pagamento date;
  data_original date;
  data_pagamento_original date;
BEGIN
  -- Log do início da operação
  RAISE NOTICE 'Iniciando edição de vagas da recorrência: %', p_recorrencia_id;
  
  -- Extrair médico_id se presente
  novo_medico_id := CASE WHEN (p_update ? 'medico_id') THEN (p_update->>'medico_id')::uuid ELSE NULL END;
  
  -- Se está atualizando vagas_datapagamento, calcular dias para pagamento baseado na primeira vaga
  IF (p_update ? 'vagas_datapagamento') AND (p_update ? 'vagas_data') THEN
    data_original := (p_update->>'vagas_data')::date;
    data_pagamento_original := (p_update->>'vagas_datapagamento')::date;
    dias_para_pagamento := calcular_dias_pagamento(data_original, data_pagamento_original);
    RAISE NOTICE 'Recalculando datas de pagamento baseado em % dias após cada data de plantão', dias_para_pagamento;
  END IF;
  
  FOR vaga IN SELECT * FROM public.vagas WHERE recorrencia_id = p_recorrencia_id LOOP
    
    -- Calcular nova data de pagamento se necessário
    IF dias_para_pagamento IS NOT NULL THEN
      nova_data_pagamento := vaga.vagas_data + (dias_para_pagamento || ' days')::interval;
    ELSE
      nova_data_pagamento := COALESCE((p_update->>'vagas_datapagamento')::date, vaga.vagas_datapagamento);
    END IF;
    
    -- Atualizar dados da vaga
    UPDATE public.vagas SET
      vagas_hospital = COALESCE((p_update->>'vagas_hospital')::uuid, vagas_hospital),
      vagas_data = COALESCE((p_update->>'vagas_data')::date, vagas_data),
      vagas_periodo = COALESCE((p_update->>'vagas_periodo')::uuid, vagas_periodo),
      vagas_horainicio = COALESCE((p_update->>'vagas_horainicio')::time, vagas_horainicio),
      vagas_horafim = COALESCE((p_update->>'vagas_horafim')::time, vagas_horafim),
      vagas_valor = COALESCE((p_update->>'vagas_valor')::integer, vagas_valor),
      vagas_datapagamento = nova_data_pagamento, -- USAR DATA RECALCULADA
      vagas_formarecebimento = COALESCE((p_update->>'vagas_formarecebimento')::uuid, vagas_formarecebimento),
      vagas_tipo = COALESCE((p_update->>'vagas_tipo')::uuid, vagas_tipo),
      vagas_observacoes = COALESCE((p_update->>'vagas_observacoes'), vagas_observacoes),
      vagas_setor = COALESCE((p_update->>'vagas_setor')::uuid, vagas_setor),
      vagas_escalista = COALESCE((p_update->>'vagas_escalista')::uuid, vagas_escalista),
      vaga_especialidade = COALESCE((p_update->>'vaga_especialidade')::uuid, vaga_especialidade),
      grupo_id = COALESCE((p_update->>'grupo_id')::uuid, grupo_id),
      -- ATUALIZAR STATUS DA VAGA baseado no médico designado
      vagas_status = CASE 
        WHEN (p_update ? 'medico_id') THEN 
          CASE WHEN novo_medico_id IS NOT NULL THEN 'fechada' ELSE 'aberta' END
        ELSE vagas_status 
      END,
      -- CAMPOS DE AUDITORIA - SEMPRE ATUALIZADOS
      vagas_updateat = now_brasil,
      vagas_updateby = p_updateby
    WHERE vagas_id = vaga.vagas_id;
    
    -- Atualizar benefícios da vaga
    DELETE FROM public.vagas_beneficio WHERE vagas_id = vaga.vagas_id;
    IF p_beneficios IS NOT NULL AND array_length(p_beneficios, 1) > 0 THEN
      FOR beneficio_id IN SELECT unnest(p_beneficios) LOOP
        INSERT INTO public.vagas_beneficio (vagas_id, beneficio_id)
        VALUES (vaga.vagas_id, beneficio_id::uuid);
      END LOOP;
    END IF;

    -- Atualizar requisitos da vaga
    DELETE FROM public.vagas_requisito WHERE vagas_id = vaga.vagas_id;
    IF p_requisitos IS NOT NULL AND array_length(p_requisitos, 1) > 0 THEN
      FOR requisito_id IN SELECT unnest(p_requisitos) LOOP
        INSERT INTO public.vagas_requisito (vagas_id, requisito_id)
        VALUES (vaga.vagas_id, requisito_id::uuid);
      END LOOP;
    END IF;
    
    vagas_atualizadas := vagas_atualizadas + 1;
    
    -- Gerenciar candidaturas quando médico é especificado
    IF (p_update ? 'medico_id') THEN
      IF novo_medico_id IS NOT NULL THEN
        -- Médico designado: verificar se já existe candidatura aprovada
        SELECT * INTO candidatura_existente 
        FROM public.candidaturas 
        WHERE vagas_id = vaga.vagas_id AND candidatura_status = 'APROVADO'
        LIMIT 1;
        
        IF candidatura_existente.candidaturas_id IS NOT NULL THEN
          -- Atualizar candidatura existente
          UPDATE public.candidaturas SET
            medico_id = novo_medico_id,
            candidaturas_updateat = now_brasil,
            candidaturas_updateby = p_updateby::text
          WHERE candidaturas_id = candidatura_existente.candidaturas_id;
          
          RAISE NOTICE 'Candidatura atualizada para vaga: % (candidatura: %)', vaga.vagas_id, candidatura_existente.candidaturas_id;
        ELSE
          -- Criar nova candidatura aprovada
          INSERT INTO public.candidaturas (
            medico_id, vagas_id, candidatura_status, candidatos_createdate, candidaturas_updateat, candidaturas_updateby, vagas_valor
          ) VALUES (
            novo_medico_id, vaga.vagas_id, 'APROVADO', now_brasil, now_brasil, p_updateby::text, vaga.vagas_valor
          );
          
          RAISE NOTICE 'Nova candidatura aprovada criada para vaga: %', vaga.vagas_id;
        END IF;
      ELSE
        -- Médico removido: remover candidaturas aprovadas
        DELETE FROM public.candidaturas 
        WHERE vagas_id = vaga.vagas_id AND candidatura_status = 'APROVADO';
        
        RAISE NOTICE 'Candidaturas aprovadas removidas da vaga: %', vaga.vagas_id;
      END IF;
    END IF;
    
    RAISE NOTICE 'Vaga % atualizada com pagamento em %', vaga.vagas_id, nova_data_pagamento;
  END LOOP;
  
  -- Log do resultado
  RAISE NOTICE 'Edição concluída. % vagas atualizadas para recorrência: %', vagas_atualizadas, p_recorrencia_id;
  
  -- Verificar se alguma vaga foi atualizada
  IF vagas_atualizadas = 0 THEN
    RAISE EXCEPTION 'Nenhuma vaga encontrada para a recorrência: %', p_recorrencia_id;
  END IF;
END;
$$;;
