
-- parte 1

-- update_phone_forotp
CREATE OR REPLACE FUNCTION public.update_phone_forotp(user_id uuid, areacodeindex integer, telefone text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE areacode TEXT;
BEGIN
  
  -- Buscar código de área na tabela
  SELECT codigo INTO areacode
  FROM codigos_area
  WHERE index = areaCodeIndex;

  -- Remover o símbolo + do código de área
  areacode := REPLACE(areacode, '+', '');

  -- Atualiza auth.users
  UPDATE auth.users
  SET phone = areacode || telefone,
      raw_app_meta_data = jsonb_set(
        COALESCE(raw_app_meta_data, '{}'::jsonb),
        '{providers}',
        '["email", "phone"]'::jsonb
      ),
      updated_at = NOW(),
      phone_confirmed_at = NOW()
  WHERE id = user_id;

    -- Cria entrada em auth identities
    INSERT INTO auth.identities (
        id,
        provider_id,
        user_id,
        identity_data,
        provider,
        updated_at,
        last_sign_in_at,
        created_at
    )
    VALUES (
        gen_random_uuid(),
        user_id,
        user_id,
        jsonb_build_object(
            'sub', user_id,
            'phone', areacode || telefone,
            'email_verified', false,
            'phone_verified', true
        ),
        'phone',
        NOW(),
        NOW(),
        NOW()
    );

  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Erro: %', SQLERRM;
END;
$function$
;


-- get_cpf
CREATE OR REPLACE FUNCTION public.get_cpf(cpf_input text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    exists_flag BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM public.medicos
        WHERE cpf = cpf_input
    ) INTO exists_flag;
    
    RETURN exists_flag;
END;
$function$
;

-- get_crm
CREATE OR REPLACE FUNCTION public.get_crm(crm_input text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    exists_flag BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM public.medicos
        WHERE crm = crm_input
    ) INTO exists_flag;
    
    RETURN exists_flag;
END;
$function$
;

-- criar_escalista_from_auth >> create_user_from_auth

DROP TRIGGER IF EXISTS auth_users_criar_escalista_trigger ON auth.users;

DROP FUNCTION IF EXISTS public.criar_escalista_from_auth();

CREATE OR REPLACE FUNCTION public.create_user_from_auth()
RETURNS TRIGGER 
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  user_phone varchar;
  user_metadata jsonb;
  user_name text;
  new_user_id uuid;
  group_id uuid;
  role houston.app_role;
  platform_origin text;
BEGIN
 RAISE NOTICE 'TRIGGER DEBUG: create_user_from_auth() executada para usuário %', NEW.id;

  user_metadata := COALESCE(NEW.raw_user_meta_data, '{}'::jsonb);
  RAISE NOTICE 'TRIGGER DEBUG: Metadados do usuário: %', user_metadata;
  platform_origin := user_metadata->>'platform';
  user_phone := NULLIF(user_metadata->>'phone', '');
  user_name := NULLIF(user_metadata->>'name', '');
  new_user_id := NEW.id;

  IF platform_origin = 'houston' OR platform_origin IS NOT NULL THEN
  
 -- group_id seguro
    BEGIN
      group_id := NULLIF(user_metadata->>'group_id', '')::uuid;
    EXCEPTION WHEN invalid_text_representation THEN
      RAISE NOTICE 'TRIGGER DEBUG: group_id inválido para usuário %: %', NEW.id, user_metadata->>'group_id';
      group_id := NULL;
    END;
  -- Cast do enum app_role; se vier inválido, tratar como NULL
 BEGIN
      role := (user_metadata->>'role')::houston.app_role;
    EXCEPTION WHEN invalid_text_representation THEN
      RAISE NOTICE 'TRIGGER DEBUG: role inválido para usuário %: %', NEW.id, user_metadata->>'role';
      role := NULL;
    END;


  IF group_id IS NOT NULL then

   INSERT INTO public.escalistas (
    id,
    nome,
    telefone,
    email,
    created_at,
    update_at,
    update_by,
    grupo_id,
    escalista_status
  )
  VALUES (
    new_user_id,
    user_name,
    user_phone,
    NEW.email,
    NOW(),
    NOW(),
    new_user_id,
    group_id,
    'pendente'
  )
  ON CONFLICT (id) DO UPDATE SET
    nome = EXCLUDED.nome,
    telefone = EXCLUDED.telefone,
    email = EXCLUDED.email,
    grupo_id = EXCLUDED.grupo_id,
    update_at = NOW();

  INSERT INTO houston.user_roles (
    user_id,
    role,
    group_ids
  )
  VALUES (
    new_user_id,
    role,
    ARRAY[group_id]  -- array de UUIDs com sintaxe correta
  );

  else  
    INSERT INTO public.escalistas (
    id,
    email,
    nome,
    created_at,
    telefone,
    update_at,
    update_by,
    escalista_status
  )
  VALUES (
    new_user_id,
    NEW.email,
    'Usuário',
    NOW(),
    '0000000000000000',
    NOW(),
    new_user_id,
    'pendente'
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    update_at = NOW();

  INSERT INTO houston.user_roles (
    user_id,
    role
  )
  VALUES (
    new_user_id,
    ('escalista')::houston.app_role
    -- array de UUIDs com sintaxe correta
  );
  end if;
 
  -- ON CONFLICT (new_user_id) DO UPDATE SET
  --   role = COALESCE(EXCLUDED.role, houston.user_roles.role),
  --   group_ids = houston.user_roles.group_ids || EXCLUDED.group_ids; -- mescla arrays, ajuste conforme a regra de negócio

  RAISE NOTICE 'TRIGGER DEBUG: Escalista criado/atualizado com sucesso para usuário %', NEW.id;

  else
       insert into public.user_profile(
        id, 
        created_at, 
        role, 
        displayname,
        platform
       ) values (
        new_user_id, 
        NOW(), 
        'signup',
        user_name, 
        'android'
       );

  end if;

  RETURN NEW;
END;
$$;

-- drop trigger e recriar

CREATE TRIGGER users_1_criar_usuario AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION create_user_from_auth;

DROP TRIGGER IF EXISTS activate_escalista_on_email_confirmation ON auth.users;

CREATE TRIGGER users_2_ativar_escalista AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION activate_escalista_on_confirmation;


-- cleanup_medicos_precadastro
CREATE OR REPLACE FUNCTION cleanup_medicos_precadastro ()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
  -- PRIMEIRO: Atualizar registros em equipes_medicos que referenciam pré-cadastros
  UPDATE equipes_medicos 
  SET 
    medico_id = NEW.id,
    medico_precadastro_id = NULL
  WHERE medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'
    AND medico_precadastro_id IN (
      SELECT id FROM medicos_precadastro 
      WHERE (crm = NEW.crm AND estado = NEW.estado)
         OR (
           NEW.cpf IS NOT NULL 
           AND cpf IS NOT NULL 
           AND REPLACE(REPLACE(REPLACE(cpf, '.', ''), '-', ''), ' ', '') = 
               REPLACE(REPLACE(REPLACE(NEW.cpf, '.', ''), '-', ''), ' ', '')
         )
    );
    
  -- SEGUNDO: Atualizar registros em candidaturas que referenciam pré-cadastros
  UPDATE candidaturas 
  SET 
    medico_id = NEW.id,
    medico_precadastro_id = NULL
  WHERE medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'
    AND medico_precadastro_id IN (
      SELECT id FROM medicos_precadastro 
      WHERE (crm = NEW.crm AND estado = NEW.estado)
         OR (
           NEW.cpf IS NOT NULL 
           AND cpf IS NOT NULL 
           AND REPLACE(REPLACE(REPLACE(cpf, '.', ''), '-', ''), ' ', '') = 
               REPLACE(REPLACE(REPLACE(NEW.cpf, '.', ''), '-', ''), ' ', '')
         )
    );

  -- TERCEIRO: Deletar pré-cadastros com mesmo CRM + estado (agora que as referências foram atualizadas)
  DELETE FROM medicos_precadastro 
  WHERE crm = NEW.crm 
    AND estado = NEW.estado;
  
  -- QUARTO: Deletar pré-cadastros com mesmo CPF (se informado)
  IF NEW.cpf IS NOT NULL THEN
    DELETE FROM medicos_precadastro 
    WHERE cpf IS NOT NULL 
      AND (
        -- CPF igual (considerando que pode estar formatado ou não)
        REPLACE(REPLACE(REPLACE(cpf, '.', ''), '-', ''), ' ', '') = 
        REPLACE(REPLACE(REPLACE(NEW.cpf, '.', ''), '-', ''), ' ', '')
      );
  END IF;
  
  RETURN NEW;
END;
$function$;

