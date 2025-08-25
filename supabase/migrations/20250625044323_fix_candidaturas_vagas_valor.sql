-- Corrigir o problema do vagas_valor

-- 1. Alterar o valor padrão para 1 (temporário, será substituído pelo trigger)
ALTER TABLE candidaturas 
ALTER COLUMN vagas_valor SET DEFAULT 1;

-- 2. Criar função para copiar valor da vaga
CREATE OR REPLACE FUNCTION set_candidatura_vagas_valor()
RETURNS TRIGGER AS $$
BEGIN
  -- Se vagas_valor não foi informado ou é 0, buscar da tabela vagas
  IF NEW.vagas_valor IS NULL OR NEW.vagas_valor = 0 THEN
    SELECT vagas_valor INTO NEW.vagas_valor 
    FROM vagas 
    WHERE vagas_id = NEW.vagas_id;
    
    -- Se não encontrou a vaga, manter valor padrão
    IF NEW.vagas_valor IS NULL THEN
      NEW.vagas_valor := 1;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Criar trigger que executa ANTES do trigger de sincronização
DROP TRIGGER IF EXISTS set_candidatura_vagas_valor_trigger ON candidaturas;
CREATE TRIGGER set_candidatura_vagas_valor_trigger
  BEFORE INSERT OR UPDATE ON candidaturas
  FOR EACH ROW
  EXECUTE FUNCTION set_candidatura_vagas_valor();;
