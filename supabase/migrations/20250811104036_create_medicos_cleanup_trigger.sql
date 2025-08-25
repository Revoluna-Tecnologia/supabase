-- Função para limpeza automática de pré-cadastros
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
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que executa após inserção na tabela medicos
CREATE TRIGGER medicos_1_cleanup_precadastro
  AFTER INSERT ON medicos
  FOR EACH ROW
  EXECUTE FUNCTION cleanup_medicos_precadastro();;
