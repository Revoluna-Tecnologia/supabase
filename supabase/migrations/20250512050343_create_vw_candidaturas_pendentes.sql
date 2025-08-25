
-- Create View para candidaturas com status 'PENDENTE'
CREATE OR REPLACE VIEW vw_candidaturas_pendentes AS
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
    c.vagas_id
    
FROM 
    candidaturas c
    -- Junção com tabela de médicos
    JOIN medicos m ON c.medicos_id = m.id
    -- Junção com tabela de vagas
    JOIN vagas v ON c.vagas_id = v.vagas_id
    -- Junção com tabela de hospitais
    JOIN hospital h ON v.vagas_hospital = h.hospital_id
    -- Junção com tabela de escalistas
    JOIN escalista e ON v.vagas_escalista = e.escalista_id

-- Filtro para candidaturas pendentes
WHERE c.candidatura_status = 'PENDENTE'

-- Ordenação por data e hora do plantão
ORDER BY 
    v.vagas_data, 
    v.vagas_horainicio;
;
