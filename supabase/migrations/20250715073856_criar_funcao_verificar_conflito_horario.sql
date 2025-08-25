
-- Função para verificar conflitos de horário antes de permitir candidatura
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
BEGIN
    -- Buscar informações da vaga
    SELECT v.vagas_data, v.vagas_horainicio, v.vagas_horafim
    INTO vaga_data, vaga_inicio, vaga_fim
    FROM vagas v
    WHERE v.vagas_id = NEW.vagas_id;
    
    -- Verificar conflitos e buscar detalhes da vaga conflitante
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
    
    -- Bloquear se houver conflito
    IF conflito_encontrado THEN
        RAISE EXCEPTION 'CONFLITO DE HORÁRIO: % | Nova candidatura: % das % às %', 
            vaga_conflitante_info, vaga_data, vaga_inicio, vaga_fim;
    END IF;
    
    RETURN NEW;
END;
$$;
;
