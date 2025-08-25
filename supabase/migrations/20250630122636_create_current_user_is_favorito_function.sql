-- Criar função para verificar se o usuário atual é favorito em um grupo
CREATE OR REPLACE FUNCTION current_user_is_favorito(p_grupo_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    current_user_id UUID;
BEGIN
    -- Obter o ID do usuário atual
    current_user_id := auth.uid();
    
    -- Se não há usuário autenticado, retornar false
    IF current_user_id IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Verificar se o usuário é favorito no grupo
    RETURN EXISTS (
        SELECT 1 
        FROM medicos_favoritos mf 
        WHERE mf.grupo_id = p_grupo_id 
        AND mf.medico_id = current_user_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;;
