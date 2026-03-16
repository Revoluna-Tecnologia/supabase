-- Migration: julia_escalistas_externos
-- Epic 01 - Tarefa 2: Criar tabela escalistas_externos
-- Tabela separada para contatos extraidos dos grupos WhatsApp
-- Necessaria porque escalistas.id tem FK com auth.users e externos nao tem login

CREATE TABLE IF NOT EXISTS escalistas_externos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome VARCHAR NOT NULL DEFAULT 'Contato da vaga',
  telefone VARCHAR,
  grupo_id UUID REFERENCES grupos(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indice para busca por telefone
CREATE INDEX IF NOT EXISTS idx_escalistas_externos_telefone
  ON escalistas_externos(telefone);

-- Registro fallback generico
INSERT INTO escalistas_externos (id, nome, telefone, grupo_id)
VALUES (
  'b0000000-0000-0000-0000-000000000001',
  'Contato da vaga',
  '',
  'a0000000-0000-0000-0000-000000000001'
)
ON CONFLICT (id) DO NOTHING;

-- RLS: habilitar e criar politicas
ALTER TABLE escalistas_externos ENABLE ROW LEVEL SECURITY;

-- Politica de leitura: usuarios autenticados (igual a escalistas)
CREATE POLICY "escalistas_externos_select_policy"
  ON escalistas_externos
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM user_profile
      WHERE user_profile.id = (SELECT auth.uid())
    )
  );

-- INSERT/UPDATE/DELETE: service_role apenas (worker Julia)
