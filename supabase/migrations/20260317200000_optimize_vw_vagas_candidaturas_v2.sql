-- =============================================================================
-- Migration: Otimizar vw_vagas_candidaturas v2
-- Motivo: A view causa timeout (8s+) porque o row_number() OVER() impede o
--         Postgres de empurrar filtros (WHERE vaga_status = 'aberta') para
--         dentro da query. O Postgres computa TODAS as linhas antes de filtrar.
--
-- Solucao: Remover row_number() e a subquery wrapper, permitindo filter
--          push-down direto nas tabelas base. Ninguem usa a coluna idx.
-- =============================================================================

-- 1. Recriar a view SEM row_number() e SEM subquery wrapper
DROP VIEW IF EXISTS public.vw_vagas_candidaturas;

CREATE OR REPLACE VIEW public.vw_vagas_candidaturas
WITH (security_invoker = on)
AS
SELECT
    v.id AS vaga_id,
    v.data AS vaga_data,
    v.created_at AS vaga_createdate,
    v.status AS vaga_status,
    v.valor AS vaga_valor,
    v.hora_inicio AS vaga_horainicio,
    v.hora_fim AS vaga_horafim,
    v.data_pagamento AS vaga_datapagamento,
    v.periodo_id AS vaga_periodo,
    p.nome AS vaga_periodo_nome,
    v.tipos_vaga_id AS vaga_tipo,
    t.nome AS vaga_tipo_nome,
    v.forma_recebimento_id AS vaga_formarecebimento,
    f.forma_recebimento AS vaga_formarecebimento_nome,
    v.observacoes AS vaga_observacoes,
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
    c.id AS candidatura_id,
    COALESCE(candidatura_counts.total_count, 0)::INTEGER AS total_candidaturas,
    c.status AS candidatura_status,
    c.created_at AS candidatura_createdate,
    c.updated_by AS candidatura_updateby,
    c.updated_at AS candidatura_updatedat,
    CASE
        WHEN c.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
        AND c.medico_precadastro_id IS NOT NULL THEN c.medico_precadastro_id
        ELSE vm.medico_id
    END AS medico_id,
    COALESCE(m.primeiro_nome, mp.primeiro_nome::text) AS medico_primeiro_nome,
    COALESCE(m.sobrenome, mp.sobrenome::text) AS medico_sobrenome,
    COALESCE(m.crm, mp.crm::text) AS medico_crm,
    COALESCE(m.cpf, mp.cpf::text) AS medico_cpf,
    COALESCE(m.estado, mp.estado) AS medico_estado,
    COALESCE(m.email, mp.email::text) AS medico_email,
    COALESCE(m.telefone, mp.telefone::text) AS medico_telefone,
    c.medico_precadastro_id,
    v.recorrencia_id,
    CASE
        WHEN vs.medico_id IS NOT NULL OR vsp.medico_id IS NOT NULL THEN true
        ELSE false
    END AS vaga_salva,
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
        SELECT candidaturas.vaga_id, candidaturas.medico_id
        FROM candidaturas
        WHERE candidaturas.medico_id IS NOT NULL
            AND candidaturas.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
        UNION ALL
        SELECT candidaturas.vaga_id, candidaturas.medico_precadastro_id AS medico_id
        FROM candidaturas
        WHERE candidaturas.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
            AND candidaturas.medico_precadastro_id IS NOT NULL
        UNION ALL
        SELECT vagas_salvas.vaga_id, vagas_salvas.medico_id
        FROM vagas_salvas
        WHERE vagas_salvas.medico_id IS NOT NULL
    ) vm ON vm.vaga_id = v.id
    LEFT JOIN (
        SELECT vaga_id, COUNT(*)::INTEGER AS total_count
        FROM candidaturas
        GROUP BY vaga_id
    ) candidatura_counts ON candidatura_counts.vaga_id = v.id
    LEFT JOIN candidaturas c ON c.vaga_id = v.id AND (
        c.medico_id = vm.medico_id AND c.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
        OR c.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid AND c.medico_precadastro_id = vm.medico_id
    )
    LEFT JOIN medicos m ON c.medico_id = m.id AND c.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
    LEFT JOIN medicos_precadastro mp ON c.medico_precadastro_id = mp.id
    LEFT JOIN vagas_salvas vs ON vs.vaga_id = v.id AND vs.medico_id = vm.medico_id
    LEFT JOIN vagas_salvas vsp ON vsp.vaga_id = v.id AND vsp.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
    LEFT JOIN checkin_checkout cc ON cc.vaga_id = v.id AND cc.medico_id = vm.medico_id
    LEFT JOIN checkin_checkout ccp ON ccp.vaga_id = v.id AND ccp.medico_id =
        CASE
            WHEN c.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid THEN c.medico_precadastro_id
            ELSE vm.medico_id
        END
    LEFT JOIN pagamentos pg ON pg.candidatura_id = c.id;

-- 2. Permissoes
GRANT SELECT ON public.vw_vagas_candidaturas TO anon;
GRANT SELECT ON public.vw_vagas_candidaturas TO authenticated;

-- 3. Corrigir RLS da tabela vagas — auth.uid() re-avaliado por linha
--    Trocar auth.uid() por (SELECT auth.uid()) para executar apenas 1 vez
DROP POLICY IF EXISTS vagas_select_policy ON vagas;
CREATE POLICY vagas_select_policy ON vagas FOR SELECT USING (
    EXISTS (SELECT 1 FROM user_profile WHERE user_profile.id = (SELECT auth.uid()))
);

DROP POLICY IF EXISTS vagas_update_policy ON vagas;
CREATE POLICY vagas_update_policy ON vagas FOR UPDATE
    USING (EXISTS (SELECT 1 FROM user_profile WHERE user_profile.id = (SELECT auth.uid())))
    WITH CHECK (EXISTS (SELECT 1 FROM user_profile WHERE user_profile.id = (SELECT auth.uid())));
