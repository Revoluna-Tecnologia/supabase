-- Migration corrigida após padronização dos enums

-- Removendo e recriando policies de user_roles com os novos valores do enum
DROP POLICY IF EXISTS delete_user_role ON houston.user_roles;
DROP POLICY IF EXISTS insert_user_role ON houston.user_roles;
DROP POLICY IF EXISTS read_user_role ON houston.user_roles;
DROP POLICY IF EXISTS update_user_role ON houston.user_roles;

CREATE POLICY delete_user_role ON houston.user_roles AS PERMISSIVE FOR DELETE TO authenticated USING (houston.authorize_simple('roles.delete'::houston.app_permission));

CREATE POLICY insert_user_role ON houston.user_roles AS PERMISSIVE FOR INSERT TO authenticated WITH CHECK (houston.authorize_simple('roles.insert'::houston.app_permission));

CREATE POLICY read_user_role ON houston.user_roles AS PERMISSIVE FOR SELECT TO authenticated USING (houston.authorize_simple('roles.select'::houston.app_permission));

CREATE POLICY update_user_role ON houston.user_roles AS PERMISSIVE FOR UPDATE TO authenticated USING (houston.authorize_simple('roles.update'::houston.app_permission)) WITH CHECK (houston.authorize_simple('roles.update'::houston.app_permission));

-- Removendo e recriando policies de equipes
DROP POLICY IF EXISTS "Read policy" ON public.equipes;
CREATE POLICY "Read policy" ON public.equipes AS PERMISSIVE FOR SELECT TO authenticated USING (houston.authorize('grupos.select'::houston.app_permission, NULL::uuid, NULL::uuid, grupo_id)); 

-- Removendo e recriando policies de escalistas
DROP POLICY IF EXISTS escalistas_delete_policy ON public.escalistas;
DROP POLICY IF EXISTS escalistas_insert_policy ON public.escalistas;
DROP POLICY IF EXISTS escalistas_select_policy ON public.escalistas;
DROP POLICY IF EXISTS escalistas_update_policy ON public.escalistas;

CREATE POLICY escalistas_delete_policy ON public.escalistas AS PERMISSIVE FOR DELETE TO authenticated USING (houston.authorize('membros.delete'::houston.app_permission, NULL::uuid, NULL::uuid, grupo_id));

CREATE POLICY escalistas_insert_policy ON public.escalistas AS PERMISSIVE FOR INSERT TO authenticated WITH CHECK (houston.authorize('membros.insert'::houston.app_permission, NULL::uuid, NULL::uuid, grupo_id));

CREATE POLICY escalistas_select_policy ON public.escalistas AS PERMISSIVE FOR SELECT TO authenticated USING (((EXISTS ( SELECT 1
   FROM user_profile
  WHERE (user_profile.id = auth.uid()))) OR houston.authorize('membros.select'::houston.app_permission, NULL::uuid, NULL::uuid, grupo_id)));                                                                                                  
  
CREATE POLICY escalistas_update_policy ON public.escalistas AS PERMISSIVE FOR UPDATE TO authenticated USING (houston.authorize('membros.update'::houston.app_permission, NULL::uuid, NULL::uuid, grupo_id)) WITH CHECK (houston.authorize('membros.update'::houston.app_permission, NULL::uuid, NULL::uuid, grupo_id));

-- Removendo e recriando policies de grupos
DROP POLICY IF EXISTS grupos_delete_policy ON public.grupos;
DROP POLICY IF EXISTS grupos_insert_policy ON public.grupos;
DROP POLICY IF EXISTS grupos_select_policy ON public.grupos;
DROP POLICY IF EXISTS grupos_update_policy ON public.grupos;

CREATE POLICY grupos_delete_policy ON public.grupos AS PERMISSIVE FOR DELETE TO authenticated USING (houston.authorize('grupos.delete'::houston.app_permission, NULL::uuid, NULL::uuid, id));

CREATE POLICY grupos_insert_policy ON public.grupos AS PERMISSIVE FOR INSERT TO authenticated WITH CHECK (houston.authorize('grupos.insert'::houston.app_permission, NULL::uuid, NULL::uuid, id)); 

CREATE POLICY grupos_select_policy ON public.grupos AS PERMISSIVE FOR SELECT TO authenticated USING (((EXISTS ( SELECT 1
   FROM user_profile
  WHERE (user_profile.id = auth.uid()))) OR houston.group_authorization('grupos.select'::houston.app_permission, id)));
  
CREATE POLICY grupos_update_policy ON public.grupos AS PERMISSIVE FOR UPDATE TO authenticated USING (houston.authorize('grupos.update'::houston.app_permission, NULL::uuid, NULL::uuid, id)) WITH CHECK (houston.authorize('grupos.update'::houston.app_permission, NULL::uuid, NULL::uuid, id)); 

-- Removendo e recriando policies de medicos
DROP POLICY IF EXISTS medicos_delete_policy ON public.medicos;
DROP POLICY IF EXISTS medicos_insert_policy ON public.medicos;
DROP POLICY IF EXISTS medicos_select_policy ON public.medicos;
DROP POLICY IF EXISTS medicos_update_policy ON public.medicos;

CREATE POLICY medicos_delete_policy ON public.medicos AS PERMISSIVE FOR DELETE TO authenticated USING ((((EXISTS ( SELECT 1
   FROM user_profile
  WHERE (user_profile.id = auth.uid()))) AND (id = auth.uid())) OR houston.authorize_simple('medicos.delete'::houston.app_permission)));     
  
CREATE POLICY medicos_insert_policy ON public.medicos AS PERMISSIVE FOR INSERT TO authenticated WITH CHECK ((((EXISTS ( SELECT 1
   FROM user_profile
  WHERE (user_profile.id = auth.uid()))) AND (id = auth.uid())) OR houston.authorize_simple('medicos.insert'::houston.app_permission)));   
  
CREATE POLICY medicos_select_policy ON public.medicos AS PERMISSIVE FOR SELECT TO authenticated USING ((((EXISTS ( SELECT 1
   FROM user_profile
  WHERE (user_profile.id = auth.uid()))) AND (id = auth.uid())) OR houston.authorize_simple('medicos.select'::houston.app_permission)));       
  
CREATE POLICY medicos_update_policy ON public.medicos AS PERMISSIVE FOR UPDATE TO authenticated USING ((((EXISTS ( SELECT 1
   FROM user_profile
  WHERE (user_profile.id = auth.uid()))) AND (id = auth.uid())) OR houston.authorize_simple('medicos.update'::houston.app_permission))) WITH CHECK ((((EXISTS ( SELECT 1
   FROM user_profile
  WHERE (user_profile.id = auth.uid()))) AND (id = auth.uid())) OR houston.authorize_simple('medicos.update'::houston.app_permission)));                                                                                             

-- Removendo e recriando policies de medicos_precadastro
DROP POLICY IF EXISTS medicos_precadastro_delete_policy ON public.medicos_precadastro;
DROP POLICY IF EXISTS medicos_precadastro_insert_policy ON public.medicos_precadastro;
DROP POLICY IF EXISTS medicos_precadastro_select_policy ON public.medicos_precadastro;
DROP POLICY IF EXISTS medicos_precadastro_update_policy ON public.medicos_precadastro;

CREATE POLICY medicos_precadastro_delete_policy ON public.medicos_precadastro AS PERMISSIVE FOR DELETE TO authenticated USING (houston.authorize_simple('medicos_precadastro.delete'::houston.app_permission));                                                    
  
CREATE POLICY medicos_precadastro_insert_policy ON public.medicos_precadastro AS PERMISSIVE FOR INSERT TO authenticated WITH CHECK (houston.authorize_simple('medicos_precadastro.insert'::houston.app_permission));                                                  
  
CREATE POLICY medicos_precadastro_select_policy ON public.medicos_precadastro AS PERMISSIVE FOR SELECT TO authenticated USING (((EXISTS ( SELECT 1
   FROM user_profile
  WHERE (user_profile.id = auth.uid()))) OR houston.authorize_simple('medicos_precadastro.select'::houston.app_permission)));
                                                                                           
CREATE POLICY medicos_precadastro_update_policy ON public.medicos_precadastro AS PERMISSIVE FOR UPDATE TO authenticated USING (houston.authorize_simple('medicos_precadastro.update'::houston.app_permission)) WITH CHECK (houston.authorize_simple('medicos_precadastro.update'::houston.app_permission));

-- Removendo e recriando policies de vagas
DROP POLICY IF EXISTS vagas_delete_policy ON public.vagas;
DROP POLICY IF EXISTS vagas_insert_policy ON public.vagas;
DROP POLICY IF EXISTS vagas_select_policy ON public.vagas;
DROP POLICY IF EXISTS vagas_update_policy ON public.vagas;

CREATE POLICY vagas_delete_policy ON public.vagas AS PERMISSIVE FOR DELETE TO authenticated USING (houston.authorize('vagas.delete'::houston.app_permission, hospital_id, setor_id, grupo_id));

CREATE POLICY vagas_insert_policy ON public.vagas AS PERMISSIVE FOR INSERT TO authenticated WITH CHECK (houston.authorize('vagas.insert'::houston.app_permission, hospital_id, setor_id, grupo_id));

CREATE POLICY vagas_select_policy ON public.vagas AS PERMISSIVE FOR SELECT TO authenticated USING (((EXISTS ( SELECT 1
   FROM user_profile
  WHERE (user_profile.id = auth.uid()))) OR houston.authorize('vagas.select'::houston.app_permission, hospital_id, setor_id, grupo_id)));           
  
CREATE POLICY vagas_update_policy ON public.vagas AS PERMISSIVE FOR UPDATE TO authenticated USING (houston.authorize('vagas.update'::houston.app_permission, hospital_id, setor_id, grupo_id));