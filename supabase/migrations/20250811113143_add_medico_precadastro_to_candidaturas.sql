-- Adicionar nova coluna para médicos pré-cadastrados
ALTER TABLE candidaturas 
ADD COLUMN medico_precadastro_id UUID;

-- Criar FK constraint para a nova coluna
ALTER TABLE candidaturas 
ADD CONSTRAINT fk_medico_precadastro_candidaturas 
FOREIGN KEY (medico_precadastro_id) REFERENCES medicos_precadastro(id);

-- Adicionar constraint para garantir que apenas um dos campos seja preenchido
ALTER TABLE candidaturas 
ADD CONSTRAINT chk_one_medico_type_candidaturas 
CHECK (
  (medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5' AND medico_precadastro_id IS NOT NULL) 
  OR 
  (medico_id != '9cd29712-91b5-492f-86ff-41e38c7b03d5' AND medico_precadastro_id IS NULL)
);

-- Criar índice para performance
CREATE INDEX idx_candidaturas_medico_precadastro_id ON candidaturas(medico_precadastro_id);;
