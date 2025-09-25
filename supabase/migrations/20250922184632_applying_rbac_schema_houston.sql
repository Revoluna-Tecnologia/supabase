/*
  Este script SQL implementa um sistema de controle de acesso baseado em funções (RBAC) para o schema "houston".

  Principais componentes:
  - Criação do schema "houston" e dos tipos ENUM "app_role" (funções) e "app_permission" (permissões).
  - Tabela "role_permissions": associa funções às permissões específicas.
  - Inserção das permissões para cada função (administrador, moderador, gestor, coordenador, escalista).
  - Tabela "user_roles": vincula usuários (referenciados pelo UUID do auth.users) às funções.
  - Função "role_level": retorna o nível hierárquico de cada função.
  - Função "custom_access_token_hook": adiciona a função do usuário aos claims do token de autenticação.
  - Configuração de permissões e políticas de acesso para o Supabase Auth Admin.
  - Função "authorize": verifica se o usuário autenticado possui a permissão solicitada, baseada em sua função.
  - Política de acesso: permite que usuários autenticados deletem registros em "public.vagas" apenas se autorizados.

  Observações:
  - O sistema facilita a gestão de permissões granulares por função.
  - As funções e permissões são facilmente extensíveis para novos papéis ou ações.
  - O uso de funções e políticas garante segurança e flexibilidade na autorização de operações.
*/
create schema if not exists houston;

create type houston.app_role as enum (
      'administrador',
      'moderador',
      'gestor',
      'coordenador',
      'escalista'
);
create type houston.app_permission as enum (
      -- Vagas
      'vagas.view',
      'vagas.create',
      'vagas.edit',
      'vagas.delete',
      -- Membros
      'membros.view',
      'membros.add',
      'membros.edit',
      'membros.remove',
      -- Médicos (cadastro “ativo”)
      'medicos.view',
      'medicos.add',
      'medicos.edit',
      'medicos.remove',
      -- Médicos pré-cadastrados
      'medicos_precadastro.view',
      'medicos_precadastro.add',
      'medicos_precadastro.edit',
      'medicos_precadastro.remove'
    );


create table houston.role_permissions (
    role houston.app_role not null,
    permission houston.app_permission not null,
    primary key (role, permission)
);


insert into houston.role_permissions (role, permission) values
    -- Permissões do administrador
    ('administrador', 'vagas.view'),
    ('administrador', 'vagas.create'),
    ('administrador', 'vagas.edit'),
    ('administrador', 'vagas.delete'),
    ('administrador', 'membros.view'),
    ('administrador', 'membros.add'),
    ('administrador', 'membros.edit'),
    ('administrador', 'membros.remove'),
    ('administrador', 'medicos.view'),
    ('administrador', 'medicos.add'),
    ('administrador', 'medicos.edit'),
    ('administrador', 'medicos.remove'),
    ('administrador', 'medicos_precadastro.view'),
    ('administrador', 'medicos_precadastro.add'),
    ('administrador', 'medicos_precadastro.edit'),
    ('administrador', 'medicos_precadastro.remove'),

    -- Permissões do moderador
    ('moderador', 'vagas.view'),
    ('moderador', 'vagas.create'),
    ('moderador', 'vagas.edit'),
    ('moderador', 'vagas.delete'),
    ('moderador', 'membros.view'),
    ('moderador', 'membros.add'),
    ('moderador', 'membros.edit'),
    ('moderador', 'membros.remove'),

    -- Permissões do gestor
    ('gestor', 'vagas.view'),
    ('gestor', 'vagas.create'),
    ('gestor', 'vagas.edit'),
    ('gestor', 'membros.view'),
    ('gestor', 'membros.add'),
    ('gestor', 'membros.edit'),

    -- Permissões do coordenador
    ('coordenador', 'vagas.view'),
    ('coordenador', 'vagas.create'),
    ('coordenador', 'vagas.edit'),

    -- Permissões do escalista
    ('escalista', 'vagas.view');

-- Tabela de papéis por usuário agora suporta múltiplos grupos e hospitais via arrays
create table houston.user_roles (
  user_id uuid not null references auth.users(id) on delete cascade,
  role houston.app_role not null,
  group_ids uuid[] not null default '{}'::uuid[],      -- grupos associados ao papel
  hospital_ids uuid[] not null default '{}'::uuid[],   -- hospitais associados ao papel
  primary key (user_id, role)
);
create index idx_user_roles_user_id on houston.user_roles(user_id);
create index idx_user_roles_group_ids on houston.user_roles using gin (group_ids);
create index idx_user_roles_hospital_ids on houston.user_roles using gin (hospital_ids);

create or replace function houston.role_level(role houston.app_role) 
returns int 
language plpgsql
as $$
begin
  case role
    when 'administrador' then return 4;
    when 'moderador' then return 3;
    when 'gestor' then return 2;
    when 'coordenador' then return 1;
    when 'escalista' then return 0;
    else return -1;
  end case;
end;
$$;

-- Create the auth hook function
create or replace function houston.custom_access_token_hook(event jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, houston
as $$
declare
  uid uuid := (event->>'user_id')::uuid;
  payload jsonb := event->'claims';
  highest_role_text text;
begin
  select r.app_role
  from (
     select ur.role as app_role,
            max(houston.role_level(ur.role)) over() as max_level
     from houston.user_roles ur
     where ur.user_id = uid
  ) r
  where houston.role_level(r.app_role) = r.max_level
  limit 1
  into highest_role_text;

  if highest_role_text is null then
    highest_role_text := 'escalista'; -- default mais baixo ou null
  end if;

  -- Opcional: agregar arrays de group_ids / hospital_ids
  -- CUIDADO: pode explodir tamanho do JWT se muitos
  return jsonb_build_object(
    'claims',
    payload
      || jsonb_build_object(
            'user_role', highest_role_text,
            'permissions', coalesce((
               select jsonb_agg(distinct rp.permission) from houston.role_permissions rp
               join houston.user_roles ur on ur.role = rp.role
               where ur.user_id = uid
            ), '[]'::jsonb),
            'roles', coalesce((
               select jsonb_agg(distinct ur.role) from houston.user_roles ur where ur.user_id = uid
            ), '[]'::jsonb)
         )
  );
end;
$$;

grant usage on schema public to supabase_auth_admin;
grant usage on schema houston to supabase_auth_admin;

grant execute
  on function houston.custom_access_token_hook
  to supabase_auth_admin;

revoke execute
  on function houston.custom_access_token_hook
  from authenticated, anon, public;

grant all
  on table houston.user_roles
to supabase_auth_admin;

revoke all
  on table houston.user_roles
  from authenticated, anon, public;

create policy "Allow auth admin to read user roles" ON houston.user_roles
as permissive for select
to supabase_auth_admin
using (true);


create or replace function houston.authorize(
  requested_permission houston.app_permission
)
returns boolean as $$
declare
  bind_permissions int;
  user_role houston.app_role;
begin
  -- Fetch user role once and store it to reduce number of calls
  select (auth.jwt() ->> 'user_role')::houston.app_role into user_role;

  select count(*)
  into bind_permissions
  from houston.role_permissions
  where role_permissions.permission = requested_permission
    and role_permissions.role = user_role;

  return bind_permissions > 0;
end;
$$ language plpgsql stable security definer set search_path = '';

