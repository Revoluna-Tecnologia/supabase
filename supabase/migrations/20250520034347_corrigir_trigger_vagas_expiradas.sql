
-- Migration para corrigir o comportamento do trigger de vagas expiradas
CREATE OR REPLACE FUNCTION public.atualizar_vagas_expiradas()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
    -- Se a vaga já passou da data de hoje E não está com status 'fechada', marcar como 'cancelada'
    IF NEW.vagas_data < CURRENT_DATE AND NEW.vagas_status != 'fechada' THEN
        NEW.vagas_status := 'cancelada';
    END IF;
    RETURN NEW;
END;
$function$;
;
