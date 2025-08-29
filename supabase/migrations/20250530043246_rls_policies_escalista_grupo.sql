-- Função auxiliar para buscar o grupo_id do escalista logado
CREATE OR REPLACE FUNCTION get_current_user_grupo_id()
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_role TEXT;
    grupo_id_result UUID;
BEGIN
    -- Buscar o role do usuário logado
    SELECT role INTO user_role
    FROM user_profile 
    WHERE id = auth.uid();
    
    -- Se for astronauta, permitir acesso a todos os grupos (retorna NULL = sem filtro)
    IF user_role = 'astronauta' THEN
        RETURN NULL;
    END IF;
    
    -- Se for escalista, buscar o grupo_id
    IF user_role = 'escalista' THEN
        SELECT grupo_id INTO grupo_id_result
        FROM escalista
        WHERE escalista_auth_id = auth.uid();
        
        RETURN grupo_id_result;
    END IF;
    
    -- Se não for astronauta nem escalista, negar acesso
    RETURN '00000000-0000-0000-0000-000000000000'::UUID;
END;
$$;

-- Política para tabela vagas
DROP POLICY IF EXISTS "vagas_escalista_policy" ON vagas;
CREATE POLICY "vagas_escalista_policy" ON vagas
FOR ALL USING (
    CASE 
        WHEN get_current_user_grupo_id() IS NULL THEN TRUE  -- Astronauta vê tudo
        ELSE grupo_id = get_current_user_grupo_id()  -- Escalista vê só do seu grupo
    END
);

-- Política para tabela candidaturas (baseada nas vagas)
DROP POLICY IF EXISTS "candidaturas_escalista_policy" ON candidaturas;
CREATE POLICY "candidaturas_escalista_policy" ON candidaturas
FOR ALL USING (
    EXISTS (
        SELECT 1 FROM vagas v 
        WHERE v.vagas_id = candidaturas.vagas_id
        AND (
            CASE 
                WHEN get_current_user_grupo_id() IS NULL THEN TRUE  -- Astronauta vê tudo
                ELSE v.grupo_id = get_current_user_grupo_id()  -- Escalista vê só do seu grupo
            END
        )
    )
);

-- Política para tabela escalista
DROP POLICY IF EXISTS "escalista_policy" ON escalista;
CREATE POLICY "escalista_policy" ON escalista
FOR ALL USING (
    CASE 
        WHEN get_current_user_grupo_id() IS NULL THEN TRUE  -- Astronauta vê tudo
        ELSE grupo_id = get_current_user_grupo_id()  -- Escalista vê só do seu grupo
    END
);

-- Política para tabela medicos_favoritos
DROP POLICY IF EXISTS "medicos_favoritos_escalista_policy" ON medicos_favoritos;
CREATE POLICY "medicos_favoritos_escalista_policy" ON medicos_favoritos
FOR ALL USING (
    EXISTS (
        SELECT 1 FROM escalista e
        WHERE e.escalista_id = medicos_favoritos.escalista_id
        AND (
            CASE 
                WHEN get_current_user_grupo_id() IS NULL THEN TRUE  -- Astronauta vê tudo
                ELSE e.grupo_id = get_current_user_grupo_id()  -- Escalista vê só do seu grupo
            END
        )
    )
);

-- Política para tabela checkin_checkout (baseada nas vagas)
DROP POLICY IF EXISTS "checkin_checkout_escalista_policy" ON checkin_checkout;
CREATE POLICY "checkin_checkout_escalista_policy" ON checkin_checkout
FOR ALL USING (
    EXISTS (
        SELECT 1 FROM vagas v 
        WHERE v.vagas_id = checkin_checkout.vagas_id
        AND (
            CASE 
                WHEN get_current_user_grupo_id() IS NULL THEN TRUE  -- Astronauta vê tudo
                ELSE v.grupo_id = get_current_user_grupo_id()  -- Escalista vê só do seu grupo
            END
        )
    )
);

-- Política para tabela pagamentos (baseada nas vagas)
DROP POLICY IF EXISTS "pagamentos_escalista_policy" ON pagamentos;
CREATE POLICY "pagamentos_escalista_policy" ON pagamentos
FOR ALL USING (
    EXISTS (
        SELECT 1 FROM vagas v 
        WHERE v.vagas_id = pagamentos.vagas_id
        AND (
            CASE 
                WHEN get_current_user_grupo_id() IS NULL THEN TRUE  -- Astronauta vê tudo
                ELSE v.grupo_id = get_current_user_grupo_id()  -- Escalista vê só do seu grupo
            END
        )
    )
);

-- Política para tabela vagas_beneficio (baseada nas vagas)
DROP POLICY IF EXISTS "vagas_beneficio_escalista_policy" ON vagas_beneficio;
CREATE POLICY "vagas_beneficio_escalista_policy" ON vagas_beneficio
FOR ALL USING (
    EXISTS (
        SELECT 1 FROM vagas v 
        WHERE v.vagas_id = vagas_beneficio.vagas_id
        AND (
            CASE 
                WHEN get_current_user_grupo_id() IS NULL THEN TRUE  -- Astronauta vê tudo
                ELSE v.grupo_id = get_current_user_grupo_id()  -- Escalista vê só do seu grupo
            END
        )
    )
);

-- Política para tabela vagas_requisito (baseada nas vagas)
DROP POLICY IF EXISTS "vagas_requisito_escalista_policy" ON vagas_requisito;
CREATE POLICY "vagas_requisito_escalista_policy" ON vagas_requisito
FOR ALL USING (
    EXISTS (
        SELECT 1 FROM vagas v 
        WHERE v.vagas_id = vagas_requisito.vagas_id
        AND (
            CASE 
                WHEN get_current_user_grupo_id() IS NULL THEN TRUE  -- Astronauta vê tudo
                ELSE v.grupo_id = get_current_user_grupo_id()  -- Escalista vê só do seu grupo
            END
        )
    )
);;
