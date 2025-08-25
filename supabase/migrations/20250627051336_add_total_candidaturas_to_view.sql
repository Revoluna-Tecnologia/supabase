-- Derrubar a view atual
DROP VIEW IF EXISTS vw_vagas_candidaturas;

-- Recriar a view com a nova coluna total_candidaturas
CREATE OR REPLACE VIEW vw_vagas_candidaturas AS
SELECT 
    row_number() OVER (ORDER BY combined_data.vagas_id, combined_data.medico_id, combined_data.candidaturas_id) AS idx,
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
    combined_data.total_candidaturas,  -- NOVA COLUNA ADICIONADA AQUI
    combined_data.candidatura_status,
    combined_data.candidatos_createdate,
    combined_data.medico_id,
    combined_data.medico_primeironome,
    combined_data.medico_sobrenome,
    combined_data.medico_crm,
    combined_data.medico_email,
    combined_data.medico_telefone,
    combined_data.recorrencia_id,
    combined_data.vaga_salva
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
        -- Subconsulta para contar total de candidaturas por vaga
        (SELECT COUNT(*) FROM candidaturas c2 WHERE c2.vagas_id = v.vagas_id) AS total_candidaturas,
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
            WHEN (vs.medico_id IS NOT NULL) THEN true
            ELSE false
        END AS vaga_salva
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
        SELECT candidaturas.vagas_id, candidaturas.medico_id
        FROM candidaturas
        WHERE (candidaturas.medico_id IS NOT NULL)
        UNION
        SELECT vagas_salvas.vagas_id, vagas_salvas.medico_id
        FROM vagas_salvas
        WHERE (vagas_salvas.medico_id IS NOT NULL)
    ) vm ON (vm.vagas_id = v.vagas_id)
    LEFT JOIN candidaturas c ON ((c.vagas_id = v.vagas_id) AND (c.medico_id = vm.medico_id))
    LEFT JOIN medicos m ON (m.id = vm.medico_id)
    LEFT JOIN vagas_salvas vs ON ((vs.vagas_id = v.vagas_id) AND (vs.medico_id = vm.medico_id))
) combined_data;;
