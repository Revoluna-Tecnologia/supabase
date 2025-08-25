-- Função para verificar status do geofencing para uma vaga
CREATE OR REPLACE FUNCTION verificar_status_geofencing(
    p_vaga_id UUID,
    p_medico_id UUID
) RETURNS JSON AS $$
DECLARE
    vaga_info RECORD;
    checkin_info RECORD;
    agora TIMESTAMP WITH TIME ZONE := NOW();
    inicio_plantao TIMESTAMP WITH TIME ZONE;
    fim_plantao TIMESTAMP WITH TIME ZONE;
    fim_janela_checkin TIMESTAMP WITH TIME ZONE;
    inicio_janela_checkout TIMESTAMP WITH TIME ZONE;
    fim_janela_checkout TIMESTAMP WITH TIME ZONE;
    resultado JSON;
    status_atual VARCHAR(50);
    geofencing_ativo BOOLEAN := false;
BEGIN
    -- Buscar informações da vaga
    SELECT v.vagas_hospital, v.vagas_data, v.vagas_horainicio, v.vagas_horafim
    INTO vaga_info
    FROM vagas v
    WHERE v.vagas_id = p_vaga_id;
    
    IF NOT FOUND THEN
        RETURN '{"success": false, "error": "Vaga não encontrada"}'::JSON;
    END IF;
    
    inicio_plantao := vaga_info.vagas_data + vaga_info.vagas_horainicio;
    fim_plantao := vaga_info.vagas_data + vaga_info.vagas_horafim;
    fim_janela_checkin := inicio_plantao + INTERVAL '20 minutes';
    inicio_janela_checkout := fim_plantao - INTERVAL '10 minutes';
    fim_janela_checkout := fim_plantao + INTERVAL '10 minutes';
    
    -- Verificar check-in existente
    SELECT * INTO checkin_info
    FROM checkin_checkout 
    WHERE vagas_id = p_vaga_id AND medico_id = p_medico_id;
    
    -- Determinar status atual
    IF checkin_info.vagas_id IS NULL THEN
        -- Sem check-in ainda
        IF agora <= fim_janela_checkin THEN
            status_atual := 'janela_checkin_automatico';
            geofencing_ativo := true;
        ELSIF agora > fim_janela_checkin AND agora < inicio_plantao THEN
            status_atual := 'aguardando_plantao';
        ELSE
            status_atual := 'checkin_manual_obrigatorio';
        END IF;
    ELSIF checkin_info.checkout IS NULL THEN
        -- Com check-in, sem check-out
        IF agora >= inicio_janela_checkout AND agora <= fim_plantao THEN
            status_atual := 'janela_checkout_automatico';
            geofencing_ativo := true;
        ELSIF agora < inicio_janela_checkout THEN
            status_atual := 'plantao_ativo';
        ELSE
            status_atual := 'checkout_manual_obrigatorio';
        END IF;
    ELSE
        -- Check-in e check-out completos
        status_atual := 'plantao_finalizado';
    END IF;
    
    resultado := json_build_object(
        'success', true,
        'status_atual', status_atual,
        'geofencing_ativo', geofencing_ativo,
        'agora', agora,
        'inicio_plantao', inicio_plantao,
        'fim_plantao', fim_plantao,
        'fim_janela_checkin', fim_janela_checkin,
        'inicio_janela_checkout', inicio_janela_checkout,
        'fim_janela_checkout', fim_janela_checkout,
        'checkin_realizado', checkin_info.vagas_id IS NOT NULL,
        'checkout_realizado', checkin_info.checkout IS NOT NULL
    );
    
    RETURN resultado;
END;
$$ LANGUAGE plpgsql;;
