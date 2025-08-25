-- Melhorar a função get_current_user_grupo_id para ser mais robusta
CREATE OR REPLACE FUNCTION public.get_current_user_grupo_id()
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    current_user_id UUID;
    user_role TEXT;
    grupo_id_result UUID;
BEGIN
    -- Obter o ID do usuário atual
    current_user_id := auth.uid();
    
    -- Se não há usuário autenticado, negar acesso
    IF current_user_id IS NULL THEN
        RETURN '00000000-0000-0000-0000-000000000000'::UUID;
    END IF;
    
    -- Buscar o role do usuário logado
    SELECT role INTO user_role
    FROM user_profile 
    WHERE id = current_user_id;
    
    -- Se não encontrou o usuário no user_profile, negar acesso
    IF user_role IS NULL THEN
        RETURN '00000000-0000-0000-0000-000000000000'::UUID;
    END IF;
    
    -- Se for astronauta, permitir acesso a todos os grupos (retorna NULL = sem filtro)
    IF user_role = 'astronauta' THEN
        RETURN NULL;
    END IF;
    
    -- Se for escalista, buscar o grupo_id
    IF user_role = 'escalista' THEN
        SELECT grupo_id INTO grupo_id_result
        FROM escalista
        WHERE escalista_auth_id = current_user_id;
        
        -- Se encontrou o grupo, retornar
        IF grupo_id_result IS NOT NULL THEN
            RETURN grupo_id_result;
        END IF;
        
        -- Se não encontrou o grupo para o escalista, negar acesso
        RETURN '00000000-0000-0000-0000-000000000000'::UUID;
    END IF;
    
    -- Se não for astronauta nem escalista, negar acesso
    RETURN '00000000-0000-0000-0000-000000000000'::UUID;
END;
$$;;
