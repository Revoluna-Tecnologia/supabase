
-- PASSO 1: Remover todos os triggers atuais da tabela candidaturas
DROP TRIGGER IF EXISTS candidaturas_sync_medico_id ON public.candidaturas;
DROP TRIGGER IF EXISTS trigger_aprovacao_automatica_favoritos ON public.candidaturas;
DROP TRIGGER IF EXISTS tr_update_total_candidaturas ON public.candidaturas;
DROP TRIGGER IF EXISTS tr_update_total_plantoes ON public.candidaturas;
DROP TRIGGER IF EXISTS trg_atualizar_vagas_status ON public.candidaturas;

-- PASSO 2: Recriar triggers com nomenclatura organizada e ordem correta

-- BEFORE INSERT (ordem de execução é importante)
-- 1. Verificar conflitos de horário (PRIMEIRA verificação - bloqueia se necessário)
CREATE TRIGGER candidaturas_1_verificar_conflito_horario
    BEFORE INSERT ON public.candidaturas
    FOR EACH ROW
    EXECUTE FUNCTION verificar_conflito_antes_candidatura();

-- 2. Sincronizar campos medico_id e medicos_id
CREATE TRIGGER candidaturas_2_sync_medico_id
    BEFORE INSERT OR UPDATE ON public.candidaturas
    FOR EACH ROW
    EXECUTE FUNCTION sync_candidaturas_medico_id();

-- 3. Auto aprovar médicos favoritos
CREATE TRIGGER candidaturas_3_auto_aprovar_favoritos
    BEFORE INSERT ON public.candidaturas
    FOR EACH ROW
    EXECUTE FUNCTION aprovacao_automatica_favoritos();

-- AFTER INSERT/DELETE
-- 4. Atualizar contador de candidaturas na vaga
CREATE TRIGGER candidaturas_4_atualizar_contador_vagas
    AFTER INSERT OR DELETE ON public.candidaturas
    FOR EACH ROW
    EXECUTE FUNCTION update_total_candidaturas();

-- AFTER UPDATE
-- 5. Fechar vaga quando candidatura é aprovada manualmente
CREATE TRIGGER candidaturas_5_fechar_vaga_ao_aprovar
    AFTER UPDATE ON public.candidaturas
    FOR EACH ROW
    WHEN (NEW.candidatura_status = 'APROVADO')
    EXECUTE FUNCTION atualizar_vagas_status();

-- 6. Contar plantões do médico quando status muda
CREATE TRIGGER candidaturas_6_contar_plantoes_medico
    AFTER UPDATE ON public.candidaturas
    FOR EACH ROW
    WHEN (OLD.candidatura_status IS DISTINCT FROM NEW.candidatura_status)
    EXECUTE FUNCTION update_total_plantoes_medico();

-- PASSO 3: Adicionar comentários para documentação
COMMENT ON TRIGGER candidaturas_1_verificar_conflito_horario ON public.candidaturas 
IS 'Verifica conflitos de horário antes de permitir candidatura (executa PRIMEIRO)';

COMMENT ON TRIGGER candidaturas_2_sync_medico_id ON public.candidaturas 
IS 'Sincroniza campos medico_id e medicos_id para compatibilidade entre versões';

COMMENT ON TRIGGER candidaturas_3_auto_aprovar_favoritos ON public.candidaturas 
IS 'Aprova automaticamente médicos favoritos e fecha vaga';

COMMENT ON TRIGGER candidaturas_4_atualizar_contador_vagas ON public.candidaturas 
IS 'Atualiza contador vagas_totalcandidaturas na tabela vagas';

COMMENT ON TRIGGER candidaturas_5_fechar_vaga_ao_aprovar ON public.candidaturas 
IS 'Fecha vaga e reprova outros candidatos quando aprovação manual ocorre';

COMMENT ON TRIGGER candidaturas_6_contar_plantoes_medico ON public.candidaturas 
IS 'Atualiza contador de plantões do médico quando status muda para CONFIRMADO';
;
