-- Migration: julia_sync_control_tables
-- Epic 01 - Tarefa 3: Criar tabelas de controle de sync
-- Tabelas usadas pelo worker para rastrear sincronizacao e mapear IDs

-- Tabela principal de sync: relaciona vagas do Julia com vagas do App
CREATE TABLE IF NOT EXISTS vagas_sync_julia (
  julia_vaga_id UUID PRIMARY KEY,
  app_vaga_id UUID NOT NULL REFERENCES vagas(id) ON DELETE CASCADE,
  app_hospital_id UUID REFERENCES hospitais(id),
  app_escalista_ext_id UUID REFERENCES escalistas_externos(id),
  source_hash TEXT,
  synced_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(app_vaga_id)
);

CREATE INDEX IF NOT EXISTS idx_sync_julia_updated
  ON vagas_sync_julia(updated_at);

-- Tabela de mapeamento de especialidades entre Julia e App
CREATE TABLE IF NOT EXISTS sync_especialidades_map (
  julia_id UUID PRIMARY KEY,
  app_id UUID NOT NULL,
  nome TEXT NOT NULL,
  mapped_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de mapeamento de periodos entre Julia e App
CREATE TABLE IF NOT EXISTS sync_periodos_map (
  julia_id UUID PRIMARY KEY,
  app_id UUID NOT NULL,
  nome TEXT NOT NULL,
  mapped_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de mapeamento de setores entre Julia e App
CREATE TABLE IF NOT EXISTS sync_setores_map (
  julia_id UUID PRIMARY KEY,
  app_id UUID NOT NULL,
  nome TEXT NOT NULL,
  mapped_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS para todas as tabelas de sync (apenas service_role)
ALTER TABLE vagas_sync_julia ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_especialidades_map ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_periodos_map ENABLE ROW LEVEL SECURITY;
ALTER TABLE sync_setores_map ENABLE ROW LEVEL SECURITY;

-- Politicas para vagas_sync_julia
CREATE POLICY "vagas_sync_julia_select_policy"
  ON vagas_sync_julia FOR SELECT
  USING (
    current_setting('role', true) = 'service_role'
    OR current_setting('request.jwt.claims', true)::jsonb->>'role' = 'service_role'
  );

CREATE POLICY "vagas_sync_julia_insert_policy"
  ON vagas_sync_julia FOR INSERT
  WITH CHECK (
    current_setting('role', true) = 'service_role'
    OR current_setting('request.jwt.claims', true)::jsonb->>'role' = 'service_role'
  );

CREATE POLICY "vagas_sync_julia_update_policy"
  ON vagas_sync_julia FOR UPDATE
  USING (
    current_setting('role', true) = 'service_role'
    OR current_setting('request.jwt.claims', true)::jsonb->>'role' = 'service_role'
  );

CREATE POLICY "vagas_sync_julia_delete_policy"
  ON vagas_sync_julia FOR DELETE
  USING (
    current_setting('role', true) = 'service_role'
    OR current_setting('request.jwt.claims', true)::jsonb->>'role' = 'service_role'
  );

-- Politicas para sync_especialidades_map
CREATE POLICY "sync_especialidades_map_all_policy"
  ON sync_especialidades_map FOR ALL
  USING (
    current_setting('role', true) = 'service_role'
    OR current_setting('request.jwt.claims', true)::jsonb->>'role' = 'service_role'
  );

-- Politicas para sync_periodos_map
CREATE POLICY "sync_periodos_map_all_policy"
  ON sync_periodos_map FOR ALL
  USING (
    current_setting('role', true) = 'service_role'
    OR current_setting('request.jwt.claims', true)::jsonb->>'role' = 'service_role'
  );

-- Politicas para sync_setores_map
CREATE POLICY "sync_setores_map_all_policy"
  ON sync_setores_map FOR ALL
  USING (
    current_setting('role', true) = 'service_role'
    OR current_setting('request.jwt.claims', true)::jsonb->>'role' = 'service_role'
  );
