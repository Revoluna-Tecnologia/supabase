-- Função para calcular distância entre duas coordenadas (fórmula de Haversine)
CREATE OR REPLACE FUNCTION calcular_distancia(
    lat1 DECIMAL, lon1 DECIMAL, 
    lat2 DECIMAL, lon2 DECIMAL
) RETURNS DECIMAL AS $$
DECLARE
    dlat DECIMAL;
    dlon DECIMAL;
    a DECIMAL;
    c DECIMAL;
    r DECIMAL := 6371000; -- Raio da Terra em metros
BEGIN
    dlat := radians(lat2 - lat1);
    dlon := radians(lon2 - lon1);
    
    a := sin(dlat/2) * sin(dlat/2) + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon/2) * sin(dlon/2);
    c := 2 * atan2(sqrt(a), sqrt(1-a));
    
    RETURN r * c;
END;
$$ LANGUAGE plpgsql;

-- Função para validar se médico está na localização correta
CREATE OR REPLACE FUNCTION validar_localizacao_medico(
    p_hospital_id UUID,
    p_latitude DECIMAL,
    p_longitude DECIMAL
) RETURNS BOOLEAN AS $$
DECLARE
    config_hospital RECORD;
    distancia DECIMAL;
BEGIN
    -- Buscar configuração do hospital
    SELECT latitude, longitude, raio_metros, ativo
    INTO config_hospital
    FROM hospital_geofencing 
    WHERE hospital_id = p_hospital_id AND ativo = true;
    
    -- Se não há configuração, assume válido
    IF NOT FOUND THEN
        RETURN true;
    END IF;
    
    -- Calcular distância
    distancia := calcular_distancia(
        config_hospital.latitude, config_hospital.longitude,
        p_latitude, p_longitude
    );
    
    -- Retornar se está dentro do raio
    RETURN distancia <= config_hospital.raio_metros;
END;
$$ LANGUAGE plpgsql;;
