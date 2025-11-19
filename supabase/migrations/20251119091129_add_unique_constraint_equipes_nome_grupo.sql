-- Migration: Add unique constraint for equipes nome per grupo
-- Data: 2025-11-19 09:11:29
-- Descrição: Garante que não possa haver equipes com o mesmo nome dentro do mesmo grupo,
--            mas permite o mesmo nome em grupos diferentes

-- ============================================================================
-- CONSTRAINT: Unicidade de nome de equipe por grupo
-- ============================================================================

-- Adiciona constraint única composta por (nome, grupo_id)
ALTER TABLE public.equipes
  ADD CONSTRAINT equipes_nome_grupo_id_key
  UNIQUE (nome, grupo_id);

-- Comentário explicativo
COMMENT ON CONSTRAINT equipes_nome_grupo_id_key ON public.equipes IS
  'Garante que cada equipe tenha um nome único dentro do seu grupo, mas permite nomes duplicados em grupos diferentes';
