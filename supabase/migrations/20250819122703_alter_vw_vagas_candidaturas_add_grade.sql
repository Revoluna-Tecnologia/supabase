-- Criar uma view temporária com as informações de grade
CREATE OR REPLACE VIEW vw_vagas_grade_info AS
SELECT 
    v.vagas_id,
    v.grade_id,
    g.nome as grade_nome,
    g.cor as grade_cor
FROM vagas v
LEFT JOIN grades g ON v.grade_id = g.id;;
