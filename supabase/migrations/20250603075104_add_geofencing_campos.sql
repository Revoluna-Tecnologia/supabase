-- Adicionar campos para geofencing inteligente
ALTER TABLE checkin_checkout 
ADD COLUMN checkin_tipo VARCHAR(20) DEFAULT 'manual' CHECK (checkin_tipo IN ('automatico', 'manual')),
ADD COLUMN checkout_tipo VARCHAR(20) DEFAULT 'manual' CHECK (checkout_tipo IN ('automatico', 'manual')),
ADD COLUMN checkin_latitude DECIMAL(10, 8),
ADD COLUMN checkin_longitude DECIMAL(11, 8),
ADD COLUMN checkout_latitude DECIMAL(10, 8),
ADD COLUMN checkout_longitude DECIMAL(11, 8),
ADD COLUMN checkin_justificativa TEXT,
ADD COLUMN checkout_justificativa TEXT,
ADD COLUMN status_checkin VARCHAR(20) DEFAULT 'pendente' CHECK (status_checkin IN ('pendente', 'validado', 'atrasado')),
ADD COLUMN status_checkout VARCHAR(20) DEFAULT 'pendente' CHECK (status_checkout IN ('pendente', 'validado', 'antecipado', 'atrasado')),
ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();;
