-- do $$

-- begin
--   drop policy if exists "Enable full acess to astronauta user" on public.grupos;
--   drop policy if exists "Enable read to medico users" on public.grupos;
--   drop policy if exists "Enable read to medico users" on public.grupos;
-- end $$;


-- create policy "grupo_read_all" on public.grupos
--   for select
--   to authenticated
--   using (houston.authorize('grupos.view'));

--   create policy "grupo_insert_own" on public.grupos
--   for insert
--   to authenticated
--   with check (houston.authorize('grupos.add'));

--   create policy "grupo_update_own" on public.grupos
--   for update
--   to authenticated
--   using (houston.authorize('grupos.edit'))
--   with check (houston.authorize('grupos.edit'));

--   create policy "grupo_delete_own" on public.grupos
--   for delete
--   to authenticated
--   using (houston.authorize('grupos.remove'));