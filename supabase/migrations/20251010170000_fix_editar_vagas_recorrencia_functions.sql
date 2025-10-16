-- Migration: Fix editar_vagas_recorrencia functions with correct table and column names
-- Date: 2025-10-10

-- =====================================================
-- Função 1: editar_vagas_recorrencia (versão básica)
-- =====================================================

CREATE OR REPLACE FUNCTION public.editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
  now_brasil timestamp := (now() at time zone 'America/Sao_Paulo');
  vaga RECORD;
  vagas_atualizadas integer := 0;
  novo_medico_id uuid;
  candidatura_existente RECORD;
BEGIN
  -- Log do início da operação
  RAISE NOTICE 'Iniciando edição de vagas da recorrência: %', p_recorrencia_id;
  
  -- Extrair médico_id se presente
  novo_medico_id := CASE WHEN (p_update ? 'medico_id') THEN (p_update->>'medico_id')::uuid ELSE NULL END;
  
  FOR vaga IN SELECT * FROM public.vagas WHERE recorrencia_id = p_recorrencia_id LOOP
    -- Atualizar dados da vaga (usando nomenclatura correta)
    UPDATE public.vagas SET
      hospital_id = COALESCE((p_update->>'hospital_id')::uuid, hospital_id),
      data = COALESCE((p_update->>'data')::date, data),
      periodo_id = COALESCE((p_update->>'periodo_id')::uuid, periodo_id),
      hora_inicio = COALESCE((p_update->>'hora_inicio')::time, hora_inicio),
      hora_fim = COALESCE((p_update->>'hora_fim')::time, hora_fim),
      valor = COALESCE((p_update->>'valor')::integer, valor),
      data_pagamento = COALESCE((p_update->>'data_pagamento')::date, data_pagamento),
      forma_recebimento_id = COALESCE((p_update->>'forma_recebimento_id')::uuid, forma_recebimento_id),
      tipos_vaga_id = COALESCE((p_update->>'tipos_vaga_id')::uuid, tipos_vaga_id),
      observacoes = COALESCE((p_update->>'observacoes'), observacoes),
      setor_id = COALESCE((p_update->>'setor_id')::uuid, setor_id),
      escalista_id = COALESCE((p_update->>'escalista_id')::uuid, escalista_id),
      especialidade_id = COALESCE((p_update->>'especialidade_id')::uuid, especialidade_id),
      grupo_id = COALESCE((p_update->>'grupo_id')::uuid, grupo_id),
      -- ATUALIZAR STATUS DA VAGA baseado no médico designado
      status = CASE 
        WHEN (p_update ? 'medico_id') THEN 
          CASE WHEN novo_medico_id IS NOT NULL THEN 'fechada' ELSE 'aberta' END
        ELSE status 
      END,
      -- CAMPOS DE AUDITORIA - SEMPRE ATUALIZADOS
      updated_at = now_brasil,
      updated_by = p_updateby
    WHERE id = vaga.id;
    
    vagas_atualizadas := vagas_atualizadas + 1;
    
    -- Gerenciar candidaturas quando médico é especificado
    IF (p_update ? 'medico_id') THEN
      IF novo_medico_id IS NOT NULL THEN
        -- Médico designado: verificar se já existe candidatura aprovada
        SELECT * INTO candidatura_existente 
        FROM public.candidaturas 
        WHERE vagas_id = vaga.id AND status = 'APROVADO'
        LIMIT 1;
        
        IF candidatura_existente.id IS NOT NULL THEN
          -- Atualizar candidatura existente
          UPDATE public.candidaturas SET
            medico_id = novo_medico_id,
            updated_at = now_brasil,
            updated_by = p_updateby::text
          WHERE id = candidatura_existente.id;
          
          RAISE NOTICE 'Candidatura atualizada para vaga: % (candidatura: %)', vaga.id, candidatura_existente.id;
        ELSE
          -- Criar nova candidatura aprovada
          INSERT INTO public.candidaturas (
            medico_id, vagas_id, status, created_at, updated_at, updated_by, valor
          ) VALUES (
            novo_medico_id, vaga.id, 'APROVADO', now_brasil, now_brasil, p_updateby::text, vaga.valor
          );
          
          RAISE NOTICE 'Nova candidatura aprovada criada para vaga: %', vaga.id;
        END IF;
      ELSE
        -- Médico removido: remover candidaturas aprovadas
        DELETE FROM public.candidaturas 
        WHERE vagas_id = vaga.id AND status = 'APROVADO';
        
        RAISE NOTICE 'Candidaturas aprovadas removidas da vaga: %', vaga.id;
      END IF;
    END IF;
  END LOOP;
  
  -- Log do resultado
  RAISE NOTICE 'Edição concluída. % vagas atualizadas para recorrência: %', vagas_atualizadas, p_recorrencia_id;
  
  -- Verificar se alguma vaga foi atualizada
  IF vagas_atualizadas = 0 THEN
    RAISE EXCEPTION 'Nenhuma vaga encontrada para a recorrência: %', p_recorrencia_id;
  END IF;
END;
$function$;

-- =====================================================
-- Função 2: editar_vagas_recorrencia (com benefícios e requisitos)
-- =====================================================

CREATE OR REPLACE FUNCTION public.editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid, p_beneficios text[] DEFAULT ARRAY[]::text[], p_requisitos text[] DEFAULT ARRAY[]::text[])
 RETURNS void
 LANGUAGE plpgsql
AS $function$
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
  nova_data_plantao date;
BEGIN
  -- Log do início da operação
  RAISE NOTICE 'Iniciando edição de vagas da recorrência: %', p_recorrencia_id;
  
  -- Extrair médico_id se presente
  novo_medico_id := CASE WHEN (p_update ? 'medico_id') THEN (p_update->>'medico_id')::uuid ELSE NULL END;
  
  -- LÓGICA CORRIGIDA: Se há data_pagamento no update, calcular dias baseado na primeira vaga da recorrência
  IF (p_update ? 'data_pagamento') THEN
    -- Buscar primeira vaga da recorrência para calcular os dias de pagamento originais
    SELECT v.data, v.data_pagamento INTO nova_data_plantao, nova_data_pagamento
    FROM vagas v 
    WHERE v.recorrencia_id = p_recorrencia_id 
    ORDER BY v.data 
    LIMIT 1;
    
    -- Se encontrou dados da primeira vaga, calcular dias
    IF nova_data_plantao IS NOT NULL AND nova_data_pagamento IS NOT NULL THEN
      dias_para_pagamento := calcular_dias_pagamento(nova_data_plantao, nova_data_pagamento);
      RAISE NOTICE 'Recalculando datas de pagamento baseado em % dias após cada data de plantão (baseado na primeira vaga)', dias_para_pagamento;
    ELSE
      -- Se não encontrou dados, usar o valor do update como padrão
      dias_para_pagamento := NULL;
      RAISE NOTICE 'Não foi possível calcular dias, usando data fixa do update';
    END IF;
  END IF;
  
  FOR vaga IN SELECT * FROM public.vagas WHERE recorrencia_id = p_recorrencia_id LOOP
    
    -- CALCULAR NOVA DATA DE PAGAMENTO PARA CADA VAGA INDIVIDUALMENTE
    IF dias_para_pagamento IS NOT NULL THEN
      -- Recalcular baseado na data específica desta vaga + dias calculados
      nova_data_pagamento := vaga.data + (dias_para_pagamento || ' days')::interval;
      RAISE NOTICE 'Vaga %: Data plantão %, nova data pagamento %', vaga.id, vaga.data, nova_data_pagamento;
    ELSE
      -- Usar data do update se não conseguiu calcular dias
      nova_data_pagamento := COALESCE((p_update->>'data_pagamento')::date, vaga.data_pagamento);
    END IF;
    
    -- Atualizar dados da vaga (usando nomenclatura correta)
    UPDATE public.vagas SET
      hospital_id = COALESCE((p_update->>'hospital_id')::uuid, hospital_id),
      data = COALESCE((p_update->>'data')::date, data),
      periodo_id = COALESCE((p_update->>'periodo_id')::uuid, periodo_id),
      hora_inicio = COALESCE((p_update->>'hora_inicio')::time, hora_inicio),
      hora_fim = COALESCE((p_update->>'hora_fim')::time, hora_fim),
      valor = COALESCE((p_update->>'valor')::integer, valor),
      data_pagamento = nova_data_pagamento, -- USAR DATA RECALCULADA INDIVIDUALMENTE
      forma_recebimento_id = COALESCE((p_update->>'forma_recebimento_id')::uuid, forma_recebimento_id),
      tipos_vaga_id = COALESCE((p_update->>'tipos_vaga_id')::uuid, tipos_vaga_id),
      observacoes = COALESCE((p_update->>'observacoes'), observacoes),
      setor_id = COALESCE((p_update->>'setor_id')::uuid, setor_id),
      escalista_id = COALESCE((p_update->>'escalista_id')::uuid, escalista_id),
      especialidade_id = COALESCE((p_update->>'especialidade_id')::uuid, especialidade_id),
      grupo_id = COALESCE((p_update->>'grupo_id')::uuid, grupo_id),
      -- ATUALIZAR STATUS DA VAGA baseado no médico designado
      status = CASE 
        WHEN (p_update ? 'medico_id') THEN 
          CASE WHEN novo_medico_id IS NOT NULL THEN 'fechada' ELSE 'aberta' END
        ELSE status 
      END,
      -- CAMPOS DE AUDITORIA - SEMPRE ATUALIZADOS
      updated_at = now_brasil,
      updated_by = p_updateby
    WHERE id = vaga.id;
    
    -- Atualizar benefícios da vaga
    DELETE FROM public.vagas_beneficio WHERE vagas_id = vaga.id;
    IF p_beneficios IS NOT NULL AND array_length(p_beneficios, 1) > 0 THEN
      FOR beneficio_id IN SELECT unnest(p_beneficios) LOOP
        INSERT INTO public.vagas_beneficio (vagas_id, beneficio_id)
        VALUES (vaga.id, beneficio_id::uuid);
      END LOOP;
    END IF;

    -- Atualizar requisitos da vaga
    DELETE FROM public.vagas_requisito WHERE vagas_id = vaga.id;
    IF p_requisitos IS NOT NULL AND array_length(p_requisitos, 1) > 0 THEN
      FOR requisito_id IN SELECT unnest(p_requisitos) LOOP
        INSERT INTO public.vagas_requisito (vagas_id, requisito_id)
        VALUES (vaga.id, requisito_id::uuid);
      END LOOP;
    END IF;
    
    vagas_atualizadas := vagas_atualizadas + 1;
    
    -- Gerenciar candidaturas quando médico é especificado
    IF (p_update ? 'medico_id') THEN
      IF novo_medico_id IS NOT NULL THEN
        -- Médico designado: verificar se já existe candidatura aprovada
        SELECT * INTO candidatura_existente 
        FROM public.candidaturas 
        WHERE vagas_id = vaga.id AND status = 'APROVADO'
        LIMIT 1;
        
        IF candidatura_existente.id IS NOT NULL THEN
          -- Atualizar candidatura existente
          UPDATE public.candidaturas SET
            medico_id = novo_medico_id,
            updated_at = now_brasil,
            updated_by = p_updateby::text
          WHERE id = candidatura_existente.id;
          
          RAISE NOTICE 'Candidatura atualizada para vaga: % (candidatura: %)', vaga.id, candidatura_existente.id;
        ELSE
          -- Criar nova candidatura aprovada
          INSERT INTO public.candidaturas (
            medico_id, vagas_id, status, created_at, updated_at, updated_by, valor
          ) VALUES (
            novo_medico_id, vaga.id, 'APROVADO', now_brasil, now_brasil, p_updateby::text, vaga.valor
          );
          
          RAISE NOTICE 'Nova candidatura aprovada criada para vaga: %', vaga.id;
        END IF;
      ELSE
        -- Médico removido: remover candidaturas aprovadas
        DELETE FROM public.candidaturas 
        WHERE vagas_id = vaga.id AND status = 'APROVADO';
        
        RAISE NOTICE 'Candidaturas aprovadas removidas da vaga: %', vaga.id;
      END IF;
    END IF;
    
    RAISE NOTICE 'Vaga % atualizada com pagamento em %', vaga.id, nova_data_pagamento;
  END LOOP;
  
  -- Log do resultado
  RAISE NOTICE 'Edição concluída. % vagas atualizadas para recorrência: %', vagas_atualizadas, p_recorrencia_id;
  
  -- Verificar se alguma vaga foi atualizada
  IF vagas_atualizadas = 0 THEN
    RAISE EXCEPTION 'Nenhuma vaga encontrada para a recorrência: %', p_recorrencia_id;
  END IF;
END;
$function$;

-- =====================================================
-- Função 3: editar_vagas_recorrencia (com dias de pagamento)
-- =====================================================

CREATE OR REPLACE FUNCTION public.editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid, p_beneficios text[] DEFAULT ARRAY[]::text[], p_requisitos text[] DEFAULT ARRAY[]::text[], p_dias_pagamento integer DEFAULT NULL::integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
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
BEGIN
  -- Log do início da operação
  RAISE NOTICE 'Iniciando edição de vagas da recorrência: % (dias_pagamento: %)', p_recorrencia_id, p_dias_pagamento;
  
  -- Extrair médico_id se presente
  novo_medico_id := CASE WHEN (p_update ? 'medico_id') THEN (p_update->>'medico_id')::uuid ELSE NULL END;
  
  -- Determinar quantos dias usar para cálculo da data de pagamento
  IF p_dias_pagamento IS NOT NULL THEN
    -- Usar dias passados diretamente como parâmetro
    dias_para_pagamento := p_dias_pagamento;
    RAISE NOTICE 'Usando dias de pagamento especificados: % dias', dias_para_pagamento;
  ELSIF (p_update ? 'data_pagamento') THEN
    -- Tentar calcular baseado na primeira vaga da recorrência
    SELECT calcular_dias_pagamento(v.data, v.data_pagamento) 
    INTO dias_para_pagamento
    FROM vagas v 
    WHERE v.recorrencia_id = p_recorrencia_id 
    ORDER BY v.data 
    LIMIT 1;
    
    RAISE NOTICE 'Calculando dias baseado na primeira vaga: % dias', dias_para_pagamento;
  ELSE
    -- Não recalcular datas de pagamento
    dias_para_pagamento := NULL;
    RAISE NOTICE 'Mantendo datas de pagamento originais';
  END IF;
  
  FOR vaga IN SELECT * FROM public.vagas WHERE recorrencia_id = p_recorrencia_id LOOP
    
    -- CALCULAR NOVA DATA DE PAGAMENTO PARA CADA VAGA INDIVIDUALMENTE
    IF dias_para_pagamento IS NOT NULL THEN
      nova_data_pagamento := vaga.data + (dias_para_pagamento || ' days')::interval;
      RAISE NOTICE 'Vaga %: Data plantão %, nova data pagamento % (+ % dias)', 
        vaga.id, vaga.data, nova_data_pagamento, dias_para_pagamento;
    ELSE
      nova_data_pagamento := COALESCE((p_update->>'data_pagamento')::date, vaga.data_pagamento);
    END IF;
    
    -- Atualizar dados da vaga (usando nomenclatura correta)
    UPDATE public.vagas SET
      hospital_id = COALESCE((p_update->>'hospital_id')::uuid, hospital_id),
      data = COALESCE((p_update->>'data')::date, data),
      periodo_id = COALESCE((p_update->>'periodo_id')::uuid, periodo_id),
      hora_inicio = COALESCE((p_update->>'hora_inicio')::time, hora_inicio),
      hora_fim = COALESCE((p_update->>'hora_fim')::time, hora_fim),
      valor = COALESCE((p_update->>'valor')::integer, valor),
      data_pagamento = nova_data_pagamento, -- DATA RECALCULADA INDIVIDUALMENTE
      forma_recebimento_id = COALESCE((p_update->>'forma_recebimento_id')::uuid, forma_recebimento_id),
      tipos_vaga_id = COALESCE((p_update->>'tipos_vaga_id')::uuid, tipos_vaga_id),
      observacoes = COALESCE((p_update->>'observacoes'), observacoes),
      setor_id = COALESCE((p_update->>'setor_id')::uuid, setor_id),
      escalista_id = COALESCE((p_update->>'escalista_id')::uuid, escalista_id),
      especialidade_id = COALESCE((p_update->>'especialidade_id')::uuid, especialidade_id),
      grupo_id = COALESCE((p_update->>'grupo_id')::uuid, grupo_id),
      status = CASE 
        WHEN (p_update ? 'medico_id') THEN 
          CASE WHEN novo_medico_id IS NOT NULL THEN 'fechada' ELSE 'aberta' END
        ELSE status 
      END,
      updated_at = now_brasil,
      updated_by = p_updateby
    WHERE id = vaga.id;
    
    -- Atualizar benefícios da vaga
    DELETE FROM public.vagas_beneficio WHERE vagas_id = vaga.id;
    IF p_beneficios IS NOT NULL AND array_length(p_beneficios, 1) > 0 THEN
      FOR beneficio_id IN SELECT unnest(p_beneficios) LOOP
        INSERT INTO public.vagas_beneficio (vagas_id, beneficio_id)
        VALUES (vaga.id, beneficio_id::uuid);
      END LOOP;
    END IF;

    -- Atualizar requisitos da vaga
    DELETE FROM public.vagas_requisito WHERE vagas_id = vaga.id;
    IF p_requisitos IS NOT NULL AND array_length(p_requisitos, 1) > 0 THEN
      FOR requisito_id IN SELECT unnest(p_requisitos) LOOP
        INSERT INTO public.vagas_requisito (vagas_id, requisito_id)
        VALUES (vaga.id, requisito_id::uuid);
      END LOOP;
    END IF;
    
    vagas_atualizadas := vagas_atualizadas + 1;
    
    -- Gerenciar candidaturas quando médico é especificado
    IF (p_update ? 'medico_id') THEN
      IF novo_medico_id IS NOT NULL THEN
        SELECT * INTO candidatura_existente 
        FROM public.candidaturas 
        WHERE vagas_id = vaga.id AND status = 'APROVADO'
        LIMIT 1;
        
        IF candidatura_existente.id IS NOT NULL THEN
          UPDATE public.candidaturas SET
            medico_id = novo_medico_id,
            updated_at = now_brasil,
            updated_by = p_updateby::text
          WHERE id = candidatura_existente.id;
        ELSE
          INSERT INTO public.candidaturas (
            medico_id, vagas_id, status, created_at, updated_at, updated_by, valor
          ) VALUES (
            novo_medico_id, vaga.id, 'APROVADO', now_brasil, now_brasil, p_updateby::text, vaga.valor
          );
        END IF;
      ELSE
        DELETE FROM public.candidaturas 
        WHERE vagas_id = vaga.id AND status = 'APROVADO';
      END IF;
    END IF;
  END LOOP;
  
  RAISE NOTICE 'Edição concluída. % vagas atualizadas para recorrência: %', vagas_atualizadas, p_recorrencia_id;
  
  IF vagas_atualizadas = 0 THEN
    RAISE EXCEPTION 'Nenhuma vaga encontrada para a recorrência: %', p_recorrencia_id;
  END IF;
END;
$function$;