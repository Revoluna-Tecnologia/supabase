-- Função para criar vagas recorrentes e candidaturas aprovadas se houver médico designado
CREATE OR REPLACE FUNCTION public.gerar_vagas_recorrentes(
  p_recorrencia_id uuid,
  p_vaga_base_id uuid,
  p_medico_id uuid DEFAULT NULL
) RETURNS void AS $$
DECLARE
  rec public.vagas_recorrencia%ROWTYPE;
  vaga_base public.vagas%ROWTYPE;
  dia date;
  dias integer[];
  i integer;
  nova_vaga_id uuid;
BEGIN
  -- Busca dados da recorrência e da vaga base
  SELECT * INTO rec FROM public.vagas_recorrencia WHERE recorrencia_id = p_recorrencia_id;
  SELECT * INTO vaga_base FROM public.vagas WHERE vagas_id = p_vaga_base_id;
  dias := rec.dias_semana;

  -- Loop de datas
  dia := rec.data_inicio;
  WHILE dia <= rec.data_fim LOOP
    IF array_position(dias, extract(dow from dia)::integer) IS NOT NULL THEN
      -- Cria nova vaga (copia dados da base, mas muda data e recorrencia_id)
      INSERT INTO public.vagas (
        vagas_createdate, vagas_hospital, vagas_data, vagas_periodo, vagas_horainicio, vagas_horafim, vagas_valor,
        vagas_datapagamento, vagas_formarecebimento, vagas_tipo, vagas_setor, vagas_escalista, vagas_updateat, vagas_status,
        vagas_updateby, vaga_especialidade, grupo_id, vagas_observacoes, vagas_totalcandidaturas, recorrencia_id
      ) VALUES (
        now(), vaga_base.vagas_hospital, dia, vaga_base.vagas_periodo, vaga_base.vagas_horainicio, vaga_base.vagas_horafim, vaga_base.vagas_valor,
        vaga_base.vagas_datapagamento, vaga_base.vagas_formarecebimento, vaga_base.vagas_tipo, vaga_base.vagas_setor, vaga_base.vagas_escalista, now(),
        CASE WHEN p_medico_id IS NOT NULL THEN 'fechada' ELSE 'aberta' END,
        vaga_base.vagas_updateby, vaga_base.vaga_especialidade, vaga_base.grupo_id, vaga_base.vagas_observacoes, 0, p_recorrencia_id
      ) RETURNING vagas_id INTO nova_vaga_id;
      -- Se houver médico designado, cria candidatura aprovada
      IF p_medico_id IS NOT NULL THEN
        INSERT INTO public.candidaturas (
          medicos_id, vagas_id, candidatura_status, candidatos_createdate, candidaturas_updateat, candidaturas_updateby, vagas_valor
        ) VALUES (
          p_medico_id, nova_vaga_id, 'APROVADO', now(), now(), vaga_base.vagas_updateby, vaga_base.vagas_valor
        );
      END IF;
    END IF;
    dia := dia + interval '1 day';
  END LOOP;
END;
$$ LANGUAGE plpgsql;;
