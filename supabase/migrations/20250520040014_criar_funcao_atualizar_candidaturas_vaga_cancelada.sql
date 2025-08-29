
-- Função para atualizar candidaturas quando uma vaga é cancelada
CREATE OR REPLACE FUNCTION public.atualizar_candidaturas_vaga_cancelada()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
    -- Verificar se o status da vaga foi alterado para 'cancelada'
    IF NEW.vagas_status = 'cancelada' AND (OLD.vagas_status IS NULL OR OLD.vagas_status != 'cancelada') THEN
        -- Atualizar todas as candidaturas pendentes associadas a esta vaga para 'REPROVADO'
        UPDATE public.candidaturas
        SET 
            candidatura_status = 'REPROVADO',
            candidaturas_updateat = now(),
            candidaturas_updateby = 'Sistema: Vaga Cancelada'
        WHERE 
            vagas_id = NEW.vagas_id
            AND candidatura_status = 'PENDENTE';
    END IF;
    
    RETURN NEW;
END;
$function$;
;
