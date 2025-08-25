
-- Trigger para atualizar candidaturas quando uma vaga é cancelada
CREATE TRIGGER trg_atualizar_candidaturas_vaga_cancelada
AFTER UPDATE OF vagas_status ON public.vagas
FOR EACH ROW
EXECUTE FUNCTION public.atualizar_candidaturas_vaga_cancelada();
;
