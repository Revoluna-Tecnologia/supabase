-- Script para alterar o tipo de dados das colunas hospital_nome, hospital_cidade e hospital_estado
-- de VARCHAR para TEXT na tabela public.hospital

-- 1. Salvar as definições das views para posterior recriação
DO $$
DECLARE
  vw_vagas_completo TEXT;
  vw_candidaturas_pendentes TEXT;
  vw_todas_candidaturas TEXT;
  vw_distribuicao_especialidades TEXT;
  vw_vagas_por_mes TEXT;
  vw_vagas_disponiveis TEXT;
BEGIN
  -- Obter definições das views
  SELECT definition INTO vw_vagas_completo FROM pg_views WHERE viewname = 'vagas_completo';
  SELECT definition INTO vw_candidaturas_pendentes FROM pg_views WHERE viewname = 'vw_candidaturas_pendentes';
  SELECT definition INTO vw_todas_candidaturas FROM pg_views WHERE viewname = 'vw_todas_candidaturas';
  SELECT definition INTO vw_distribuicao_especialidades FROM pg_views WHERE viewname = 'vw_distribuicao_especialidades';
  SELECT definition INTO vw_vagas_por_mes FROM pg_views WHERE viewname = 'vw_vagas_por_mes';
  SELECT definition INTO vw_vagas_disponiveis FROM pg_matviews WHERE matviewname = 'vw_vagas_disponiveis';
  
  -- Salvar as definições em uma tabela temporária
  CREATE TEMP TABLE temp_views (
    viewname TEXT PRIMARY KEY,
    definition TEXT
  );
  
  INSERT INTO temp_views VALUES
    ('vagas_completo', vw_vagas_completo),
    ('vw_candidaturas_pendentes', vw_candidaturas_pendentes),
    ('vw_todas_candidaturas', vw_todas_candidaturas),
    ('vw_distribuicao_especialidades', vw_distribuicao_especialidades),
    ('vw_vagas_por_mes', vw_vagas_por_mes),
    ('vw_vagas_disponiveis', vw_vagas_disponiveis);
END $$;

-- 2. Remover as views dependentes na ordem correta
DROP VIEW IF EXISTS vw_distribuicao_especialidades;
DROP VIEW IF EXISTS vw_vagas_por_mes;
DROP VIEW IF EXISTS vagas_completo;
DROP VIEW IF EXISTS vw_candidaturas_pendentes;
DROP VIEW IF EXISTS vw_todas_candidaturas;
DROP MATERIALIZED VIEW IF EXISTS vw_vagas_disponiveis;

-- 3. Alterar o tipo de dados das colunas
ALTER TABLE public.hospital 
  ALTER COLUMN hospital_nome TYPE text,
  ALTER COLUMN hospital_cidade TYPE text,
  ALTER COLUMN hospital_estado TYPE text;

-- 4. Recriar as views na ordem inversa
CREATE VIEW vagas_completo AS
SELECT 
    v.vagas_id,
    v.vagas_createdate,
    v.vagas_data,
    v.vagas_horainicio,
    v.vagas_horafim,
    v.vagas_valor,
    v.vagas_datapagamento,
    fr.forma_recebimento AS vagas_formarecebimento,
    v.vagas_observacoes,
    h.hospital_nome,
    s.setor_nome,
    p.periodo AS periodo_nome,
    t.tipo AS tipo_nome,
    esp.especialidade_nome,
    g.grupo_id,
    g.grupo_nome,
    g.grupo_responsavel,
    g.grupo_telefone,
    g.grupo_email,
    v.vagas_status,
    e.escalista_nome,
    e.escalista_id,
    e.escalista_telefone,
    e.escalista_email,
    h.latitude AS hospital_lat,
    h.longitude AS hospital_log,
    h.endereco_formatado AS hospital_end,
    h.hospital_avatar
FROM vagas v
LEFT JOIN hospital h ON v.vagas_hospital = h.hospital_id
LEFT JOIN setores s ON v.vagas_setor = s.setor_id
LEFT JOIN periodo p ON v.vagas_periodo = p.periodo_id
LEFT JOIN tipovaga t ON v.vagas_tipo = t.id
LEFT JOIN escalista e ON v.vagas_escalista = e.escalista_id
LEFT JOIN especialidades esp ON v.vaga_especialidade = esp.especialidade_id
LEFT JOIN grupo g ON v.grupo_id = g.grupo_id
LEFT JOIN formas_recebimento fr ON v.vagas_formarecebimento = fr.id;

CREATE VIEW vw_candidaturas_pendentes AS
SELECT 
    ((m.medico_primeironome || ' '::text) || m.medico_sobrenome) AS nome_medico,
    m.medico_crm AS crm_medico,
    h.hospital_nome AS nome_hospital,
    v.vagas_data AS data_plantao,
    v.vagas_horainicio AS hora_inicio,
    v.vagas_horafim AS hora_fim,
    e.escalista_nome AS nome_escalista,
    e.escalista_telefone AS telefone_escalista,
    c.candidatura_status AS status_candidatura,
    c.candidaturas_id,
    c.medicos_id,
    c.vagas_id,
    espec_medico.especialidade_nome AS especialidade_medico,
    espec_vaga.especialidade_nome AS especialidade_vaga,
    m.medico_telefone AS telefone_medico
FROM candidaturas c
JOIN medicos m ON c.medicos_id = m.id
LEFT JOIN especialidades espec_medico ON m.medico_especialidade = espec_medico.especialidade_id
JOIN vagas v ON c.vagas_id = v.vagas_id
LEFT JOIN especialidades espec_vaga ON v.vaga_especialidade = espec_vaga.especialidade_id
JOIN hospital h ON v.vagas_hospital = h.hospital_id
JOIN escalista e ON v.vagas_escalista = e.escalista_id
WHERE c.candidatura_status = 'PENDENTE'::text
ORDER BY v.vagas_data, v.vagas_horainicio;

CREATE VIEW vw_todas_candidaturas AS
SELECT 
    ((m.medico_primeironome || ' '::text) || m.medico_sobrenome) AS nome_medico,
    m.medico_crm AS crm_medico,
    h.hospital_nome AS nome_hospital,
    v.vagas_data AS data_plantao,
    v.vagas_horainicio AS hora_inicio,
    v.vagas_horafim AS hora_fim,
    e.escalista_nome AS nome_escalista,
    e.escalista_telefone AS telefone_escalista,
    c.candidatura_status AS status_candidatura,
    c.candidaturas_id,
    c.medicos_id,
    c.vagas_id,
    espec_medico.especialidade_nome AS especialidade_medico,
    espec_vaga.especialidade_nome AS especialidade_vaga,
    m.medico_telefone AS telefone_medico
FROM candidaturas c
JOIN medicos m ON c.medicos_id = m.id
LEFT JOIN especialidades espec_medico ON m.medico_especialidade = espec_medico.especialidade_id
JOIN vagas v ON c.vagas_id = v.vagas_id
LEFT JOIN especialidades espec_vaga ON v.vaga_especialidade = espec_vaga.especialidade_id
JOIN hospital h ON v.vagas_hospital = h.hospital_id
JOIN escalista e ON v.vagas_escalista = e.escalista_id
ORDER BY v.vagas_data, v.vagas_horainicio;

CREATE VIEW vw_vagas_por_mes AS
SELECT 
    date_trunc('month'::text, (vagas_completo.vagas_data)::timestamp without time zone) AS mes,
    count(vagas_completo.vagas_id) AS total_vagas
FROM vagas_completo
GROUP BY (date_trunc('month'::text, (vagas_completo.vagas_data)::timestamp without time zone))
ORDER BY (date_trunc('month'::text, (vagas_completo.vagas_data)::timestamp without time zone));

CREATE VIEW vw_distribuicao_especialidades AS
SELECT 
    vagas_completo.especialidade_nome AS especialidade,
    count(*) AS total
FROM vagas_completo
GROUP BY vagas_completo.especialidade_nome
ORDER BY (count(*)) DESC;

-- Recriar a view materializada
CREATE MATERIALIZED VIEW vw_vagas_disponiveis AS
SELECT 
    v.vagas_id,
    v.vagas_data,
    v.vagas_horainicio,
    v.vagas_horafim,
    v.vagas_valor,
    h.hospital_nome,
    h.hospital_cidade,
    h.hospital_estado,
    s.setor_nome,
    e.especialidade_nome,
    p.periodo,
    v.vagas_totalcandidaturas,
    v.vagas_status
FROM vagas v
JOIN hospital h ON v.vagas_hospital = h.hospital_id
JOIN setores s ON v.vagas_setor = s.setor_id
JOIN especialidades e ON v.vaga_especialidade = e.especialidade_id
JOIN periodo p ON v.vagas_periodo = p.periodo_id
WHERE v.vagas_status::text = 'DISPONIVEL'::text;

-- 5. Verificação final
DO $$
BEGIN
  RAISE NOTICE 'Alteração de tipo de dados concluída com sucesso!';
  RAISE NOTICE 'Colunas modificadas:';
  RAISE NOTICE '  - hospital_nome: VARCHAR -> TEXT';
  RAISE NOTICE '  - hospital_cidade: VARCHAR -> TEXT';
  RAISE NOTICE '  - hospital_estado: VARCHAR -> TEXT';
  RAISE NOTICE 'Views recriadas com sucesso:';
  RAISE NOTICE '  - vagas_completo';
  RAISE NOTICE '  - vw_candidaturas_pendentes';
  RAISE NOTICE '  - vw_todas_candidaturas';
  RAISE NOTICE '  - vw_vagas_por_mes';
  RAISE NOTICE '  - vw_distribuicao_especialidades';
  RAISE NOTICE '  - vw_vagas_disponiveis (materializada)';
END $$;;
