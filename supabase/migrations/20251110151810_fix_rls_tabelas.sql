-- medicos
DROP POLICY IF EXISTS "medicos_update_rbac" ON "public"."medicos";
DROP POLICY IF EXISTS "medicos_update_policy" ON "public"."medicos";
CREATE POLICY "medicos_update_policy"
ON "public"."medicos"
AS PERMISSIVE
FOR UPDATE
TO authenticated
  USING (
  (((EXISTS ( SELECT 1
   FROM user_profile
  WHERE (user_profile.id = auth.uid()))) AND (id = auth.uid())) OR houston.authorize_simple('medicos.edit'::houston.app_permission))
  )
  WITH CHECK (
  (((EXISTS ( SELECT 1
   FROM user_profile
  WHERE (user_profile.id = auth.uid()))) AND (id = auth.uid())) OR houston.authorize_simple('medicos.edit'::houston.app_permission))
  );

DROP POLICY IF EXISTS "medicos_select_rbac" ON "public"."medicos";
DROP POLICY IF EXISTS "medicos_select_policy" ON "public"."medicos";
CREATE POLICY "medicos_select_policy"
on "public"."medicos"
as permissive
for select
to authenticated
  USING (
  (((EXISTS ( SELECT 1
   FROM user_profile
  WHERE (user_profile.id = auth.uid()))) AND (id = auth.uid())) OR houston.authorize_simple('medicos.view'::houston.app_permission))
  );


DROP POLICY IF EXISTS "medicos_insert_rbac" ON "public"."medicos";
DROP POLICY IF EXISTS "medicos_insert_policy" ON "public"."medicos";
create policy "medicos_insert_policy"
on "public"."medicos"
as permissive
for insert
to authenticated
with check ( -- Usuários na user_profile podem inserir somente com seu próprio ID
  (((EXISTS ( SELECT 1
   FROM user_profile
  WHERE (user_profile.id = auth.uid()))) AND (id = auth.uid())) OR houston.authorize_simple('medicos.add'::houston.app_permission))
  );

DROP POLICY IF EXISTS "medicos_delete_rbac" ON "public"."medicos";
DROP POLICY IF EXISTS "medicos_delete_policy" ON "public"."medicos";
create policy "medicos_delete_policy"
on "public"."medicos"
as permissive
for delete
to authenticated
  USING (
  (((EXISTS ( SELECT 1
   FROM user_profile
  WHERE (user_profile.id = auth.uid()))) AND (id = auth.uid())) OR houston.authorize_simple('medicos.remove'::houston.app_permission))
  );


-- escalistas

drop policy if exists "escalista_select_houston_rbac" on "public"."escalistas";
drop policy if exists "escalistas_select_policy" on "public"."escalistas";
create policy "escalistas_select_policy"
on "public"."escalistas"
as permissive
for select
to authenticated
using ( 
   EXISTS ( SELECT 1
   FROM user_profile
  WHERE (user_profile.id = auth.uid())) OR
   houston.authorize('membros.view'::houston.app_permission, NULL::uuid, NULL::uuid, grupo_id)
);

drop policy if exists "escalista_update_houston_rbac" on "public"."escalistas";
drop policy if exists "escalistas_update_policy" on "public"."escalistas";
create policy "escalistas_update_policy"
on "public"."escalistas"
as permissive
for update
to authenticated
using ( 
     houston.authorize('membros.edit'::houston.app_permission, NULL::uuid, NULL::uuid, grupo_id)
) with check ( 
     houston.authorize('membros.edit'::houston.app_permission, NULL::uuid, NULL::uuid, grupo_id)
);

drop policy if exists "escalista_insert_houston_rbac" on "public"."escalistas";
drop policy if exists "escalistas_insert_policy" on "public"."escalistas";
create policy "escalistas_insert_policy"
on "public"."escalistas"
as permissive
for insert
to authenticated
with check ( 
     houston.authorize('membros.add'::houston.app_permission, NULL::uuid, NULL::uuid, grupo_id)
);

drop policy if exists "escalista_delete_houston_rbac" on "public"."escalistas";
drop policy if exists "escalistas_delete_policy" on "public"."escalistas";
create policy "escalistas_delete_policy"
on "public"."escalistas"
as permissive
for delete
to authenticated
using (
   houston.authorize('membros.remove'::houston.app_permission, NULL::uuid, NULL::uuid, grupo_id)
);

-- grupos

drop policy if exists "grupo_delete_houston_rbac" on "public"."grupos";
drop policy if exists "grupos_delete_policy" on "public"."grupos";
create policy "grupos_delete_policy"
on "public"."grupos"
as permissive
for delete
to authenticated

using (  
   houston.authorize('grupos.remove'::houston.app_permission, NULL::uuid, NULL::uuid, id)
   );


drop policy if exists "grupo_insert_houston_rbac" on "public"."grupos";
drop policy if exists "grupos_insert_policy" on "public"."grupos";
create policy "grupos_insert_policy"
on "public"."grupos"
as permissive
for insert
to authenticated
with check (
  houston.authorize('grupos.add'::houston.app_permission, NULL::uuid, NULL::uuid, id)
);

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
  IF user_complete_data.role IN ('administrador', 'gestor') THEN
    RAISE LOG 'group_authorization RESULTADO: TRUE - role admin/gestor: %', user_complete_data.role;
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


drop policy if exists "grupo_select_houston_rbac" on "public"."grupos";
drop policy if exists "grupos_select_policy" on "public"."grupos";
create policy "grupos_select_policy"
on "public"."grupos"
as permissive
for select
to authenticated
using (
   EXISTS ( SELECT 1
   FROM user_profile
  WHERE (user_profile.id = auth.uid())) OR
     houston.group_authorization('grupos.view'::houston.app_permission, id)
     );

drop policy if exists "grupo_update_houston_rbac" on "public"."grupos";
drop policy if exists "grupos_update_policy" on "public"."grupos";
create policy "grupos_update_policy"
on "public"."grupos"
as permissive
for update
to authenticated
using (
   houston.authorize('grupos.edit'::houston.app_permission, NULL::uuid, NULL::uuid, id)
) with check (
   houston.authorize('grupos.edit'::houston.app_permission, NULL::uuid, NULL::uuid, id)
);

-- medicos_precadastro

drop policy if exists "medicos_precadastro_update_rbac" on "public"."medicos_precadastro";
drop policy if exists "medicos_precadastro_update_policy" on "public"."medicos_precadastro";
create policy "medicos_precadastro_update_policy"
on "public"."medicos_precadastro"
as permissive
for update
to authenticated
using (
     houston.authorize_simple('medicos_precadastro.edit'::houston.app_permission)
) with check (
     houston.authorize_simple('medicos_precadastro.edit'::houston.app_permission)
);

drop policy if exists "medicos_precadastro_select_rbac" on "public"."medicos_precadastro";
drop policy if exists "medicos_precadastro_select_policy" on "public"."medicos_precadastro";
create policy "medicos_precadastro_select_policy"
on "public"."medicos_precadastro"
as permissive
for select
to authenticated
using (
      EXISTS ( SELECT 1
   FROM user_profile
  WHERE (user_profile.id = auth.uid())) OR
   houston.authorize_simple('medicos_precadastro.view'::houston.app_permission)
);

drop policy if exists "medicos_precadastro_insert_rbac" on "public"."medicos_precadastro";
drop policy if exists "medicos_precadastro_insert_policy" on "public"."medicos_precadastro";
create policy "medicos_precadastro_insert_policy"
on "public"."medicos_precadastro"
as permissive
for insert
to authenticated
with check (
   houston.authorize_simple('medicos_precadastro.add'::houston.app_permission)
);

drop policy if exists "medicos_precadastro_delete_rbac" on "public"."medicos_precadastro";
drop policy if exists "medicos_precadastro_delete_policy" on "public"."medicos_precadastro";
create policy "medicos_precadastro_delete_policy"
on "public"."medicos_precadastro"
as permissive
for delete
to authenticated
using (
   houston.authorize_simple('medicos_precadastro.remove'::houston.app_permission)
);

-- vagas

drop policy if exists "vagas_delete_houston_rbac" on "public"."vagas";
drop policy if exists "vagas_delete_policy" on "public"."vagas";
create policy "vagas_delete_policy"
on "public"."vagas"
as permissive
for delete
to authenticated
using (
     houston.authorize('vagas.delete'::houston.app_permission, hospital_id, setor_id, grupo_id)
);

drop policy if exists "vagas_insert_houston_rbac" on "public"."vagas";
drop policy if exists "vagas_insert_policy" on "public"."vagas";
create policy "vagas_insert_policy"
on "public"."vagas"
as permissive
for insert
to authenticated
with check (
     houston.authorize('vagas.create'::houston.app_permission, hospital_id, setor_id, grupo_id)
);


drop policy if exists "vagas_select_houston_rbac" on "public"."vagas";
drop policy if exists "vagas_select_policy" on "public"."vagas";
create policy "vagas_select_policy"
on "public"."vagas"
as permissive
for select
to authenticated
using (
     EXISTS ( SELECT 1
   FROM user_profile
  WHERE (user_profile.id = auth.uid())) OR houston.authorize('vagas.view'::houston.app_permission, hospital_id, setor_id, grupo_id)
);

drop policy if exists "vagas_update_houston_rbac" on "public"."vagas";
drop policy if exists "vagas_update_policy" on "public"."vagas";
create policy "vagas_update_policy"
on "public"."vagas"
as permissive
for update
to authenticated
using (
houston.authorize('vagas.edit'::houston.app_permission, hospital_id, setor_id, grupo_id)
);

  
  
