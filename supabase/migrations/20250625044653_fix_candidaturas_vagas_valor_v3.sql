-- Remover o trigger desnecessário já que o app envia o valor
DROP TRIGGER IF EXISTS set_candidatura_vagas_valor_trigger ON candidaturas;
DROP FUNCTION IF EXISTS set_candidatura_vagas_valor();

-- Simplesmente alterar o valor padrão para um valor válido que passe na constraint
ALTER TABLE candidaturas 
ALTER COLUMN vagas_valor SET DEFAULT 100;;
