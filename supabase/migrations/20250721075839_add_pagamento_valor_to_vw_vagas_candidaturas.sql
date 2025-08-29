-- Drop da view atual
DROP VIEW IF EXISTS vw_vagas_candidaturas;

-- Recriar a view incluindo pagamento_valor
CREATE VIEW vw_vagas_candidaturas
WITH (security_invoker = true) AS
SELECT 
    row_number() OVER (ORDER BY vagas_id, medico_id, candidaturas_id) AS idx,
    vagas_id,
    vagas_data,
    vagas_createdate,
    vagas_status,
    vagas_valor,
    vagas_horainicio,
    vagas_horafim,
    vagas_datapagamento,
    vagas_periodo,
    vagas_periodo_nome,
    vagas_tipo,
    vagas_tipo_nome,
    vagas_formarecebimento,
    vagas_formarecebimento_nome,
    vagas_observacoes,
    hospital_id,
    hospital_nome,
    hospital_estado,
    hospital_lat,
    hospital_log,
    hospital_end,
    hospital_avatar,
    especialidade_id,
    especialidade_nome,
    setor_id,
    setor_nome,
    escalista_id,
    escalista_nome,
    escalista_email,
    escalista_telefone,
    grupo_id,
    grupo_nome,
    candidaturas_id,
    total_candidaturas,
    candidatura_status,
    candidatos_createdate,
    medico_id,
    medico_primeironome,
    medico_sobrenome,
    medico_crm,
    medico_email,
    medico_telefone,
    recorrencia_id,
    vaga_salva,
    medico_favorito,
    checkin,
    checkout,
    pagamento_valor
FROM (
    SELECT DISTINCT
        v.vagas_id,
        v.vagas_data,
        v.vagas_createdate,
        v.vagas_status,
        v.vagas_valor,
        v.vagas_horainicio,
        v.vagas_horafim,
        v.vagas_datapagamento,
        v.vagas_periodo,
        p.periodo AS vagas_periodo_nome,
        v.vagas_tipo,
        t.tipo AS vagas_tipo_nome,
        v.vagas_formarecebimento,
        f.forma_recebimento AS vagas_formarecebimento_nome,
        v.vagas_observacoes,
        h.hospital_id,
        h.hospital_nome,
        h.hospital_estado,
        h.latitude AS hospital_lat,
        h.longitude AS hospital_log,
        h.endereco_formatado AS hospital_end,
        h.hospital_avatar,
        e.especialidade_id,
        e.especialidade_nome,
        s.setor_id,
        s.setor_nome,
        esc.escalista_id,
        esc.escalista_nome,
        esc.escalista_email,
        esc.escalista_telefone,
        g.grupo_id,
        g.grupo_nome,
        c.candidaturas_id,
        count_candidaturas_total(v.vagas_id) AS total_candidaturas,
        c.candidatura_status,
        c.candidatos_createdate,
        vm.medico_id,
        m.medico_primeironome,
        m.medico_sobrenome,
        m.medico_crm,
        m.medico_email,
        m.medico_telefone,
        v.recorrencia_id,
        CASE 
            WHEN vs.medico_id IS NOT NULL THEN true 
            ELSE false 
        END AS vaga_salva,
        current_user_is_favorito(v.grupo_id) AS medico_favorito,
        cc.checkin,
        cc.checkout,
        pg.valor AS pagamento_valor
    FROM vagas v
        JOIN hospital h ON (v.vagas_hospital = h.hospital_id)
        JOIN especialidades e ON (v.vaga_especialidade = e.especialidade_id)
        JOIN setores s ON (v.vagas_setor = s.setor_id)
        LEFT JOIN escalista esc ON (v.vagas_escalista = esc.escalista_id)
        LEFT JOIN grupo g ON (v.grupo_id = g.grupo_id)
        LEFT JOIN periodo p ON (v.vagas_periodo = p.periodo_id)
        LEFT JOIN tipovaga t ON (v.vagas_tipo = t.id)
        LEFT JOIN formas_recebimento f ON (v.vagas_formarecebimento = f.id)
        LEFT JOIN (
            SELECT vagas_id, medico_id FROM candidaturas WHERE medico_id IS NOT NULL
            UNION
            SELECT vagas_id, medico_id FROM vagas_salvas WHERE medico_id IS NOT NULL
        ) vm ON (vm.vagas_id = v.vagas_id)
        LEFT JOIN candidaturas c ON (c.vagas_id = v.vagas_id AND c.medico_id = vm.medico_id)
        LEFT JOIN medicos m ON (m.id = vm.medico_id)
        LEFT JOIN vagas_salvas vs ON (vs.vagas_id = v.vagas_id AND vs.medico_id = vm.medico_id)
        LEFT JOIN checkin_checkout cc ON (cc.vagas_id = v.vagas_id AND cc.medico_id = vm.medico_id)
        LEFT JOIN pagamentos pg ON (pg.candidaturas_id = c.candidaturas_id)
) combined_data;;
