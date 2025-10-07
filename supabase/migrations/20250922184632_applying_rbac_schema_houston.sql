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
      'medicos_precadastro.remove',

      -- Grupo
      'grupo.view',
      'grupo.add',
      'grupo.edit',
      'grupo.remove'
    );


create table houston.role_permissions (
    role houston.app_role not null,
    permission houston.app_permission not null,
    primary key (role, permission)
);

create or replace function houston.vaga_in_user_scope(
  p_grupo_id uuid,
  p_hospital_id uuid
) returns boolean
language plpgsql
stable
security invoker
as $$
declare
  jwt_role_text text;
  lvl int;
begin
  -- Captura papel do JWT (caso exista)
  jwt_role_text := auth.jwt()->>'user_role';
  if jwt_role_text is not null then
    begin
      lvl := houston.role_level(jwt_role_text::houston.app_role);
      -- Papéis de nível moderador ou superior ignoram escopo
      if lvl >= houston.role_level('moderador') then
        return true;
      end if;
    exception when others then
      -- Se por algum motivo o cast falhar, segue fluxo normal
      null;
    end;
  end if;

  -- Sem usuário autenticado -> fora do escopo
  if auth.uid() is null then
    return false;
  end if;

  -- Se ambos nulos não há ancoragem de escopo; negar (a menos que papel alto acima, já retornado)
  if p_grupo_id is null and p_hospital_id is null then
    return false;
  end if;

  return exists (
    select 1
    from houston.user_roles ur
    where ur.user_id = auth.uid()
      and (
        (p_grupo_id    is not null and p_grupo_id    = any(coalesce(ur.group_ids,    '{}'::uuid[])))
        or
        (p_hospital_id is not null and p_hospital_id = any(coalesce(ur.hospital_ids, '{}'::uuid[])))
      )
  );
end;
$$;

comment on function houston.vaga_in_user_scope(uuid, uuid) is 'Retorna true se vaga está no escopo do usuário (grupos/hospitais) ou se papel >= moderador.';
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
    ('administrador', 'grupo.view'),
    ('administrador', 'grupo.add'),
    ('administrador', 'grupo.edit'),
    ('administrador', 'grupo.remove'),

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
    ('gestor', 'medicos.view'),
    ('gestor', 'medicos.add'),
    ('gestor', 'medicos.edit'),
    ('gestor', 'medicos.remove'),
    ('gestor', 'grupo.view'),
    ('gestor', 'grupo.add'),
    ('gestor', 'grupo.edit'),
    ('gestor', 'grupo.remove'),

    -- Permissões do coordenador
    ('coordenador', 'vagas.view'),
    ('coordenador', 'vagas.create'),
    ('coordenador', 'vagas.edit'),
    ('coordenador', 'membros.view'),
    ('coordenador', 'membros.add'),
    ('coordenador', 'membros.edit'),
    ('coordenador', 'medicos_precadastro.view'),
    ('coordenador', 'medicos_precadastro.add'),
    ('coordenador', 'medicos_precadastro.edit'),
    ('coordenador', 'medicos_precadastro.remove'),
    -- Permissões do escalista
    ('escalista', 'membros.view'),
    ('escalista', 'vagas.view'),
    ('escalista', 'medicos_precadastro.view'),
    ('escalista', 'medicos.view'),
    ('escalista', 'grupo.view');

-- Tabela de papéis por usuário agora suporta múltiplos grupos e hospitais via arrays
create table houston.user_roles (
  user_id uuid not null references auth.users(id) on delete cascade,
  role houston.app_role not null,
  group_ids uuid[] not null default '{}'::uuid[],      -- grupos associados ao papel
  hospital_ids uuid[] not null default '{}'::uuid[],   -- hospitais associados ao papel
  setor_ids uuid[] null default '{}'::uuid[],
  primary key (user_id, role)
);
create index idx_user_roles_user_id on houston.user_roles(user_id);
create index idx_user_roles_group_ids on houston.user_roles using gin (group_ids);
create index idx_user_roles_hospital_ids on houston.user_roles using gin (hospital_ids);
create index idx_user_roles_setor_ids on houston.user_roles using gin (setor_ids);

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
    -- Insere usuário com papel padrão 'escalista' se não existir
    insert into houston.user_roles (user_id, role, group_ids, hospital_ids, setor_ids)
    values (uid, 'escalista', '{}'::uuid[], '{}'::uuid[], '{}'::uuid[])
    on conflict (user_id, role) do nothing;
    
    highest_role_text := 'escalista'; -- define papel padrão
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

grant usage on schema public to supabase_auth_admin, authenticated;
grant usage on schema houston to supabase_auth_admin, authenticated;

grant execute
  on function houston.custom_access_token_hook
  to supabase_auth_admin, authenticated;

revoke execute
  on function houston.custom_access_token_hook
  from authenticated, anon, public;


grant all
  on table houston.user_roles
  to supabase_auth_admin, authenticated;

create policy "Allow auth admin to read user roles" ON houston.user_roles
as permissive for select
to supabase_auth_admin, authenticated
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

  if user_role is null then
    return false; -- No role assigned
  end if;

  if user_role = 'administrador' then
    return true; -- Admin tem todas as permissões
  end if;


  

  select count(*)
  into bind_permissions
  from houston.role_permissions
  where role_permissions.permission = requested_permission
    and role_permissions.role = user_role;
  return bind_permissions > 0;
end;
$$ language plpgsql stable security definer set search_path = '';



grant execute
  on function houston.authorize(houston.app_permission)
  to supabase_auth_admin, authenticated;
revoke execute
  on function houston.authorize(houston.app_permission)
  from public;

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
as $$
declare
  user_id uuid := auth.uid();
  user_role houston.app_role;
  has_permission boolean := false;
begin
    select (auth.jwt() ->> 'user_role')::houston.app_role into user_role;

  if(user_role = 'gestor'::houston.app_role ) then
    select exists (
      select 1
      from houston.user_roles ur
      join houston.role_permissions rp
        on ur.role = rp.role
      where 
        ur.user_id = auth.uid()
        and ur.role = user_role
        and requested_permission = rp.permission
        and (group_id = any(ur.group_ids))
    ) into has_permission;
    return has_permission;
  end if;
  if(user_role = 'coordenador'::houston.app_role ) then
    select exists (
      select 1
      from houston.user_roles ur
      join houston.role_permissions rp
        on ur.role = rp.role
      where 
        ur.user_id = auth.uid()
        and ur.role = user_role
        and requested_permission = rp.permission
       and (
          cardinality(ur.hospital_ids) = 0  -- Se vazio, ignora validação
          OR hospital_id = any(ur.hospital_ids)
        )
        and (
          cardinality(ur.setor_ids) = 0  -- Se vazio, ignora validação
          OR setor_id = any(ur.setor_ids)
        )
    ) into has_permission;
    return has_permission;
  end if;
  if(user_role = 'escalista'::houston.app_role ) then
  select exists (
    select 1
    from houston.user_roles ur
    join houston.role_permissions rp
      on ur.role = rp.role
    where 
      ur.user_id = auth.uid()
      and ur.role = user_role
      and requested_permission = rp.permission
      and (hospital_id = any(ur.hospital_ids))
      and (setor_id = any(ur.setor_ids))
      and (group_id = any(ur.group_ids))
  ) into has_permission;

  return has_permission;
  else return houston.authorize('vagas.view');
  end if;
end;
$$;

grant all on  houston.role_permissions  to supabase_auth_admin, authenticated;




-- ❌💀☠️✋🏾🛑DEVE SER REMOVIDO ANTES E SUBIR PARA PRODUÇÃO ---- 

-- INSERT INTO houston.user_roles (user_id, role, group_ids, hospital_ids, setor_ids)
-- VALUES (
--   'a41308b5-a6ba-4a2a-81f7-e93fe962322b',
--   'escalista',
--   ARRAY['3e21c0a7-2002-43b1-9c78-181596ea5470']::uuid[],
--   ARRAY['0548cd47-0e14-44be-bdc7-2e5dc9907f23']::uuid[],
--   ARRAY['6beadfb3-861d-46fe-8515-16c0c2708204']::uuid[]
-- );