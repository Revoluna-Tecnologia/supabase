-- Função para processar check-in
CREATE OR REPLACE FUNCTION processar_checkin(
    p_vaga_id UUID,
    p_medico_id UUID,
    p_latitude DECIMAL DEFAULT NULL,
    p_longitude DECIMAL DEFAULT NULL,
    p_justificativa TEXT DEFAULT NULL
) RETURNS JSON AS $$
DECLARE
    vaga_info RECORD;
    hospital_id_vaga UUID;
    agora TIMESTAMP WITH TIME ZONE := NOW();
    inicio_plantao TIMESTAMP WITH TIME ZONE;
    fim_janela_auto TIMESTAMP WITH TIME ZONE;
    localizacao_valida BOOLEAN := false;
    tipo_checkin VARCHAR(20);
    status_checkin VARCHAR(20);
    resultado JSON;
BEGIN
    -- Buscar informações da vaga
    SELECT v.vagas_hospital, v.vagas_data, v.vagas_horainicio
    INTO vaga_info
    FROM vagas v
    WHERE v.vagas_id = p_vaga_id;
    
    IF NOT FOUND THEN
        RETURN '{"success": false, "error": "Vaga não encontrada"}'::JSON;
    END IF;
    
    hospital_id_vaga := vaga_info.vagas_hospital;
    inicio_plantao := vaga_info.vagas_data + vaga_info.vagas_horainicio;
    fim_janela_auto := inicio_plantao + INTERVAL '20 minutes';
    
    -- Verificar se já existe check-in
    IF EXISTS (SELECT 1 FROM checkin_checkout WHERE vagas_id = p_vaga_id AND medico_id = p_medico_id) THEN
        RETURN '{"success": false, "error": "Check-in já realizado"}'::JSON;
    END IF;
    
    -- Determinar tipo e status do check-in
    IF agora <= fim_janela_auto THEN
        -- Dentro da janela automática
        IF p_latitude IS NOT NULL AND p_longitude IS NOT NULL THEN
            localizacao_valida := validar_localizacao_medico(hospital_id_vaga, p_latitude, p_longitude);
            IF localizacao_valida THEN
                tipo_checkin := 'automatico';
                status_checkin := 'validado';
            ELSE
                tipo_checkin := 'manual';
                status_checkin := 'pendente';
            END IF;
        ELSE
            tipo_checkin := 'manual';
            status_checkin := 'pendente';
        END IF;
    ELSE
        -- Fora da janela automática (atrasado)
        tipo_checkin := 'manual';
        status_checkin := 'atrasado';
    END IF;
    
    -- Inserir check-in
    INSERT INTO checkin_checkout (
        vagas_id, medico_id, checkin, 
        checkin_tipo, checkin_latitude, checkin_longitude,
        checkin_justificativa, status_checkin,
        created_at, updated_at
    ) VALUES (
        p_vaga_id, p_medico_id, agora,
        tipo_checkin, p_latitude, p_longitude,
        p_justificativa, status_checkin,
        agora, agora
    );
    
    -- Retornar resultado
    resultado := json_build_object(
        'success', true,
        'tipo', tipo_checkin,
        'status', status_checkin,
        'localizacao_valida', localizacao_valida,
        'timestamp', agora
    );
    
    RETURN resultado;
END;
$$ LANGUAGE plpgsql;;
