-- Atualizar trigger para usar estratégia one-for-all
CREATE OR REPLACE FUNCTION cleanup_medicos_precadastro()
RETURNS TRIGGER AS $$
BEGIN
  -- Deletar pré-cadastros com mesmo CRM
  DELETE FROM medicos_precadastro 
  WHERE medico_crm = NEW.medico_crm;
  
  -- Deletar pré-cadastros com mesmo CPF (se informado)
  IF NEW.medico_cpf IS NOT NULL THEN
    DELETE FROM medicos_precadastro 
    WHERE medico_cpf = NEW.medico_cpf;
  END IF;
  
  -- Atualizar registros em equipes_medicos que referenciam pré-cadastros
  -- Mover de médico fantasma + medico_precadastro_id para médico real
  UPDATE equipes_medicos 
  SET 
    medico_id = NEW.id,
    medico_precadastro_id = NULL
  WHERE medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'
    AND medico_precadastro_id IN (
      SELECT id FROM medicos_precadastro 
      WHERE medico_crm = NEW.medico_crm 
         OR (NEW.medico_cpf IS NOT NULL AND medico_cpf = NEW.medico_cpf)
    );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;;
