-- =============================
-- Policies para public.medicos_precadastro
-- Permissões: medicos_precadastro.view / add / edit / remove
-- =============================

-- APAGA AS POLITICAS ANTIGAS
do $$
begin
  drop policy if exists "Insert policy" on public.medicos_precadastro;
  drop policy if exists "Enable read access for all authenticated users" on public.medicos_precadastro;
  drop policy if exists "Update policy" on public.medicos_precadastro;
  drop policy if exists "Select policy" on public.medicos_precadastro;
end $$;
-- CRIA AS NOVAS POLITICAS
CREATE POLICY medicos_precadastro_select_rbac
ON public.medicos_precadastro
FOR SELECT
TO authenticated
-- USING (houston.authorize('medicos_precadastro.view'));
USING (true);  -- Permitido para todos os autenticados, controle via view     

CREATE POLICY medicos_precadastro_insert_rbac
ON public.medicos_precadastro
FOR INSERT
TO authenticated
WITH CHECK (houston.authorize('medicos_precadastro.add'));

CREATE POLICY medicos_precadastro_update_rbac
ON public.medicos_precadastro
FOR UPDATE
TO authenticated
USING (houston.authorize('medicos_precadastro.edit'))
WITH CHECK (houston.authorize('medicos_precadastro.edit'));

CREATE POLICY medicos_precadastro_delete_rbac
ON public.medicos_precadastro
FOR DELETE
TO authenticated
USING (houston.authorize('medicos_precadastro.remove'));


