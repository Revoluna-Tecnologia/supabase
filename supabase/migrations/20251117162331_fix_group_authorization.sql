CREATE OR REPLACE FUNCTION houston.group_authorization(requested_permission houston.app_permission, group_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE
 SET search_path TO ''
 SET statement_timeout TO '15s'
AS $function$
DECLARE 
  user_complete_data RECORD;
  current_user_id uuid;
BEGIN
  -- 📝 Log inicial
  current_user_id := auth.uid();
  RAISE LOG 'group_authorization INICIADO - user_id: %, permission: %, group_id: %', 
    current_user_id, requested_permission, group_id;

  -- ✅ Buscar dados completos do usuário autenticado
  SELECT * INTO user_complete_data 
  FROM houston.get_user_complete_data(current_user_id) 
  LIMIT 1;

  -- 📝 Log dos dados do usuário
  RAISE LOG 'group_authorization DADOS_USER - encontrado: %, role: %, groups: %, permissions: %', 
    (user_complete_data.user_id IS NOT NULL), 
    COALESCE(user_complete_data.role::text, 'NULL'),
    COALESCE(array_length(user_complete_data.group_ids, 1), 0),
    COALESCE(array_length(user_complete_data.permissions, 1), 0);

  -- ✅ Se usuário não encontrado ou dados inválidos
  IF user_complete_data.user_id IS NULL THEN 
    RAISE LOG 'group_authorization RESULTADO: FALSE - usuário não encontrado';
    RETURN false;
  END IF;

  -- ✅ Administrador e Gestor têm acesso total
  IF user_complete_data.role IN ('administrador') THEN
    RAISE LOG 'group_authorization RESULTADO: TRUE - role admin: %', user_complete_data.role;
    RETURN true;
  END IF;

  -- ✅ Verificar se tem a permissão básica solicitada
  IF NOT (requested_permission = ANY(user_complete_data.permissions)) THEN
    RAISE LOG 'group_authorization RESULTADO: FALSE - sem permissão básica. Tem: %, Precisa: %', 
      user_complete_data.permissions, requested_permission;
    RETURN false; -- Não tem a permissão básica
  END IF;

  -- 📝 Log da verificação de permissão básica
  RAISE LOG 'group_authorization PERMISSÃO_OK - usuário tem permissão: %', requested_permission;

  -- ✅ Verificar se pertence ao grupo específico
  -- Se array de grupos está vazio, permite acesso a qualquer grupo
  IF cardinality(user_complete_data.group_ids) = 0 THEN
    RAISE LOG 'group_authorization RESULTADO: TRUE - array grupos vazio (sem restrições)';
    RETURN true; -- Sem restrições de grupo
  END IF;

  -- 📝 Log da verificação de grupo
  RAISE LOG 'group_authorization VERIFICANDO_GRUPO - user_groups: %, target_group: %', 
    user_complete_data.group_ids, group_id;

  -- ✅ Verificar se o group_id está nos grupos do usuário
  IF group_id = ANY(user_complete_data.group_ids) THEN
    RAISE LOG 'group_authorization RESULTADO: TRUE - usuário pertence ao grupo: %', group_id;
    RETURN true; -- Usuário pertence ao grupo
  END IF;

  -- ✅ Se chegou até aqui, não tem acesso
  RAISE LOG 'group_authorization RESULTADO: FALSE - usuário NÃO pertence ao grupo. User_groups: %, Target: %', 
    user_complete_data.group_ids, group_id;
  RETURN false;
END;
$function$;