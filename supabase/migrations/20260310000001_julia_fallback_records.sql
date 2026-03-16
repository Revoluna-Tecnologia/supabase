-- Migration: julia_fallback_records
-- Epic 01 - Tarefa 1: Criar registros de fallback para vagas externas (Julia)
-- Grupo "Vagas Externas (Julia)" e setor "Não informado"

-- Grupo fallback para vagas externas
INSERT INTO grupos (id, nome, responsavel, telefone, email, created_at, updated_at)
VALUES (
  'a0000000-0000-0000-0000-000000000001',
  'Vagas Externas (Julia)',
  'Julia - Revoluna',
  NULL, NULL, NOW(), NOW()
)
ON CONFLICT (id) DO NOTHING;

-- Setor fallback para vagas sem setor definido
INSERT INTO setores (id, nome, created_at, updated_at)
VALUES (
  'a0000000-0000-0000-0000-000000000002',
  'Não informado',
  NOW(), NOW()
)
ON CONFLICT (id) DO NOTHING;
