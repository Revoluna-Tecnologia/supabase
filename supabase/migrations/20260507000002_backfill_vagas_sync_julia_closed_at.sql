-- =============================================================================
-- Migration: Backfill vagas_sync_julia.closed_at
-- Motivo: marcar linhas de sync cujas vagas do app ja estao fechadas, para que
--         a primeira execucao com filtro closed_at IS NULL nao reprocesse todo
--         o historico de fechamentos.
-- =============================================================================

BEGIN;

UPDATE public.vagas_sync_julia vs
SET closed_at = COALESCE(v.updated_at, NOW())
FROM public.vagas v
WHERE vs.app_vaga_id = v.id
  AND v.status = 'fechada'
  AND vs.closed_at IS NULL;

DO $$
DECLARE
  closed_count INT;
  open_count INT;
BEGIN
  SELECT COUNT(*) INTO closed_count
  FROM public.vagas_sync_julia
  WHERE closed_at IS NOT NULL;

  SELECT COUNT(*) INTO open_count
  FROM public.vagas_sync_julia
  WHERE closed_at IS NULL;

  RAISE NOTICE 'vagas_sync_julia closed_at backfill: closed=% open=%',
    closed_count,
    open_count;
END $$;

COMMIT;

