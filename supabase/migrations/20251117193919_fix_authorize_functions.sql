create or replace function houston.get_user_complete_data(
  input_user_id uuid
)
returns table(
  user_id uuid,
  role houston.app_role,
  group_ids uuid[],
  hospital_ids uuid[],
  setor_ids uuid[],
  permissions houston.app_permission[]
) 
language plpgsql
stable
security definer
set search_path = ''
set statement_timeout = '10s'
as $$
declare
  user_role_data houston.app_role;
  permissions_array houston.app_permission[];
begin
  -- Buscar role do usuário na tabela user_roles
  SELECT ur.role INTO user_role_data
  FROM houston.user_roles ur
  WHERE ur.user_id = input_user_id
  LIMIT 1;
  
  -- Se usuário não encontrado, retornar resultado vazio
  if user_role_data IS NULL then
    return;
  end if;
  
  -- Buscar permissões baseadas no role do usuário
  if user_role_data IN ('administrador') then
    -- Administradores e Gestores têm TODAS as permissões do sistema
    SELECT array_agg(DISTINCT rp.permission)
    INTO permissions_array
    FROM houston.role_permissions rp;
  else
    -- Outros roles têm apenas permissões específicas do seu role
    SELECT array_agg(DISTINCT rp.permission)
    INTO permissions_array
    FROM houston.role_permissions rp
    WHERE rp.role = user_role_data;
  end if;
  
  -- Retornar dados completos do usuário
  RETURN QUERY
  SELECT 
    ur.user_id,
    ur.role,
    COALESCE(ur.group_ids, '{}'),    -- Array vazio se NULL
    COALESCE(ur.hospital_ids, '{}'), -- Array vazio se NULL
    COALESCE(ur.setor_ids, '{}'),    -- Array vazio se NULL
    COALESCE(permissions_array, '{}') -- Array vazio se NULL
  FROM houston.user_roles ur
  WHERE ur.user_id = input_user_id;
end;
$$;


create or replace function houston.authorize(
  requested_permission houston.app_permission,
  hospital_id uuid default null,
  setor_id uuid default null,
  group_id uuid default null
)
returns boolean as $$
declare
  user_complete_data RECORD;
  has_permission boolean := false;
begin
  -- Buscar dados completos do usuário autenticado
  SELECT * INTO user_complete_data 
  FROM houston.get_user_complete_data(auth.uid())
  LIMIT 1;
  
  -- Se usuário não encontrado ou sem dados, negar acesso
  if user_complete_data.user_id IS NULL then
    return false;
  end if;

  -- REGRA 1: Administrador têm acesso TOTAL
  if user_complete_data.role IN ('administrador') then
    return true;
  end if;

  -- REGRA 2: Verificar se usuário tem a permissão básica solicitada
  if NOT (requested_permission = ANY(user_complete_data.permissions)) then
    return false; -- Não tem a permissão básica, negar acesso
  end if;

  -- REGRA 3: Se chegou até aqui, tem a permissão básica
  -- Agora verificar restrições de contexto (grupo, hospital, setor)
  
  -- Se nenhum contexto foi fornecido, autorizar (só verificou permissão básica)
  if hospital_id IS NULL AND setor_id IS NULL AND group_id IS NULL then
    return true;
  end if;

  -- REGRA 4: Verificar GROUP_ID (se fornecido)
  if group_id IS NOT NULL then
    if cardinality(user_complete_data.group_ids) = 0 then
      -- Array vazio = sem restrição de grupo
      has_permission := true;
    else
      -- Verificar se o grupo solicitado está na lista do usuário
      has_permission := group_id = ANY(user_complete_data.group_ids);
    end if;
    
    -- Se falhou na verificação de grupo, negar acesso
    if NOT has_permission then
      return false;
    end if;
  end if;

  -- REGRA 5: Verificar HOSPITAL_ID (se fornecido)
  if hospital_id IS NOT NULL then
    if cardinality(user_complete_data.hospital_ids) = 0 then
      -- Array vazio = sem restrição de hospital
      has_permission := true;
    else
      -- Verificar se o hospital solicitado está na lista do usuário
      has_permission := hospital_id = ANY(user_complete_data.hospital_ids);
    end if;
    
    -- Se falhou na verificação de hospital, negar acesso
    if NOT has_permission then
      return false;
    end if;
  end if;

  -- REGRA 6: Verificar SETOR_ID (se fornecido)
  if setor_id IS NOT NULL then
    if cardinality(user_complete_data.setor_ids) = 0 then
      -- Array vazio = sem restrição de setor
      has_permission := true;
    else
      -- Verificar se o setor solicitado está na lista do usuário
      has_permission := setor_id = ANY(user_complete_data.setor_ids);
    end if;
    
    -- Se falhou na verificação de setor, negar acesso
    if NOT has_permission then
      return false;
    end if;
  end if;

  -- Se passou por todas as verificações, autorizar acesso
  return true;
end;
$$ language plpgsql 
   stable 
   security invoker 
   set search_path = ''
   set statement_timeout = '15s';
