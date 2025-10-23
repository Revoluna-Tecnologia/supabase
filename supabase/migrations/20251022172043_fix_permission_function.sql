-- =============================================================================
-- MIGRATION: Houston Permission System - Functions and Permissions
-- =============================================================================
-- Created: 2025-10-22
-- Author: System
-- Description: Sistema completo de autorização e permissões para Houston RBAC
-- Version: 2.0
-- 
-- Esta migration contém:
-- 1. Função para buscar dados completos do usuário
-- 2. Função de autorização contextual principal
-- 3. Função de autorização simplificada (backward compatibility)
-- 4. Função otimizada para scheduler
-- 5. Permissões e grants necessários
-- =============================================================================

-- =============================================================================
-- 1. FUNÇÃO: get_user_complete_data
-- =============================================================================
-- Propósito: Busca dados completos do usuário incluindo role, grupos, hospitais, 
-- setores e todas as permissões baseadas no role
-- Parâmetros: input_user_id (uuid) - ID do usuário
-- Retorna: Table com dados completos do usuário
-- Uso: Base para outras funções de autorização
-- =============================================================================

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
  if user_role_data IN ('administrador', 'gestor') then
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

-- =============================================================================
-- 2. FUNÇÃO: authorize (PRINCIPAL)
-- =============================================================================
-- Propósito: Função principal de autorização com verificação contextual
-- Parâmetros: 
--   - requested_permission: Permissão solicitada
--   - hospital_id: ID do hospital (opcional)
--   - setor_id: ID do setor (opcional) 
--   - group_id: ID do grupo (opcional)
-- Retorna: boolean (true = autorizado, false = negado)
-- 
-- Lógica:
-- 1. Admin/Gestor: SEMPRE true
-- 2. Outros: Verifica se tem a permissão básica
-- 3. Verifica contexto (grupo, hospital, setor) se fornecido
-- 4. Arrays vazios = sem restrição para aquele contexto
-- =============================================================================

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

  -- REGRA 1: Administrador e Gestor têm acesso TOTAL
  if user_complete_data.role IN ('administrador', 'gestor') then
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

-- =============================================================================
-- 3. FUNÇÃO: authorize_simple (BACKWARD COMPATIBILITY)
-- =============================================================================
-- Propósito: Versão simplificada da função authorize para compatibilidade
-- Parâmetros: requested_permission apenas
-- Retorna: boolean
-- Uso: Para códigos existentes que só verificam permissão básica
-- =============================================================================

create or replace function houston.authorize_simple(
  requested_permission houston.app_permission
)
returns boolean as $$
begin
  -- Chama a função principal sem contexto (só verifica permissão básica)
  return houston.authorize(requested_permission, null, null, null);
end;
$$ language plpgsql 
   stable 
   security invoker 
   set search_path = ''
   set statement_timeout = '10s';

-- =============================================================================
-- 4. FUNÇÃO: scheduler_belongs_can_access (OTIMIZADA)
-- =============================================================================
-- Propósito: Função otimizada para verificações de acesso em massa
-- Parâmetros: permission, hospital_id, setor_id, group_id
-- Retorna: boolean
-- Uso: Para verificações em RLS policies e funções de paginação
-- Nota: Wrapper otimizado que usa a função authorize principal
-- =============================================================================

create or replace function houston.scheduler_belongs_can_access(
  requested_permission houston.app_permission,
  hospital_id uuid,
  setor_id uuid,
  group_id uuid
)
returns boolean
language plpgsql
stable
security invoker
set search_path = ''
set statement_timeout = '15s'
as $$
begin
  -- Delegar para a função principal de autorização
  -- Isso garante consistência e evita duplicação de lógica
  return houston.authorize(
    requested_permission,
    hospital_id,
    setor_id,
    group_id
  );
end;
$$;

-- =============================================================================
-- 5. GRANTS E PERMISSÕES
-- =============================================================================
-- Configuração de permissões para todas as funções criadas
-- =============================================================================

-- Permissões para função get_user_complete_data
grant execute on function houston.get_user_complete_data(uuid) 
  to supabase_auth_admin, authenticated;

-- Permissões para função authorize principal
grant execute on function houston.authorize(houston.app_permission, uuid, uuid, uuid) 
  to supabase_auth_admin, authenticated;
  
-- Permissões para função authorize_simple
grant execute on function houston.authorize_simple(houston.app_permission) 
  to supabase_auth_admin, authenticated;

-- Permissões para função scheduler_belongs_can_access
grant execute on function houston.scheduler_belongs_can_access(houston.app_permission, uuid, uuid, uuid) 
  to supabase_auth_admin, authenticated;

-- =============================================================================
-- 6. PERMISSÕES PARA SCHEMA E OBJETOS HOUSTON
-- =============================================================================
-- Configuração de acesso ao schema houston e seus objetos
-- =============================================================================

-- Acesso ao schema houston
GRANT USAGE ON SCHEMA houston TO authenticated, supabase_auth_admin;

-- Acesso às tabelas principais
GRANT SELECT ON houston.user_roles TO authenticated, supabase_auth_admin;
GRANT SELECT ON houston.role_permissions TO authenticated, supabase_auth_admin;

-- Acesso aos tipos/enums
GRANT USAGE ON TYPE houston.app_role TO authenticated, supabase_auth_admin;
GRANT USAGE ON TYPE houston.app_permission TO authenticated, supabase_auth_admin;

-- Permissões adicionais para administração
GRANT ALL PRIVILEGES ON houston.role_permissions TO supabase_auth_admin, authenticated;

-- =============================================================================
-- FIM DA MIGRATION
-- =============================================================================
-- 
-- RESUMO DAS FUNÇÕES CRIADAS:
-- 
-- 1. houston.get_user_complete_data(uuid) 
--    - Busca dados completos do usuário
--    - Base para outras funções
-- 
-- 2. houston.authorize(permission, hospital, setor, group)
--    - Função principal de autorização
--    - Verificação contextual completa
-- 
-- 3. houston.authorize_simple(permission)
--    - Versão simplificada para backward compatibility
-- 
-- 4. houston.scheduler_belongs_can_access(permission, hospital, setor, group)
--    - Função otimizada para uso em RLS policies
-- 
-- COMO USAR:
-- 
-- -- Verificação simples
-- SELECT houston.authorize_simple('vagas.view');
-- 
-- -- Verificação com contexto
-- SELECT houston.authorize('vagas.create', hospital_uuid, setor_uuid, group_uuid);
-- 
-- -- Para RLS policies
-- WHERE houston.scheduler_belongs_can_access('vagas.view', hospital_id, setor_id, grupo_id)
-- 
-- =============================================================================


