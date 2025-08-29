-- Atualizar função cleanup_medicos_precadastro para incluir estado do CRM e CPF formatado
CREATE OR REPLACE FUNCTION cleanup_medicos_precadastro()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Deletar pré-cadastros com mesmo CRM + estado
  DELETE FROM medicos_precadastro 
  WHERE medico_crm = NEW.medico_crm 
    AND medico_estado = NEW.medico_estado;
  
  -- Deletar pré-cadastros com mesmo CPF (se informado)
  -- Comparar tanto CPF sem formatação quanto CPF com formatação
  IF NEW.medico_cpf IS NOT NULL THEN
    DELETE FROM medicos_precadastro 
    WHERE medico_cpf IS NOT NULL 
      AND (
        -- CPF igual (considerando que pode estar formatado ou não)
        REPLACE(REPLACE(REPLACE(medico_cpf, '.', ''), '-', ''), ' ', '') = 
        REPLACE(REPLACE(REPLACE(NEW.medico_cpf, '.', ''), '-', ''), ' ', '')
      );
  END IF;
  
  -- Atualizar registros em equipes_medicos que referenciam pré-cadastros
  UPDATE equipes_medicos 
  SET 
    medico_id = NEW.id,
    medico_precadastro_id = NULL
  WHERE medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'
    AND medico_precadastro_id IN (
      SELECT id FROM medicos_precadastro 
      WHERE (medico_crm = NEW.medico_crm AND medico_estado = NEW.medico_estado)
         OR (
           NEW.medico_cpf IS NOT NULL 
           AND medico_cpf IS NOT NULL 
           AND REPLACE(REPLACE(REPLACE(medico_cpf, '.', ''), '-', ''), ' ', '') = 
               REPLACE(REPLACE(REPLACE(NEW.medico_cpf, '.', ''), '-', ''), ' ', '')
         )
    );
    
  -- Atualizar registros em candidaturas que referenciam pré-cadastros
  UPDATE candidaturas 
  SET 
    medico_id = NEW.id,
    medico_precadastro_id = NULL
  WHERE medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'
    AND medico_precadastro_id IN (
      SELECT id FROM medicos_precadastro 
      WHERE (medico_crm = NEW.medico_crm AND medico_estado = NEW.medico_estado)
         OR (
           NEW.medico_cpf IS NOT NULL 
           AND medico_cpf IS NOT NULL 
           AND REPLACE(REPLACE(REPLACE(medico_cpf, '.', ''), '-', ''), ' ', '') = 
               REPLACE(REPLACE(REPLACE(NEW.medico_cpf, '.', ''), '-', ''), ' ', '')
         )
    );
  
  RETURN NEW;
END;
$$;;
