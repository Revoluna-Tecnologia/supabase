

-- REMOVER POLITICA PARA ROLES PERMISSIONS
drop policy if exists "Allow auth admin to read user roles" on houston.user_roles;

create policy "read_user_role" on houston.user_roles
  for select
  to authenticated
  using (houston.authorize('roles.view'));

  create policy "insert_user_role" on houston.user_roles
  for insert
  to authenticated
  with check (houston.authorize('roles.add'));

  create policy "update_user_role" on houston.user_roles
  for update
  to authenticated
  using (houston.authorize('roles.edit'))
  with check (houston.authorize('roles.edit'));

  create policy "delete_user_role" on houston.user_roles
  for delete
  to authenticated
  using (houston.authorize('roles.remove'));

  alter table houston.user_roles enable row level security;


  -- AJUSTANDO ACESSO NA TABELA ROLE PERMISSION PARA SOMENTE O supabase_auth_admin

 create policy "read_role_permission" on houston.role_permissions
  for select
  to authenticated, supabase_admin
  using (auth.role() = 'supabase_auth_admin');

  create policy "insert_role_permission" on houston.role_permissions
  for insert
  to authenticated, supabase_admin 
  with check (auth.role() = 'supabase_auth_admin');

  create policy "update_role_permission" on houston.role_permissions
  for update
  to authenticated, supabase_admin
  using (auth.role() = 'supabase_auth_admin')
  with check (auth.role() = 'supabase_auth_admin');

  create policy "delete_role_permission" on houston.role_permissions
  for delete
  to authenticated, supabase_admin
  using (auth.role() = 'supabase_auth_admin');

  alter table houston.role_permissions enable row level security;