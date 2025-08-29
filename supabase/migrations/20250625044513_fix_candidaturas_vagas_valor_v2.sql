-- Corrigir o trigger para detectar valor padrão também

CREATE OR REPLACE FUNCTION set_candidatura_vagas_valor()
RETURNS TRIGGER AS $$
BEGIN
  -- Se vagas_valor não foi informado, é 0, ou é o valor padrão (1), buscar da tabela vagas
  IF NEW.vagas_valor IS NULL OR NEW.vagas_valor = 0 OR NEW.vagas_valor = 1 THEN
    SELECT vagas_valor INTO NEW.vagas_valor 
    FROM vagas 
    WHERE vagas_id = NEW.vagas_id;
    
    -- Se não encontrou a vaga, usar valor padrão que passa na constraint
    IF NEW.vagas_valor IS NULL OR NEW.vagas_valor = 0 THEN
      NEW.vagas_valor := 100; -- Valor padrão seguro
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;;
