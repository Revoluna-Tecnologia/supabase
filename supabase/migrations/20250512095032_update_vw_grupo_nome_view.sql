DROP VIEW IF EXISTS vw_grupo_nome;

CREATE VIEW vw_grupo_nome AS
SELECT 
    grupo_id,
    grupo_nome
FROM 
    grupo;;
