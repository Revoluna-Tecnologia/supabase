-- Criar tabela para médicos favoritos
CREATE TABLE medicos_favoritos (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    escalista_id UUID NOT NULL,
    medico_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Foreign keys
    CONSTRAINT fk_medicos_favoritos_escalista 
        FOREIGN KEY (escalista_id) 
        REFERENCES escalista(escalista_id) 
        ON DELETE CASCADE,
    
    CONSTRAINT fk_medicos_favoritos_medico 
        FOREIGN KEY (medico_id) 
        REFERENCES medicos(id) 
        ON DELETE CASCADE,
    
    -- Constraint de unicidade para evitar duplicatas
    CONSTRAINT unique_escalista_medico 
        UNIQUE (escalista_id, medico_id)
);

-- Criar índices para melhor performance
CREATE INDEX idx_medicos_favoritos_escalista ON medicos_favoritos(escalista_id);
CREATE INDEX idx_medicos_favoritos_medico ON medicos_favoritos(medico_id);

-- Comentários para documentação
COMMENT ON TABLE medicos_favoritos IS 'Tabela para armazenar médicos favoritos de cada escalista';
COMMENT ON COLUMN medicos_favoritos.escalista_id IS 'ID do escalista (FK para escalista)';
COMMENT ON COLUMN medicos_favoritos.medico_id IS 'ID do médico favorito (FK para medicos)';
COMMENT ON COLUMN medicos_favoritos.created_at IS 'Data e hora quando o médico foi favoritado';;
