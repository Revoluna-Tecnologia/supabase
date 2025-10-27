CREATE OR REPLACE FUNCTION public.get_current_user_grupo_id()
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$DECLARE
    current_user_id UUID;
    user_role TEXT;
    grupo_id_result UUID;
BEGIN
    -- Obter o ID do usuário atual
    current_user_id := auth.uid();
    
    -- Se não há usuário autenticado, retornar NULL
    IF current_user_id IS NULL THEN
        RETURN NULL;
    END IF;

    -- Buscar o grupo_id
        SELECT grupo_id INTO grupo_id_result
        FROM escalistas
        WHERE id = current_user_id;
        
        -- Se encontrou o grupo, retornar
        IF grupo_id_result IS NOT NULL THEN
            RETURN grupo_id_result;
        END IF;

        -- Se encontrou não grupo, retornar NULL
        RETURN NULL;

END;$function$;