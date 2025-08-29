-- Criar uma view temporária para debug
CREATE OR REPLACE VIEW vw_debug_medico_favorito AS
SELECT 
    v.vagas_id,
    v.grupo_id,
    auth.uid() as current_auth_uid,
    CASE 
        WHEN auth.uid() IS NULL THEN 'AUTH_UID_IS_NULL'
        WHEN EXISTS (
            SELECT 1 FROM medicos_favoritos mf 
            WHERE mf.grupo_id = v.grupo_id 
            AND mf.medico_id = auth.uid()
        ) THEN 'TRUE_FOUND_FAVORITO'
        ELSE 'FALSE_NOT_FOUND'
    END as debug_status,
    (SELECT COUNT(*) FROM medicos_favoritos mf 
     WHERE mf.grupo_id = v.grupo_id 
     AND mf.medico_id = auth.uid()) as count_favoritos
FROM vagas v
WHERE v.grupo_id = '3e21c0a7-2002-43b1-9c78-181596ea5470'
LIMIT 5;;
