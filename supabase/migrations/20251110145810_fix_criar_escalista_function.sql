CREATE OR REPLACE FUNCTION "public"."criar_escalista"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$DECLARE
  user_phone varchar;
  user_email varchar;
  user_metadata jsonb;
BEGIN
  -- Verificar se o role foi definido como 'astronauta'
  IF NEW.role = 'astronauta' THEN
    -- Obter email e metadados do usuário da tabela auth.users
    SELECT 
      email, 
      raw_user_meta_data
    INTO 
      user_email,
      user_metadata
    FROM auth.users
    WHERE id = NEW.id;
    
    -- Obter telefone dos metadados (apenas do campo 'phone' dentro de 'data')
    user_phone := user_metadata->'data'->>'phone';
    
    -- Adicionar prefixo '55' se não existir e o telefone não for nulo
    IF user_phone IS NOT NULL AND user_phone NOT LIKE '55%' THEN
      user_phone := '55' || user_phone;
    END IF;
    
    INSERT INTO public.escalistas (
      id,
      nome,
      telefone,
      email
    )
    VALUES (
      NEW.id,
      NEW.displayname,
      user_phone,
      user_email
    )
    ON CONFLICT (id) DO UPDATE SET
      nome = NEW.displayname,
      telefone = user_phone,
      email = user_email;
  END IF;
  RETURN NEW;
END;$$;