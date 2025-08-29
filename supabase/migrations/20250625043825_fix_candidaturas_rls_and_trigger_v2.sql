BEGIN;

-- 1. REMOVER POLÍTICAS PROBLEMÁTICAS
DROP POLICY IF EXISTS "Enable medicos full acess to their own data" ON candidaturas;
DROP POLICY IF EXISTS "Enable full read access to medicos users" ON candidaturas;

-- 2. CRIAR POLÍTICA DE LEITURA PARA MÉDICOS (role "free")
-- Médicos podem VER todas as candidaturas
CREATE POLICY "medicos_read_all_candidaturas" ON candidaturas
FOR SELECT 
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_profile up
    JOIN medicos m ON m.id = up.id  
    WHERE up.id = auth.uid() 
    AND up.role = 'free'
  )
);

-- 3. CRIAR POLÍTICA DE INSERT PARA MÉDICOS (role "free")  
CREATE POLICY "medicos_insert_own_candidaturas" ON candidaturas
FOR INSERT
TO authenticated
WITH CHECK (
  medico_id = auth.uid() 
  AND EXISTS (
    SELECT 1 FROM user_profile up
    JOIN medicos m ON m.id = up.id
    WHERE up.id = auth.uid() 
    AND up.role = 'free'
  )
);

-- 4. CRIAR POLÍTICA DE UPDATE PARA MÉDICOS (role "free")  
CREATE POLICY "medicos_update_own_candidaturas" ON candidaturas
FOR UPDATE
TO authenticated
USING (
  medico_id = auth.uid() 
  AND EXISTS (
    SELECT 1 FROM user_profile up
    JOIN medicos m ON m.id = up.id
    WHERE up.id = auth.uid() 
    AND up.role = 'free'
  )
)
WITH CHECK (
  medico_id = auth.uid() 
  AND EXISTS (
    SELECT 1 FROM user_profile up
    JOIN medicos m ON m.id = up.id
    WHERE up.id = auth.uid() 
    AND up.role = 'free'
  )
);

-- 5. CRIAR POLÍTICA DE DELETE PARA MÉDICOS (role "free")  
CREATE POLICY "medicos_delete_own_candidaturas" ON candidaturas
FOR DELETE
TO authenticated
USING (
  medico_id = auth.uid() 
  AND EXISTS (
    SELECT 1 FROM user_profile up
    JOIN medicos m ON m.id = up.id
    WHERE up.id = auth.uid() 
    AND up.role = 'free'
  )
);

-- 6. CORRIGIR A FUNÇÃO DO TRIGGER
CREATE OR REPLACE FUNCTION sync_candidaturas_medico_id()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    -- CENÁRIO 1: App antigo enviou medicos_id, mas não medico_id
    IF NEW.medicos_id IS NOT NULL AND NEW.medico_id IS NULL THEN
      NEW.medico_id = NEW.medicos_id;
    
    -- CENÁRIO 2: App novo enviou medico_id, mas não medicos_id  
    ELSIF NEW.medico_id IS NOT NULL AND NEW.medicos_id IS NULL THEN
      NEW.medicos_id = NEW.medico_id;
    
    -- CENÁRIO 3: Nenhum dos dois foi enviado (erro)
    ELSIF NEW.medico_id IS NULL AND NEW.medicos_id IS NULL THEN
      RAISE EXCEPTION 'É obrigatório enviar medico_id ou medicos_id';
    
    -- CENÁRIO 4: Ambos foram enviados (validar se são iguais)
    ELSIF NEW.medico_id IS NOT NULL AND NEW.medicos_id IS NOT NULL THEN
      IF NEW.medico_id != NEW.medicos_id THEN
        RAISE EXCEPTION 'medico_id e medicos_id devem ser iguais quando ambos são enviados';
      END IF;
      -- Se são iguais, mantém como está
    END IF;
    
  ELSIF TG_OP = 'UPDATE' THEN
    -- Se medico_id foi alterado, sincroniza para medicos_id
    IF NEW.medico_id IS DISTINCT FROM OLD.medico_id THEN
      NEW.medicos_id = NEW.medico_id;
    END IF;
    
    -- Se medicos_id foi alterado e medico_id não foi, sincroniza medicos_id para medico_id
    IF NEW.medicos_id IS DISTINCT FROM OLD.medicos_id AND NEW.medico_id IS NOT DISTINCT FROM OLD.medico_id THEN
      NEW.medico_id = NEW.medicos_id;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMIT;;
