-- Corrigir cálculo da data de pagamento em vagas recorrentes
-- As funções agora vão recalcular a data de pagamento baseada na nova data da vaga + dias originais

-- Primeiro, vamos criar uma função auxiliar para calcular a diferença em dias
CREATE OR REPLACE FUNCTION calcular_dias_pagamento(
    data_plantao date,
    data_pagamento date
) RETURNS integer
LANGUAGE plpgsql
AS $$
BEGIN
    IF data_pagamento IS NULL OR data_plantao IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN (data_pagamento - data_plantao);
END;
$$;

-- Atualizar função gerar_vagas_recorrentes para recalcular data de pagamento
CREATE OR REPLACE FUNCTION public.gerar_vagas_recorrentes(
    p_recorrencia_id uuid, 
    p_vaga_base_id uuid, 
    p_medico_id uuid DEFAULT NULL::uuid, 
    p_created_by uuid DEFAULT NULL::uuid, 
    p_beneficios text[] DEFAULT ARRAY[]::text[], 
    p_requisitos text[] DEFAULT ARRAY[]::text[]
) RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  rec public.vagas_recorrencia%ROWTYPE;
  vaga_base public.vagas%ROWTYPE;
  dia date;
  dias integer[];
  i integer;
  nova_vaga_id uuid;
  now_brasil timestamp := (now() at time zone 'America/Sao_Paulo');
  audit_user uuid;
  beneficio_id text;
  requisito_id text;
  dias_para_pagamento integer;
  nova_data_pagamento date;
BEGIN
  -- Busca dados da recorrência e da vaga base
  SELECT * INTO rec FROM public.vagas_recorrencia WHERE recorrencia_id = p_recorrencia_id;
  SELECT * INTO vaga_base FROM public.vagas WHERE vagas_id = p_vaga_base_id;
  dias := rec.dias_semana;
  
  -- Calcular quantos dias há entre a data do plantão e a data de pagamento na vaga base
  dias_para_pagamento := calcular_dias_pagamento(vaga_base.vagas_data, vaga_base.vagas_datapagamento);
  
  -- Determinar usuário para auditoria
  audit_user := COALESCE(p_created_by, rec.created_by, vaga_base.vagas_updateby);

  -- Log do início da operação
  RAISE NOTICE 'Gerando vagas recorrentes para recorrência: % de % até % (dias para pagamento: %)', 
    p_recorrencia_id, rec.data_inicio, rec.data_fim, dias_para_pagamento;

  -- Loop de datas
  dia := rec.data_inicio + interval '1 day'; -- Pula o primeiro dia (já criado na vaga base)
  WHILE dia <= rec.data_fim LOOP
    IF array_position(dias, extract(dow from dia)::integer) IS NOT NULL THEN
      
      -- Calcular nova data de pagamento baseada na nova data + dias originais
      IF dias_para_pagamento IS NOT NULL THEN
        nova_data_pagamento := dia + (dias_para_pagamento || ' days')::interval;
      ELSE
        nova_data_pagamento := NULL;
      END IF;
      
      -- Cria nova vaga com data de pagamento recalculada
      INSERT INTO public.vagas (
        vagas_createdate, vagas_hospital, vagas_data, vagas_periodo, vagas_horainicio, vagas_horafim, vagas_valor,
        vagas_datapagamento, vagas_formarecebimento, vagas_tipo, vagas_setor, vagas_escalista, vagas_updateat, vagas_status,
        vagas_updateby, vaga_especialidade, grupo_id, vagas_observacoes, vagas_totalcandidaturas, recorrencia_id
      ) VALUES (
        now_brasil, vaga_base.vagas_hospital, dia, vaga_base.vagas_periodo, vaga_base.vagas_horainicio, vaga_base.vagas_horafim, vaga_base.vagas_valor,
        nova_data_pagamento, -- DATA DE PAGAMENTO RECALCULADA
        vaga_base.vagas_formarecebimento, vaga_base.vagas_tipo, vaga_base.vagas_setor, vaga_base.vagas_escalista, now_brasil,
        CASE WHEN p_medico_id IS NOT NULL THEN 'fechada' ELSE 'aberta' END,
        audit_user,
        vaga_base.vaga_especialidade, vaga_base.grupo_id, vaga_base.vagas_observacoes, 0, p_recorrencia_id
      ) RETURNING vagas_id INTO nova_vaga_id;
      
      -- Inserir benefícios para cada vaga criada
      IF p_beneficios IS NOT NULL AND array_length(p_beneficios, 1) > 0 THEN
        FOR beneficio_id IN SELECT unnest(p_beneficios) LOOP
          INSERT INTO public.vagas_beneficio (vagas_id, beneficio_id)
          VALUES (nova_vaga_id, beneficio_id::uuid);
        END LOOP;
      END IF;

      -- Inserir requisitos para cada vaga criada
      IF p_requisitos IS NOT NULL AND array_length(p_requisitos, 1) > 0 THEN
        FOR requisito_id IN SELECT unnest(p_requisitos) LOOP
          INSERT INTO public.vagas_requisito (vagas_id, requisito_id)
          VALUES (nova_vaga_id, requisito_id::uuid);
        END LOOP;
      END IF;
      
      -- Se houver médico designado, cria candidatura aprovada
      IF p_medico_id IS NOT NULL THEN
        INSERT INTO public.candidaturas (
          medico_id, vagas_id, candidatura_status, candidatos_createdate, candidaturas_updateat, candidaturas_updateby, vagas_valor
        ) VALUES (
          p_medico_id, nova_vaga_id, 'APROVADO', now_brasil, now_brasil, 
          audit_user::text,
          vaga_base.vagas_valor
        );
      END IF;
      
      RAISE NOTICE 'Vaga criada para dia % com pagamento em %: %', dia, nova_data_pagamento, nova_vaga_id;
    END IF;
    dia := dia + interval '1 day';
  END LOOP;
  
  RAISE NOTICE 'Geração de vagas recorrentes concluída para recorrência: %', p_recorrencia_id;
END;
$$;;
