-- Tabela de configuração de geofencing por hospital
CREATE TABLE hospital_geofencing (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    hospital_id UUID REFERENCES hospital(hospital_id) ON DELETE CASCADE,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    raio_metros INTEGER DEFAULT 100, -- Raio em metros para validar presença
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_hospital_geofencing_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_hospital_geofencing_timestamp
    BEFORE UPDATE ON hospital_geofencing
    FOR EACH ROW
    EXECUTE FUNCTION update_hospital_geofencing_timestamp();;
