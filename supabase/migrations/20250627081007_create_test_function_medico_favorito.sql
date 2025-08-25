-- Criar função para testar medico_favorito com um médico específico
CREATE OR REPLACE FUNCTION test_medico_favorito_view(p_medico_id UUID)
RETURNS TABLE (
    vagas_id UUID,
    grupo_id UUID,
    medico_favorito BOOLEAN,
    debug_info TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        v.vagas_id,
        v.grupo_id,
        CASE 
            WHEN EXISTS (
                SELECT 1 FROM medicos_favoritos mf 
                WHERE mf.grupo_id = v.grupo_id 
                AND mf.medico_id = p_medico_id
            ) THEN true 
            ELSE false 
        END as medico_favorito,
        CONCAT('Testing with medico_id: ', p_medico_id) as debug_info
    FROM vagas v
    WHERE v.grupo_id = '3e21c0a7-2002-43b1-9c78-181596ea5470'
    LIMIT 3;
END;
$$ LANGUAGE plpgsql;;
