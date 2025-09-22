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

create table houston.user_roles (
    user_id uuid not null references auth.users(id) on delete cascade,
    role houston.app_role not null,
    primary key (user_id, role)
);
create index idx_user_roles_user_id on houston.user_roles(user_id);

create function houston.role_level(role houston.app_role) returns int as $$
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

-- Create the auth hook function
create or replace function houston.custom_access_token_hook(event jsonb)
returns jsonb
language plpgsql
stable
as $$
  declare
    claims jsonb;
    user_role houston.app_role;
  begin
    -- Fetch the user role in the user_roles table
    select role into user_role from houston.user_roles where user_id = (event->>'user_id')::uuid;

    claims := event->'claims';

    if user_role is not null then
      -- Set the claim
      claims := jsonb_set(claims, '{user_role}', to_jsonb(user_role));
    else
      claims := jsonb_set(claims, '{user_role}', 'null');
    end if;

    -- Update the 'claims' object in the original event
    event := jsonb_set(event, '{claims}', claims);

    -- Return the modified or original event
    return event;
  end;
$$;

grant usage on schema public to supabase_auth_admin;

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
  requested_permission app_permission
)
returns boolean as $$
declare
  bind_permissions int;
  user_role public.app_role;
begin
  -- Fetch user role once and store it to reduce number of calls
  select (auth.jwt() ->> 'user_role')::public.app_role into user_role;

  select count(*)
  into bind_permissions
  from houston.role_permissions
  where role_permissions.permission = requested_permission
    and role_permissions.role = user_role;

  return bind_permissions > 0;
end;
$$ language plpgsql stable security definer set search_path = '';


create policy "Allow authorized delete access" on public.vagas for delete to authenticated using ((SELECT houston.authorize('vagas.delete')) );