do $$

begin
  drop policy if exists "Enable full acess to astronauta user" on public.grupo;
  drop policy if exists "Enable read to medico users" on public.grupo;
  drop policy if exists "Enable read to medico users" on public.grupo;
end $$;


create policy "grupo_read_all" on public.grupo
  for select
  to authenticated
  using (houston.authorize('grupo.view'));

  create policy "grupo_insert_own" on public.grupo
  for insert
  to authenticated
  with check (houston.authorize('grupo.add'));

  create policy "grupo_update_own" on public.grupo
  for update
  to authenticated
  using (houston.authorize('grupo.edit'))
  with check (houston.authorize('grupo.edit'));

  create policy "grupo_delete_own" on public.grupo
  for delete
  to authenticated
  using (houston.authorize('grupo.remove'));