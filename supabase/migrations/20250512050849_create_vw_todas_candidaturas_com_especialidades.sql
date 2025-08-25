
-- View para todas as candidaturas com especialidades
CREATE OR REPLACE VIEW vw_todas_candidaturas AS
SELECT 
    -- Dados do médico
    (m.medico_primeironome || ' ' || m.medico_sobrenome) AS nome_medico,
    m.medico_crm AS crm_medico,
    
    -- Dados do hospital
    h.hospital_nome AS nome_hospital,
    
    -- Data e horário do plantão
    v.vagas_data AS data_plantao,
    v.vagas_horainicio AS hora_inicio,
    v.vagas_horafim AS hora_fim,
    
    -- Dados do escalista
    e.escalista_nome AS nome_escalista,
    e.escalista_telefone AS telefone_escalista,
    
    -- Status da candidatura
    c.candidatura_status AS status_candidatura,
    
    -- IDs para possíveis operações de atualização
    c.candidaturas_id,
    c.medicos_id,
    c.vagas_id,
    
    -- Especialidades
    espec_medico.especialidade_nome AS especialidade_medico,
    espec_vaga.especialidade_nome AS especialidade_vaga
    
FROM 
    candidaturas c
    -- Junção com tabela de médicos
    JOIN medicos m ON c.medicos_id = m.id
    -- Junção com especialidade do médico
    LEFT JOIN especialidades espec_medico ON m.medico_especialidade = espec_medico.especialidade_id
    -- Junção com tabela de vagas
    JOIN vagas v ON c.vagas_id = v.vagas_id
    -- Junção com especialidade da vaga
    LEFT JOIN especialidades espec_vaga ON v.vaga_especialidade = espec_vaga.especialidade_id
    -- Junção com tabela de hospitais
    JOIN hospital h ON v.vagas_hospital = h.hospital_id
    -- Junção com tabela de escalistas
    JOIN escalista e ON v.vagas_escalista = e.escalista_id

-- Ordenação por data e hora do plantão
ORDER BY 
    v.vagas_data, 
    v.vagas_horainicio;
;
