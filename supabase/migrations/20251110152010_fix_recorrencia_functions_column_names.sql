-- Migration: Corrigir nomenclatura de colunas nas funções de recorrência
-- Data: 2025-10-31
-- Descrição: Corrige todas as funções relacionadas a criação e edição de vagas recorrentes
-- Issue: Funções usavam nomenclatura antiga após refatoração (vagas_* → nomes sem prefixo)
-- Impacto: Sistema de recorrência completamente quebrado

-- ============================================
-- MAPEAMENTO DE CORREÇÕES
-- ============================================
-- TABELA: vagas
-- vagas_createdate → created_at
-- vagas_hospital → hospital_id
-- vagas_data → data
-- vagas_periodo → periodo_id
-- vagas_horainicio → hora_inicio
-- vagas_horafim → hora_fim
-- vagas_valor → valor
-- vagas_datapagamento → data_pagamento
-- vagas_formarecebimento → forma_recebimento_id
-- vagas_tipo → tipos_vaga_id
-- vagas_setor → setor_id
-- vagas_escalista → escalista_id
-- vagas_updateat → updated_at
-- vagas_status → status
-- vagas_updateby → updated_by
-- vaga_especialidade → especialidade_id
-- vagas_observacoes → observacoes
-- vagas_totalcandidaturas → total_candidaturas
-- vagas_id → id

-- TABELA: candidaturas
-- vagas_id → vaga_id
-- candidatura_status → status
-- candidatos_createdate → created_at
-- candidaturas_updateat → updated_at
-- candidaturas_updateby → updated_by
-- vagas_valor → vaga_valor
-- candidaturas_id → id

-- TABELAS RELACIONADAS
-- vagas_beneficio → vagas_beneficios (com 's')
-- vagas_requisito → vagas_requisitos (com 's')
-- vagas_recorrencia → vagas_recorrencias (com 's')

-- ============================================
-- 1. Função: criar_recorrencia_com_vagas (versão completa com benefícios/requisitos)
-- ============================================

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
)
RETURNS uuid
LANGUAGE plpgsql
AS $function$
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
  INSERT INTO public.vagas_recorrencias (  -- CORRIGIDO: vagas_recorrencia → vagas_recorrencias
    data_inicio, data_fim, dias_semana, observacoes, created_by
  ) VALUES (
    p_data_inicio, p_data_fim, p_dias_semana, p_observacoes, p_created_by
  ) RETURNING id INTO nova_recorrencia_id;  -- CORRIGIDO: recorrencia_id → id

  -- Cria a vaga base (primeira vaga) com nomenclatura correta
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
    grupo_id,                -- OK: já estava correto
    observacoes,             -- CORRIGIDO: vagas_observacoes
    total_candidaturas,      -- CORRIGIDO: vagas_totalcandidaturas
    recorrencia_id           -- OK: já estava correto
  ) VALUES (
    now_brasil,
    (p_vaga_base->>'hospital_id')::uuid,          -- CORRIGIDO chave JSON
    (p_vaga_base->>'data')::date,                 -- CORRIGIDO chave JSON
    (p_vaga_base->>'periodo_id')::uuid,           -- CORRIGIDO chave JSON
    (p_vaga_base->>'hora_inicio')::time,          -- CORRIGIDO chave JSON
    (p_vaga_base->>'hora_fim')::time,             -- CORRIGIDO chave JSON
    (p_vaga_base->>'valor')::integer,             -- CORRIGIDO chave JSON
    CASE
      WHEN p_vaga_base->>'data_pagamento' IS NOT NULL  -- CORRIGIDO chave JSON
      THEN (p_vaga_base->>'data_pagamento')::date
      ELSE NULL
    END,
    CASE
      WHEN p_vaga_base->>'forma_recebimento_id' IS NOT NULL  -- CORRIGIDO chave JSON
      THEN (p_vaga_base->>'forma_recebimento_id')::uuid
      ELSE NULL
    END,
    (p_vaga_base->>'tipos_vaga_id')::uuid,        -- CORRIGIDO chave JSON
    (p_vaga_base->>'setor_id')::uuid,             -- CORRIGIDO chave JSON
    (p_vaga_base->>'escalista_id')::uuid,         -- CORRIGIDO chave JSON
    now_brasil,
    CASE WHEN p_medico_id IS NOT NULL THEN 'fechada' ELSE 'aberta' END,
    p_created_by,
    (p_vaga_base->>'especialidade_id')::uuid,     -- CORRIGIDO chave JSON
    (p_vaga_base->>'grupo_id')::uuid,
    p_vaga_base->>'observacoes',                  -- CORRIGIDO chave JSON
    0,
    nova_recorrencia_id
  ) RETURNING id INTO nova_vaga_id;  -- CORRIGIDO: vagas_id → id

  -- Inserir benefícios da vaga base
  IF p_beneficios IS NOT NULL AND array_length(p_beneficios, 1) > 0 THEN
    FOR beneficio_id IN SELECT unnest(p_beneficios) LOOP
      INSERT INTO public.vagas_beneficios (vaga_id, beneficio_id)  -- CORRIGIDO: vagas_beneficio → vagas_beneficios, vagas_id → vaga_id
      VALUES (nova_vaga_id, beneficio_id::uuid);
    END LOOP;
  END IF;

  -- Inserir requisitos da vaga base
  IF p_requisitos IS NOT NULL AND array_length(p_requisitos, 1) > 0 THEN
    FOR requisito_id IN SELECT unnest(p_requisitos) LOOP
      INSERT INTO public.vagas_requisitos (vaga_id, requisito_id)  -- CORRIGIDO: vagas_requisito → vagas_requisitos, vagas_id → vaga_id
      VALUES (nova_vaga_id, requisito_id::uuid);
    END LOOP;
  END IF;

  -- Criar candidatura aprovada para a vaga base se há médico designado
  IF p_medico_id IS NOT NULL THEN
    INSERT INTO public.candidaturas (
      medico_id,
      vaga_id,            -- CORRIGIDO: vagas_id → vaga_id
      status,             -- CORRIGIDO: candidatura_status → status
      created_at,         -- CORRIGIDO: candidatos_createdate → created_at
      updated_at,         -- CORRIGIDO: candidaturas_updateat → updated_at
      updated_by,         -- CORRIGIDO: candidaturas_updateby → updated_by
      vaga_valor          -- CORRIGIDO: vagas_valor → vaga_valor
    ) VALUES (
      p_medico_id,
      nova_vaga_id,
      'APROVADO',
      now_brasil,
      now_brasil,
      p_created_by::text,
      (p_vaga_base->>'valor')::integer  -- CORRIGIDO chave JSON
    );

    RAISE NOTICE 'Candidatura aprovada criada para vaga base: % (médico: %)', nova_vaga_id, p_medico_id;
  END IF;

  -- Gera as demais vagas recorrentes
  PERFORM public.gerar_vagas_recorrentes(nova_recorrencia_id, nova_vaga_id, p_medico_id, p_created_by, p_beneficios, p_requisitos);

  RAISE NOTICE 'Recorrência criada com sucesso: % (vaga base: %)', nova_recorrencia_id, nova_vaga_id;

  RETURN nova_recorrencia_id;
END;
$function$;

-- ============================================
-- 2. Função: criar_recorrencia_com_vagas (versão simplificada sem benefícios/requisitos)
-- ============================================

CREATE OR REPLACE FUNCTION public.criar_recorrencia_com_vagas(
  p_data_inicio date,
  p_data_fim date,
  p_dias_semana integer[],
  p_vaga_base jsonb,
  p_created_by uuid,
  p_medico_id uuid DEFAULT NULL::uuid,
  p_observacoes text DEFAULT NULL::text
)
RETURNS uuid
LANGUAGE plpgsql
AS $function$
BEGIN
  -- Chama a versão completa com arrays vazios
  RETURN criar_recorrencia_com_vagas(
    p_data_inicio,
    p_data_fim,
    p_dias_semana,
    p_vaga_base,
    p_created_by,
    p_medico_id,
    p_observacoes,
    ARRAY[]::text[],  -- beneficios vazios
    ARRAY[]::text[]   -- requisitos vazios
  );
END;
$function$;

