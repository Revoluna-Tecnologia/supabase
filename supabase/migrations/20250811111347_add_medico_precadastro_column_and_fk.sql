-- Recriar a FK constraint para medico_id
ALTER TABLE equipes_medicos 
ADD CONSTRAINT fk_medico 
FOREIGN KEY (medico_id) REFERENCES medicos(id);

-- Adicionar nova coluna para médicos pré-cadastrados
ALTER TABLE equipes_medicos 
ADD COLUMN medico_precadastro_id UUID;

-- Criar FK constraint para a nova coluna
ALTER TABLE equipes_medicos 
ADD CONSTRAINT fk_medico_precadastro 
FOREIGN KEY (medico_precadastro_id) REFERENCES medicos_precadastro(id);

-- Adicionar constraint para garantir que apenas um dos campos seja preenchido
ALTER TABLE equipes_medicos 
ADD CONSTRAINT chk_one_medico_type 
CHECK (
  (medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5' AND medico_precadastro_id IS NOT NULL) 
  OR 
  (medico_id != '9cd29712-91b5-492f-86ff-41e38c7b03d5' AND medico_precadastro_id IS NULL)
);;
