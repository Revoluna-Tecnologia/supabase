-- Corrigir conversão de tipo para candidaturas_updateby na função gerar_vagas_recorrentes
CREATE OR REPLACE FUNCTION public.gerar_vagas_recorrentes(
  p_recorrencia_id uuid, 
  p_vaga_base_id uuid, 
  p_medico_id uuid DEFAULT NULL::uuid, 
  p_created_by uuid DEFAULT NULL::uuid
)
RETURNS void
LANGUAGE plpgsql
AS $function$
DECLARE
  rec public.vagas_recorrencia%ROWTYPE;
  vaga_base public.vagas%ROWTYPE;
  dia date;
  dias integer[];
  i integer;
  nova_vaga_id uuid;
  now_brasil timestamp := (now() at time zone 'America/Sao_Paulo');
  audit_user uuid;
BEGIN
  -- Busca dados da recorrência e da vaga base
  SELECT * INTO rec FROM public.vagas_recorrencia WHERE recorrencia_id = p_recorrencia_id;
  SELECT * INTO vaga_base FROM public.vagas WHERE vagas_id = p_vaga_base_id;
  dias := rec.dias_semana;
  
  -- Determinar usuário para auditoria (prioridade: p_created_by, depois rec.created_by, depois vaga_base.vagas_updateby)
  audit_user := COALESCE(p_created_by, rec.created_by, vaga_base.vagas_updateby);

  -- Log do início da operação
  RAISE NOTICE 'Gerando vagas recorrentes para recorrência: % de % até %', p_recorrencia_id, rec.data_inicio, rec.data_fim;

  -- Loop de datas
  dia := rec.data_inicio + interval '1 day'; -- Pula o primeiro dia (já criado na vaga base)
  WHILE dia <= rec.data_fim LOOP
    IF array_position(dias, extract(dow from dia)::integer) IS NOT NULL THEN
      -- Cria nova vaga (copia dados da base, mas muda data e campos de auditoria)
      INSERT INTO public.vagas (
        vagas_createdate, vagas_hospital, vagas_data, vagas_periodo, vagas_horainicio, vagas_horafim, vagas_valor,
        vagas_datapagamento, vagas_formarecebimento, vagas_tipo, vagas_setor, vagas_escalista, vagas_updateat, vagas_status,
        vagas_updateby, vaga_especialidade, grupo_id, vagas_observacoes, vagas_totalcandidaturas, recorrencia_id
      ) VALUES (
        now_brasil, vaga_base.vagas_hospital, dia, vaga_base.vagas_periodo, vaga_base.vagas_horainicio, vaga_base.vagas_horafim, vaga_base.vagas_valor,
        vaga_base.vagas_datapagamento, vaga_base.vagas_formarecebimento, vaga_base.vagas_tipo, vaga_base.vagas_setor, vaga_base.vagas_escalista, now_brasil,
        CASE WHEN p_medico_id IS NOT NULL THEN 'fechada' ELSE 'aberta' END,
        audit_user,  -- CORRIGIDO: Usar usuário correto para auditoria
        vaga_base.vaga_especialidade, vaga_base.grupo_id, vaga_base.vagas_observacoes, 0, p_recorrencia_id
      ) RETURNING vagas_id INTO nova_vaga_id;
      
      -- Se houver médico designado, cria candidatura aprovada
      IF p_medico_id IS NOT NULL THEN
        INSERT INTO public.candidaturas (
          medicos_id, vagas_id, candidatura_status, candidatos_createdate, candidaturas_updateat, candidaturas_updateby, vagas_valor
        ) VALUES (
          p_medico_id, nova_vaga_id, 'APROVADO', now_brasil, now_brasil, 
          audit_user::text,  -- CORRIGIDO: Converter UUID para TEXT
          vaga_base.vagas_valor
        );
      END IF;
      
      RAISE NOTICE 'Vaga criada para dia %: %', dia, nova_vaga_id;
    END IF;
    dia := dia + interval '1 day';
  END LOOP;
  
  RAISE NOTICE 'Geração de vagas recorrentes concluída para recorrência: %', p_recorrencia_id;
END;
$function$;;
