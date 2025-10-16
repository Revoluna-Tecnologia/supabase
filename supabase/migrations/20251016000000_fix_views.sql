-- Migration: Fix remaining view deletion
-- Date: 2025-10-16

-- =====================================================
-- 1. Remover view vagas_completo que não foi deletada
-- =====================================================

DROP VIEW IF EXISTS "public"."vagas_completo" CASCADE;
