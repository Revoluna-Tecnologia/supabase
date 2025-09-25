-- Remove views
DROP VIEW IF EXISTS vw_candidaturas_pendentes CASCADE;
DROP VIEW IF EXISTS vw_candidaturas_por_dia CASCADE;
DROP VIEW IF EXISTS vw_dashboard_metrics CASCADE;
DROP VIEW IF EXISTS vw_distribuicao_especialidades CASCADE;
DROP VIEW IF EXISTS vw_grupo_nome CASCADE;
DROP VIEW IF EXISTS vw_ocupacao_plantoes CASCADE;
DROP VIEW IF EXISTS vw_todas_candidaturas CASCADE;
DROP VIEW IF EXISTS vw_usuarios_por_dia CASCADE;
DROP VIEW IF EXISTS vw_vagas_dias_contagem CASCADE;
DROP VIEW IF EXISTS vw_vagas_especialidade CASCADE;
DROP VIEW IF EXISTS vw_vagas_grade_info CASCADE;
DROP VIEW IF EXISTS vw_vagas_por_mes CASCADE;

DROP MATERIALIZED VIEW IF EXISTS vw_vagas_disponiveis CASCADE;

-- Remove tables
DROP TABLE IF EXISTS local_medico CASCADE;
DROP TABLE IF EXISTS local CASCADE;
DROP TABLE IF EXISTS sistema_logs CASCADE;
DROP TABLE IF EXISTS tipos_documentos CASCADE;
DROP TABLE IF EXISTS validacao_documentos CASCADE;

