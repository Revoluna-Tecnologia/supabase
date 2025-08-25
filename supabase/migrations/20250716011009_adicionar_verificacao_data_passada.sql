
-- Modificar função para verificar conflitos + data passada
CREATE OR REPLACE FUNCTION verificar_conflito_antes_candidatura()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    conflito_encontrado boolean := false;
    vaga_data date;
    vaga_inicio time;
    vaga_fim time;
    vaga_conflitante_info text;
    current_role text;
BEGIN
    -- Verificar o role atual do usuário
    SELECT auth.role() INTO current_role;
    
    -- Só aplicar verificações para usuários authenticated
    -- Roles de serviço podem trabalhar sem amarras
    IF current_role != 'authenticated' THEN
        RETURN NEW;
    END IF;
    
    -- Buscar informações da vaga
    SELECT v.vagas_data, v.vagas_horainicio, v.vagas_horafim
    INTO vaga_data, vaga_inicio, vaga_fim
    FROM vagas v
    WHERE v.vagas_id = NEW.vagas_id;
    
    -- VERIFICAÇÃO 1: Impedir candidatura em vagas com data passada
    IF vaga_data < CURRENT_DATE THEN
        RAISE EXCEPTION 'CANDIDATURA BLOQUEADA: Não é possível se candidatar em vaga com data passada. Data da vaga: %', vaga_data;
    END IF;
    
    -- VERIFICAÇÃO 2: Verificar conflitos de horário
    SELECT 
        EXISTS (
            SELECT 1
            FROM candidaturas c
            JOIN vagas v ON c.vagas_id = v.vagas_id
            WHERE c.medico_id = NEW.medico_id
            AND c.candidatura_status = 'APROVADO'
            AND v.vagas_data = vaga_data
            AND v.vagas_horainicio < vaga_fim 
            AND vaga_inicio < v.vagas_horafim
        ),
        (
            SELECT 'Plantão já aprovado: ' || v.vagas_data || ' das ' || v.vagas_horainicio || ' às ' || v.vagas_horafim
            FROM candidaturas c
            JOIN vagas v ON c.vagas_id = v.vagas_id
            WHERE c.medico_id = NEW.medico_id
            AND c.candidatura_status = 'APROVADO'
            AND v.vagas_data = vaga_data
            AND v.vagas_horainicio < vaga_fim 
            AND vaga_inicio < v.vagas_horafim
            LIMIT 1
        )
    INTO conflito_encontrado, vaga_conflitante_info;
    
    -- Bloquear se houver conflito de horário
    IF conflito_encontrado THEN
        RAISE EXCEPTION 'CONFLITO DE HORÁRIO: % | Nova candidatura: % das % às %', 
            vaga_conflitante_info, vaga_data, vaga_inicio, vaga_fim;
    END IF;
    
    RETURN NEW;
END;
$$;

-- Atualizar comentário do trigger
COMMENT ON TRIGGER candidaturas_1_verificar_conflito_horario ON public.candidaturas 
IS 'Verifica data passada e conflitos de horário para usuários authenticated (roles de serviço são liberados)';
;
