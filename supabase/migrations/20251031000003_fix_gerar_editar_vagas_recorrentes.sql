-- Migration: Corrigir funções gerar_vagas_recorrentes e editar_vagas_recorrencia
-- Data: 2025-10-31
-- Descrição: Corrige funções auxiliares de gerenciamento de vagas recorrentes
-- Issue: Mesmas inconsistências de nomenclatura das outras funções de recorrência

-- ============================================
-- 1. Função: gerar_vagas_recorrentes
-- ============================================

CREATE OR REPLACE FUNCTION public.gerar_vagas_recorrentes(
  p_recorrencia_id uuid,
  p_vaga_base_id uuid,
  p_medico_id uuid DEFAULT NULL::uuid,
  p_created_by uuid DEFAULT NULL::uuid,
  p_beneficios text[] DEFAULT ARRAY[]::text[],
  p_requisitos text[] DEFAULT ARRAY[]::text[]
)
RETURNS void
LANGUAGE plpgsql
AS $function$
DECLARE
  rec public.vagas_recorrencias%ROWTYPE;  -- CORRIGIDO: vagas_recorrencia → vagas_recorrencias
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
  SELECT * INTO rec FROM public.vagas_recorrencias WHERE id = p_recorrencia_id;  -- CORRIGIDO: vagas_recorrencia → vagas_recorrencias, recorrencia_id → id
  SELECT * INTO vaga_base FROM public.vagas WHERE id = p_vaga_base_id;  -- CORRIGIDO: vagas_id → id
  dias := rec.dias_semana;

  -- Calcular quantos dias há entre a data do plantão e a data de pagamento na vaga base
  dias_para_pagamento := calcular_dias_pagamento(vaga_base.data, vaga_base.data_pagamento);  -- CORRIGIDO: vagas_data → data, vagas_datapagamento → data_pagamento

  -- Determinar usuário para auditoria
  audit_user := COALESCE(p_created_by, rec.created_by, vaga_base.updated_by);  -- CORRIGIDO: vagas_updateby → updated_by

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
        created_at,              -- CORRIGIDO: vagas_createdate
        hospital_id,             -- CORRIGIDO: vagas_hospital
        data,                    -- CORRIGIDO: vagas_data
        periodo_id,              -- CORRIGIDO: vagas_periodo
        hora_inicio,             -- CORRIGIDO: vagas_horainicio
        hora_fim,                -- CORRIGIDO: vagas_horafim
        valor,                   -- CORRIGIDO: vagas_valor
        data_pagamento,          -- CORRIGIDO: vagas_datapagamento
        forma_recebimento_id,    -- CORRIGIDO: vagas_formarecebimento
        tipos_vaga_id,           -- CORRIGIDO: vagas_tipo
        setor_id,                -- CORRIGIDO: vagas_setor
        escalista_id,            -- CORRIGIDO: vagas_escalista
        updated_at,              -- CORRIGIDO: vagas_updateat
        status,                  -- CORRIGIDO: vagas_status
        updated_by,              -- CORRIGIDO: vagas_updateby
        especialidade_id,        -- CORRIGIDO: vaga_especialidade
        grupo_id,
        observacoes,             -- CORRIGIDO: vagas_observacoes
        total_candidaturas,      -- CORRIGIDO: vagas_totalcandidaturas
        recorrencia_id
      ) VALUES (
        now_brasil,
        vaga_base.hospital_id,   -- CORRIGIDO: vagas_hospital
        dia,
        vaga_base.periodo_id,    -- CORRIGIDO: vagas_periodo
        vaga_base.hora_inicio,   -- CORRIGIDO: vagas_horainicio
        vaga_base.hora_fim,      -- CORRIGIDO: vagas_horafim
        vaga_base.valor,         -- CORRIGIDO: vagas_valor
        nova_data_pagamento,     -- DATA DE PAGAMENTO RECALCULADA
        vaga_base.forma_recebimento_id,  -- CORRIGIDO: vagas_formarecebimento
        vaga_base.tipos_vaga_id, -- CORRIGIDO: vagas_tipo
        vaga_base.setor_id,      -- CORRIGIDO: vagas_setor
        vaga_base.escalista_id,  -- CORRIGIDO: vagas_escalista
        now_brasil,
        CASE WHEN p_medico_id IS NOT NULL THEN 'fechada' ELSE 'aberta' END,
        audit_user,
        vaga_base.especialidade_id,  -- CORRIGIDO: vaga_especialidade
        vaga_base.grupo_id,
        vaga_base.observacoes,   -- CORRIGIDO: vagas_observacoes
        0,
        p_recorrencia_id
      ) RETURNING id INTO nova_vaga_id;  -- CORRIGIDO: vagas_id → id

      -- Inserir benefícios para cada vaga criada
      IF p_beneficios IS NOT NULL AND array_length(p_beneficios, 1) > 0 THEN
        FOR beneficio_id IN SELECT unnest(p_beneficios) LOOP
          INSERT INTO public.vagas_beneficios (vaga_id, beneficio_id)  -- CORRIGIDO: vagas_beneficio → vagas_beneficios, vagas_id → vaga_id
          VALUES (nova_vaga_id, beneficio_id::uuid);
        END LOOP;
      END IF;

      -- Inserir requisitos para cada vaga criada
      IF p_requisitos IS NOT NULL AND array_length(p_requisitos, 1) > 0 THEN
        FOR requisito_id IN SELECT unnest(p_requisitos) LOOP
          INSERT INTO public.vagas_requisitos (vaga_id, requisito_id)  -- CORRIGIDO: vagas_requisito → vagas_requisitos, vagas_id → vaga_id
          VALUES (nova_vaga_id, requisito_id::uuid);
        END LOOP;
      END IF;

      -- Se houver médico designado, cria candidatura aprovada
      IF p_medico_id IS NOT NULL THEN
        INSERT INTO public.candidaturas (
          medico_id,
          vaga_id,          -- CORRIGIDO: vagas_id → vaga_id
          status,           -- CORRIGIDO: candidatura_status → status
          created_at,       -- CORRIGIDO: candidatos_createdate → created_at
          updated_at,       -- CORRIGIDO: candidaturas_updateat → updated_at
          updated_by,       -- CORRIGIDO: candidaturas_updateby → updated_by
          vaga_valor        -- CORRIGIDO: vagas_valor → vaga_valor
        ) VALUES (
          p_medico_id,
          nova_vaga_id,
          'APROVADO',
          now_brasil,
          now_brasil,
          audit_user::text,
          vaga_base.valor  -- CORRIGIDO: vagas_valor → valor
        );
      END IF;

      RAISE NOTICE 'Vaga criada para dia % com pagamento em %: %', dia, nova_data_pagamento, nova_vaga_id;
    END IF;
    dia := dia + interval '1 day';
  END LOOP;

  RAISE NOTICE 'Geração de vagas recorrentes concluída para recorrência: %', p_recorrencia_id;
END;
$function$;

-- ============================================
-- 2. Função: editar_vagas_recorrencia
-- ============================================

CREATE OR REPLACE FUNCTION public.editar_vagas_recorrencia(
  p_recorrencia_id uuid,
  p_update jsonb,
  p_updateby uuid,
  p_beneficios text[] DEFAULT ARRAY[]::text[],
  p_requisitos text[] DEFAULT ARRAY[]::text[],
  p_dias_pagamento integer DEFAULT NULL::integer
)
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
    dias_para_pagamento := p_dias_pagamento;
    RAISE NOTICE 'Usando dias de pagamento especificados: % dias', dias_para_pagamento;
  ELSIF (p_update ? 'data_pagamento') THEN  -- CORRIGIDO chave JSON
    SELECT calcular_dias_pagamento(v.data, v.data_pagamento)  -- CORRIGIDO: vagas_data → data, vagas_datapagamento → data_pagamento
    INTO dias_para_pagamento
    FROM vagas v
    WHERE v.recorrencia_id = p_recorrencia_id
    ORDER BY v.data  -- CORRIGIDO: vagas_data → data
    LIMIT 1;

    RAISE NOTICE 'Calculando dias baseado na primeira vaga: % dias', dias_para_pagamento;
  ELSE
    dias_para_pagamento := NULL;
    RAISE NOTICE 'Mantendo datas de pagamento originais';
  END IF;

  FOR vaga IN SELECT * FROM public.vagas WHERE recorrencia_id = p_recorrencia_id LOOP

    -- CALCULAR NOVA DATA DE PAGAMENTO PARA CADA VAGA INDIVIDUALMENTE
    IF dias_para_pagamento IS NOT NULL THEN
      nova_data_pagamento := vaga.data + (dias_para_pagamento || ' days')::interval;  -- CORRIGIDO: vagas_data → data
      RAISE NOTICE 'Vaga %: Data plantão %, nova data pagamento % (+ % dias)',
        vaga.id, vaga.data, nova_data_pagamento, dias_para_pagamento;  -- CORRIGIDO: vagas_id → id, vagas_data → data
    ELSE
      nova_data_pagamento := COALESCE((p_update->>'data_pagamento')::date, vaga.data_pagamento);  -- CORRIGIDO chave JSON e coluna
    END IF;

    -- Atualizar dados da vaga (usando nomenclatura correta)
    UPDATE public.vagas SET
      hospital_id = COALESCE((p_update->>'hospital_id')::uuid, hospital_id),                      -- CORRIGIDO
      data = COALESCE((p_update->>'data')::date, data),                                          -- CORRIGIDO
      periodo_id = COALESCE((p_update->>'periodo_id')::uuid, periodo_id),                        -- CORRIGIDO
      hora_inicio = COALESCE((p_update->>'hora_inicio')::time, hora_inicio),                     -- CORRIGIDO
      hora_fim = COALESCE((p_update->>'hora_fim')::time, hora_fim),                              -- CORRIGIDO
      valor = COALESCE((p_update->>'valor')::integer, valor),                                    -- CORRIGIDO
      data_pagamento = nova_data_pagamento,                                                      -- CORRIGIDO
      forma_recebimento_id = COALESCE((p_update->>'forma_recebimento_id')::uuid, forma_recebimento_id),  -- CORRIGIDO
      tipos_vaga_id = COALESCE((p_update->>'tipos_vaga_id')::uuid, tipos_vaga_id),             -- CORRIGIDO
      observacoes = COALESCE((p_update->>'observacoes'), observacoes),                          -- CORRIGIDO
      setor_id = COALESCE((p_update->>'setor_id')::uuid, setor_id),                            -- CORRIGIDO
      escalista_id = COALESCE((p_update->>'escalista_id')::uuid, escalista_id),                -- CORRIGIDO
      especialidade_id = COALESCE((p_update->>'especialidade_id')::uuid, especialidade_id),    -- CORRIGIDO
      grupo_id = COALESCE((p_update->>'grupo_id')::uuid, grupo_id),
      status = CASE                                                                              -- CORRIGIDO
        WHEN (p_update ? 'medico_id') THEN
          CASE WHEN novo_medico_id IS NOT NULL THEN 'fechada' ELSE 'aberta' END
        ELSE status
      END,
      updated_at = now_brasil,                                                                   -- CORRIGIDO
      updated_by = p_updateby                                                                    -- CORRIGIDO
    WHERE id = vaga.id;  -- CORRIGIDO: vagas_id → id

    -- Atualizar benefícios da vaga
    DELETE FROM public.vagas_beneficios WHERE vaga_id = vaga.id;  -- CORRIGIDO: vagas_beneficio → vagas_beneficios, vagas_id → vaga_id
    IF p_beneficios IS NOT NULL AND array_length(p_beneficios, 1) > 0 THEN
      FOR beneficio_id IN SELECT unnest(p_beneficios) LOOP
        INSERT INTO public.vagas_beneficios (vaga_id, beneficio_id)  -- CORRIGIDO
        VALUES (vaga.id, beneficio_id::uuid);  -- CORRIGIDO: vagas_id → id
      END LOOP;
    END IF;

    -- Atualizar requisitos da vaga
    DELETE FROM public.vagas_requisitos WHERE vaga_id = vaga.id;  -- CORRIGIDO: vagas_requisito → vagas_requisitos, vagas_id → vaga_id
    IF p_requisitos IS NOT NULL AND array_length(p_requisitos, 1) > 0 THEN
      FOR requisito_id IN SELECT unnest(p_requisitos) LOOP
        INSERT INTO public.vagas_requisitos (vaga_id, requisito_id)  -- CORRIGIDO
        VALUES (vaga.id, requisito_id::uuid);  -- CORRIGIDO: vagas_id → id
      END LOOP;
    END IF;

    vagas_atualizadas := vagas_atualizadas + 1;

    -- Gerenciar candidaturas quando médico é especificado
    IF (p_update ? 'medico_id') THEN
      IF novo_medico_id IS NOT NULL THEN
        SELECT * INTO candidatura_existente
        FROM public.candidaturas
        WHERE vaga_id = vaga.id AND status = 'APROVADO'  -- CORRIGIDO: vagas_id → vaga_id, vagas_id (vaga) → id, candidatura_status → status
        LIMIT 1;

        IF candidatura_existente.id IS NOT NULL THEN  -- CORRIGIDO: candidaturas_id → id
          UPDATE public.candidaturas SET
            medico_id = novo_medico_id,
            updated_at = now_brasil,           -- CORRIGIDO: candidaturas_updateat → updated_at
            updated_by = p_updateby::text      -- CORRIGIDO: candidaturas_updateby → updated_by
          WHERE id = candidatura_existente.id;  -- CORRIGIDO: candidaturas_id → id
        ELSE
          INSERT INTO public.candidaturas (
            medico_id,
            vaga_id,        -- CORRIGIDO: vagas_id → vaga_id
            status,         -- CORRIGIDO: candidatura_status → status
            created_at,     -- CORRIGIDO: candidatos_createdate → created_at
            updated_at,     -- CORRIGIDO: candidaturas_updateat → updated_at
            updated_by,     -- CORRIGIDO: candidaturas_updateby → updated_by
            vaga_valor      -- CORRIGIDO: vagas_valor → vaga_valor
          ) VALUES (
            novo_medico_id,
            vaga.id,        -- CORRIGIDO: vagas_id → id
            'APROVADO',
            now_brasil,
            now_brasil,
            p_updateby::text,
            vaga.valor      -- CORRIGIDO: vagas_valor → valor
          );
        END IF;
      ELSE
        DELETE FROM public.candidaturas
        WHERE vaga_id = vaga.id AND status = 'APROVADO';  -- CORRIGIDO: vagas_id → vaga_id, vagas_id (vaga) → id, candidatura_status → status
      END IF;
    END IF;
  END LOOP;

  RAISE NOTICE 'Edição concluída. % vagas atualizadas para recorrência: %', vagas_atualizadas, p_recorrencia_id;

  IF vagas_atualizadas = 0 THEN
    RAISE EXCEPTION 'Nenhuma vaga encontrada para a recorrência: %', p_recorrencia_id;
  END IF;
END;
$function$;

-- ============================================
-- 3. Versões simplificadas (overloaded functions)
-- ============================================

-- Versão sem benefícios/requisitos para gerar_vagas_recorrentes
CREATE OR REPLACE FUNCTION public.gerar_vagas_recorrentes(
  p_recorrencia_id uuid,
  p_vaga_base_id uuid,
  p_medico_id uuid DEFAULT NULL::uuid,
  p_created_by uuid DEFAULT NULL::uuid
)
RETURNS void
LANGUAGE plpgsql
AS $function$
BEGIN
  PERFORM gerar_vagas_recorrentes(
    p_recorrencia_id,
    p_vaga_base_id,
    p_medico_id,
    p_created_by,
    ARRAY[]::text[],  -- beneficios vazios
    ARRAY[]::text[]   -- requisitos vazios
  );
END;
$function$;

-- Versão sem dias_pagamento para editar_vagas_recorrencia
CREATE OR REPLACE FUNCTION public.editar_vagas_recorrencia(
  p_recorrencia_id uuid,
  p_update jsonb,
  p_updateby uuid,
  p_beneficios text[] DEFAULT ARRAY[]::text[],
  p_requisitos text[] DEFAULT ARRAY[]::text[]
)
RETURNS void
LANGUAGE plpgsql
AS $function$
BEGIN
  PERFORM editar_vagas_recorrencia(
    p_recorrencia_id,
    p_update,
    p_updateby,
    p_beneficios,
    p_requisitos,
    NULL  -- dias_pagamento
  );
END;
$function$;

-- Versão mais simples sem benefícios/requisitos/dias_pagamento
CREATE OR REPLACE FUNCTION public.editar_vagas_recorrencia(
  p_recorrencia_id uuid,
  p_update jsonb,
  p_updateby uuid
)
RETURNS void
LANGUAGE plpgsql
AS $function$
BEGIN
  PERFORM editar_vagas_recorrencia(
    p_recorrencia_id,
    p_update,
    p_updateby,
    ARRAY[]::text[],  -- beneficios vazios
    ARRAY[]::text[],  -- requisitos vazios
    NULL              -- dias_pagamento
  );
END;
$function$;