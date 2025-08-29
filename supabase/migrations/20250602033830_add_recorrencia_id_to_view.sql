-- Atualizar view vw_vagas_candidaturas para incluir recorrencia_id
CREATE OR REPLACE VIEW vw_vagas_candidaturas AS
SELECT 
    row_number() OVER (ORDER BY v.vagas_id, c.candidaturas_id) AS idx,
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
    e.especialidade_id,
    e.especialidade_nome,
    s.setor_id,
    s.setor_nome,
    esc.escalista_id,
    esc.escalista_nome,
    g.grupo_id,
    g.grupo_nome,
    c.candidaturas_id,
    c.candidatura_status,
    c.candidatos_createdate,
    m.id AS medico_id,
    m.medico_primeironome,
    m.medico_sobrenome,
    m.medico_crm,
    m.medico_email,
    m.medico_telefone,
    v.recorrencia_id  -- CAMPO ADICIONADO
FROM vagas v
    JOIN hospital h ON v.vagas_hospital = h.hospital_id
    JOIN especialidades e ON v.vaga_especialidade = e.especialidade_id
    JOIN setores s ON v.vagas_setor = s.setor_id
    LEFT JOIN escalista esc ON v.vagas_escalista = esc.escalista_id
    LEFT JOIN grupo g ON v.grupo_id = g.grupo_id
    LEFT JOIN candidaturas c ON c.vagas_id = v.vagas_id
    LEFT JOIN medicos m ON c.medico_id = m.id
    LEFT JOIN periodo p ON v.vagas_periodo = p.periodo_id
    LEFT JOIN tipovaga t ON v.vagas_tipo = t.id
    LEFT JOIN formas_recebimento f ON v.vagas_formarecebimento = f.id;;
