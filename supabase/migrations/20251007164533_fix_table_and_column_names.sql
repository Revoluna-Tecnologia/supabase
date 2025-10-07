-- MIGRAÇÃO: Correções de nomenclatura de tabelas e colunas

-- =====================================================
-- RENOMEAÇÕES DE TABELAS E COLUNAS
-- =====================================================

--
-- codigos_de_areas → codigos_area
--

ALTER TABLE IF EXISTS public.codigos_de_areas RENAME TO codigos_area;

--
-- clean_hospitais → clean_hospital
--

ALTER TABLE IF EXISTS public.clean_hospitais RENAME TO clean_hospital;

--
-- formas_recebimentos → formas_recebimento
--

-- PRIMEIRO: Remover foreign keys que dependem desta tabela
ALTER TABLE public.vagas
    DROP CONSTRAINT IF EXISTS vagas_formarecebimento_fkey;

-- Renomear a tabela
ALTER TABLE public.formas_recebimentos RENAME TO formas_recebimento;

-- Recriar foreign key com novo nome da tabela
ALTER TABLE public.vagas
    ADD CONSTRAINT vagas_formarecebimento_fkey 
    FOREIGN KEY (forma_recebimento_id) REFERENCES formas_recebimento (id);

--
-- tipo_vagas → tipos_vaga
--

-- PRIMEIRO: Remover foreign keys que dependem desta tabela
ALTER TABLE public.vagas
    DROP CONSTRAINT IF EXISTS vagas_vagas_tipo_fkey;

-- Renomear a tabela
ALTER TABLE public.tipo_vagas RENAME TO tipos_vaga;

-- Recriar foreign key com novo nome da tabela
ALTER TABLE public.vagas
    ADD CONSTRAINT vagas_vagas_tipo_fkey 
    FOREIGN KEY (tipo_vagas_id) REFERENCES tipos_vaga (id);

--
-- vagas: alterar tipo_vagas_id para tipos_vaga_id
--

-- Primeiro remover a constraint
ALTER TABLE public.vagas
    DROP CONSTRAINT IF EXISTS vagas_vagas_tipo_fkey;

-- Renomear a coluna
ALTER TABLE public.vagas
    RENAME COLUMN tipo_vagas_id TO tipos_vaga_id;

-- Recriar a constraint com o novo nome da coluna
ALTER TABLE public.vagas
    ADD CONSTRAINT vagas_vagas_tipo_fkey 
    FOREIGN KEY (tipos_vaga_id) REFERENCES tipos_vaga (id);

-- =====================================================
-- ATUALIZAR VIEWS AFETADAS
-- =====================================================

-- Atualizar view vagas_completo para usar os novos nomes das tabelas
DROP VIEW IF EXISTS "public"."vagas_completo" CASCADE;

CREATE OR REPLACE VIEW "public"."vagas_completo"
WITH (security_invoker = on)
AS SELECT v.id AS vagas_id,
    v.created_at AS vagas_createdate,
    v.data AS vagas_data,
    v.hora_inicio AS vagas_horainicio,
    v.hora_fim AS vagas_horafim,
    v.valor AS vagas_valor,
    v.data_pagamento AS vagas_datapagamento,
    fr.forma_recebimento AS vagas_formarecebimento,
    v.observacoes AS vagas_observacoes,
    h.nome AS hospital_nome,
    s.nome AS setor_nome,
    p.nome AS periodo_nome,
    t.nome AS tipo_nome,
    esp.nome AS especialidade_nome,
    g.id AS grupo_id,
    g.nome AS grupo_nome,
    g.responsavel AS grupo_responsavel,
    g.telefone AS grupo_telefone,
    g.email AS grupo_email,
    v.status AS vagas_status,
    e.nome AS escalista_nome,
    e.id AS escalista_id,
    e.telefone AS escalista_telefone,
    e.email AS escalista_email,
    h.latitude AS hospital_lat,
    h.longitude AS hospital_log,
    h.endereco_formatado AS hospital_end,
    h.avatar AS hospital_avatar
   FROM ((((((((vagas v
     LEFT JOIN hospitais h ON ((v.hospital_id = h.id)))
     LEFT JOIN setores s ON ((v.setor_id = s.id)))
     LEFT JOIN periodos p ON ((v.periodo_id = p.id)))
     LEFT JOIN tipos_vaga t ON ((v.tipos_vaga_id = t.id)))        -- Atualizado: tipos_vaga_id → tipos_vaga
     LEFT JOIN escalistas e ON ((v.escalista_id = e.id)))
     LEFT JOIN especialidades esp ON ((v.especialidade_id = esp.id)))
     LEFT JOIN grupos g ON ((v.grupo_id = g.id)))
     LEFT JOIN formas_recebimento fr ON ((v.forma_recebimento_id = fr.id))); -- Atualizado: formas_recebimento

-- Recriar view vw_vagas_candidaturas com os novos nomes das tabelas
DROP VIEW IF EXISTS "public"."vw_vagas_candidaturas" CASCADE;

CREATE VIEW public.vw_vagas_candidaturas AS
SELECT
  row_number() OVER (
    ORDER BY 
      combined_data.vagas_id,
      combined_data.effective_medico_id,
      combined_data.candidaturas_id
  ) AS idx,
  combined_data.vagas_id,
  combined_data.vagas_data,
  combined_data.vagas_createdate,
  combined_data.vagas_status,
  combined_data.vagas_valor,
  combined_data.vagas_horainicio,
  combined_data.vagas_horafim,
  combined_data.vagas_datapagamento,
  combined_data.vagas_periodo,
  combined_data.vagas_periodo_nome,
  combined_data.vagas_tipo,
  combined_data.vagas_tipo_nome,
  combined_data.vagas_formarecebimento,
  combined_data.vagas_formarecebimento_nome,
  combined_data.vagas_observacoes,
  combined_data.hospital_id,
  combined_data.hospital_nome,
  combined_data.setor_id,
  combined_data.setor_nome,
  combined_data.escalista_id,
  combined_data.escalista_nome,
  combined_data.escalista_telefone,
  combined_data.escalista_email,
  combined_data.grupo_id,
  combined_data.grupo_nome,
  combined_data.grupo_responsavel,
  combined_data.grupo_telefone,
  combined_data.grupo_email,
  combined_data.especialidade_id,
  combined_data.especialidade_nome,
  combined_data.candidaturas_id,
  combined_data.candidatura_status,
  combined_data.candidatura_createdate,
  combined_data.candidatura_data_confirmacao,
  combined_data.candidatura_updatedat,
  combined_data.candidatura_updateby,
  combined_data.effective_medico_id,
  combined_data.medico_id,
  combined_data.medico_precadastro_id,
  combined_data.medico_primeiro_nome,
  combined_data.medico_sobrenome,
  combined_data.medico_crm,
  combined_data.medico_cpf,
  combined_data.medico_email,
  combined_data.medico_telefone,
  combined_data.medico_especialidade_nome,
  combined_data.medico_estado,
  combined_data.vaga_salva,
  combined_data.medico_favorito,
  combined_data.checkin,
  combined_data.checkout,
  combined_data.pagamento_valor,
  combined_data.grade_id,
  combined_data.grade_nome,
  combined_data.grade_cor
FROM (
  SELECT
    v.id AS vagas_id,
    v.data AS vagas_data,
    v.created_at AS vagas_createdate,
    v.status AS vagas_status,
    v.valor AS vagas_valor,
    v.hora_inicio AS vagas_horainicio,
    v.hora_fim AS vagas_horafim,
    v.data_pagamento AS vagas_datapagamento,
    v.periodo_id AS vagas_periodo,
    p.nome AS vagas_periodo_nome,
    v.tipos_vaga_id AS vagas_tipo,
    t.nome AS vagas_tipo_nome,
    v.forma_recebimento_id AS vagas_formarecebimento,
    f.forma_recebimento AS vagas_formarecebimento_nome,
    v.observacoes AS vagas_observacoes,
    v.hospital_id,
    h.nome AS hospital_nome,
    v.setor_id,
    s.nome AS setor_nome,
    v.escalista_id,
    esc.nome AS escalista_nome,
    esc.telefone AS escalista_telefone,
    esc.email AS escalista_email,
    v.grupo_id,
    g.nome AS grupo_nome,
    g.responsavel AS grupo_responsavel,
    g.telefone AS grupo_telefone,
    g.email AS grupo_email,
    v.especialidade_id,
    e.nome AS especialidade_nome,
    c.id AS candidaturas_id,
    c.status AS candidatura_status,
    c.created_at AS candidatura_createdate,
    c.data_confirmacao AS candidatura_data_confirmacao,
    c.updated_at AS candidatura_updatedat,
    c.updated_by AS candidatura_updateby,
    vm.medico_id AS effective_medico_id,
    COALESCE(m.id, mp.id) AS medico_id,
    c.medico_precadastro_id,
    COALESCE(m.primeiro_nome, mp.primeiro_nome) AS medico_primeiro_nome,
    COALESCE(m.sobrenome, mp.sobrenome) AS medico_sobrenome,
    COALESCE(m.crm, mp.crm) AS medico_crm,
    COALESCE(m.cpf, mp.cpf) AS medico_cpf,
    COALESCE(m.email, mp.email) AS medico_email,
    COALESCE(m.telefone, mp.telefone) AS medico_telefone,
    COALESCE(me.nome, mep.nome) AS medico_especialidade_nome,
    COALESCE(m.estado, mp.estado) AS medico_estado,
    CASE
      WHEN vs.medico_id IS NOT NULL OR vsp.medico_id IS NOT NULL THEN true
      ELSE false
    END AS vaga_salva,
    current_user_is_favorito(v.grupo_id) AS medico_favorito,
    COALESCE(cc.checkin, ccp.checkin) AS checkin,
    COALESCE(cc.checkout, ccp.checkout) AS checkout,
    pg.valor AS pagamento_valor,
    v.grade_id,
    gr.nome AS grade_nome,
    gr.cor AS grade_cor
  FROM vagas v
  JOIN hospitais h ON v.hospital_id = h.id
  JOIN especialidades e ON v.especialidade_id = e.id
  JOIN setores s ON v.setor_id = s.id
  LEFT JOIN escalistas esc ON v.escalista_id = esc.id
  LEFT JOIN grupos g ON v.grupo_id = g.id
  LEFT JOIN periodos p ON v.periodo_id = p.id
  LEFT JOIN tipos_vaga t ON v.tipos_vaga_id = t.id
  LEFT JOIN formas_recebimento f ON v.forma_recebimento_id = f.id
  LEFT JOIN grades gr ON v.grade_id = gr.id
  LEFT JOIN (
    SELECT
      candidaturas.vagas_id,
      candidaturas.medico_id
    FROM candidaturas
    WHERE candidaturas.medico_id IS NOT NULL
      AND candidaturas.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
    UNION
    SELECT
      candidaturas.vagas_id,
      candidaturas.medico_precadastro_id AS medico_id
    FROM candidaturas
    WHERE candidaturas.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
      AND candidaturas.medico_precadastro_id IS NOT NULL
    UNION
    SELECT
      vagas_salvas.vagas_id,
      vagas_salvas.medico_id
    FROM vagas_salvas
    WHERE vagas_salvas.medico_id IS NOT NULL
  ) vm ON vm.vagas_id = v.id
  LEFT JOIN candidaturas c ON c.vagas_id = v.id
    AND (
      (c.medico_id = vm.medico_id AND c.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid)
      OR (c.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid AND c.medico_precadastro_id = vm.medico_id)
    )
  LEFT JOIN medicos m ON c.medico_id = m.id
    AND c.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
  LEFT JOIN medicos_precadastro mp ON c.medico_precadastro_id = mp.id
  LEFT JOIN especialidades me ON m.especialidade_id = me.id
  LEFT JOIN especialidades mep ON mp.especialidade_id = mep.id
  LEFT JOIN vagas_salvas vs ON vs.vagas_id = v.id AND vs.medico_id = vm.medico_id
  LEFT JOIN vagas_salvas vsp ON vsp.vagas_id = v.id AND vsp.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
  LEFT JOIN checkin_checkout cc ON cc.vaga_id = v.id AND cc.medico_id = vm.medico_id
  LEFT JOIN checkin_checkout ccp ON ccp.vaga_id = v.id
    AND ccp.medico_id = CASE
      WHEN c.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid THEN c.medico_precadastro_id
      ELSE vm.medico_id
    END
  LEFT JOIN pagamentos pg ON pg.candidaturas_id = c.id
) combined_data;

