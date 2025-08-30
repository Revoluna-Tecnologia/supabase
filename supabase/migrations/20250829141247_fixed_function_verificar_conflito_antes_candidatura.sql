CREATE OR REPLACE FUNCTION public.verificar_conflito_antes_candidatura()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$DECLARE
    conflito_encontrado boolean := false;
    vaga_data date;
    vaga_inicio time;
    vaga_fim time;
    vaga_conflitante_info text;
    current_user_id uuid;
    current_user_role text;
    
    -- Adicionar variáveis para timestamps
    vaga_inicio_ts timestamp;
    vaga_fim_ts timestamp;
    current_vaga_id uuid;
BEGIN
    -- SANITIZAÇÃO: Converter strings vazias em NULL para UUIDs
    IF NEW.vagas_id::text = '' THEN
        NEW.vagas_id := NULL;
    END IF;
    
    IF NEW.medico_id::text = '' THEN
        NEW.medico_id := NULL;
    END IF;
    
    -- VERIFICAÇÃO DE AUTENTICAÇÃO: Só usuários autenticados podem prosseguir
    IF auth.role() != 'authenticated' THEN
        RAISE EXCEPTION 'ACESSO NEGADO: Apenas usuários autenticados podem se candidatar a vagas';
    END IF;
    
    -- Verificar o role atual do usuário
    current_user_id := auth.uid();
    
    -- VALIDAÇÃO: Verificar se o UUID do usuário é válido
    IF current_user_id IS NULL THEN
        RAISE EXCEPTION 'USUÁRIO INVÁLIDO: ID do usuário não encontrado';
    END IF;
    
    -- VALIDAÇÃO: Verificar se os UUIDs da candidatura são válidos
    IF NEW.vagas_id IS NULL THEN
        RAISE EXCEPTION 'VAGA INVÁLIDA: ID da vaga não pode ser nulo';
    END IF;
    
    IF NEW.medico_id IS NULL THEN
        RAISE EXCEPTION 'MÉDICO INVÁLIDO: ID do médico não pode ser nulo';
    END IF;
    
    -- Verificar se o usuário existe no user_profile
    SELECT role INTO current_user_role
    FROM user_profile
    WHERE id = current_user_id;
    
    -- Se não encontrou o usuário no user_profile, bloquear
    IF current_user_role IS NULL THEN
        RAISE EXCEPTION 'PERFIL INVÁLIDO: Usuário não encontrado no sistema';
    END IF;
    
    -- Buscar informações da vaga
    SELECT v.vagas_data, v.vagas_horainicio, v.vagas_horafim
    INTO vaga_data, vaga_inicio, vaga_fim
    FROM vagas v
    WHERE v.vagas_id = NEW.vagas_id;
    
    -- Verificar se a vaga existe
    IF vaga_data IS NULL OR vaga_inicio IS NULL OR vaga_fim IS NULL THEN
        RAISE EXCEPTION 'VAGA INVÁLIDA: Vaga não encontrada ou dados incompletos';
    END IF;
    
    -- CONVERTER para timestamps considerando turnos noturnos
    vaga_inicio_ts := vaga_data + vaga_inicio;
    
    -- Se hora fim <= hora início, é turno noturno (vai para o dia seguinte)
    IF vaga_fim <= vaga_inicio THEN
        vaga_fim_ts := (vaga_data + INTERVAL '1 day') + vaga_fim;
    ELSE
        vaga_fim_ts := vaga_data + vaga_fim;
    END IF;
    
    -- VERIFICAÇÃO 1: Impedir candidatura em vagas com data passada
    IF vaga_data < CURRENT_DATE AND current_user_role ='free' THEN
        RAISE EXCEPTION 'CANDIDATURA BLOQUEADA: Não é possível se candidatar em vaga com data passada. Data da vaga: %', vaga_data;
    END IF;
    
    -- VERIFICAÇÃO 2: Verificar conflitos de horário (CORRIGIDO PARA TURNOS NOTURNOS)
    SELECT 
        EXISTS (
            SELECT 1
            FROM candidaturas c
            JOIN vagas v ON c.vagas_id = v.vagas_id
            WHERE c.medico_id = NEW.medico_id
            AND c.candidatura_status = 'APROVADO'
            AND (
                -- Usar OVERLAPS com timestamps calculados
                (v.vagas_data + v.vagas_horainicio, 
                 CASE 
                     WHEN v.vagas_horafim <= v.vagas_horainicio 
                     THEN (v.vagas_data + INTERVAL '1 day') + v.vagas_horafim
                     ELSE v.vagas_data + v.vagas_horafim
                 END
                ) OVERLAPS 
                (vaga_inicio_ts, vaga_fim_ts)
            )
        ),
        (
            SELECT 'Plantão já aprovado: ' || v.vagas_data || ' das ' || v.vagas_horainicio || ' às ' || v.vagas_horafim ||
                   CASE WHEN v.vagas_horafim <= v.vagas_horainicio THEN ' (madrugada)' ELSE '' END
            FROM candidaturas c
            JOIN vagas v ON c.vagas_id = v.vagas_id
            WHERE c.medico_id = NEW.medico_id
            AND c.candidatura_status = 'APROVADO'
            AND (
                (v.vagas_data + v.vagas_horainicio, 
                 CASE 
                     WHEN v.vagas_horafim <= v.vagas_horainicio 
                     THEN (v.vagas_data + INTERVAL '1 day') + v.vagas_horafim
                     ELSE v.vagas_data + v.vagas_horafim
                 END
                ) OVERLAPS 
                (vaga_inicio_ts, vaga_fim_ts)
            )
            LIMIT 1
        )
    INTO conflito_encontrado, vaga_conflitante_info;
           
    -- Bloquear se houver conflito de horário
    IF conflito_encontrado THEN
        RAISE EXCEPTION 'CONFLITO DE HORÁRIO DETECTADO';
    END IF;
    
    -- Se chegou até aqui, usuário está autenticado e validações passaram
    RETURN NEW;
END;$function$