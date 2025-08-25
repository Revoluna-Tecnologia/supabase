-- Função para processar check-out
CREATE OR REPLACE FUNCTION processar_checkout(
    p_vaga_id UUID,
    p_medico_id UUID,
    p_latitude DECIMAL DEFAULT NULL,
    p_longitude DECIMAL DEFAULT NULL,
    p_justificativa TEXT DEFAULT NULL
) RETURNS JSON AS $$
DECLARE
    vaga_info RECORD;
    checkin_info RECORD;
    hospital_id_vaga UUID;
    agora TIMESTAMP WITH TIME ZONE := NOW();
    fim_plantao TIMESTAMP WITH TIME ZONE;
    inicio_janela_auto TIMESTAMP WITH TIME ZONE;
    fim_janela_normal TIMESTAMP WITH TIME ZONE;
    localizacao_valida BOOLEAN := false;
    tipo_checkout VARCHAR(20);
    status_checkout VARCHAR(20);
    resultado JSON;
BEGIN
    -- Buscar informações da vaga
    SELECT v.vagas_hospital, v.vagas_data, v.vagas_horafim
    INTO vaga_info
    FROM vagas v
    WHERE v.vagas_id = p_vaga_id;
    
    IF NOT FOUND THEN
        RETURN '{"success": false, "error": "Vaga não encontrada"}'::JSON;
    END IF;
    
    hospital_id_vaga := vaga_info.vagas_hospital;
    fim_plantao := vaga_info.vagas_data + vaga_info.vagas_horafim;
    inicio_janela_auto := fim_plantao - INTERVAL '10 minutes';
    fim_janela_normal := fim_plantao + INTERVAL '10 minutes';
    
    -- Verificar se existe check-in
    SELECT * INTO checkin_info
    FROM checkin_checkout 
    WHERE vagas_id = p_vaga_id AND medico_id = p_medico_id;
    
    IF NOT FOUND THEN
        RETURN '{"success": false, "error": "Check-in não encontrado"}'::JSON;
    END IF;
    
    IF checkin_info.checkout IS NOT NULL THEN
        RETURN '{"success": false, "error": "Check-out já realizado"}'::JSON;
    END IF;
    
    -- Determinar tipo e status do check-out
    IF agora < inicio_janela_auto THEN
        -- Checkout antecipado
        tipo_checkout := 'manual';
        status_checkout := 'antecipado';
    ELSIF agora >= inicio_janela_auto AND agora <= fim_plantao THEN
        -- Dentro da janela automática
        IF p_latitude IS NOT NULL AND p_longitude IS NOT NULL THEN
            localizacao_valida := validar_localizacao_medico(hospital_id_vaga, p_latitude, p_longitude);
            IF localizacao_valida THEN
                tipo_checkout := 'automatico';
                status_checkout := 'validado';
            ELSE
                tipo_checkout := 'manual';
                status_checkout := 'pendente';
            END IF;
        ELSE
            tipo_checkout := 'manual';
            status_checkout := 'pendente';
        END IF;
    ELSIF agora > fim_janela_normal THEN
        -- Checkout atrasado
        tipo_checkout := 'manual';
        status_checkout := 'atrasado';
    ELSE
        -- Entre fim do plantão e fim da janela normal
        tipo_checkout := 'manual';
        status_checkout := 'validado';
    END IF;
    
    -- Atualizar check-out
    UPDATE checkin_checkout SET
        checkout = agora,
        checkout_tipo = tipo_checkout,
        checkout_latitude = p_latitude,
        checkout_longitude = p_longitude,
        checkout_justificativa = p_justificativa,
        status_checkout = status_checkout,
        updated_at = agora
    WHERE vagas_id = p_vaga_id AND medico_id = p_medico_id;
    
    -- Retornar resultado
    resultado := json_build_object(
        'success', true,
        'tipo', tipo_checkout,
        'status', status_checkout,
        'localizacao_valida', localizacao_valida,
        'timestamp', agora
    );
    
    RETURN resultado;
END;
$$ LANGUAGE plpgsql;;
