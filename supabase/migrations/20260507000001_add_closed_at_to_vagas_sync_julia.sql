-- =============================================================================
-- Migration: Add closed_at to vagas_sync_julia
-- Motivo: rastrear quais vagas sincronizadas pela Julia ja foram fechadas no app.
--         Isso permite que get_sync_state retorne apenas linhas abertas no caminho
--         quente do worker, evitando reprocessar fechamentos antigos a cada sync.
-- =============================================================================

BEGIN;

ALTER TABLE public.vagas_sync_julia
  ADD COLUMN IF NOT EXISTS closed_at TIMESTAMPTZ NULL;

CREATE INDEX IF NOT EXISTS vagas_sync_julia_open_idx
  ON public.vagas_sync_julia (julia_vaga_id)
  WHERE closed_at IS NULL;

COMMENT ON COLUMN public.vagas_sync_julia.closed_at IS
  'Set by julia-sync close_vaga / close_vagas_bulk when the corresponding app vaga is closed. NULL = still open.';

COMMIT;

