
-- PASSO 1: Remover trigger atual da tabela vagas
DROP TRIGGER IF EXISTS trg_atualizar_candidaturas_vaga_cancelada ON public.vagas;

-- PASSO 2: Recriar com nomenclatura organizada
-- vagas_1_reprovar_candidaturas_ao_cancelar
CREATE TRIGGER vagas_1_reprovar_candidaturas_ao_cancelar
    AFTER UPDATE OF vagas_status ON public.vagas
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_candidaturas_vaga_cancelada();

-- Comentário para documentar o trigger
COMMENT ON TRIGGER vagas_1_reprovar_candidaturas_ao_cancelar ON public.vagas 
IS 'Reprova automaticamente todas as candidaturas pendentes quando uma vaga é cancelada';
;
