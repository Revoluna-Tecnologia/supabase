/*
  Função: verificar_conflito_de_horario_rpc

  Descrição:
  Função RPC (Remote Procedure Call) para verificar conflitos de horário para um médico com base em uma data e hora específicas.
  Pode ser chamada diretamente pela sua aplicação ou API para validar um novo plantão antes de criá-lo.

  Parâmetros:
  - p_medico_id (uuid, opcional): O ID do médico. Se não for fornecido, a verificação não é realizada.
  - p_data (date, opcional): A data do novo plantão a ser verificado.
  - p_hora_inicio (time, opcional): A hora de início do novo plantão.
  - p_hora_fim (time, opcional): A hora de fim do novo plantão.

  Retorno:
  - Retorna um objeto JSON.
    - Se houver conflito: `{"conflito": true, "mensagem": "Detalhes do conflito..."}`
    - Se não houver conflito: `{"conflito": false, "mensagem": "Nenhum conflito encontrado."}`
    - Se os parâmetros forem insuficientes: `{"conflito": false, "mensagem": "Parâmetros insuficientes..."}`

  Observações:
  - A função itera sobre os plantões existentes e aprovados do médico para verificar sobreposição de horários.
*/
CREATE OR REPLACE FUNCTION public.verificar_conflito_candidatura_rpc(
    p_medico_id uuid DEFAULT NULL,
    p_data DATE DEFAULT NULL,
    p_hora_inicio TIME DEFAULT NULL,
    p_hora_fim TIME DEFAULT NULL
)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY INVOKER
 SET search_path TO 'public'
AS $function$
DECLARE
    plantao_existente RECORD;
    novo_intervalo_inicio timestamp;
    novo_intervalo_fim timestamp;
    plantao_existente_inicio timestamp;
    plantao_existente_fim timestamp;
BEGIN
    -- Validação de parâmetros
    IF p_medico_id IS NULL THEN
        RETURN jsonb_build_object('conflito', false, 'mensagem', 'Nenhum médico especificado, verificação de conflito não realizada.');
    END IF;

    IF p_data IS NULL OR p_hora_inicio IS NULL OR p_hora_fim IS NULL THEN
        RETURN jsonb_build_object('conflito', false, 'mensagem', 'Parâmetros de data, hora de início ou hora de fim insuficientes para verificar o conflito.');
    END IF;

    -- Calcular o timestamp do novo intervalo que queremos verificar
    novo_intervalo_inicio := p_data + p_hora_inicio;
    IF p_hora_fim <= p_hora_inicio THEN
        novo_intervalo_fim := (p_data + INTERVAL '1 day') + p_hora_fim;
    ELSE
        novo_intervalo_fim := p_data + p_hora_fim;
    END IF;

    -- Loop sobre todas as candidaturas aprovadas para o médico
    FOR plantao_existente IN
        SELECT
            v.vagas_data,
            v.vagas_horainicio,
            v.vagas_horafim
        FROM candidaturas c
        JOIN vagas v ON c.vagas_id = v.vagas_id
        WHERE c.medico_id = p_medico_id
          AND c.candidatura_status = 'APROVADO'
    LOOP
        -- Calcular o timestamp do plantão existente
        plantao_existente_inicio := plantao_existente.vagas_data + plantao_existente.vagas_horainicio;
        IF plantao_existente.vagas_horafim <= plantao_existente.vagas_horainicio THEN
            plantao_existente_fim := (plantao_existente.vagas_data + INTERVAL '1 day') + plantao_existente.vagas_horafim;
        ELSE
            plantao_existente_fim := plantao_existente.vagas_data + plantao_existente.vagas_horafim;
        END IF;

        -- Verificar se há sobreposição (conflito)
        IF (novo_intervalo_inicio, novo_intervalo_fim) OVERLAPS (plantao_existente_inicio, plantao_existente_fim) THEN
            RETURN jsonb_build_object(
                'conflito', true,
                'mensagem', 'Conflito de horário detectado com um plantão existente em ' ||
                            to_char(plantao_existente.vagas_data, 'DD/MM/YYYY') ||
                            ' das ' || to_char(plantao_existente.vagas_horainicio, 'HH24:MI') ||
                            ' às ' || to_char(plantao_existente.vagas_horafim, 'HH24:MI')
            );
        END IF;
    END LOOP;

    -- Se o loop terminar sem encontrar conflitos
    RETURN jsonb_build_object('conflito', false, 'mensagem', 'Nenhum conflito de horário encontrado.');

END;
$function$;