-- Migration: Corrigir função deletar_vagas_recorrencia e outras funções auxiliares
-- Data: 2025-10-31
-- Descrição: Corrige função de exclusão de vagas recorrentes e outras funções relacionadas
-- Issue: Múltiplas referências incorretas a colunas e tabelas

-- ============================================
-- 1. Função: deletar_vagas_recorrencia
-- ============================================

CREATE OR REPLACE FUNCTION public.deletar_vagas_recorrencia(
  p_recorrencia_id uuid,
  p_updateby uuid
)
RETURNS void
LANGUAGE plpgsql
AS $function$
DECLARE
  vaga RECORD;
BEGIN
  -- Loop através de todas as vagas da recorrência
  FOR vaga IN SELECT id FROM public.vagas WHERE recorrencia_id = p_recorrencia_id LOOP  -- CORRIGIDO: vagas_id → id
    -- Deleta benefícios
    DELETE FROM public.vagas_beneficios WHERE vaga_id = vaga.id;  -- CORRIGIDO: vagas_beneficio → vagas_beneficios, vagas_id → vaga_id, vaga.vagas_id → vaga.id

    -- Deleta requisitos
    DELETE FROM public.vagas_requisitos WHERE vaga_id = vaga.id;  -- CORRIGIDO: vagas_requisito → vagas_requisitos, vagas_id → vaga_id, vaga.vagas_id → vaga.id

    -- Deleta candidaturas
    DELETE FROM public.candidaturas WHERE vaga_id = vaga.id;  -- CORRIGIDO: vagas_id → vaga_id, vaga.vagas_id → vaga.id

    -- Deleta a vaga
    DELETE FROM public.vagas WHERE id = vaga.id;  -- CORRIGIDO: vagas_id → id, vaga.vagas_id → vaga.id
  END LOOP;

  -- Deleta a recorrência
  DELETE FROM public.vagas_recorrencias WHERE id = p_recorrencia_id;  -- CORRIGIDO: vagas_recorrencia → vagas_recorrencias, recorrencia_id → id

  RAISE NOTICE 'Recorrência % e todas as suas vagas foram deletadas', p_recorrencia_id;
END;
$function$;

-- ============================================
-- 2. Comentários de documentação
-- ============================================

COMMENT ON FUNCTION public.deletar_vagas_recorrencia(uuid, uuid) IS
'Função corrigida em 2025-10-31: Deleta todas as vagas de uma recorrência e suas dependências (benefícios, requisitos, candidaturas) e depois deleta a recorrência. Nomenclatura atualizada.';
