do $$
begin
  drop policy if exists "Enable full access to astronauta user" on public.escalistas;
  drop policy if exists "Enable read access for all authenticated users" on public.escalistas;

end $$;

create policy "escalista_read_all" on public.escalistas
  for select
  to authenticated
  using (houston.authorize('membros.view'));

  create policy "escalista_insert_own" on public.escalistas
  for insert
  to authenticated
  with check (houston.authorize('membros.add'));


  create policy "escalista_update_own" on public.escalistas
  for update
  to authenticated
  using (houston.authorize('membros.edit'))
  with check (houston.authorize('membros.edit'));

  create policy "escalista_delete_own" on public.escalistas
  for delete
  to authenticated
  using (houston.authorize('membros.remove'));
