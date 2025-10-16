-- Migration: Add total_candidaturas field to vw_vagas_candidaturas view
-- Date: 2025-10-14

-- =====================================================
-- Adicionar campo total_candidaturas à view vw_vagas_candidaturas
-- =====================================================

-- Drop the existing view
DROP VIEW IF EXISTS public.vw_vagas_candidaturas CASCADE;

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
  combined_data.hospital_estado,
  combined_data.hospital_lat,
  combined_data.hospital_log,
  combined_data.hospital_end,
  combined_data.hospital_avatar,
  combined_data.especialidade_id,
  combined_data.especialidade_nome,
  combined_data.setor_id,
  combined_data.setor_nome,
  combined_data.escalista_id,
  combined_data.escalista_nome,
  combined_data.escalista_email,
  combined_data.escalista_telefone,
  combined_data.grupo_id,
  combined_data.grupo_nome,
  combined_data.candidaturas_id,
  combined_data.total_candidaturas,
  combined_data.candidatura_status,
  combined_data.candidatura_createdate,
  combined_data.candidatura_updateby,
  combined_data.candidatura_updatedat,
  combined_data.effective_medico_id AS medico_id,
  combined_data.medico_primeiro_nome,
  combined_data.medico_sobrenome,
  combined_data.medico_crm,
  combined_data.medico_cpf,
  combined_data.medico_estado,
  combined_data.medico_email,
  combined_data.medico_telefone,
  combined_data.medico_precadastro_id,
  combined_data.recorrencia_id,
  combined_data.vaga_salva,
  combined_data.medico_favorito,
  combined_data.checkin,
  combined_data.checkout,
  combined_data.pagamento_valor,
  combined_data.grade_id,
  combined_data.grade_nome,
  combined_data.grade_cor
FROM (
  SELECT DISTINCT
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
    h.estado AS hospital_estado,
    h.latitude AS hospital_lat,
    h.longitude AS hospital_log,
    h.endereco_formatado AS hospital_end,
    h.avatar AS hospital_avatar,
    v.especialidade_id,
    e.nome AS especialidade_nome,
    v.setor_id,
    s.nome AS setor_nome,
    v.escalista_id,
    esc.nome AS escalista_nome,
    esc.email AS escalista_email,
    esc.telefone AS escalista_telefone,
    v.grupo_id,
    g.nome AS grupo_nome,
    c.id AS candidaturas_id,
    count_candidaturas_total(v.id) AS total_candidaturas,
    c.status AS candidatura_status,
    c.created_at AS candidatura_createdate,
    c.updated_by AS candidatura_updateby,
    c.updated_at AS candidatura_updatedat,
    CASE
      WHEN c.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
      AND c.medico_precadastro_id IS NOT NULL THEN c.medico_precadastro_id
      ELSE vm.medico_id
    END AS effective_medico_id,
    COALESCE(
      m.primeiro_nome,
      mp.primeiro_nome::text
    ) AS medico_primeiro_nome,
    COALESCE(m.sobrenome, mp.sobrenome::text) AS medico_sobrenome,
    COALESCE(m.crm, mp.crm::text) AS medico_crm,
    COALESCE(m.cpf, mp.cpf::text) AS medico_cpf,
    COALESCE(m.estado, mp.estado) AS medico_estado,
    COALESCE(m.email, mp.email::text) AS medico_email,
    COALESCE(m.telefone, mp.telefone::text) AS medico_telefone,
    c.medico_precadastro_id,
    v.recorrencia_id,
    CASE
      WHEN vs.medico_id IS NOT NULL
      OR vsp.medico_id IS NOT NULL THEN true
      ELSE false
    END AS vaga_salva,
    current_user_is_favorito(v.grupo_id) AS medico_favorito,
    COALESCE(cc.checkin, ccp.checkin) AS checkin,
    COALESCE(cc.checkout, ccp.checkout) AS checkout,
    pg.valor AS pagamento_valor,
    v.grade_id,
    gr.nome AS grade_nome,
    gr.cor AS grade_cor
  FROM
    vagas v
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
      FROM
        candidaturas
      WHERE
        candidaturas.medico_id IS NOT NULL
        AND candidaturas.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
      UNION
      SELECT
        candidaturas.vagas_id,
        candidaturas.medico_precadastro_id AS medico_id
      FROM
        candidaturas
      WHERE
        candidaturas.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
        AND candidaturas.medico_precadastro_id IS NOT NULL
      UNION
      SELECT
        vagas_salvas.vagas_id,
        vagas_salvas.medico_id
      FROM
        vagas_salvas
      WHERE
        vagas_salvas.medico_id IS NOT NULL
    ) vm ON vm.vagas_id = v.id
    LEFT JOIN candidaturas c ON c.vagas_id = v.id
    AND (
      c.medico_id = vm.medico_id
      AND c.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
      OR c.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
      AND c.medico_precadastro_id = vm.medico_id
    )
    LEFT JOIN medicos m ON c.medico_id = m.id
    AND c.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
    LEFT JOIN medicos_precadastro mp ON c.medico_precadastro_id = mp.id
    LEFT JOIN vagas_salvas vs ON vs.vagas_id = v.id
    AND vs.medico_id = vm.medico_id
    LEFT JOIN vagas_salvas vsp ON vsp.vagas_id = v.id
    AND vsp.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
    LEFT JOIN checkin_checkout cc ON cc.vaga_id = v.id
    AND cc.medico_id = vm.medico_id
    LEFT JOIN checkin_checkout ccp ON ccp.vaga_id = v.id
    AND ccp.medico_id = CASE
      WHEN c.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid THEN c.medico_precadastro_id
      ELSE vm.medico_id
    END
    LEFT JOIN pagamentos pg ON pg.candidaturas_id = c.id
) combined_data;