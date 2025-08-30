
CREATE OR REPLACE FUNCTION public.handle_intelligent_candidatura_conflict()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
    -- Intervalo de tempo da candidatura que está sendo inserida/atualizada
    new_shift_start_time timestamp;
    new_shift_end_time timestamp;

    -- Variável para armazenar os detalhes de um plantão conflitante
    conflicting_shift RECORD;

    -- ID do usuário que está executando a ação
    current_user_id uuid := auth.uid();
BEGIN
    -- Etapa 1: Obter o intervalo de tempo da vaga associada à candidatura atual.
    SELECT
        v.vagas_data + v.vagas_horainicio,
        CASE
            WHEN v.vagas_horafim <= v.vagas_horainicio THEN (v.vagas_data + INTERVAL '1 day') + v.vagas_horafim
            ELSE v.vagas_data + v.vagas_horafim
        END
    INTO new_shift_start_time, new_shift_end_time
    FROM vagas v
    WHERE v.vagas_id = NEW.vagas_id;

    -- Se a vaga não for encontrada, algo está errado, mas não é responsabilidade deste gatilho.
    IF NOT FOUND THEN
        RETURN NEW;
    END IF;

    -- Etapa 2: Procurar por um plantão conflitante.
    -- Um conflito existe se houver uma candidatura 'APROVADA' para o mesmo médico
    -- cujo horário se sobrepõe ao da nova candidatura.
    SELECT
        c.candidaturas_id as candidatura_id,
        v.vagas_id,
        v.vagas_createdate,
        v.vagas_updateby
    INTO conflicting_shift
    FROM candidaturas c
    JOIN vagas v ON c.vagas_id = v.vagas_id
    WHERE c.medico_id = NEW.medico_id
      AND c.candidatura_status = 'APROVADO'
      AND c.candidaturas_id <> NEW.candidaturas_id -- Ignora a própria candidatura se for uma atualização
      AND (
            (v.vagas_data + v.vagas_horainicio,
             CASE
                 WHEN v.vagas_horafim <= v.vagas_horainicio THEN (v.vagas_data + INTERVAL '1 day') + v.vagas_horafim
                 ELSE v.vagas_data + v.vagas_horafim
             END
            )
            OVERLAPS (new_shift_start_time, new_shift_end_time)
          )
    LIMIT 1;

    -- Etapa 3: Analisar e tratar o conflito, se encontrado.
    IF FOUND THEN
        -- Se um conflito for encontrado, a operação deve ser bloqueada.
        RAISE EXCEPTION 'CONFLITO DE HORÁRIO: O médico já possui um plantão aprovado que conflita com este horário.';
    END IF;

    -- Etapa 4: Se nenhum conflito foi encontrado, permite a operação.
    RETURN NEW;
END;
$$;

-- Remove gatilhos antigos para evitar duplicidade de lógica
DROP TRIGGER IF EXISTS check_candidatura_conflict_on_insert ON public.candidaturas;
DROP TRIGGER IF EXISTS check_candidatura_conflict_on_update ON public.candidaturas;
DROP TRIGGER IF EXISTS verificar_conflito_antes_candidatura ON public.candidaturas;


-- Gatilho para a operação de INSERT
CREATE TRIGGER check_conflict_on_insert
BEFORE INSERT ON public.candidaturas
FOR EACH ROW
WHEN (NEW.candidatura_status = 'APROVADO')
EXECUTE FUNCTION public.handle_intelligent_candidatura_conflict();

-- Gatilho para a operação de UPDATE
CREATE TRIGGER check_conflict_on_update
BEFORE UPDATE ON public.candidaturas
FOR EACH ROW
WHEN (
    NEW.candidatura_status = 'APROVADO' AND
    (OLD.candidatura_status IS DISTINCT FROM NEW.candidatura_status OR OLD.vagas_id IS DISTINCT FROM NEW.vagas_id)
)
EXECUTE FUNCTION public.handle_intelligent_candidatura_conflict();
