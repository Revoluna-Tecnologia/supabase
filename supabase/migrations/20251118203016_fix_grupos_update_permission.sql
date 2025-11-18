-- Migration: Fix grupos.update permission
-- Data: 2025-11-18 20:30:16
-- Descrição: Corrige a permissão grupos.update - adiciona para gestor, remove de escalista

-- ============================================================================
-- Adicionar grupos.update para gestor
-- ============================================================================

-- Gestor precisa da permissão grupos.update para atualizar grupos
INSERT INTO houston.role_permissions (role, permission)
VALUES ('gestor', 'grupos.update'::houston.app_permission)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- Remover grupos.update de escalista
-- ============================================================================

-- Escalista não deve ter permissão para atualizar grupos
-- (apenas gestores e superiores devem poder atualizar grupos)
DELETE FROM houston.role_permissions
WHERE role = 'escalista'
  AND permission = 'grupos.update'::houston.app_permission;
