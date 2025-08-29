-- Corrigir função gerar_vagas_recorrentes para usar medico_id
CREATE OR REPLACE FUNCTION public.gerar_vagas_recorrentes(p_recorrencia_id uuid, p_vaga_base_id uuid, p_medico_id uuid DEFAULT NULL::uuid, p_created_by uuid DEFAULT NULL::uuid)
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
          medico_id, vagas_id, candidatura_status, candidatos_createdate, candidaturas_updateat, candidaturas_updateby, vagas_valor
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
$function$;

-- Corrigir função editar_vagas_recorrencia para usar medico_id
CREATE OR REPLACE FUNCTION public.editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid)
RETURNS void
LANGUAGE plpgsql
AS $function$
DECLARE
  now_brasil timestamp := (now() at time zone 'America/Sao_Paulo');
  vaga RECORD;
  vagas_atualizadas integer := 0;
  novo_medico_id uuid;
  candidatura_existente RECORD;
BEGIN
  -- Log do início da operação
  RAISE NOTICE 'Iniciando edição de vagas da recorrência: %', p_recorrencia_id;
  
  -- Extrair médico_id se presente
  novo_medico_id := CASE WHEN (p_update ? 'medico_id') THEN (p_update->>'medico_id')::uuid ELSE NULL END;
  
  FOR vaga IN SELECT * FROM public.vagas WHERE recorrencia_id = p_recorrencia_id LOOP
    -- Atualizar dados da vaga
    UPDATE public.vagas SET
      vagas_hospital = COALESCE((p_update->>'vagas_hospital')::uuid, vagas_hospital),
      vagas_data = COALESCE((p_update->>'vagas_data')::date, vagas_data),
      vagas_periodo = COALESCE((p_update->>'vagas_periodo')::uuid, vagas_periodo),
      vagas_horainicio = COALESCE((p_update->>'vagas_horainicio')::time, vagas_horainicio),
      vagas_horafim = COALESCE((p_update->>'vagas_horafim')::time, vagas_horafim),
      vagas_valor = COALESCE((p_update->>'vagas_valor')::integer, vagas_valor),
      vagas_datapagamento = COALESCE((p_update->>'vagas_datapagamento')::date, vagas_datapagamento),
      vagas_formarecebimento = COALESCE((p_update->>'vagas_formarecebimento')::uuid, vagas_formarecebimento),
      vagas_tipo = COALESCE((p_update->>'vagas_tipo')::uuid, vagas_tipo),
      vagas_observacoes = COALESCE((p_update->>'vagas_observacoes'), vagas_observacoes),
      vagas_setor = COALESCE((p_update->>'vagas_setor')::uuid, vagas_setor),
      vagas_escalista = COALESCE((p_update->>'vagas_escalista')::uuid, vagas_escalista),
      vaga_especialidade = COALESCE((p_update->>'vaga_especialidade')::uuid, vaga_especialidade),
      grupo_id = COALESCE((p_update->>'grupo_id')::uuid, grupo_id),
      -- ATUALIZAR STATUS DA VAGA baseado no médico designado
      vagas_status = CASE 
        WHEN (p_update ? 'medico_id') THEN 
          CASE WHEN novo_medico_id IS NOT NULL THEN 'fechada' ELSE 'aberta' END
        ELSE vagas_status 
      END,
      -- CAMPOS DE AUDITORIA - SEMPRE ATUALIZADOS
      vagas_updateat = now_brasil,
      vagas_updateby = p_updateby
    WHERE vagas_id = vaga.vagas_id;
    
    vagas_atualizadas := vagas_atualizadas + 1;
    
    -- Gerenciar candidaturas quando médico é especificado
    IF (p_update ? 'medico_id') THEN
      IF novo_medico_id IS NOT NULL THEN
        -- Médico designado: verificar se já existe candidatura aprovada
        SELECT * INTO candidatura_existente 
        FROM public.candidaturas 
        WHERE vagas_id = vaga.vagas_id AND candidatura_status = 'APROVADO'
        LIMIT 1;
        
        IF candidatura_existente.candidaturas_id IS NOT NULL THEN
          -- Atualizar candidatura existente
          UPDATE public.candidaturas SET
            medico_id = novo_medico_id,
            candidaturas_updateat = now_brasil,
            candidaturas_updateby = p_updateby::text
          WHERE candidaturas_id = candidatura_existente.candidaturas_id;
          
          RAISE NOTICE 'Candidatura atualizada para vaga: % (candidatura: %)', vaga.vagas_id, candidatura_existente.candidaturas_id;
        ELSE
          -- Criar nova candidatura aprovada
          INSERT INTO public.candidaturas (
            medico_id, vagas_id, candidatura_status, candidatos_createdate, candidaturas_updateat, candidaturas_updateby, vagas_valor
          ) VALUES (
            novo_medico_id, vaga.vagas_id, 'APROVADO', now_brasil, now_brasil, p_updateby::text, vaga.vagas_valor
          );
          
          RAISE NOTICE 'Nova candidatura aprovada criada para vaga: %', vaga.vagas_id;
        END IF;
      ELSE
        -- Médico removido: remover candidaturas aprovadas
        DELETE FROM public.candidaturas 
        WHERE vagas_id = vaga.vagas_id AND candidatura_status = 'APROVADO';
        
        RAISE NOTICE 'Candidaturas aprovadas removidas da vaga: %', vaga.vagas_id;
      END IF;
    END IF;
  END LOOP;
  
  -- Log do resultado
  RAISE NOTICE 'Edição concluída. % vagas atualizadas para recorrência: %', vagas_atualizadas, p_recorrencia_id;
  
  -- Verificar se alguma vaga foi atualizada
  IF vagas_atualizadas = 0 THEN
    RAISE EXCEPTION 'Nenhuma vaga encontrada para a recorrência: %', p_recorrencia_id;
  END IF;
END;
$function$;;
