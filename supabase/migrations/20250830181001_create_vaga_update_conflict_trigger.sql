
CREATE OR REPLACE FUNCTION public.handle_vaga_update_conflict()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
    approved_candidatura RECORD;
    new_shift_start_time timestamp;
    new_shift_end_time timestamp;
    conflicting_shift_exists BOOLEAN;
BEGIN
    -- Etapa 1: Verificar se a atualização envolve campos de horário e se existe uma candidatura APROVADA.
    IF (OLD.vagas_data IS DISTINCT FROM NEW.vagas_data OR
        OLD.vagas_horainicio IS DISTINCT FROM NEW.vagas_horainicio OR
        OLD.vagas_horafim IS DISTINCT FROM NEW.vagas_horafim)
    THEN
        -- Encontrar a candidatura aprovada para esta vaga, se houver.
        SELECT *
        INTO approved_candidatura
        FROM public.candidaturas
        WHERE vagas_id = NEW.vagas_id
          AND candidatura_status = 'APROVADO'
        LIMIT 1;

        -- Se não houver candidatura aprovada, não há conflito a verificar.
        IF NOT FOUND THEN
            RETURN NEW;
        END IF;

        -- Etapa 2: Calcular o novo intervalo de tempo da vaga.
        new_shift_start_time := NEW.vagas_data + NEW.vagas_horainicio;
        new_shift_end_time :=
            CASE
                WHEN NEW.vagas_horafim <= NEW.vagas_horainicio THEN (NEW.vagas_data + INTERVAL '1 day') + NEW.vagas_horafim
                ELSE NEW.vagas_data + NEW.vagas_horafim
            END;

        -- Etapa 3: Verificar se o médico da candidatura aprovada tem outro plantão conflitante.
        SELECT EXISTS (
            SELECT 1
            FROM candidaturas c
            JOIN vagas v ON c.vagas_id = v.vagas_id
            WHERE c.medico_id = approved_candidatura.medico_id
              AND c.candidatura_status = 'APROVADO'
              AND c.vagas_id <> NEW.vagas_id -- Exclui a vaga que está sendo atualizada.
              AND (
                    (v.vagas_data + v.vagas_horainicio,
                     CASE
                         WHEN v.vagas_horafim <= v.vagas_horainicio THEN (v.vagas_data + INTERVAL '1 day') + v.vagas_horafim
                         ELSE v.vagas_data + v.vagas_horafim
                     END
                    )
                    OVERLAPS (new_shift_start_time, new_shift_end_time)
                  )
        )
        INTO conflicting_shift_exists;

        -- Etapa 4: Se um conflito for encontrado, bloquear a atualização.
        IF conflicting_shift_exists THEN
            RAISE EXCEPTION 'CONFLITO DE HORÁRIO: A alteração do horário desta vaga cria um conflito com outro plantão já aprovado para o médico alocado.';
        END IF;
    END IF;

    -- Se não houver conflito, permite a atualização.
    RETURN NEW;
END;
$$;

-- Gatilho para a operação de UPDATE na tabela de vagas
CREATE TRIGGER check_conflict_on_vaga_update
BEFORE UPDATE ON public.vagas
FOR EACH ROW
EXECUTE FUNCTION public.handle_vaga_update_conflict();
