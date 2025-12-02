-- Política para UPDATE com hierarquia
  CREATE POLICY "Allow users to update lower roles"
  ON houston.user_roles
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM houston.user_roles ur
      WHERE ur.user_id = auth.uid()
      AND (
        ur.role = 'administrador'
        OR (ur.role = 'moderador' AND houston.user_roles.role IN ('gestor', 'coordenador', 'escalista'))
        OR (ur.role = 'gestor' AND houston.user_roles.role IN ('coordenador', 'escalista'))
        OR (ur.role = 'coordenador' AND houston.user_roles.role = 'escalista')
      )
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM houston.user_roles ur
      WHERE ur.user_id = auth.uid()
      AND (
        ur.role = 'administrador'
        OR (ur.role = 'moderador' AND houston.user_roles.role IN ('gestor', 'coordenador', 'escalista'))
        OR (ur.role = 'gestor' AND houston.user_roles.role IN ('coordenador', 'escalista'))
        OR (ur.role = 'coordenador' AND houston.user_roles.role = 'escalista')
      )
    )
  );

  -- Política para INSERT com hierarquia
  CREATE POLICY "Allow users to insert lower roles"
  ON houston.user_roles
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM houston.user_roles ur
      WHERE ur.user_id = auth.uid()
      AND (
        ur.role = 'administrador'
        OR (ur.role = 'moderador' AND houston.user_roles.role IN ('gestor', 'coordenador', 'escalista'))
        OR (ur.role = 'gestor' AND houston.user_roles.role IN ('coordenador', 'escalista'))
        OR (ur.role = 'coordenador' AND houston.user_roles.role = 'escalista')
      )
    )
  );