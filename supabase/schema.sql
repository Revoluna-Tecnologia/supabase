

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";






COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "http" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pg_trgm" WITH SCHEMA "public";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."app_permission" AS ENUM (
    'channels.delete',
    'messages.delete'
);


ALTER TYPE "public"."app_permission" OWNER TO "postgres";


CREATE TYPE "public"."app_role" AS ENUM (
    'admin',
    'moderator'
);


ALTER TYPE "public"."app_role" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."aprovacao_automatica_favoritos"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Verifica se existe uma relação de favorito entre o médico e o grupo da vaga
    IF EXISTS (
        SELECT 1 
        FROM medicos_favoritos mf
        INNER JOIN vagas v ON v.id = NEW.vagas_id
        WHERE mf.medico_id = NEW.medico_id 
        AND mf.grupo_id = v.grupo_id
    ) THEN
        -- Se o médico é favorito do grupo, aprova automaticamente
        NEW.status := 'APROVADO';
        NEW.data_confirmacao := CURRENT_DATE;
        NEW.updated_at := NOW();
        NEW.updated_by := auth.uid();
        
        -- Fechar a vaga
        UPDATE vagas
        SET status = 'fechada',
            updated_at = NOW(),
            updated_by = auth.uid()
        WHERE id = NEW.vagas_id;
        
        -- Reprovar outras candidaturas pendentes
        UPDATE candidaturas
        SET status = 'REPROVADO',
            updated_at = NOW(),
            updated_by = auth.uid()
        WHERE vagas_id = NEW.vagas_id
        AND id != NEW.id;
        
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."aprovacao_automatica_favoritos"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."aprovar_todos_documentos"("p_carteira_id" "uuid", "p_user_id" "uuid") RETURNS TABLE("success" boolean, "message" "text", "documentos_atualizados" integer)
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_count INTEGER := 0;
BEGIN
    -- Aprovar cada documento
    UPDATE carteira_digital
    SET
        carteira_diploma_status = true,
        carteira_diploma_updatedate = NOW(),
        carteira_diploma_updateuserid = p_user_id,
        
        carteira_crm_status = true,
        carteira_crm_updatedate = NOW(),
        carteira_crm_updateuserid = p_user_id,
        
        carteira_cpf_status = true,
        carteira_cpf_updatedate = NOW(),
        carteira_cpf_updateuserid = p_user_id,
        
        carteira_rg_status = true,
        carteira_rg_updatedate = NOW(),
        carteira_rg_updateuserid = p_user_id,
        
        carteira_especializacaodiploma_status = true,
        carteira_especializacaodiploma_updatedate = NOW(),
        carteira_especializacaodiploma_updateuserid = p_user_id,
        
        carteira_anuidadecrm_status = true,
        carteira_anuidadecrm_updatedate = NOW(),
        carteira_anuidadecrm_updateuserid = p_user_id,
        
        carteira_eticoprofissional_status = true,
        carteira_eticoprofissional_updatedate = NOW(),
        carteira_eticoprofissional_updateuserid = p_user_id,
        
        carteira_comprovanteresidencia_status = true,
        carteira_comprovanteresidencia_updatedate = NOW(),
        carteira_comprovanteresidencia_updateuserid = p_user_id,
        
        carteira_foto_status = true,
        carteira_foto_updatedate = NOW(),
        carteira_foto_updateuserid = p_user_id,
        
        carteira_comprovantevacina_status = true,
        carteira_comprovantevacina_updatedate = NOW(),
        carteira_comprovantevacina_updateuserid = p_user_id,
        
        carteira_status = true
    WHERE carteira_id = p_carteira_id
    RETURNING 10 INTO v_count;

    RETURN QUERY
    SELECT 
        v_count > 0,
        CASE 
            WHEN v_count > 0 THEN 'Todos os documentos foram aprovados com sucesso'
            ELSE 'Carteira não encontrada'
        END,
        v_count;
END;
$$;


ALTER FUNCTION "public"."aprovar_todos_documentos"("p_carteira_id" "uuid", "p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."aretheytester"("user_id" "text") RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$BEGIN
    RETURN user_id = ANY(ARRAY[
        '276f5e38-82bc-445b-940c-20ee81454b7c'
    ]);
END;$$;


ALTER FUNCTION "public"."aretheytester"("user_id" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."atualizar_candidaturas_vaga_cancelada"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
BEGIN
    -- Verificar se o status da vaga foi alterado para 'cancelada'
    IF NEW.status = 'cancelada' AND (OLD.status IS NULL OR OLD.status != 'cancelada') THEN
        -- Atualizar todas as candidaturas pendentes associadas a esta vaga para 'REPROVADO'
        UPDATE public.candidaturas
        SET 
            status = 'REPROVADO',
            updated_at = now(),
            updated_by = 'Sistema: Vaga Cancelada'
        WHERE 
            vagas_id = NEW.id
            AND status = 'PENDENTE';
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."atualizar_candidaturas_vaga_cancelada"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."atualizar_status_vagas_expiradas"() RETURNS TABLE("vagas_atualizadas_canceladas" integer, "vagas_atualizadas_fechadas" integer, "candidaturas_reprovadas" integer)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    vagas_canceladas INTEGER := 0;
    vagas_fechadas INTEGER := 0;
    candidaturas_reprovadas_count INTEGER := 0;
BEGIN
    -- 1. Atualizar vagas expiradas SEM candidaturas para 'cancelada'
    UPDATE vagas 
    SET 
        vagas_status = 'cancelada',
        vagas_updateat = NOW(),
        vagas_updateby = 'ada3a79a-6437-4e27-9e22-40c08c36c59b'
    WHERE 
        vagas_data < CURRENT_DATE 
        AND vagas_status = 'aberta'
        AND vagas_totalcandidaturas = 0
        AND NOT EXISTS (
            SELECT 1 FROM candidaturas c 
            WHERE c.vagas_id = vagas.vagas_id
        );
    
    GET DIAGNOSTICS vagas_canceladas = ROW_COUNT;
    
    -- 2. Atualizar vagas expiradas COM candidaturas para 'fechada'
    UPDATE vagas 
    SET 
        vagas_status = 'fechada',
        vagas_updateat = NOW(),
        vagas_updateby = 'ada3a79a-6437-4e27-9e22-40c08c36c59b'
    WHERE 
        vagas_data < CURRENT_DATE 
        AND vagas_status = 'aberta'
        AND (
            vagas_totalcandidaturas > 0 
            OR EXISTS (
                SELECT 1 FROM candidaturas c 
                WHERE c.vagas_id = vagas.vagas_id
            )
        );
    
    GET DIAGNOSTICS vagas_fechadas = ROW_COUNT;
    
    -- 3. Reprovar candidaturas pendentes de vagas expiradas
    UPDATE candidaturas 
    SET 
        candidatura_status = 'REPROVADO',
        candidaturas_updateat = NOW(),
        candidaturas_updateby = 'Sistema - Vaga expirada'
    WHERE 
        candidatura_status = 'PENDENTE'
        AND vagas_id IN (
            SELECT vagas_id 
            FROM vagas 
            WHERE vagas_data < CURRENT_DATE 
            AND vagas_status IN ('fechada', 'cancelada')
        );
    
    GET DIAGNOSTICS candidaturas_reprovadas_count = ROW_COUNT;
    
    -- Retornar resultados
    RETURN QUERY SELECT 
        vagas_canceladas,
        vagas_fechadas,
        candidaturas_reprovadas_count;
END;
$$;


ALTER FUNCTION "public"."atualizar_status_vagas_expiradas"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."atualizar_urls_documentos"("p_carteira_id" "uuid", "p_base_url" character varying, "p_user_id" "uuid") RETURNS TABLE("documento" character varying, "url_antiga" character varying, "url_nova" character varying, "sucesso" boolean)
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_medico_id UUID;
    v_medico_nome VARCHAR;
BEGIN
    -- Obter informações do médico
    SELECT cd.medicos_id, (m.medico_primeironome || ' ' || m.medico_sobrenome)
    INTO v_medico_id, v_medico_nome
    FROM carteira_digital cd
    JOIN medicos m ON m.medico_id = cd.medicos_id
    WHERE cd.carteira_id = p_carteira_id;

    -- Criar tabela temporária para resultados
    CREATE TEMP TABLE IF NOT EXISTS temp_resultados (
        documento VARCHAR,
        url_antiga VARCHAR,
        url_nova VARCHAR,
        sucesso BOOLEAN
    ) ON COMMIT DROP;

    -- Atualizar cada documento que está como AGUARDANDO
    -- Diploma
    INSERT INTO temp_resultados
    SELECT 
        'Diploma',
        carteira_diploma,
        CASE 
            WHEN carteira_diploma = 'AGUARDANDO' THEN 
                p_base_url || '/documentos/' || v_medico_id || '/diploma.pdf'
            ELSE carteira_diploma
        END,
        carteira_diploma = 'AGUARDANDO'
    FROM carteira_digital
    WHERE carteira_id = p_carteira_id
    AND carteira_diploma = 'AGUARDANDO';

    -- CRM
    INSERT INTO temp_resultados
    SELECT 
        'CRM',
        carteira_crm,
        CASE 
            WHEN carteira_crm = 'AGUARDANDO' THEN 
                p_base_url || '/documentos/' || v_medico_id || '/crm.pdf'
            ELSE carteira_crm
        END,
        carteira_crm = 'AGUARDANDO'
    FROM carteira_digital
    WHERE carteira_id = p_carteira_id
    AND carteira_crm = 'AGUARDANDO';

    -- Atualizar os documentos no banco
    UPDATE carteira_digital
    SET
        carteira_diploma = CASE WHEN carteira_diploma = 'AGUARDANDO' 
            THEN p_base_url || '/documentos/' || v_medico_id || '/diploma.pdf' 
            ELSE carteira_diploma END,
        carteira_crm = CASE WHEN carteira_crm = 'AGUARDANDO' 
            THEN p_base_url || '/documentos/' || v_medico_id || '/crm.pdf' 
            ELSE carteira_crm END,
        carteira_cpf = CASE WHEN carteira_cpf = 'AGUARDANDO' 
            THEN p_base_url || '/documentos/' || v_medico_id || '/cpf.pdf' 
            ELSE carteira_cpf END,
        carteira_rg = CASE WHEN carteira_rg = 'AGUARDANDO' 
            THEN p_base_url || '/documentos/' || v_medico_id || '/rg.pdf' 
            ELSE carteira_rg END,
        carteira_especializacaodiploma = CASE WHEN carteira_especializacaodiploma = 'AGUARDANDO' 
            THEN p_base_url || '/documentos/' || v_medico_id || '/especializacao.pdf' 
            ELSE carteira_especializacaodiploma END,
        carteira_anuidadecrm = CASE WHEN carteira_anuidadecrm = 'AGUARDANDO' 
            THEN p_base_url || '/documentos/' || v_medico_id || '/anuidade.pdf' 
            ELSE carteira_anuidadecrm END,
        carteira_eticoprofissional = CASE WHEN carteira_eticoprofissional = 'AGUARDANDO' 
            THEN p_base_url || '/documentos/' || v_medico_id || '/etico.pdf' 
            ELSE carteira_eticoprofissional END,
        carteira_comprovanteresidencia = CASE WHEN carteira_comprovanteresidencia = 'AGUARDANDO' 
            THEN p_base_url || '/documentos/' || v_medico_id || '/residencia.pdf' 
            ELSE carteira_comprovanteresidencia END,
        carteira_foto = CASE WHEN carteira_foto = 'AGUARDANDO' 
            THEN p_base_url || '/documentos/' || v_medico_id || '/foto.jpg' 
            ELSE carteira_foto END,
        carteira_comprovantevacina = CASE WHEN carteira_comprovantevacina = 'AGUARDANDO' 
            THEN p_base_url || '/documentos/' || v_medico_id || '/vacina.pdf' 
            ELSE carteira_comprovantevacina END
    WHERE carteira_id = p_carteira_id;

    -- Retornar resultados
    RETURN QUERY
    SELECT * FROM temp_resultados;
END;
$$;


ALTER FUNCTION "public"."atualizar_urls_documentos"("p_carteira_id" "uuid", "p_base_url" character varying, "p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."atualizar_vagas_status"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Atualiza o status da vaga para 'fechada' quando a candidatura for 'APROVADO'
    IF NEW.status = 'APROVADO' THEN
        -- 1. Atualiza o status da vaga para 'fechada'
        UPDATE vagas
        SET status = 'fechada'
        WHERE id = NEW.vagas_id;
        
        -- 2. Reprova todas as demais candidaturas para a mesma vaga
        UPDATE candidaturas
        SET status = 'REPROVADO',
            updated_at = NOW(),
            updated_by = 'SISTEMA_AUTO_REPROVACAO'
        WHERE vagas_id = NEW.vagas_id
        AND id != NEW.id;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."atualizar_vagas_status"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calcular_dias_pagamento"("data_plantao" "date", "data_pagamento" "date") RETURNS integer
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    IF data_pagamento IS NULL OR data_plantao IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN (data_pagamento - data_plantao);
END;
$$;


ALTER FUNCTION "public"."calcular_dias_pagamento"("data_plantao" "date", "data_pagamento" "date") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calcular_distancia"("lat1" numeric, "lon1" numeric, "lat2" numeric, "lon2" numeric) RETURNS numeric
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    dlat DECIMAL;
    dlon DECIMAL;
    a DECIMAL;
    c DECIMAL;
    r DECIMAL := 6371000; -- Raio da Terra em metros
BEGIN
    dlat := radians(lat2 - lat1);
    dlon := radians(lon2 - lon1);
    
    a := sin(dlat/2) * sin(dlat/2) + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon/2) * sin(dlon/2);
    c := 2 * atan2(sqrt(a), sqrt(1-a));
    
    RETURN r * c;
END;
$$;


ALTER FUNCTION "public"."calcular_distancia"("lat1" numeric, "lon1" numeric, "lat2" numeric, "lon2" numeric) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."cleanup_medicos_precadastro"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- PRIMEIRO: Atualizar registros em equipes_medicos que referenciam pré-cadastros
  UPDATE equipes_medicos 
  SET 
    medico_id = NEW.medico_id,
    medico_precadastro_id = NULL
  WHERE medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'
    AND medico_precadastro_id IN (
      SELECT id FROM medicos_precadastro 
      WHERE (crm = NEW.crm AND estado = NEW.estado)
         OR (
           NEW.cpf IS NOT NULL 
           AND cpf IS NOT NULL 
           AND REPLACE(REPLACE(REPLACE(cpf, '.', ''), '-', ''), ' ', '') = 
               REPLACE(REPLACE(REPLACE(NEW.cpf, '.', ''), '-', ''), ' ', '')
         )
    );
    
  -- SEGUNDO: Atualizar registros em candidaturas que referenciam pré-cadastros
  UPDATE candidaturas 
  SET 
    medico_id = NEW.medico_id,
    medico_precadastro_id = NULL
  WHERE medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'
    AND medico_precadastro_id IN (
      SELECT id FROM medicos_precadastro 
      WHERE (crm = NEW.crm AND estado = NEW.estado)
         OR (
           NEW.cpf IS NOT NULL 
           AND cpf IS NOT NULL 
           AND REPLACE(REPLACE(REPLACE(cpf, '.', ''), '-', ''), ' ', '') = 
               REPLACE(REPLACE(REPLACE(NEW.cpf, '.', ''), '-', ''), ' ', '')
         )
    );

  -- TERCEIRO: Deletar pré-cadastros com mesmo CRM + estado (agora que as referências foram atualizadas)
  DELETE FROM medicos_precadastro 
  WHERE crm = NEW.crm 
    AND estado = NEW.estado;
  
  -- QUARTO: Deletar pré-cadastros com mesmo CPF (se informado)
  IF NEW.cpf IS NOT NULL THEN
    DELETE FROM medicos_precadastro 
    WHERE cpf IS NOT NULL 
      AND (
        -- CPF igual (considerando que pode estar formatado ou não)
        REPLACE(REPLACE(REPLACE(cpf, '.', ''), '-', ''), ' ', '') = 
        REPLACE(REPLACE(REPLACE(NEW.cpf, '.', ''), '-', ''), ' ', '')
      );
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."cleanup_medicos_precadastro"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."contar_linhas_duplo"("nome_tabela" "text") RETURNS TABLE("total_linhas" bigint, "total_menos_um" bigint)
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    quantidade BIGINT;
BEGIN
    -- Conta o número total de linhas da tabela
    EXECUTE format('SELECT COUNT(*) FROM %I', nome_tabela) INTO quantidade;
    
    -- Retorna o total e o total -1
    RETURN QUERY SELECT quantidade, quantidade - 1;
END;
$$;


ALTER FUNCTION "public"."contar_linhas_duplo"("nome_tabela" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."corrigir_inconsistencias_vagas"() RETURNS TABLE("acao" "text", "quantidade" integer)
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE
    correcoes_fechadas INTEGER := 0;
    correcoes_candidaturas INTEGER := 0;
BEGIN
    -- Corrigir vagas fechadas incorretamente
    UPDATE vagas 
    SET 
        vagas_status = 'cancelada',
        vagas_updateat = NOW(),
        vagas_updateby = 'ada3a79a-6437-4e27-9e22-40c08c36c59b'
    WHERE vagas_status = 'fechada' 
    AND vagas_totalcandidaturas = 0
    AND NOT EXISTS (
        SELECT 1 FROM candidaturas c 
        WHERE c.vagas_id = vagas.vagas_id
    );
    
    GET DIAGNOSTICS correcoes_fechadas = ROW_COUNT;
    
    -- Corrigir candidaturas pendentes em vagas encerradas
    UPDATE candidaturas 
    SET 
        candidatura_status = 'REPROVADO',
        candidaturas_updateat = NOW(),
        candidaturas_updateby = 'Sistema - Correção automática'
    WHERE candidatura_status = 'PENDENTE'
    AND vagas_id IN (
        SELECT vagas_id 
        FROM vagas 
        WHERE vagas_status IN ('fechada', 'cancelada')
    );
    
    GET DIAGNOSTICS correcoes_candidaturas = ROW_COUNT;
    
    -- Retornar resultados
    RETURN QUERY SELECT 
        'Vagas corrigidas (fechada -> cancelada)'::TEXT,
        correcoes_fechadas;
        
    RETURN QUERY SELECT 
        'Candidaturas corrigidas (pendente -> reprovado)'::TEXT,
        correcoes_candidaturas;
END;
$$;


ALTER FUNCTION "public"."corrigir_inconsistencias_vagas"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."count_candidaturas_total"("vaga_id_param" "uuid") RETURNS integer
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  SELECT COUNT(*)::INTEGER 
  FROM candidaturas 
  WHERE vagas_id = vaga_id_param;
$$;


ALTER FUNCTION "public"."count_candidaturas_total"("vaga_id_param" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."criar_carteira_digital"("p_medico_id" "uuid") RETURNS TABLE("success" boolean, "message" "text", "new_carteira_id" "uuid")
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    v_carteira_id UUID;
BEGIN
    -- Verificar se já existe carteira para este médico
    SELECT cd.carteira_id INTO v_carteira_id
    FROM carteira_digital cd
    WHERE cd.medicos_id = p_medico_id;
    
    IF v_carteira_id IS NOT NULL THEN
        RETURN QUERY SELECT false, 'Médico já possui carteira digital', v_carteira_id;
        RETURN;
    END IF;
    
    -- Criar nova carteira
    INSERT INTO carteira_digital (
        carteira_id,
        medicos_id,
        carteira_createdate,
        carteira_status,
        -- Inicializar todos os documentos como AGUARDANDO
        carteira_diploma,
        carteira_crm,
        carteira_cpf,
        carteira_rg,
        carteira_especializacaodiploma,
        carteira_anuidadecrm,
        carteira_eticoprofissional,
        carteira_comprovanteresidencia,
        carteira_foto,
        carteira_comprovantevacina,
        -- Inicializar todos os status como false
        carteira_diploma_status,
        carteira_crm_status,
        carteira_cpf_status,
        carteira_rg_status,
        carteira_especializacaodiploma_status,
        carteira_anuidadecrm_status,
        carteira_eticoprofissional_status,
        carteira_comprovanteresidencia_status,
        carteira_foto_status,
        carteira_comprovantevacina_status
    )
    VALUES (
        gen_random_uuid(),
        p_medico_id,
        NOW(),
        false,
        'AGUARDANDO',
        'AGUARDANDO',
        'AGUARDANDO',
        'AGUARDANDO',
        'AGUARDANDO',
        'AGUARDANDO',
        'AGUARDANDO',
        'AGUARDANDO',
        'AGUARDANDO',
        'AGUARDANDO',
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false,
        false
    )
    RETURNING carteira_id INTO v_carteira_id;
    
    RETURN QUERY SELECT true, 'Carteira digital criada com sucesso', v_carteira_id;
END;
$$;


ALTER FUNCTION "public"."criar_carteira_digital"("p_medico_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."criar_escalista"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$DECLARE
  user_phone varchar;
  user_email varchar;
  user_metadata jsonb;
BEGIN
  -- Verificar se o role foi definido como 'astronauta'
  IF NEW.role = 'astronauta' THEN
    -- Obter email e metadados do usuário da tabela auth.users
    SELECT 
      email, 
      raw_user_meta_data
    INTO 
      user_email,
      user_metadata
    FROM auth.users
    WHERE id = NEW.id;
    
    -- Obter telefone dos metadados (apenas do campo 'phone' dentro de 'data')
    user_phone := user_metadata->'data'->>'phone';
    
    -- Adicionar prefixo '55' se não existir e o telefone não for nulo
    IF user_phone IS NOT NULL AND user_phone NOT LIKE '55%' THEN
      user_phone := '55' || user_phone;
    END IF;
    
    INSERT INTO public.escalistas (
      id,
      nome,
      telefone,
      email
    )
    VALUES (
      NEW.id,
      NEW.displayname,
      user_phone,
      user_email
    )
    ON CONFLICT (id) DO UPDATE SET
      nome = NEW.displayname,
      telefone = user_phone,
      email = user_email;
  END IF;
  RETURN NEW;
END;$$;


ALTER FUNCTION "public"."criar_escalista"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."criar_recorrencia_com_vagas"("p_data_inicio" "date", "p_data_fim" "date", "p_dias_semana" integer[], "p_vaga_base" "jsonb", "p_created_by" "uuid", "p_medico_id" "uuid" DEFAULT NULL::"uuid", "p_observacoes" "text" DEFAULT NULL::"text") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  nova_recorrencia_id uuid;
  nova_vaga_id uuid;
BEGIN
  -- Cria a recorrência
  INSERT INTO public.vagas_recorrencia (
    data_inicio, data_fim, dias_semana, observacoes, created_by
  ) VALUES (
    p_data_inicio, p_data_fim, p_dias_semana, p_observacoes, p_created_by
  ) RETURNING recorrencia_id INTO nova_recorrencia_id;

  -- Cria a vaga base (primeira vaga) com conversão explícita de todos os tipos
  INSERT INTO public.vagas (
    vagas_createdate, vagas_hospital, vagas_data, vagas_periodo, vagas_horainicio, vagas_horafim, vagas_valor,
    vagas_datapagamento, vagas_formarecebimento, vagas_tipo, vagas_setor, vagas_escalista, vagas_updateat, vagas_status,
    vagas_updateby, vaga_especialidade, grupo_id, vagas_observacoes, vagas_totalcandidaturas, recorrencia_id
  ) VALUES (
    now(),
    (p_vaga_base->>'vagas_hospital')::uuid,
    (p_vaga_base->>'vagas_data')::date,
    (p_vaga_base->>'vagas_periodo')::uuid,
    (p_vaga_base->>'vagas_horainicio')::time,
    (p_vaga_base->>'vagas_horafim')::time,
    (p_vaga_base->>'vagas_valor')::integer,
    CASE 
      WHEN p_vaga_base->>'vagas_datapagamento' IS NOT NULL 
      THEN (p_vaga_base->>'vagas_datapagamento')::date 
      ELSE NULL 
    END,
    CASE 
      WHEN p_vaga_base->>'vagas_formarecebimento' IS NOT NULL 
      THEN (p_vaga_base->>'vagas_formarecebimento')::uuid 
      ELSE NULL 
    END,
    (p_vaga_base->>'vagas_tipo')::uuid,
    (p_vaga_base->>'vagas_setor')::uuid,
    (p_vaga_base->>'vagas_escalista')::uuid,
    now(),
    CASE WHEN p_medico_id IS NOT NULL THEN 'fechada' ELSE 'aberta' END,
    p_created_by,  -- CORRIGIDO: Usar p_created_by em vez de extrair do JSON
    (p_vaga_base->>'vaga_especialidade')::uuid,
    (p_vaga_base->>'grupo_id')::uuid,
    p_vaga_base->>'vagas_observacoes',
    0,
    nova_recorrencia_id
  ) RETURNING vagas_id INTO nova_vaga_id;

  -- Gera as demais vagas recorrentes (CORRIGIDO: Passar p_created_by)
  PERFORM public.gerar_vagas_recorrentes(nova_recorrencia_id, nova_vaga_id, p_medico_id, p_created_by);

  RETURN nova_recorrencia_id;
END;
$$;


ALTER FUNCTION "public"."criar_recorrencia_com_vagas"("p_data_inicio" "date", "p_data_fim" "date", "p_dias_semana" integer[], "p_vaga_base" "jsonb", "p_created_by" "uuid", "p_medico_id" "uuid", "p_observacoes" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."criar_recorrencia_com_vagas"("p_data_inicio" "date", "p_data_fim" "date", "p_dias_semana" integer[], "p_vaga_base" "jsonb", "p_created_by" "uuid", "p_medico_id" "uuid" DEFAULT NULL::"uuid", "p_observacoes" "text" DEFAULT NULL::"text", "p_beneficios" "text"[] DEFAULT ARRAY[]::"text"[], "p_requisitos" "text"[] DEFAULT ARRAY[]::"text"[]) RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  nova_recorrencia_id uuid;
  nova_vaga_id uuid;
  beneficio_id text;
  requisito_id text;
  now_brasil timestamp := (now() at time zone 'America/Sao_Paulo');
BEGIN
  -- Log do início da operação
  RAISE NOTICE 'Criando recorrência de % até % com médico designado: %', p_data_inicio, p_data_fim, p_medico_id;

  -- Cria a recorrência
  INSERT INTO public.vagas_recorrencia (
    data_inicio, data_fim, dias_semana, observacoes, created_by
  ) VALUES (
    p_data_inicio, p_data_fim, p_dias_semana, p_observacoes, p_created_by
  ) RETURNING recorrencia_id INTO nova_recorrencia_id;

  -- Cria a vaga base (primeira vaga) com conversão explícita de todos os tipos
  INSERT INTO public.vagas (
    vagas_createdate, vagas_hospital, vagas_data, vagas_periodo, vagas_horainicio, vagas_horafim, vagas_valor,
    vagas_datapagamento, vagas_formarecebimento, vagas_tipo, vagas_setor, vagas_escalista, vagas_updateat, vagas_status,
    vagas_updateby, vaga_especialidade, grupo_id, vagas_observacoes, vagas_totalcandidaturas, recorrencia_id
  ) VALUES (
    now_brasil,
    (p_vaga_base->>'vagas_hospital')::uuid,
    (p_vaga_base->>'vagas_data')::date,
    (p_vaga_base->>'vagas_periodo')::uuid,
    (p_vaga_base->>'vagas_horainicio')::time,
    (p_vaga_base->>'vagas_horafim')::time,
    (p_vaga_base->>'vagas_valor')::integer,
    CASE 
      WHEN p_vaga_base->>'vagas_datapagamento' IS NOT NULL 
      THEN (p_vaga_base->>'vagas_datapagamento')::date 
      ELSE NULL 
    END,
    CASE 
      WHEN p_vaga_base->>'vagas_formarecebimento' IS NOT NULL 
      THEN (p_vaga_base->>'vagas_formarecebimento')::uuid 
      ELSE NULL 
    END,
    (p_vaga_base->>'vagas_tipo')::uuid,
    (p_vaga_base->>'vagas_setor')::uuid,
    (p_vaga_base->>'vagas_escalista')::uuid,
    now_brasil,
    CASE WHEN p_medico_id IS NOT NULL THEN 'fechada' ELSE 'aberta' END,
    p_created_by,
    (p_vaga_base->>'vaga_especialidade')::uuid,
    (p_vaga_base->>'grupo_id')::uuid,
    p_vaga_base->>'vagas_observacoes',
    0,
    nova_recorrencia_id
  ) RETURNING vagas_id INTO nova_vaga_id;

  -- Inserir benefícios da vaga base
  IF p_beneficios IS NOT NULL AND array_length(p_beneficios, 1) > 0 THEN
    FOR beneficio_id IN SELECT unnest(p_beneficios) LOOP
      INSERT INTO public.vagas_beneficio (vagas_id, beneficio_id)
      VALUES (nova_vaga_id, beneficio_id::uuid);
    END LOOP;
  END IF;

  -- Inserir requisitos da vaga base
  IF p_requisitos IS NOT NULL AND array_length(p_requisitos, 1) > 0 THEN
    FOR requisito_id IN SELECT unnest(p_requisitos) LOOP
      INSERT INTO public.vagas_requisito (vagas_id, requisito_id)
      VALUES (nova_vaga_id, requisito_id::uuid);
    END LOOP;
  END IF;

  -- CORREÇÃO: Criar candidatura aprovada para a vaga base se há médico designado
  IF p_medico_id IS NOT NULL THEN
    INSERT INTO public.candidaturas (
      medico_id, vagas_id, candidatura_status, candidatos_createdate, candidaturas_updateat, candidaturas_updateby, vagas_valor
    ) VALUES (
      p_medico_id, nova_vaga_id, 'APROVADO', now_brasil, now_brasil, p_created_by::text, (p_vaga_base->>'vagas_valor')::integer
    );
    
    RAISE NOTICE 'Candidatura aprovada criada para vaga base: % (médico: %)', nova_vaga_id, p_medico_id;
  END IF;

  -- Gera as demais vagas recorrentes
  PERFORM public.gerar_vagas_recorrentes(nova_recorrencia_id, nova_vaga_id, p_medico_id, p_created_by, p_beneficios, p_requisitos);

  RAISE NOTICE 'Recorrência criada com sucesso: % (vaga base: %)', nova_recorrencia_id, nova_vaga_id;
  
  RETURN nova_recorrencia_id;
END;
$$;


ALTER FUNCTION "public"."criar_recorrencia_com_vagas"("p_data_inicio" "date", "p_data_fim" "date", "p_dias_semana" integer[], "p_vaga_base" "jsonb", "p_created_by" "uuid", "p_medico_id" "uuid", "p_observacoes" "text", "p_beneficios" "text"[], "p_requisitos" "text"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."current_user_is_favorito"("p_grupo_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    current_user_id UUID;
BEGIN
    -- Obter o ID do usuário atual
    current_user_id := auth.uid();
    
    -- Se não há usuário autenticado, retornar false
    IF current_user_id IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Verificar se o usuário é favorito no grupo
    RETURN EXISTS (
        SELECT 1 
        FROM medicos_favoritos mf 
        WHERE mf.grupo_id = p_grupo_id 
        AND mf.medico_id = current_user_id
    );
END;
$$;


ALTER FUNCTION "public"."current_user_is_favorito"("p_grupo_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."deletar_vagas_recorrencia"("p_recorrencia_id" "uuid", "p_updateby" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  vaga RECORD;
BEGIN
  FOR vaga IN SELECT vagas_id FROM public.vagas WHERE recorrencia_id = p_recorrencia_id LOOP
    -- Deleta benefícios (CORRIGIDO: vaga_id -> vagas_id)
    DELETE FROM public.vagas_beneficio WHERE vagas_id = vaga.vagas_id;
    -- Deleta requisitos 
    DELETE FROM public.vagas_requisito WHERE vagas_id = vaga.vagas_id;
    -- Deleta candidaturas
    DELETE FROM public.candidaturas WHERE vagas_id = vaga.vagas_id;
    -- Deleta a vaga
    DELETE FROM public.vagas WHERE vagas_id = vaga.vagas_id;
  END LOOP;
  -- Opcional: deletar a recorrência
  DELETE FROM public.vagas_recorrencia WHERE recorrencia_id = p_recorrencia_id;
END;
$$;


ALTER FUNCTION "public"."deletar_vagas_recorrencia"("p_recorrencia_id" "uuid", "p_updateby" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."deletethisuser"("user_id" "uuid") RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
begin
  delete from auth.users
  where id = user_id;
end;
$$;


ALTER FUNCTION "public"."deletethisuser"("user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."editar_vagas_recorrencia"("p_recorrencia_id" "uuid", "p_update" "jsonb", "p_updateby" "uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
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
    -- Atualizar dados da vaga (usando nomenclatura correta)
    UPDATE public.vagas SET
      hospital_id = COALESCE((p_update->>'hospital_id')::uuid, hospital_id),
      data = COALESCE((p_update->>'data')::date, data),
      periodo_id = COALESCE((p_update->>'periodo_id')::uuid, periodo_id),
      hora_inicio = COALESCE((p_update->>'hora_inicio')::time, hora_inicio),
      hora_fim = COALESCE((p_update->>'hora_fim')::time, hora_fim),
      valor = COALESCE((p_update->>'valor')::integer, valor),
      data_pagamento = COALESCE((p_update->>'data_pagamento')::date, data_pagamento),
      forma_recebimento_id = COALESCE((p_update->>'forma_recebimento_id')::uuid, forma_recebimento_id),
      tipos_vaga_id = COALESCE((p_update->>'tipos_vaga_id')::uuid, tipos_vaga_id),
      observacoes = COALESCE((p_update->>'observacoes'), observacoes),
      setor_id = COALESCE((p_update->>'setor_id')::uuid, setor_id),
      escalista_id = COALESCE((p_update->>'escalista_id')::uuid, escalista_id),
      especialidade_id = COALESCE((p_update->>'especialidade_id')::uuid, especialidade_id),
      grupo_id = COALESCE((p_update->>'grupo_id')::uuid, grupo_id),
      -- ATUALIZAR STATUS DA VAGA baseado no médico designado
      status = CASE 
        WHEN (p_update ? 'medico_id') THEN 
          CASE WHEN novo_medico_id IS NOT NULL THEN 'fechada' ELSE 'aberta' END
        ELSE status 
      END,
      -- CAMPOS DE AUDITORIA - SEMPRE ATUALIZADOS
      updated_at = now_brasil,
      updated_by = p_updateby
    WHERE id = vaga.id;
    
    vagas_atualizadas := vagas_atualizadas + 1;
    
    -- Gerenciar candidaturas quando médico é especificado
    IF (p_update ? 'medico_id') THEN
      IF novo_medico_id IS NOT NULL THEN
        -- Médico designado: verificar se já existe candidatura aprovada
        SELECT * INTO candidatura_existente 
        FROM public.candidaturas 
        WHERE vagas_id = vaga.id AND status = 'APROVADO'
        LIMIT 1;
        
        IF candidatura_existente.id IS NOT NULL THEN
          -- Atualizar candidatura existente
          UPDATE public.candidaturas SET
            medico_id = novo_medico_id,
            updated_at = now_brasil,
            updated_by = p_updateby::text
          WHERE id = candidatura_existente.id;
          
          RAISE NOTICE 'Candidatura atualizada para vaga: % (candidatura: %)', vaga.id, candidatura_existente.id;
        ELSE
          -- Criar nova candidatura aprovada
          INSERT INTO public.candidaturas (
            medico_id, vagas_id, status, created_at, updated_at, updated_by, valor
          ) VALUES (
            novo_medico_id, vaga.id, 'APROVADO', now_brasil, now_brasil, p_updateby::text, vaga.valor
          );
          
          RAISE NOTICE 'Nova candidatura aprovada criada para vaga: %', vaga.id;
        END IF;
      ELSE
        -- Médico removido: remover candidaturas aprovadas
        DELETE FROM public.candidaturas 
        WHERE vagas_id = vaga.id AND status = 'APROVADO';
        
        RAISE NOTICE 'Candidaturas aprovadas removidas da vaga: %', vaga.id;
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
$$;


ALTER FUNCTION "public"."editar_vagas_recorrencia"("p_recorrencia_id" "uuid", "p_update" "jsonb", "p_updateby" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."editar_vagas_recorrencia"("p_recorrencia_id" "uuid", "p_update" "jsonb", "p_updateby" "uuid", "p_beneficios" "text"[] DEFAULT ARRAY[]::"text"[], "p_requisitos" "text"[] DEFAULT ARRAY[]::"text"[]) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  now_brasil timestamp := (now() at time zone 'America/Sao_Paulo');
  vaga RECORD;
  vagas_atualizadas integer := 0;
  novo_medico_id uuid;
  candidatura_existente RECORD;
  beneficio_id text;
  requisito_id text;
  dias_para_pagamento integer;
  nova_data_pagamento date;
  nova_data_plantao date;
BEGIN
  -- Log do início da operação
  RAISE NOTICE 'Iniciando edição de vagas da recorrência: %', p_recorrencia_id;
  
  -- Extrair médico_id se presente
  novo_medico_id := CASE WHEN (p_update ? 'medico_id') THEN (p_update->>'medico_id')::uuid ELSE NULL END;
  
  -- LÓGICA CORRIGIDA: Se há data_pagamento no update, calcular dias baseado na primeira vaga da recorrência
  IF (p_update ? 'data_pagamento') THEN
    -- Buscar primeira vaga da recorrência para calcular os dias de pagamento originais
    SELECT v.data, v.data_pagamento INTO nova_data_plantao, nova_data_pagamento
    FROM vagas v 
    WHERE v.recorrencia_id = p_recorrencia_id 
    ORDER BY v.data 
    LIMIT 1;
    
    -- Se encontrou dados da primeira vaga, calcular dias
    IF nova_data_plantao IS NOT NULL AND nova_data_pagamento IS NOT NULL THEN
      dias_para_pagamento := calcular_dias_pagamento(nova_data_plantao, nova_data_pagamento);
      RAISE NOTICE 'Recalculando datas de pagamento baseado em % dias após cada data de plantão (baseado na primeira vaga)', dias_para_pagamento;
    ELSE
      -- Se não encontrou dados, usar o valor do update como padrão
      dias_para_pagamento := NULL;
      RAISE NOTICE 'Não foi possível calcular dias, usando data fixa do update';
    END IF;
  END IF;
  
  FOR vaga IN SELECT * FROM public.vagas WHERE recorrencia_id = p_recorrencia_id LOOP
    
    -- CALCULAR NOVA DATA DE PAGAMENTO PARA CADA VAGA INDIVIDUALMENTE
    IF dias_para_pagamento IS NOT NULL THEN
      -- Recalcular baseado na data específica desta vaga + dias calculados
      nova_data_pagamento := vaga.data + (dias_para_pagamento || ' days')::interval;
      RAISE NOTICE 'Vaga %: Data plantão %, nova data pagamento %', vaga.id, vaga.data, nova_data_pagamento;
    ELSE
      -- Usar data do update se não conseguiu calcular dias
      nova_data_pagamento := COALESCE((p_update->>'data_pagamento')::date, vaga.data_pagamento);
    END IF;
    
    -- Atualizar dados da vaga (usando nomenclatura correta)
    UPDATE public.vagas SET
      hospital_id = COALESCE((p_update->>'hospital_id')::uuid, hospital_id),
      data = COALESCE((p_update->>'data')::date, data),
      periodo_id = COALESCE((p_update->>'periodo_id')::uuid, periodo_id),
      hora_inicio = COALESCE((p_update->>'hora_inicio')::time, hora_inicio),
      hora_fim = COALESCE((p_update->>'hora_fim')::time, hora_fim),
      valor = COALESCE((p_update->>'valor')::integer, valor),
      data_pagamento = nova_data_pagamento, -- USAR DATA RECALCULADA INDIVIDUALMENTE
      forma_recebimento_id = COALESCE((p_update->>'forma_recebimento_id')::uuid, forma_recebimento_id),
      tipos_vaga_id = COALESCE((p_update->>'tipos_vaga_id')::uuid, tipos_vaga_id),
      observacoes = COALESCE((p_update->>'observacoes'), observacoes),
      setor_id = COALESCE((p_update->>'setor_id')::uuid, setor_id),
      escalista_id = COALESCE((p_update->>'escalista_id')::uuid, escalista_id),
      especialidade_id = COALESCE((p_update->>'especialidade_id')::uuid, especialidade_id),
      grupo_id = COALESCE((p_update->>'grupo_id')::uuid, grupo_id),
      -- ATUALIZAR STATUS DA VAGA baseado no médico designado
      status = CASE 
        WHEN (p_update ? 'medico_id') THEN 
          CASE WHEN novo_medico_id IS NOT NULL THEN 'fechada' ELSE 'aberta' END
        ELSE status 
      END,
      -- CAMPOS DE AUDITORIA - SEMPRE ATUALIZADOS
      updated_at = now_brasil,
      updated_by = p_updateby
    WHERE id = vaga.id;
    
    -- Atualizar benefícios da vaga
    DELETE FROM public.vagas_beneficio WHERE vagas_id = vaga.id;
    IF p_beneficios IS NOT NULL AND array_length(p_beneficios, 1) > 0 THEN
      FOR beneficio_id IN SELECT unnest(p_beneficios) LOOP
        INSERT INTO public.vagas_beneficio (vagas_id, beneficio_id)
        VALUES (vaga.id, beneficio_id::uuid);
      END LOOP;
    END IF;

    -- Atualizar requisitos da vaga
    DELETE FROM public.vagas_requisito WHERE vagas_id = vaga.id;
    IF p_requisitos IS NOT NULL AND array_length(p_requisitos, 1) > 0 THEN
      FOR requisito_id IN SELECT unnest(p_requisitos) LOOP
        INSERT INTO public.vagas_requisito (vagas_id, requisito_id)
        VALUES (vaga.id, requisito_id::uuid);
      END LOOP;
    END IF;
    
    vagas_atualizadas := vagas_atualizadas + 1;
    
    -- Gerenciar candidaturas quando médico é especificado
    IF (p_update ? 'medico_id') THEN
      IF novo_medico_id IS NOT NULL THEN
        -- Médico designado: verificar se já existe candidatura aprovada
        SELECT * INTO candidatura_existente 
        FROM public.candidaturas 
        WHERE vagas_id = vaga.id AND status = 'APROVADO'
        LIMIT 1;
        
        IF candidatura_existente.id IS NOT NULL THEN
          -- Atualizar candidatura existente
          UPDATE public.candidaturas SET
            medico_id = novo_medico_id,
            updated_at = now_brasil,
            updated_by = p_updateby::text
          WHERE id = candidatura_existente.id;
          
          RAISE NOTICE 'Candidatura atualizada para vaga: % (candidatura: %)', vaga.id, candidatura_existente.id;
        ELSE
          -- Criar nova candidatura aprovada
          INSERT INTO public.candidaturas (
            medico_id, vagas_id, status, created_at, updated_at, updated_by, valor
          ) VALUES (
            novo_medico_id, vaga.id, 'APROVADO', now_brasil, now_brasil, p_updateby::text, vaga.valor
          );
          
          RAISE NOTICE 'Nova candidatura aprovada criada para vaga: %', vaga.id;
        END IF;
      ELSE
        -- Médico removido: remover candidaturas aprovadas
        DELETE FROM public.candidaturas 
        WHERE vagas_id = vaga.id AND status = 'APROVADO';
        
        RAISE NOTICE 'Candidaturas aprovadas removidas da vaga: %', vaga.id;
      END IF;
    END IF;
    
    RAISE NOTICE 'Vaga % atualizada com pagamento em %', vaga.id, nova_data_pagamento;
  END LOOP;
  
  -- Log do resultado
  RAISE NOTICE 'Edição concluída. % vagas atualizadas para recorrência: %', vagas_atualizadas, p_recorrencia_id;
  
  -- Verificar se alguma vaga foi atualizada
  IF vagas_atualizadas = 0 THEN
    RAISE EXCEPTION 'Nenhuma vaga encontrada para a recorrência: %', p_recorrencia_id;
  END IF;
END;
$$;


ALTER FUNCTION "public"."editar_vagas_recorrencia"("p_recorrencia_id" "uuid", "p_update" "jsonb", "p_updateby" "uuid", "p_beneficios" "text"[], "p_requisitos" "text"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."editar_vagas_recorrencia"("p_recorrencia_id" "uuid", "p_update" "jsonb", "p_updateby" "uuid", "p_beneficios" "text"[] DEFAULT ARRAY[]::"text"[], "p_requisitos" "text"[] DEFAULT ARRAY[]::"text"[], "p_dias_pagamento" integer DEFAULT NULL::integer) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  now_brasil timestamp := (now() at time zone 'America/Sao_Paulo');
  vaga RECORD;
  vagas_atualizadas integer := 0;
  novo_medico_id uuid;
  candidatura_existente RECORD;
  beneficio_id text;
  requisito_id text;
  dias_para_pagamento integer;
  nova_data_pagamento date;
BEGIN
  -- Log do início da operação
  RAISE NOTICE 'Iniciando edição de vagas da recorrência: % (dias_pagamento: %)', p_recorrencia_id, p_dias_pagamento;
  
  -- Extrair médico_id se presente
  novo_medico_id := CASE WHEN (p_update ? 'medico_id') THEN (p_update->>'medico_id')::uuid ELSE NULL END;
  
  -- Determinar quantos dias usar para cálculo da data de pagamento
  IF p_dias_pagamento IS NOT NULL THEN
    -- Usar dias passados diretamente como parâmetro
    dias_para_pagamento := p_dias_pagamento;
    RAISE NOTICE 'Usando dias de pagamento especificados: % dias', dias_para_pagamento;
  ELSIF (p_update ? 'data_pagamento') THEN
    -- Tentar calcular baseado na primeira vaga da recorrência
    SELECT calcular_dias_pagamento(v.data, v.data_pagamento) 
    INTO dias_para_pagamento
    FROM vagas v 
    WHERE v.recorrencia_id = p_recorrencia_id 
    ORDER BY v.data 
    LIMIT 1;
    
    RAISE NOTICE 'Calculando dias baseado na primeira vaga: % dias', dias_para_pagamento;
  ELSE
    -- Não recalcular datas de pagamento
    dias_para_pagamento := NULL;
    RAISE NOTICE 'Mantendo datas de pagamento originais';
  END IF;
  
  FOR vaga IN SELECT * FROM public.vagas WHERE recorrencia_id = p_recorrencia_id LOOP
    
    -- CALCULAR NOVA DATA DE PAGAMENTO PARA CADA VAGA INDIVIDUALMENTE
    IF dias_para_pagamento IS NOT NULL THEN
      nova_data_pagamento := vaga.data + (dias_para_pagamento || ' days')::interval;
      RAISE NOTICE 'Vaga %: Data plantão %, nova data pagamento % (+ % dias)', 
        vaga.id, vaga.data, nova_data_pagamento, dias_para_pagamento;
    ELSE
      nova_data_pagamento := COALESCE((p_update->>'data_pagamento')::date, vaga.data_pagamento);
    END IF;
    
    -- Atualizar dados da vaga (usando nomenclatura correta)
    UPDATE public.vagas SET
      hospital_id = COALESCE((p_update->>'hospital_id')::uuid, hospital_id),
      data = COALESCE((p_update->>'data')::date, data),
      periodo_id = COALESCE((p_update->>'periodo_id')::uuid, periodo_id),
      hora_inicio = COALESCE((p_update->>'hora_inicio')::time, hora_inicio),
      hora_fim = COALESCE((p_update->>'hora_fim')::time, hora_fim),
      valor = COALESCE((p_update->>'valor')::integer, valor),
      data_pagamento = nova_data_pagamento, -- DATA RECALCULADA INDIVIDUALMENTE
      forma_recebimento_id = COALESCE((p_update->>'forma_recebimento_id')::uuid, forma_recebimento_id),
      tipos_vaga_id = COALESCE((p_update->>'tipos_vaga_id')::uuid, tipos_vaga_id),
      observacoes = COALESCE((p_update->>'observacoes'), observacoes),
      setor_id = COALESCE((p_update->>'setor_id')::uuid, setor_id),
      escalista_id = COALESCE((p_update->>'escalista_id')::uuid, escalista_id),
      especialidade_id = COALESCE((p_update->>'especialidade_id')::uuid, especialidade_id),
      grupo_id = COALESCE((p_update->>'grupo_id')::uuid, grupo_id),
      status = CASE 
        WHEN (p_update ? 'medico_id') THEN 
          CASE WHEN novo_medico_id IS NOT NULL THEN 'fechada' ELSE 'aberta' END
        ELSE status 
      END,
      updated_at = now_brasil,
      updated_by = p_updateby
    WHERE id = vaga.id;
    
    -- Atualizar benefícios da vaga
    DELETE FROM public.vagas_beneficio WHERE vagas_id = vaga.id;
    IF p_beneficios IS NOT NULL AND array_length(p_beneficios, 1) > 0 THEN
      FOR beneficio_id IN SELECT unnest(p_beneficios) LOOP
        INSERT INTO public.vagas_beneficio (vagas_id, beneficio_id)
        VALUES (vaga.id, beneficio_id::uuid);
      END LOOP;
    END IF;

    -- Atualizar requisitos da vaga
    DELETE FROM public.vagas_requisito WHERE vagas_id = vaga.id;
    IF p_requisitos IS NOT NULL AND array_length(p_requisitos, 1) > 0 THEN
      FOR requisito_id IN SELECT unnest(p_requisitos) LOOP
        INSERT INTO public.vagas_requisito (vagas_id, requisito_id)
        VALUES (vaga.id, requisito_id::uuid);
      END LOOP;
    END IF;
    
    vagas_atualizadas := vagas_atualizadas + 1;
    
    -- Gerenciar candidaturas quando médico é especificado
    IF (p_update ? 'medico_id') THEN
      IF novo_medico_id IS NOT NULL THEN
        SELECT * INTO candidatura_existente 
        FROM public.candidaturas 
        WHERE vagas_id = vaga.id AND status = 'APROVADO'
        LIMIT 1;
        
        IF candidatura_existente.id IS NOT NULL THEN
          UPDATE public.candidaturas SET
            medico_id = novo_medico_id,
            updated_at = now_brasil,
            updated_by = p_updateby::text
          WHERE id = candidatura_existente.id;
        ELSE
          INSERT INTO public.candidaturas (
            medico_id, vagas_id, status, created_at, updated_at, updated_by, valor
          ) VALUES (
            novo_medico_id, vaga.id, 'APROVADO', now_brasil, now_brasil, p_updateby::text, vaga.valor
          );
        END IF;
      ELSE
        DELETE FROM public.candidaturas 
        WHERE vagas_id = vaga.id AND status = 'APROVADO';
      END IF;
    END IF;
  END LOOP;
  
  RAISE NOTICE 'Edição concluída. % vagas atualizadas para recorrência: %', vagas_atualizadas, p_recorrencia_id;
  
  IF vagas_atualizadas = 0 THEN
    RAISE EXCEPTION 'Nenhuma vaga encontrada para a recorrência: %', p_recorrencia_id;
  END IF;
END;
$$;


ALTER FUNCTION "public"."editar_vagas_recorrencia"("p_recorrencia_id" "uuid", "p_update" "jsonb", "p_updateby" "uuid", "p_beneficios" "text"[], "p_requisitos" "text"[], "p_dias_pagamento" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."excluir_vagas_lote"("vagas_ids" "uuid"[]) RETURNS integer
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    -- Verificar se pelo menos um UUID foi fornecido
    IF array_length(vagas_ids, 1) IS NULL OR array_length(vagas_ids, 1) = 0 THEN
        RETURN 0;
    END IF;

    -- Excluir as vagas e contar quantas foram excluídas
    DELETE FROM vagas
    WHERE vagas_id = ANY(vagas_ids);

    GET DIAGNOSTICS deleted_count = ROW_COUNT;

    -- Retornar quantidade excluída
    RETURN deleted_count;
EXCEPTION
    WHEN OTHERS THEN
        -- Em caso de erro, re-lançar com mensagem mais clara
        RAISE EXCEPTION 'Erro ao excluir vagas: %', SQLERRM;
END;
$$;


ALTER FUNCTION "public"."excluir_vagas_lote"("vagas_ids" "uuid"[]) OWNER TO "postgres";


COMMENT ON FUNCTION "public"."excluir_vagas_lote"("vagas_ids" "uuid"[]) IS 'Função para excluir múltiplas vagas em uma operação, evitando problemas de URL muito longa no cliente Supabase';



CREATE OR REPLACE FUNCTION "public"."gerar_vagas_recorrentes"("p_recorrencia_id" "uuid", "p_vaga_base_id" "uuid", "p_medico_id" "uuid" DEFAULT NULL::"uuid", "p_created_by" "uuid" DEFAULT NULL::"uuid") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "public"."gerar_vagas_recorrentes"("p_recorrencia_id" "uuid", "p_vaga_base_id" "uuid", "p_medico_id" "uuid", "p_created_by" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."gerar_vagas_recorrentes"("p_recorrencia_id" "uuid", "p_vaga_base_id" "uuid", "p_medico_id" "uuid" DEFAULT NULL::"uuid", "p_created_by" "uuid" DEFAULT NULL::"uuid", "p_beneficios" "text"[] DEFAULT ARRAY[]::"text"[], "p_requisitos" "text"[] DEFAULT ARRAY[]::"text"[]) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  rec public.vagas_recorrencia%ROWTYPE;
  vaga_base public.vagas%ROWTYPE;
  dia date;
  dias integer[];
  i integer;
  nova_vaga_id uuid;
  now_brasil timestamp := (now() at time zone 'America/Sao_Paulo');
  audit_user uuid;
  beneficio_id text;
  requisito_id text;
  dias_para_pagamento integer;
  nova_data_pagamento date;
BEGIN
  -- Busca dados da recorrência e da vaga base
  SELECT * INTO rec FROM public.vagas_recorrencia WHERE recorrencia_id = p_recorrencia_id;
  SELECT * INTO vaga_base FROM public.vagas WHERE vagas_id = p_vaga_base_id;
  dias := rec.dias_semana;
  
  -- Calcular quantos dias há entre a data do plantão e a data de pagamento na vaga base
  dias_para_pagamento := calcular_dias_pagamento(vaga_base.vagas_data, vaga_base.vagas_datapagamento);
  
  -- Determinar usuário para auditoria
  audit_user := COALESCE(p_created_by, rec.created_by, vaga_base.vagas_updateby);

  -- Log do início da operação
  RAISE NOTICE 'Gerando vagas recorrentes para recorrência: % de % até % (dias para pagamento: %)', 
    p_recorrencia_id, rec.data_inicio, rec.data_fim, dias_para_pagamento;

  -- Loop de datas
  dia := rec.data_inicio + interval '1 day'; -- Pula o primeiro dia (já criado na vaga base)
  WHILE dia <= rec.data_fim LOOP
    IF array_position(dias, extract(dow from dia)::integer) IS NOT NULL THEN
      
      -- Calcular nova data de pagamento baseada na nova data + dias originais
      IF dias_para_pagamento IS NOT NULL THEN
        nova_data_pagamento := dia + (dias_para_pagamento || ' days')::interval;
      ELSE
        nova_data_pagamento := NULL;
      END IF;
      
      -- Cria nova vaga com data de pagamento recalculada
      INSERT INTO public.vagas (
        vagas_createdate, vagas_hospital, vagas_data, vagas_periodo, vagas_horainicio, vagas_horafim, vagas_valor,
        vagas_datapagamento, vagas_formarecebimento, vagas_tipo, vagas_setor, vagas_escalista, vagas_updateat, vagas_status,
        vagas_updateby, vaga_especialidade, grupo_id, vagas_observacoes, vagas_totalcandidaturas, recorrencia_id
      ) VALUES (
        now_brasil, vaga_base.vagas_hospital, dia, vaga_base.vagas_periodo, vaga_base.vagas_horainicio, vaga_base.vagas_horafim, vaga_base.vagas_valor,
        nova_data_pagamento, -- DATA DE PAGAMENTO RECALCULADA
        vaga_base.vagas_formarecebimento, vaga_base.vagas_tipo, vaga_base.vagas_setor, vaga_base.vagas_escalista, now_brasil,
        CASE WHEN p_medico_id IS NOT NULL THEN 'fechada' ELSE 'aberta' END,
        audit_user,
        vaga_base.vaga_especialidade, vaga_base.grupo_id, vaga_base.vagas_observacoes, 0, p_recorrencia_id
      ) RETURNING vagas_id INTO nova_vaga_id;
      
      -- Inserir benefícios para cada vaga criada
      IF p_beneficios IS NOT NULL AND array_length(p_beneficios, 1) > 0 THEN
        FOR beneficio_id IN SELECT unnest(p_beneficios) LOOP
          INSERT INTO public.vagas_beneficio (vagas_id, beneficio_id)
          VALUES (nova_vaga_id, beneficio_id::uuid);
        END LOOP;
      END IF;

      -- Inserir requisitos para cada vaga criada
      IF p_requisitos IS NOT NULL AND array_length(p_requisitos, 1) > 0 THEN
        FOR requisito_id IN SELECT unnest(p_requisitos) LOOP
          INSERT INTO public.vagas_requisito (vagas_id, requisito_id)
          VALUES (nova_vaga_id, requisito_id::uuid);
        END LOOP;
      END IF;
      
      -- Se houver médico designado, cria candidatura aprovada
      IF p_medico_id IS NOT NULL THEN
        INSERT INTO public.candidaturas (
          medico_id, vagas_id, candidatura_status, candidatos_createdate, candidaturas_updateat, candidaturas_updateby, vagas_valor
        ) VALUES (
          p_medico_id, nova_vaga_id, 'APROVADO', now_brasil, now_brasil, 
          audit_user::text,
          vaga_base.vagas_valor
        );
      END IF;
      
      RAISE NOTICE 'Vaga criada para dia % com pagamento em %: %', dia, nova_data_pagamento, nova_vaga_id;
    END IF;
    dia := dia + interval '1 day';
  END LOOP;
  
  RAISE NOTICE 'Geração de vagas recorrentes concluída para recorrência: %', p_recorrencia_id;
END;
$$;


ALTER FUNCTION "public"."gerar_vagas_recorrentes"("p_recorrencia_id" "uuid", "p_vaga_base_id" "uuid", "p_medico_id" "uuid", "p_created_by" "uuid", "p_beneficios" "text"[], "p_requisitos" "text"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_applications_paginated"("page_number" integer DEFAULT 1, "page_size" integer DEFAULT 10, "hospital_ids" "uuid"[] DEFAULT NULL::"uuid"[], "specialty_ids" "uuid"[] DEFAULT NULL::"uuid"[], "sector_ids" "uuid"[] DEFAULT NULL::"uuid"[], "start_date" "date" DEFAULT NULL::"date", "end_date" "date" DEFAULT NULL::"date", "min_value" numeric DEFAULT NULL::numeric, "max_value" numeric DEFAULT NULL::numeric, "period_ids" "uuid"[] DEFAULT NULL::"uuid"[], "type_ids" "uuid"[] DEFAULT NULL::"uuid"[], "group_ids" "uuid"[] DEFAULT NULL::"uuid"[], "search_text" "text" DEFAULT NULL::"text", "doctor_ids" "uuid"[] DEFAULT NULL::"uuid"[], "application_status_filter" "text"[] DEFAULT NULL::"text"[], "job_status_filter" "text"[] DEFAULT NULL::"text"[], "grade_ids" "uuid"[] DEFAULT NULL::"uuid"[], "order_by" "text" DEFAULT 'candidatura_createdate'::"text", "order_direction" "text" DEFAULT 'DESC'::"text") RETURNS TABLE("data" "jsonb", "pagination" "jsonb")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE 
  validated_page integer;
  validated_size integer;
  total_count bigint;
  offset_value integer;
  validated_order_by text;
  validated_order_direction text;
  order_clause text;
BEGIN 
  validated_page := CASE
    WHEN page_number < 1 THEN 1
    ELSE page_number
  END;
  
  validated_size := CASE
    WHEN page_size < 1 THEN 10
    WHEN page_size > 100 THEN 100
    ELSE page_size
  END;
  
  -- Validação dos parâmetros de ordenação (nomes atualizados)
  validated_order_by := CASE
    WHEN order_by IN (
      'candidatura_createdate',
      'vagas_createdate', 
      'vagas_data',
      'vagas_valor',
      'medico_primeiro_nome',
      'hospital_nome',
      'setor_nome',
      'especialidade_nome',
      'vagas_periodo_nome',
      'vagas_status',
      'candidatura_status'
    ) THEN order_by
    ELSE 'candidatura_createdate'
  END;
  
  validated_order_direction := CASE
    WHEN UPPER(order_direction) IN ('ASC', 'DESC') THEN UPPER(order_direction)
    ELSE 'DESC'
  END;
  
  offset_value := (validated_page - 1) * validated_size;
  
  -- Contagem total de candidaturas (não agrupadas)
  SELECT COUNT(*) INTO total_count
  FROM vw_vagas_candidaturas v
  WHERE v.candidaturas_id IS NOT NULL
    AND (
      hospital_ids IS NULL
      OR v.hospital_id = ANY(hospital_ids)
    )
    AND (
      specialty_ids IS NULL
      OR v.especialidade_id = ANY(specialty_ids)
    )
    AND (
      sector_ids IS NULL
      OR v.setor_id = ANY(sector_ids)
    )
    AND (
      period_ids IS NULL
      OR v.vagas_periodo = ANY(period_ids)
    )
    AND (
      type_ids IS NULL
      OR v.vagas_tipo = ANY(type_ids)
    )
    AND (
      group_ids IS NULL
      OR v.grupo_id = ANY(group_ids)
    )
    AND (
      start_date IS NULL
      OR v.candidatura_createdate >= start_date
    )
    AND (
      end_date IS NULL
      OR v.candidatura_createdate <= end_date
    )
    AND (
      min_value IS NULL
      OR v.vagas_valor >= min_value
    )
    AND (
      max_value IS NULL
      OR v.vagas_valor <= max_value
    )
    -- Filtro por médicos (incluindo médicos regulares e pré-cadastro)
    AND (
      doctor_ids IS NULL
      OR v.medico_id = ANY(doctor_ids)
    )
    -- Filtro por status das candidaturas
    AND (
      application_status_filter IS NULL
      OR v.candidatura_status = ANY(application_status_filter)
    )
    -- Filtro por status das vagas
    AND (
      job_status_filter IS NULL
      OR v.vagas_status = ANY(job_status_filter)
    )
    -- Filtro por grades
    AND (
      grade_ids IS NULL
      OR v.grade_id = ANY(grade_ids)
    )
    AND (
      search_text IS NULL
      OR v.hospital_nome ILIKE '%' || search_text || '%'
      OR v.especialidade_nome ILIKE '%' || search_text || '%'
      OR v.vagas_observacoes ILIKE '%' || search_text || '%'
      OR v.setor_nome ILIKE '%' || search_text || '%'
    );
  
  RETURN QUERY
  SELECT COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'candidatura_id',
          v.candidaturas_id,
          'candidatura_status',
          v.candidatura_status,
          'candidatura_createdate',
          v.candidatura_createdate,
          'vaga_salva',
          v.vaga_salva,
          'medico_favorito',
          v.medico_favorito,
          'vaga',
          jsonb_build_object(
            'vagas_id',
            v.vagas_id,
            'vagas_data',
            v.vagas_data,
            'vagas_horainicio',
            v.vagas_horainicio,
            'vagas_horafim',
            v.vagas_horafim,
            'vagas_valor',
            v.vagas_valor,
            'vagas_status',
            v.vagas_status,
            'vagas_observacoes',
            v.vagas_observacoes,
            'vagas_datapagamento',
            v.vagas_datapagamento,
            'total_candidaturas',
            v.total_candidaturas,
            'vagas_createdate',
            v.vagas_createdate,
            'vagas_periodo',
            v.vagas_periodo,
            'vagas_periodo_nome',
            v.vagas_periodo_nome,
            'vagas_tipo',
            v.vagas_tipo,
            'vagas_tipo_nome',
            v.vagas_tipo_nome
          ),
          'medico',
          jsonb_build_object(
            'medico_id',
            v.medico_id,
            'medico_primeiro_nome',
            v.medico_primeiro_nome,
            'medico_sobrenome',
            v.medico_sobrenome,
            'medico_crm',
            v.medico_crm,
            'medico_estado',
            v.medico_estado,
            'medico_email',
            v.medico_email,
            'medico_telefone',
            v.medico_telefone
          ),
          'hospital',
          jsonb_build_object(
            'hospital_id',
            v.hospital_id,
            'hospital_nome',
            v.hospital_nome,
            'hospital_estado',
            v.hospital_estado,
            'hospital_lat',
            v.hospital_lat,
            'hospital_log',
            v.hospital_log,
            'hospital_end',
            v.hospital_end,
            'hospital_avatar',
            v.hospital_avatar
          ),
          'especialidade',
          jsonb_build_object(
            'especialidade_id',
            v.especialidade_id,
            'especialidade_nome',
            v.especialidade_nome
          ),
          'setor',
          jsonb_build_object(
            'setor_id',
            v.setor_id,
            'setor_nome',
            v.setor_nome
          ),
          'escalista',
          jsonb_build_object(
            'escalista_id',
            v.escalista_id,
            'escalista_nome',
            v.escalista_nome,
            'escalista_email',
            v.escalista_email,
            'escalista_telefone',
            v.escalista_telefone
          ),
          'grupo',
          jsonb_build_object(
            'grupo_id',
            v.grupo_id,
            'grupo_nome',
            v.grupo_nome
          ),
          'grade',
          jsonb_build_object(
            'grade_id',
            v.grade_id,
            'grade_nome',
            v.grade_nome,
            'grade_cor',
            v.grade_cor
          )
        )
      ),
      '[]'::jsonb
    ) AS data,
    jsonb_build_object(
      'current_page',
      validated_page,
      'page_size',
      validated_size,
      'total_count',
      total_count,
      'total_pages',
      CASE
        WHEN total_count = 0 THEN 0
        ELSE CEIL(total_count::numeric / validated_size::numeric)::integer
      END,
      'has_previous',
      validated_page > 1,
      'has_next',
      validated_page < CEIL(total_count::numeric / validated_size::numeric)::integer,
      'previous_page',
      CASE
        WHEN validated_page > 1 THEN validated_page - 1
        ELSE NULL
      END,
      'next_page',
      CASE
        WHEN validated_page < CEIL(total_count::numeric / validated_size::numeric)::integer THEN validated_page + 1
        ELSE NULL
      END
    ) AS pagination
  FROM (
      SELECT *
      FROM vw_vagas_candidaturas v
      WHERE v.candidaturas_id IS NOT NULL
        AND (
          hospital_ids IS NULL
          OR v.hospital_id = ANY(hospital_ids)
        )
        AND (
          specialty_ids IS NULL
          OR v.especialidade_id = ANY(specialty_ids)
        )
        AND (
          sector_ids IS NULL
          OR v.setor_id = ANY(sector_ids)
        )
        AND (
          period_ids IS NULL
          OR v.vagas_periodo = ANY(period_ids)
        )
        AND (
          type_ids IS NULL
          OR v.vagas_tipo = ANY(type_ids)
        )
        AND (
          group_ids IS NULL
          OR v.grupo_id = ANY(group_ids)
        )
        AND (
          start_date IS NULL
          OR v.candidatura_createdate >= start_date
        )
        AND (
          end_date IS NULL
          OR v.candidatura_createdate <= end_date
        )
        AND (
          min_value IS NULL
          OR v.vagas_valor >= min_value
        )
        AND (
          max_value IS NULL
          OR v.vagas_valor <= max_value
        )
        -- Filtro por médicos (incluindo médicos regulares e pré-cadastro)
        AND (
          doctor_ids IS NULL
          OR v.medico_id = ANY(doctor_ids)
        )
        -- Filtro por status das candidaturas
        AND (
          application_status_filter IS NULL
          OR v.candidatura_status = ANY(application_status_filter)
        )
        -- Filtro por status das vagas
        AND (
          job_status_filter IS NULL
          OR v.vagas_status = ANY(job_status_filter)
        )
        -- Filtro por grades
        AND (
          grade_ids IS NULL
          OR v.grade_id = ANY(grade_ids)
        )
        AND (
          search_text IS NULL
          OR v.hospital_nome ILIKE '%' || search_text || '%'
          OR v.especialidade_nome ILIKE '%' || search_text || '%'
          OR v.vagas_observacoes ILIKE '%' || search_text || '%'
          OR v.setor_nome ILIKE '%' || search_text || '%'
        )
      ORDER BY 
        CASE
          WHEN validated_order_by = 'candidatura_createdate'
          AND validated_order_direction = 'DESC' THEN v.candidatura_createdate
        END DESC,
        CASE
          WHEN validated_order_by = 'candidatura_createdate'
          AND validated_order_direction = 'ASC' THEN v.candidatura_createdate
        END ASC,
        CASE
          WHEN validated_order_by = 'vagas_createdate'
          AND validated_order_direction = 'DESC' THEN v.vagas_createdate
        END DESC,
        CASE
          WHEN validated_order_by = 'vagas_createdate'
          AND validated_order_direction = 'ASC' THEN v.vagas_createdate
        END ASC,
        CASE
          WHEN validated_order_by = 'vagas_data'
          AND validated_order_direction = 'DESC' THEN v.vagas_data
        END DESC,
        CASE
          WHEN validated_order_by = 'vagas_data'
          AND validated_order_direction = 'ASC' THEN v.vagas_data
        END ASC,
        CASE
          WHEN validated_order_by = 'vagas_valor'
          AND validated_order_direction = 'DESC' THEN v.vagas_valor
        END DESC,
        CASE
          WHEN validated_order_by = 'vagas_valor'
          AND validated_order_direction = 'ASC' THEN v.vagas_valor
        END ASC,
        CASE
          WHEN validated_order_by = 'medico_primeiro_nome'
          AND validated_order_direction = 'DESC' THEN v.medico_primeiro_nome
        END DESC,
        CASE
          WHEN validated_order_by = 'medico_primeiro_nome'
          AND validated_order_direction = 'ASC' THEN v.medico_primeiro_nome
        END ASC,
        CASE
          WHEN validated_order_by = 'hospital_nome'
          AND validated_order_direction = 'DESC' THEN v.hospital_nome
        END DESC,
        CASE
          WHEN validated_order_by = 'hospital_nome'
          AND validated_order_direction = 'ASC' THEN v.hospital_nome
        END ASC,
        CASE
          WHEN validated_order_by = 'setor_nome'
          AND validated_order_direction = 'DESC' THEN v.setor_nome
        END DESC,
        CASE
          WHEN validated_order_by = 'setor_nome'
          AND validated_order_direction = 'ASC' THEN v.setor_nome
        END ASC,
        CASE
          WHEN validated_order_by = 'especialidade_nome'
          AND validated_order_direction = 'DESC' THEN v.especialidade_nome
        END DESC,
        CASE
          WHEN validated_order_by = 'especialidade_nome'
          AND validated_order_direction = 'ASC' THEN v.especialidade_nome
        END ASC,
        CASE
          WHEN validated_order_by = 'vagas_periodo_nome'
          AND validated_order_direction = 'DESC' THEN v.vagas_periodo_nome
        END DESC,
        CASE
          WHEN validated_order_by = 'vagas_periodo_nome'
          AND validated_order_direction = 'ASC' THEN v.vagas_periodo_nome
        END ASC,
        CASE
          WHEN validated_order_by = 'vagas_status'
          AND validated_order_direction = 'DESC' THEN v.vagas_status
        END DESC,
        CASE
          WHEN validated_order_by = 'vagas_status'
          AND validated_order_direction = 'ASC' THEN v.vagas_status
        END ASC,
        CASE
          WHEN validated_order_by = 'candidatura_status'
          AND validated_order_direction = 'DESC' THEN v.candidatura_status
        END DESC,
        CASE
          WHEN validated_order_by = 'candidatura_status'
          AND validated_order_direction = 'ASC' THEN v.candidatura_status
        END ASC
      LIMIT validated_size OFFSET offset_value
    ) v;
END;
$$;


ALTER FUNCTION "public"."get_applications_paginated"("page_number" integer, "page_size" integer, "hospital_ids" "uuid"[], "specialty_ids" "uuid"[], "sector_ids" "uuid"[], "start_date" "date", "end_date" "date", "min_value" numeric, "max_value" numeric, "period_ids" "uuid"[], "type_ids" "uuid"[], "group_ids" "uuid"[], "search_text" "text", "doctor_ids" "uuid"[], "application_status_filter" "text"[], "job_status_filter" "text"[], "grade_ids" "uuid"[], "order_by" "text", "order_direction" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_applications_paginated"("page_number" integer, "page_size" integer, "hospital_ids" "uuid"[], "specialty_ids" "uuid"[], "sector_ids" "uuid"[], "start_date" "date", "end_date" "date", "min_value" numeric, "max_value" numeric, "period_ids" "uuid"[], "type_ids" "uuid"[], "group_ids" "uuid"[], "search_text" "text", "doctor_ids" "uuid"[], "application_status_filter" "text"[], "job_status_filter" "text"[], "grade_ids" "uuid"[], "order_by" "text", "order_direction" "text") IS 'Busca candidaturas individuais (não agrupadas) com filtros opcionais usando arrays em snake_case. Filtros disponíveis: hospital_ids[], specialty_ids[], sector_ids[], period_ids[], type_ids[], group_ids[], doctor_ids[], application_status_filter[PENDENTE,APROVADO,REPROVADO], job_status_filter[aberta,fechada,cancelada,anunciada], grade_ids[], além de filtros de data, valor e texto. Parâmetros de ordenação: order_by[candidatura_createdate,vagas_createdate,vagas_data,vagas_valor,medico_primeiro_nome,hospital_nome,setor_nome,especialidade_nome,vagas_periodo_nome,vagas_status,candidatura_status], order_direction[ASC,DESC]. Retorna cada candidatura separadamente com informações completas da vaga e médico associados.';



CREATE OR REPLACE FUNCTION "public"."get_cpf"("cpf_input" "text") RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    exists_flag BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM public.medicos
        WHERE medico_cpf = cpf_input
    ) INTO exists_flag;
    
    RETURN exists_flag;
END;
$$;


ALTER FUNCTION "public"."get_cpf"("cpf_input" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_crm"("crm_input" "text") RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$DECLARE
    exists_flag BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM public.medicos
        WHERE medico_crm = crm_input
    ) INTO exists_flag;
    
    RETURN exists_flag;
END;$$;


ALTER FUNCTION "public"."get_crm"("crm_input" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_current_user_grupo_id"() RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$DECLARE
    current_user_id UUID;
    user_role TEXT;
    grupo_id_result UUID;
BEGIN
    -- Obter o ID do usuário atual
    current_user_id := auth.uid();
    
    -- Se não há usuário autenticado, retornar NULL
    IF current_user_id IS NULL THEN
        RETURN NULL;
    END IF;

    -- Buscar o grupo_id
        SELECT grupo_id INTO grupo_id_result
        FROM escalistas
        WHERE auth_id = current_user_id;
        
        -- Se encontrou o grupo, retornar
        IF grupo_id_result IS NOT NULL THEN
            RETURN grupo_id_result;
        END IF;

        -- Se encontrou não grupo, retornar NULL
        RETURN NULL;

END;$$;


ALTER FUNCTION "public"."get_current_user_grupo_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_documento_historico"("p_carteira_id" "uuid") RETURNS TABLE("tipo" "text", "status" boolean, "updated_at" timestamp without time zone, "updated_by" "uuid")
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        unnest(ARRAY[
            'diploma', 'crm', 'cpf', 'rg', 'especializacaodiploma',
            'anuidadecrm', 'eticoprofissional', 'comprovanteresidencia',
            'foto', 'comprovantevacina'
        ]) as tipo,
        unnest(ARRAY[
            carteira_diploma_status, carteira_crm_status, carteira_cpf_status,
            carteira_rg_status, carteira_especializacaodiploma_status,
            carteira_anuidadecrm_status, carteira_eticoprofissional_status,
            carteira_comprovanteresidencia_status, carteira_foto_status,
            carteira_comprovantevacina_status
        ]) as status,
        unnest(ARRAY[
            carteira_diploma_updatedate, carteira_crm_updatedate,
            carteira_cpf_updatedate, carteira_rg_updatedate,
            carteira_especializacaodiploma_updatedate,
            carteira_anuidadecrm_updatedate,
            carteira_eticoprofissional_updatedate,
            carteira_comprovanteresidencia_updatedate,
            carteira_foto_updatedate,
            carteira_comprovantevacina_updatedate
        ]) as updated_at,
        unnest(ARRAY[
            carteira_diploma_updateuserid, carteira_crm_updateuserid,
            carteira_cpf_updateuserid, carteira_rg_updateuserid,
            carteira_especializacaodiploma_updateuserid,
            carteira_anuidadecrm_updateuserid,
            carteira_eticoprofissional_updateuserid,
            carteira_comprovanteresidencia_updateuserid,
            carteira_foto_updateuserid,
            carteira_comprovantevacina_updateuserid
        ]) as updated_by
    FROM carteira_digital
    WHERE carteira_id = p_carteira_id;
END;
$$;


ALTER FUNCTION "public"."get_documento_historico"("p_carteira_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_documento_historico"("p_carteira_id" "uuid", "p_tipo" "text") RETURNS TABLE("data_atualizacao" timestamp without time zone, "status" boolean, "url" character varying, "usuario_id" "uuid")
    LANGUAGE "plpgsql"
    AS $_$
DECLARE
    v_column_base TEXT;
BEGIN
    v_column_base := 'carteira_' || p_tipo;
    
    RETURN QUERY EXECUTE format('
        SELECT 
            %I_updatedate as data_atualizacao,
            %I_status as status,
            %I as url,
            %I_updateuserid as usuario_id
        FROM carteira_digital
        WHERE carteira_id = $$1
        AND %I_updatedate IS NOT NULL',
        v_column_base, v_column_base, v_column_base, v_column_base, v_column_base)
    USING p_carteira_id;
END;
$_$;


ALTER FUNCTION "public"."get_documento_historico"("p_carteira_id" "uuid", "p_tipo" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_documentos_pendentes"("p_carteira_id" "uuid") RETURNS TABLE("tipo" character varying, "label" character varying, "status" boolean, "url" character varying, "ultima_atualizacao" timestamp without time zone, "atualizado_por" "uuid")
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        doc.tipo,
        doc.label,
        doc.status,
        doc.url,
        doc.update_date,
        doc.update_user
    FROM (
        SELECT 
            'diploma'::VARCHAR as tipo,
            'Diploma'::VARCHAR as label,
            carteira_diploma_status as status,
            carteira_diploma as url,
            carteira_diploma_updatedate as update_date,
            carteira_diploma_updateuserid as update_user
        FROM carteira_digital WHERE carteira_id = p_carteira_id
        UNION ALL
        SELECT 'crm', 'CRM', carteira_crm_status, carteira_crm, carteira_crm_updatedate, carteira_crm_updateuserid
        FROM carteira_digital WHERE carteira_id = p_carteira_id
        UNION ALL
        SELECT 'cpf', 'CPF', carteira_cpf_status, carteira_cpf, carteira_cpf_updatedate, carteira_cpf_updateuserid
        FROM carteira_digital WHERE carteira_id = p_carteira_id
        UNION ALL
        SELECT 'rg', 'RG', carteira_rg_status, carteira_rg, carteira_rg_updatedate, carteira_rg_updateuserid
        FROM carteira_digital WHERE carteira_id = p_carteira_id
        UNION ALL
        SELECT 'especializacaodiploma', 'Diploma de Especialização', 
               carteira_especializacaodiploma_status, carteira_especializacaodiploma,
               carteira_especializacaodiploma_updatedate, carteira_especializacaodiploma_updateuserid
        FROM carteira_digital WHERE carteira_id = p_carteira_id
        UNION ALL
        SELECT 'anuidadecrm', 'Anuidade CRM', carteira_anuidadecrm_status, carteira_anuidadecrm,
               carteira_anuidadecrm_updatedate, carteira_anuidadecrm_updateuserid
        FROM carteira_digital WHERE carteira_id = p_carteira_id
        UNION ALL
        SELECT 'eticoprofissional', 'Certidão Ético-Profissional', 
               carteira_eticoprofissional_status, carteira_eticoprofissional,
               carteira_eticoprofissional_updatedate, carteira_eticoprofissional_updateuserid
        FROM carteira_digital WHERE carteira_id = p_carteira_id
        UNION ALL
        SELECT 'comprovanteresidencia', 'Comprovante de Residência',
               carteira_comprovanteresidencia_status, carteira_comprovanteresidencia,
               carteira_comprovanteresidencia_updatedate, carteira_comprovanteresidencia_updateuserid
        FROM carteira_digital WHERE carteira_id = p_carteira_id
        UNION ALL
        SELECT 'foto', 'Foto', carteira_foto_status, carteira_foto,
               carteira_foto_updatedate, carteira_foto_updateuserid
        FROM carteira_digital WHERE carteira_id = p_carteira_id
        UNION ALL
        SELECT 'comprovantevacina', 'Comprovante de Vacina',
               carteira_comprovantevacina_status, carteira_comprovantevacina,
               carteira_comprovantevacina_updatedate, carteira_comprovantevacina_updateuserid
        FROM carteira_digital WHERE carteira_id = p_carteira_id
    ) doc
    WHERE NOT doc.status OR doc.url = 'AGUARDANDO'
    ORDER BY doc.label;
END;
$$;


ALTER FUNCTION "public"."get_documentos_pendentes"("p_carteira_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_email"("e_mail" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  email_found BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM auth.users
    WHERE email = e_mail
  ) INTO email_found;
  
  RETURN email_found;
END;
$$;


ALTER FUNCTION "public"."get_email"("e_mail" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_medicos_com_documentos"() RETURNS TABLE("id" "uuid", "nome" character varying, "crm" character varying, "medico_especialidade" character varying, "especialidade_nome" character varying, "status" boolean, "createdate" timestamp without time zone, "documentos" "jsonb")
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  RETURN QUERY
  SELECT 
    vmd.id,
    vmd.nome::character varying,
    vmd.crm::character varying,
    vmd.medico_especialidade::character varying,
    vmd.especialidade_nome::character varying,
    vmd.status,
    vmd.createdate,
    vmd.documentos
  FROM vw_medicos_documentos vmd;
END;
$$;


ALTER FUNCTION "public"."get_medicos_com_documentos"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_medicos_documentacao_pendente"() RETURNS TABLE("medico_id" "uuid", "nome" character varying, "crm" character varying, "especialidade_id" "uuid", "percentual_conclusao" numeric, "documentos_pendentes" "json")
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    WITH medicos_status AS (
        SELECT 
            m.medico_id,
            (m.medico_primeironome || ' ' || m.medico_sobrenome)::VARCHAR as nome,
            m.medico_crm as crm,
            m.medico_especialidade as especialidade_id,
            cd.carteira_id,
            perc.percentual as percentual_conclusao
        FROM medicos m
        JOIN carteira_digital cd ON cd.medicos_id = m.medico_id
        CROSS JOIN LATERAL (
            SELECT percentual 
            FROM get_percentual_conclusao(cd.carteira_id)
        ) perc
        WHERE m.medico_deleteat IS NULL
    )
    SELECT 
        ms.medico_id,
        ms.nome,
        ms.crm,
        ms.especialidade_id,
        ms.percentual_conclusao,
        (
            SELECT json_agg(docs)
            FROM (
                SELECT tipo, label, url
                FROM get_documentos_pendentes(ms.carteira_id)
            ) docs
        ) as documentos_pendentes
    FROM medicos_status ms
    WHERE ms.percentual_conclusao < 100
       OR EXISTS (
           SELECT 1 
           FROM get_documentos_pendentes(ms.carteira_id) 
           WHERE url = 'AGUARDANDO' OR url LIKE 'REPROVADO:%'
       )
    ORDER BY ms.percentual_conclusao DESC, ms.nome;
END;
$$;


ALTER FUNCTION "public"."get_medicos_documentacao_pendente"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_percentual_conclusao"("p_carteira_id" "uuid") RETURNS TABLE("total_documentos" bigint, "documentos_aprovados" bigint, "percentual" numeric, "status_geral" boolean)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    WITH doc_status AS (
        SELECT 
            10::BIGINT as total,
            COUNT(*) FILTER (WHERE status) as aprovados
        FROM (
            SELECT carteira_diploma_status as status FROM carteira_digital WHERE carteira_id = p_carteira_id
            UNION ALL
            SELECT carteira_crm_status FROM carteira_digital WHERE carteira_id = p_carteira_id
            UNION ALL
            SELECT carteira_cpf_status FROM carteira_digital WHERE carteira_id = p_carteira_id
            UNION ALL
            SELECT carteira_rg_status FROM carteira_digital WHERE carteira_id = p_carteira_id
            UNION ALL
            SELECT carteira_especializacaodiploma_status FROM carteira_digital WHERE carteira_id = p_carteira_id
            UNION ALL
            SELECT carteira_anuidadecrm_status FROM carteira_digital WHERE carteira_id = p_carteira_id
            UNION ALL
            SELECT carteira_eticoprofissional_status FROM carteira_digital WHERE carteira_id = p_carteira_id
            UNION ALL
            SELECT carteira_comprovanteresidencia_status FROM carteira_digital WHERE carteira_id = p_carteira_id
            UNION ALL
            SELECT carteira_foto_status FROM carteira_digital WHERE carteira_id = p_carteira_id
            UNION ALL
            SELECT carteira_comprovantevacina_status FROM carteira_digital WHERE carteira_id = p_carteira_id
        ) docs
    )
    SELECT 
        total as total_documentos,
        aprovados as documentos_aprovados,
        ROUND((aprovados::NUMERIC / total::NUMERIC) * 100, 2) as percentual,
        aprovados = total as status_geral
    FROM doc_status;
END;
$$;


ALTER FUNCTION "public"."get_percentual_conclusao"("p_carteira_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_phonenumber"("p_phone" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  phone_found BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM auth.users
    WHERE phone = p_phone
  ) INTO phone_found;
  
  RETURN phone_found;
END;
$$;


ALTER FUNCTION "public"."get_phonenumber"("p_phone" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_urls_pendentes"("p_carteira_id" "uuid") RETURNS TABLE("tipo" character varying, "label" character varying, "status" boolean, "url" character varying, "situacao" character varying)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        doc.tipo,
        doc.label,
        doc.status,
        doc.url,
        (CASE
            WHEN doc.url = 'AGUARDANDO' THEN 'Aguardando envio'::VARCHAR
            WHEN doc.url LIKE 'REPROVADO:%' THEN ('Reprovado - ' || substring(doc.url from 11))::VARCHAR
            ELSE 'URL válida'::VARCHAR
        END) as situacao
    FROM (
        SELECT 
            'diploma'::VARCHAR as tipo,
            'Diploma'::VARCHAR as label,
            carteira_diploma_status as status,
            carteira_diploma as url
        FROM carteira_digital WHERE carteira_id = p_carteira_id
        UNION ALL
        SELECT 'crm'::VARCHAR, 'CRM'::VARCHAR, carteira_crm_status, carteira_crm
        FROM carteira_digital WHERE carteira_id = p_carteira_id
        UNION ALL
        SELECT 'cpf'::VARCHAR, 'CPF'::VARCHAR, carteira_cpf_status, carteira_cpf
        FROM carteira_digital WHERE carteira_id = p_carteira_id
        UNION ALL
        SELECT 'rg'::VARCHAR, 'RG'::VARCHAR, carteira_rg_status, carteira_rg
        FROM carteira_digital WHERE carteira_id = p_carteira_id
        UNION ALL
        SELECT 'especializacaodiploma'::VARCHAR, 'Diploma de Especialização'::VARCHAR, 
               carteira_especializacaodiploma_status, carteira_especializacaodiploma
        FROM carteira_digital WHERE carteira_id = p_carteira_id
        UNION ALL
        SELECT 'anuidadecrm'::VARCHAR, 'Anuidade CRM'::VARCHAR, carteira_anuidadecrm_status, carteira_anuidadecrm
        FROM carteira_digital WHERE carteira_id = p_carteira_id
        UNION ALL
        SELECT 'eticoprofissional'::VARCHAR, 'Certidão Ético-Profissional'::VARCHAR, 
               carteira_eticoprofissional_status, carteira_eticoprofissional
        FROM carteira_digital WHERE carteira_id = p_carteira_id
        UNION ALL
        SELECT 'comprovanteresidencia'::VARCHAR, 'Comprovante de Residência'::VARCHAR,
               carteira_comprovanteresidencia_status, carteira_comprovanteresidencia
        FROM carteira_digital WHERE carteira_id = p_carteira_id
        UNION ALL
        SELECT 'foto'::VARCHAR, 'Foto'::VARCHAR, carteira_foto_status, carteira_foto
        FROM carteira_digital WHERE carteira_id = p_carteira_id
        UNION ALL
        SELECT 'comprovantevacina'::VARCHAR, 'Comprovante de Vacina'::VARCHAR,
               carteira_comprovantevacina_status, carteira_comprovantevacina
        FROM carteira_digital WHERE carteira_id = p_carteira_id
    ) doc
    WHERE doc.url = 'AGUARDANDO' OR doc.url LIKE 'REPROVADO:%'
    ORDER BY doc.label;
END;
$$;


ALTER FUNCTION "public"."get_urls_pendentes"("p_carteira_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_vagas_paginated"("page_number" integer DEFAULT 1, "page_size" integer DEFAULT 10, "hospital_ids" "uuid"[] DEFAULT NULL::"uuid"[], "specialty_ids" "uuid"[] DEFAULT NULL::"uuid"[], "sector_ids" "uuid"[] DEFAULT NULL::"uuid"[], "start_date" "date" DEFAULT NULL::"date", "end_date" "date" DEFAULT NULL::"date", "min_value" numeric DEFAULT NULL::numeric, "max_value" numeric DEFAULT NULL::numeric, "period_ids" "uuid"[] DEFAULT NULL::"uuid"[], "type_ids" "uuid"[] DEFAULT NULL::"uuid"[], "group_ids" "uuid"[] DEFAULT NULL::"uuid"[], "search_text" "text" DEFAULT NULL::"text", "doctor_ids" "uuid"[] DEFAULT NULL::"uuid"[], "application_status_filter" "text"[] DEFAULT NULL::"text"[], "job_status_filter" "text"[] DEFAULT NULL::"text"[], "grade_ids" "uuid"[] DEFAULT NULL::"uuid"[], "order_by" "text" DEFAULT 'vagas_data'::"text", "order_direction" "text" DEFAULT 'DESC'::"text") RETURNS TABLE("data" "jsonb", "pagination" "jsonb")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
DECLARE 
  validated_page integer;
  validated_size integer;
  total_count bigint;
  offset_value integer;
  validated_order_by text;
  validated_order_direction text;
  order_clause text;
BEGIN 
  validated_page := CASE
    WHEN page_number < 1 THEN 1
    ELSE page_number
  END;
  
  validated_size := CASE
    WHEN page_size < 1 THEN 10
    WHEN page_size > 100 THEN 100
    ELSE page_size
  END;
  
  -- Validação dos parâmetros de ordenação
  validated_order_by := CASE
    WHEN order_by IN (
      'vagas_data',
      'vagas_valor',
      'hospital_nome',
      'setor_nome',
      'especialidade_nome',
      'vagas_periodo_nome',
      'vagas_status',
      'total_candidaturas'
    ) THEN order_by
    ELSE 'vagas_createdate'
  END;
  
  validated_order_direction := CASE
    WHEN UPPER(order_direction) IN ('ASC', 'DESC') THEN UPPER(order_direction)
    ELSE 'DESC'
  END;
  
  offset_value := (validated_page - 1) * validated_size;
  
  WITH vagas_filtradas AS (
    SELECT DISTINCT v.vagas_id
    FROM vw_vagas_candidaturas v
    WHERE 1 = 1
      AND (
        hospital_ids IS NULL
        OR v.hospital_id = ANY(hospital_ids)
      )
      AND (
        specialty_ids IS NULL
        OR v.especialidade_id = ANY(specialty_ids)
      )
      AND (
        sector_ids IS NULL
        OR v.setor_id = ANY(sector_ids)
      )
      AND (
        period_ids IS NULL
        OR v.vagas_periodo = ANY(period_ids)
      )
      AND (
        type_ids IS NULL
        OR v.vagas_tipo = ANY(type_ids)
      )
      AND (
        group_ids IS NULL
        OR v.grupo_id = ANY(group_ids)
      )
      AND (
        start_date IS NULL
        OR v.vagas_data >= start_date
      )
      AND (
        end_date IS NULL
        OR v.vagas_data <= end_date
      )
      AND (
        min_value IS NULL
        OR v.vagas_valor >= min_value
      )
      AND (
        max_value IS NULL
        OR v.vagas_valor <= max_value
      )
      -- Filtro por médicos (incluindo médicos regulares e pré-cadastro)
      AND (
        doctor_ids IS NULL
        OR v.medico_id = ANY(doctor_ids)
      )
      -- Filtro por status das candidaturas
      AND (
        application_status_filter IS NULL
        OR v.candidatura_status = ANY(application_status_filter)
      )
      -- Filtro por status das vagas
      AND (
        job_status_filter IS NULL
        OR v.vagas_status = ANY(job_status_filter)
      )
      -- Filtro por grades
      AND (
        grade_ids IS NULL
        OR v.grade_id = ANY(grade_ids)
      )
      AND (
        search_text IS NULL
        OR v.hospital_nome ILIKE '%' || search_text || '%'
        OR v.especialidade_nome ILIKE '%' || search_text || '%'
        OR v.vagas_observacoes ILIKE '%' || search_text || '%'
        OR v.setor_nome ILIKE '%' || search_text || '%'
      )
  )
  SELECT COUNT(*) INTO total_count
  FROM vagas_filtradas;
  
  RETURN QUERY 
  WITH vagas_agrupadas AS (
    SELECT v.vagas_id,
      (array_agg(v.vagas_data)) [1] AS vagas_data,
      (array_agg(v.vagas_horainicio)) [1] AS vagas_horainicio,
      (array_agg(v.vagas_horafim)) [1] AS vagas_horafim,
      (array_agg(v.vagas_valor)) [1] AS vagas_valor,
      (array_agg(v.vagas_status)) [1] AS vagas_status,
      (array_agg(v.vagas_observacoes)) [1] AS vagas_observacoes,
      (array_agg(v.vagas_datapagamento)) [1] AS vagas_datapagamento,
      (array_agg(v.total_candidaturas)) [1] AS total_candidaturas,
      (array_agg(v.vagas_createdate)) [1] AS vagas_createdate,
      (array_agg(v.vagas_periodo)) [1] AS vagas_periodo,
      (array_agg(v.vagas_periodo_nome)) [1] AS vagas_periodo_nome,
      (array_agg(v.vagas_tipo)) [1] AS vagas_tipo,
      (array_agg(v.vagas_tipo_nome)) [1] AS vagas_tipo_nome,
      (array_agg(v.hospital_id)) [1] AS hospital_id,
      (array_agg(v.hospital_nome)) [1] AS hospital_nome,
      (array_agg(v.hospital_estado)) [1] AS hospital_estado,
      (array_agg(v.hospital_lat)) [1] AS hospital_lat,
      (array_agg(v.hospital_log)) [1] AS hospital_log,
      (array_agg(v.hospital_end)) [1] AS hospital_end,
      (array_agg(v.hospital_avatar)) [1] AS hospital_avatar,
      (array_agg(v.especialidade_id)) [1] AS especialidade_id,
      (array_agg(v.especialidade_nome)) [1] AS especialidade_nome,
      (array_agg(v.setor_id)) [1] AS setor_id,
      (array_agg(v.setor_nome)) [1] AS setor_nome,
      (array_agg(v.escalista_id)) [1] AS escalista_id,
      (array_agg(v.escalista_nome)) [1] AS escalista_nome,
      (array_agg(v.escalista_email)) [1] AS escalista_email,
      (array_agg(v.escalista_telefone)) [1] AS escalista_telefone,
      (array_agg(v.grupo_id)) [1] AS grupo_id,
      (array_agg(v.grupo_nome)) [1] AS grupo_nome,
      (array_agg(v.grade_id)) [1] AS grade_id,
      (array_agg(v.grade_nome)) [1] AS grade_nome,
      (array_agg(v.grade_cor)) [1] AS grade_cor,
      array_agg(
        CASE
          WHEN v.candidaturas_id IS NOT NULL THEN jsonb_build_object(
            'candidaturas_id',
            v.candidaturas_id,
            'candidatura_status',
            v.candidatura_status,
            'candidatura_createdate',
            v.candidatura_createdate,
            'vaga_salva',
            v.vaga_salva,
            'medico_favorito',
            v.medico_favorito,
            'medico_id',
            v.medico_id,
            'medico_primeiro_nome',
            v.medico_primeiro_nome,
            'medico_sobrenome',
            v.medico_sobrenome,
            'medico_crm',
            v.medico_crm,
            'medico_estado',
            v.medico_estado,
            'medico_email',
            v.medico_email,
            'medico_telefone',
            v.medico_telefone
          )
          ELSE NULL
        END
        ORDER BY v.candidatura_createdate DESC
      ) FILTER (
        WHERE v.candidaturas_id IS NOT NULL
      ) AS candidaturas_list
    FROM vw_vagas_candidaturas v
    WHERE 1 = 1
      AND (
        hospital_ids IS NULL
        OR v.hospital_id = ANY(hospital_ids)
      )
      AND (
        specialty_ids IS NULL
        OR v.especialidade_id = ANY(specialty_ids)
      )
      AND (
        sector_ids IS NULL
        OR v.setor_id = ANY(sector_ids)
      )
      AND (
        period_ids IS NULL
        OR v.vagas_periodo = ANY(period_ids)
      )
      AND (
        type_ids IS NULL
        OR v.vagas_tipo = ANY(type_ids)
      )
      AND (
        group_ids IS NULL
        OR v.grupo_id = ANY(group_ids)
      )
      AND (
        start_date IS NULL
        OR v.vagas_data >= start_date
      )
      AND (
        end_date IS NULL
        OR v.vagas_data <= end_date
      )
      AND (
        min_value IS NULL
        OR v.vagas_valor >= min_value
      )
      AND (
        max_value IS NULL
        OR v.vagas_valor <= max_value
      )
      -- Filtro por médicos (incluindo médicos regulares e pré-cadastro)
      AND (
        doctor_ids IS NULL
        OR v.medico_id = ANY(doctor_ids)
      )
      -- Filtro por status das candidaturas
      AND (
        application_status_filter IS NULL
        OR v.candidatura_status = ANY(application_status_filter)
      )
      -- Filtro por status das vagas
      AND (
        job_status_filter IS NULL
        OR v.vagas_status = ANY(job_status_filter)
      )
      -- Filtro por grades
      AND (
        grade_ids IS NULL
        OR v.grade_id = ANY(grade_ids)
      )
      AND (
        search_text IS NULL
        OR v.hospital_nome ILIKE '%' || search_text || '%'
        OR v.especialidade_nome ILIKE '%' || search_text || '%'
        OR v.vagas_observacoes ILIKE '%' || search_text || '%'
        OR v.setor_nome ILIKE '%' || search_text || '%'
      )
    GROUP BY v.vagas_id
    ORDER BY 
      CASE
        WHEN validated_order_by = 'vagas_data'
        AND validated_order_direction = 'DESC' THEN (array_agg(v.vagas_data)) [1]
      END DESC,
      CASE
        WHEN validated_order_by = 'vagas_data'
        AND validated_order_direction = 'ASC' THEN (array_agg(v.vagas_data)) [1]
      END ASC,
      CASE
        WHEN validated_order_by = 'vagas_valor'
        AND validated_order_direction = 'DESC' THEN (array_agg(v.vagas_valor)) [1]
      END DESC,
      CASE
        WHEN validated_order_by = 'vagas_valor'
        AND validated_order_direction = 'ASC' THEN (array_agg(v.vagas_valor)) [1]
      END ASC,
      CASE
        WHEN validated_order_by = 'hospital_nome'
        AND validated_order_direction = 'DESC' THEN (array_agg(v.hospital_nome)) [1]
      END DESC,
      CASE
        WHEN validated_order_by = 'hospital_nome'
        AND validated_order_direction = 'ASC' THEN (array_agg(v.hospital_nome)) [1]
      END ASC,
      CASE
        WHEN validated_order_by = 'setor_nome'
        AND validated_order_direction = 'DESC' THEN (array_agg(v.setor_nome)) [1]
      END DESC,
      CASE
        WHEN validated_order_by = 'setor_nome'
        AND validated_order_direction = 'ASC' THEN (array_agg(v.setor_nome)) [1]
      END ASC,
      CASE
        WHEN validated_order_by = 'especialidade_nome'
        AND validated_order_direction = 'DESC' THEN (array_agg(v.especialidade_nome)) [1]
      END DESC,
      CASE
        WHEN validated_order_by = 'especialidade_nome'
        AND validated_order_direction = 'ASC' THEN (array_agg(v.especialidade_nome)) [1]
      END ASC,
      CASE
        WHEN validated_order_by = 'vagas_periodo_nome'
        AND validated_order_direction = 'DESC' THEN (array_agg(v.vagas_periodo_nome)) [1]
      END DESC,
      CASE
        WHEN validated_order_by = 'vagas_periodo_nome'
        AND validated_order_direction = 'ASC' THEN (array_agg(v.vagas_periodo_nome)) [1]
      END ASC,
      CASE
        WHEN validated_order_by = 'vagas_status'
        AND validated_order_direction = 'DESC' THEN (array_agg(v.vagas_status)) [1]
      END DESC,
      CASE
        WHEN validated_order_by = 'vagas_status'
        AND validated_order_direction = 'ASC' THEN (array_agg(v.vagas_status)) [1]
      END ASC,
      CASE
        WHEN validated_order_by = 'total_candidaturas'
        AND validated_order_direction = 'DESC' THEN (array_agg(v.total_candidaturas)) [1]
      END DESC,
      CASE
        WHEN validated_order_by = 'total_candidaturas'
        AND validated_order_direction = 'ASC' THEN (array_agg(v.total_candidaturas)) [1]
      END ASC
    LIMIT validated_size OFFSET offset_value
  )
  SELECT COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'vagas_id',
          v.vagas_id,
          'vagas_data',
          v.vagas_data,
          'vagas_horainicio',
          v.vagas_horainicio,
          'vagas_horafim',
          v.vagas_horafim,
          'vagas_valor',
          v.vagas_valor,
          'vagas_status',
          v.vagas_status,
          'vagas_observacoes',
          v.vagas_observacoes,
          'vagas_datapagamento',
          v.vagas_datapagamento,
          'total_candidaturas',
          v.total_candidaturas,
          'vagas_createdate',
          v.vagas_createdate,
          'vagas_periodo',
          v.vagas_periodo,
          'vagas_periodo_nome',
          v.vagas_periodo_nome,
          'vagas_tipo',
          v.vagas_tipo,
          'vagas_tipo_nome',
          v.vagas_tipo_nome,
          'hospital',
          jsonb_build_object(
            'hospital_id',
            v.hospital_id,
            'hospital_nome',
            v.hospital_nome,
            'hospital_estado',
            v.hospital_estado,
            'hospital_lat',
            v.hospital_lat,
            'hospital_log',
            v.hospital_log,
            'hospital_end',
            v.hospital_end,
            'hospital_avatar',
            v.hospital_avatar
          ),
          'especialidade',
          jsonb_build_object(
            'especialidade_id',
            v.especialidade_id,
            'especialidade_nome',
            v.especialidade_nome
          ),
          'setor',
          jsonb_build_object(
            'setor_id',
            v.setor_id,
            'setor_nome',
            v.setor_nome
          ),
          'escalista',
          jsonb_build_object(
            'escalista_id',
            v.escalista_id,
            'escalista_nome',
            v.escalista_nome,
            'escalista_email',
            v.escalista_email,
            'escalista_telefone',
            v.escalista_telefone
          ),
          'grupo',
          jsonb_build_object(
            'grupo_id',
            v.grupo_id,
            'grupo_nome',
            v.grupo_nome
          ),
          'candidaturas',
          COALESCE(
            array_to_json(v.candidaturas_list)::jsonb,
            '[]'::jsonb
          ),
          'grade',
          jsonb_build_object(
            'grade_id',
            v.grade_id,
            'grade_nome',
            v.grade_nome,
            'grade_cor',
            v.grade_cor
          )
        )
        ORDER BY 
          CASE
            WHEN validated_order_by = 'vagas_data'
            AND validated_order_direction = 'DESC' THEN v.vagas_data
          END DESC,
          CASE
            WHEN validated_order_by = 'vagas_data'
            AND validated_order_direction = 'ASC' THEN v.vagas_data
          END ASC,
          CASE
            WHEN validated_order_by = 'vagas_valor'
            AND validated_order_direction = 'DESC' THEN v.vagas_valor
          END DESC,
          CASE
            WHEN validated_order_by = 'vagas_valor'
            AND validated_order_direction = 'ASC' THEN v.vagas_valor
          END ASC,
          CASE
            WHEN validated_order_by = 'hospital_nome'
            AND validated_order_direction = 'DESC' THEN v.hospital_nome
          END DESC,
          CASE
            WHEN validated_order_by = 'hospital_nome'
            AND validated_order_direction = 'ASC' THEN v.hospital_nome
          END ASC,
          CASE
            WHEN validated_order_by = 'setor_nome'
            AND validated_order_direction = 'DESC' THEN v.setor_nome
          END DESC,
          CASE
            WHEN validated_order_by = 'setor_nome'
            AND validated_order_direction = 'ASC' THEN v.setor_nome
          END ASC,
          CASE
            WHEN validated_order_by = 'especialidade_nome'
            AND validated_order_direction = 'DESC' THEN v.especialidade_nome
          END DESC,
          CASE
            WHEN validated_order_by = 'especialidade_nome'
            AND validated_order_direction = 'ASC' THEN v.especialidade_nome
          END ASC,
          CASE
            WHEN validated_order_by = 'vagas_periodo_nome'
            AND validated_order_direction = 'DESC' THEN v.vagas_periodo_nome
          END DESC,
          CASE
            WHEN validated_order_by = 'vagas_periodo_nome'
            AND validated_order_direction = 'ASC' THEN v.vagas_periodo_nome
          END ASC,
          CASE
            WHEN validated_order_by = 'vagas_status'
            AND validated_order_direction = 'DESC' THEN v.vagas_status
          END DESC,
          CASE
            WHEN validated_order_by = 'vagas_status'
            AND validated_order_direction = 'ASC' THEN v.vagas_status
          END ASC,
          CASE
            WHEN validated_order_by = 'total_candidaturas'
            AND validated_order_direction = 'DESC' THEN v.total_candidaturas
          END DESC,
          CASE
            WHEN validated_order_by = 'total_candidaturas'
            AND validated_order_direction = 'ASC' THEN v.total_candidaturas
          END ASC
      ),
      '[]'::jsonb
    ) AS data,
    jsonb_build_object(
      'current_page',
      validated_page,
      'page_size',
      validated_size,
      'total_count',
      total_count,
      'total_pages',
      CASE
        WHEN total_count = 0 THEN 0
        ELSE CEIL(total_count::numeric / validated_size::numeric)::integer
      END,
      'has_previous',
      validated_page > 1,
      'has_next',
      validated_page < CEIL(total_count::numeric / validated_size::numeric)::integer,
      'previous_page',
      CASE
        WHEN validated_page > 1 THEN validated_page - 1
        ELSE NULL
      END,
      'next_page',
      CASE
        WHEN validated_page < CEIL(total_count::numeric / validated_size::numeric)::integer THEN validated_page + 1
        ELSE NULL
      END
    ) AS pagination
  FROM vagas_agrupadas v;
END;
$$;


ALTER FUNCTION "public"."get_vagas_paginated"("page_number" integer, "page_size" integer, "hospital_ids" "uuid"[], "specialty_ids" "uuid"[], "sector_ids" "uuid"[], "start_date" "date", "end_date" "date", "min_value" numeric, "max_value" numeric, "period_ids" "uuid"[], "type_ids" "uuid"[], "group_ids" "uuid"[], "search_text" "text", "doctor_ids" "uuid"[], "application_status_filter" "text"[], "job_status_filter" "text"[], "grade_ids" "uuid"[], "order_by" "text", "order_direction" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."get_vagas_paginated"("page_number" integer, "page_size" integer, "hospital_ids" "uuid"[], "specialty_ids" "uuid"[], "sector_ids" "uuid"[], "start_date" "date", "end_date" "date", "min_value" numeric, "max_value" numeric, "period_ids" "uuid"[], "type_ids" "uuid"[], "group_ids" "uuid"[], "search_text" "text", "doctor_ids" "uuid"[], "application_status_filter" "text"[], "job_status_filter" "text"[], "grade_ids" "uuid"[], "order_by" "text", "order_direction" "text") IS 'Busca vagas agrupadas com suas candidaturas usando filtros opcionais. Filtros disponíveis: hospital_ids[], specialty_ids[], sector_ids[], period_ids[], type_ids[], group_ids[], doctor_ids[], application_status_filter[PENDENTE,APROVADO,REPROVADO], job_status_filter[aberta,fechada,cancelada,anunciada], grade_ids[], além de filtros de data, valor e texto. Parâmetros de ordenação: order_by[vagas_createdate,vagas_data,vagas_valor,hospital_nome,setor_nome,especialidade_nome,vagas_periodo_nome,vagas_status,total_candidaturas], order_direction[ASC,DESC]. Retorna vagas agrupadas com array de candidaturas associadas.';



CREATE OR REPLACE FUNCTION "public"."getidfromemail"("e_mail" "text") RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  select id
  from auth.users
  where email = e_mail
  limit 1;
$$;


ALTER FUNCTION "public"."getidfromemail"("e_mail" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."getidfromphone"("p_phone" "text") RETURNS "uuid"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  select id
  from auth.users
  where phone = p_phone
  limit 1;
$$;


ALTER FUNCTION "public"."getidfromphone"("p_phone" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."getuserprofile"("user_id" "uuid") RETURNS "text"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    AS $$
  select role
    from public.user_profile
   where id = user_id
   limit 1;
$$;


ALTER FUNCTION "public"."getuserprofile"("user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_grades_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc'::text, NOW());
  NEW.updated_by = auth.uid();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_grades_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."inserir_carteira_digital"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Inserir nova linha na tabela carteira_digital
    INSERT INTO carteira_digital (medicos_id)
    VALUES (NEW.medico_id);
    -- Retorna o valor da nova linha inserida
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."inserir_carteira_digital"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."inserir_validacao_documentos"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    INSERT INTO validacao_documentos (
        carteira_id, carteira_alteracao, validacaoby, 
        carteira_diploma, carteira_crm, carteira_cpf, carteira_rg, 
        carteira_especializacaodiploma, carteira_anuidadecrm, 
        carteira_eticoprofissional, carteira_comprovanteresidencia, 
        carteira_foto, carteira_comprovantevacina
    ) VALUES (
        NEW.carteira_id, NOW(), NULL, 
        'AGUARDANDO', 'AGUARDANDO', 'AGUARDANDO', 'AGUARDANDO', 
        'AGUARDANDO', 'AGUARDANDO', 'AGUARDANDO', 'AGUARDANDO', 
        'AGUARDANDO', 'AGUARDANDO'
    );
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."inserir_validacao_documentos"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."pode_ver_candidatura_colega"("candidatura_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
  DECLARE
      current_user_id UUID;
      candidatura_hospital UUID;
      candidatura_setor UUID;
      current_user_role TEXT;
  BEGIN
      current_user_id := auth.uid();

      -- Se não há usuário autenticado, retorna false
      IF current_user_id IS NULL THEN
          RETURN FALSE;
      END IF;

      -- Verificar se o usuário tem role 'free'
      SELECT role INTO current_user_role
      FROM user_profile
      WHERE id = current_user_id;

      IF current_user_role != 'free' THEN
          RETURN FALSE;
      END IF;

      -- Verificar se o usuário está na tabela médicos OU médicos_precadastro
      IF NOT EXISTS (
          SELECT 1 FROM medicos WHERE id = current_user_id
          UNION
          SELECT 1 FROM medicos_precadastro WHERE id = current_user_id
      ) THEN
          RETURN FALSE;
      END IF;

      -- Buscar hospital e setor da candidatura que está sendo verificada
      SELECT v.vagas_hospital, v.vagas_setor
      INTO candidatura_hospital, candidatura_setor
      FROM candidaturas c
      JOIN vagas v ON c.vagas_id = v.vagas_id
      WHERE c.candidaturas_id = candidatura_id
        AND c.candidatura_status = 'APROVADO';

      -- Se não encontrou dados da candidatura, retorna false
      IF candidatura_hospital IS NULL OR candidatura_setor IS NULL THEN
          RETURN FALSE;
      END IF;

      -- Verificar se o médico atual tem candidatura aprovada no mesmo hospital/setor
      -- Buscar tanto em medico_id quanto em medico_precadastro_id para o usuário atual
      RETURN EXISTS (
          SELECT 1
          FROM candidaturas c_user
          JOIN vagas v_user ON c_user.vagas_id = v_user.vagas_id
          WHERE (
              c_user.medico_id = current_user_id OR
              c_user.medico_precadastro_id = current_user_id
          )
            AND c_user.candidatura_status = 'APROVADO'
            AND v_user.vagas_hospital = candidatura_hospital
            AND v_user.vagas_setor = candidatura_setor
      );
  EXCEPTION
      WHEN OTHERS THEN
          RETURN FALSE;
  END;
  $$;


ALTER FUNCTION "public"."pode_ver_candidatura_colega"("candidatura_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."pode_ver_candidatura_colega_debug"("candidatura_id" "uuid") RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
  DECLARE
      current_user_id UUID;
      candidatura_hospital UUID;
      candidatura_setor UUID;
      current_user_role TEXT;
      user_in_medicos BOOLEAN;
      user_in_precadastro BOOLEAN;
      found_candidatura BOOLEAN;
      found_user_candidatura BOOLEAN;
      debug_info TEXT;
  BEGIN
      current_user_id := auth.uid();
      debug_info := 'User ID: ' || COALESCE(current_user_id::text, 'NULL');

      -- Verificar role
      SELECT role INTO current_user_role
      FROM user_profile
      WHERE id = current_user_id;

      debug_info := debug_info || ' | Role: ' || COALESCE(current_user_role, 'NULL');

      -- Verificar se está nas tabelas
      SELECT EXISTS(SELECT 1 FROM medicos WHERE id = current_user_id) INTO
  user_in_medicos;
      SELECT EXISTS(SELECT 1 FROM medicos_precadastro WHERE id = current_user_id) INTO
  user_in_precadastro;

      debug_info := debug_info || ' | In medicos: ' || user_in_medicos || ' | In 
  precadastro: ' || user_in_precadastro;

      -- Buscar dados da candidatura
      SELECT v.vagas_hospital, v.vagas_setor
      INTO candidatura_hospital, candidatura_setor
      FROM candidaturas c
      JOIN vagas v ON c.vagas_id = v.vagas_id
      WHERE c.candidaturas_id = candidatura_id
        AND c.candidatura_status = 'APROVADO';

      found_candidatura := (candidatura_hospital IS NOT NULL AND candidatura_setor IS
  NOT NULL);
      debug_info := debug_info || ' | Found candidatura: ' || found_candidatura;
      debug_info := debug_info || ' | Hospital: ' ||
  COALESCE(candidatura_hospital::text, 'NULL');
      debug_info := debug_info || ' | Setor: ' || COALESCE(candidatura_setor::text,
  'NULL');

      -- Buscar candidatura do usuário no mesmo hospital/setor
      SELECT EXISTS(
          SELECT 1
          FROM candidaturas c_user
          JOIN vagas v_user ON c_user.vagas_id = v_user.vagas_id
          WHERE (
              c_user.medico_id = current_user_id OR
              c_user.medico_precadastro_id = current_user_id
          )
            AND c_user.candidatura_status = 'APROVADO'
            AND v_user.vagas_hospital = candidatura_hospital
            AND v_user.vagas_setor = candidatura_setor
      ) INTO found_user_candidatura;

      debug_info := debug_info || ' | User has candidatura in same hospital/setor: ' ||
  found_user_candidatura;

      RETURN debug_info;
  EXCEPTION
      WHEN OTHERS THEN
          RETURN 'ERROR: ' || SQLERRM;
  END;
  $$;


ALTER FUNCTION "public"."pode_ver_candidatura_colega_debug"("candidatura_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."refresh_dashboard_metrics"() RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY vw_dashboard_metrics;
END;
$$;


ALTER FUNCTION "public"."refresh_dashboard_metrics"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."refresh_vw_vagas_disponiveis"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY vw_vagas_disponiveis;
    RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."refresh_vw_vagas_disponiveis"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."reprovar_documento"("p_carteira_id" "uuid", "p_tipo" "text", "p_motivo" "text", "p_user_id" "uuid") RETURNS TABLE("success" boolean, "message" "text")
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Atualizar status para false
    PERFORM update_documento_status(p_carteira_id, p_tipo, false, p_user_id);
    
    -- Atualizar URL para conter o motivo da reprovação
    PERFORM update_documento_url(
        p_carteira_id, 
        p_tipo, 
        'REPROVADO: ' || p_motivo
    );
    
    RETURN QUERY SELECT true, 'Documento reprovado com sucesso';
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT false, 'Erro ao reprovar documento: ' || SQLERRM;
END;
$$;


ALTER FUNCTION "public"."reprovar_documento"("p_carteira_id" "uuid", "p_tipo" "text", "p_motivo" "text", "p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sync_pagamentos_medico_id"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- Para INSERT, priorizar o que foi enviado pelo app
  IF TG_OP = 'INSERT' THEN
    -- Se app mobile enviou medicos_id mas não medico_id, usar medicos_id como fonte
    IF NEW.medicos_id IS NOT NULL AND NEW.medico_id IS NULL THEN
      NEW.medico_id = NEW.medicos_id;
    -- Se medico_id foi enviado, sincronizar para medicos_id
    ELSIF NEW.medico_id IS NOT NULL THEN
      NEW.medicos_id = NEW.medico_id;
    END IF;
    
    -- *** NOVO: Preencher vagas_id automaticamente se estiver vazio ***
    IF NEW.vagas_id IS NULL AND NEW.candidaturas_id IS NOT NULL THEN
      SELECT vagas_id INTO NEW.vagas_id 
      FROM candidaturas 
      WHERE candidaturas_id = NEW.candidaturas_id;
    END IF;
    
  ELSIF TG_OP = 'UPDATE' THEN
    -- Se medico_id foi alterado, copia para medicos_id
    IF NEW.medico_id IS DISTINCT FROM OLD.medico_id THEN
      NEW.medicos_id = NEW.medico_id;
    END IF;
    -- Se medicos_id foi alterado e medico_id não foi, copia medicos_id para medico_id
    IF NEW.medicos_id IS DISTINCT FROM OLD.medicos_id AND NEW.medico_id IS NOT DISTINCT FROM OLD.medico_id THEN
      NEW.medico_id = NEW.medicos_id;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."sync_pagamentos_medico_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sync_user_profile"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    -- Verifica tanto no nível raiz quanto dentro de data
    DECLARE
      platform_origin TEXT;
      display_name TEXT;
    BEGIN
      -- Usa COALESCE para verificar ambos os caminhos
      platform_origin := COALESCE(
        NEW.raw_user_meta_data->'data'->>'platform_origin',
        NEW.raw_user_meta_data->>'platform_origin'
      );
      
      display_name := COALESCE(
        NEW.raw_user_meta_data->'data'->>'display_name', 
        NEW.raw_user_meta_data->>'display_name'
      );

      -- Lógica existente
      IF (platform_origin = 'houston') THEN
        INSERT INTO public.user_profile (id, created_at, role, displayname)
        VALUES (NEW.id, NEW.created_at, 'astronauta', display_name)
        ON CONFLICT (id) DO NOTHING;
      ELSE
        INSERT INTO public.user_profile (id, created_at, role, displayname)
        VALUES (NEW.id, NEW.created_at, 'signup', display_name)
        ON CONFLICT (id) DO NOTHING;
      END IF;
      
      RETURN NEW;
    END;
  END IF;
  RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."sync_user_profile"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sync_vagas_beneficio_vaga_id"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  -- Para INSERT, priorizar vagas_id (coluna primária)
  IF TG_OP = 'INSERT' THEN
    -- Se vagas_id foi enviado, sincronizar para vaga_id
    IF NEW.vagas_id IS NOT NULL THEN
      NEW.vaga_id = NEW.vagas_id;
    -- Se apenas vaga_id foi enviado, usar como fonte para vagas_id
    ELSIF NEW.vaga_id IS NOT NULL AND NEW.vagas_id IS NULL THEN
      NEW.vagas_id = NEW.vaga_id;
    END IF;
  ELSIF TG_OP = 'UPDATE' THEN
    -- Se vagas_id foi alterado, copia para vaga_id
    IF NEW.vagas_id IS DISTINCT FROM OLD.vagas_id THEN
      NEW.vaga_id = NEW.vagas_id;
    END IF;
    -- Se vaga_id foi alterado e vagas_id não foi, copia vaga_id para vagas_id
    IF NEW.vaga_id IS DISTINCT FROM OLD.vaga_id AND NEW.vagas_id IS NOT DISTINCT FROM OLD.vagas_id THEN
      NEW.vagas_id = NEW.vaga_id;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."sync_vagas_beneficio_vaga_id"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_documento_status"("p_carteira_id" "uuid", "p_tipo" "text", "p_status" boolean, "p_user_id" "uuid") RETURNS TABLE("success" boolean, "message" "text")
    LANGUAGE "plpgsql"
    AS $_$
DECLARE
    v_column_name TEXT;
    v_status_column TEXT;
    v_update_date TEXT;
    v_update_user TEXT;
    v_sql TEXT;
BEGIN
    -- Construir nomes das colunas
    v_column_name := 'carteira_' || p_tipo;
    v_status_column := v_column_name || '_status';
    v_update_date := v_column_name || '_updatedate';
    v_update_user := v_column_name || '_updateuserid';
    
    -- Construir query de atualização
    v_sql := format('
        UPDATE carteira_digital 
        SET %I = $$1,
            %I = $$2,
            %I = $$3
        WHERE carteira_id = $$4
        RETURNING true', 
        v_status_column, v_update_date, v_update_user);
    
    -- Log da query (para debug)
    RAISE NOTICE 'SQL: %', v_sql;
    
    -- Executar atualização
    EXECUTE v_sql
    USING 
        p_status,
        NOW(),
        p_user_id,
        p_carteira_id;

    -- Atualizar status geral
    UPDATE carteira_digital
    SET carteira_status = (
        SELECT CASE 
            WHEN bool_and(COALESCE(col.status, false)) THEN true
            ELSE false
        END
        FROM (
            SELECT carteira_diploma_status as status
            UNION ALL SELECT carteira_crm_status
            UNION ALL SELECT carteira_cpf_status
            UNION ALL SELECT carteira_rg_status
            UNION ALL SELECT carteira_especializacaodiploma_status
            UNION ALL SELECT carteira_anuidadecrm_status
            UNION ALL SELECT carteira_eticoprofissional_status
            UNION ALL SELECT carteira_comprovanteresidencia_status
            UNION ALL SELECT carteira_foto_status
            UNION ALL SELECT carteira_comprovantevacina_status
        ) col
    )
    WHERE carteira_id = p_carteira_id;

    RETURN QUERY SELECT true, 'Documento atualizado com sucesso';
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT false, 'Erro: ' || SQLERRM;
END;
$_$;


ALTER FUNCTION "public"."update_documento_status"("p_carteira_id" "uuid", "p_tipo" "text", "p_status" boolean, "p_user_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_documento_url"("p_carteira_id" "uuid", "p_tipo" "text", "p_url" "text") RETURNS TABLE("success" boolean, "message" "text")
    LANGUAGE "plpgsql"
    AS $_$
DECLARE
    v_column_name TEXT;
    v_sql TEXT;
BEGIN
    -- Construir nome da coluna
    v_column_name := 'carteira_' || p_tipo;
    
    -- Construir query
    v_sql := format('
        UPDATE carteira_digital 
        SET %I = $$1
        WHERE carteira_id = $$2', 
        v_column_name);
    
    -- Log da query
    RAISE NOTICE 'SQL: %', v_sql;
    
    -- Executar atualização
    EXECUTE v_sql
    USING p_url, p_carteira_id;

    RETURN QUERY SELECT true, 'URL atualizada com sucesso';
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT false, 'Erro: ' || SQLERRM;
END;
$_$;


ALTER FUNCTION "public"."update_documento_url"("p_carteira_id" "uuid", "p_tipo" "text", "p_url" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_especialidade_nome"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    SELECT esp.nome INTO NEW.especialidade_nome
    FROM public.especialidades esp
    WHERE esp.id = NEW.especialidade_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_especialidade_nome"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_phone_forotp"("user_id" "uuid", "areacodeindex" integer, "telefone" "text") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE areacode TEXT;
BEGIN
  
  -- Buscar código de área na tabela
  SELECT "Código" INTO areacode 
  FROM codigosdearea 
  WHERE "Index" = areaCodeIndex;

  -- Remover o símbolo + do código de área
  areacode := REPLACE(areacode, '+', '');

  -- Atualiza auth.users
  UPDATE auth.users
  SET phone = areacode || telefone,
      raw_app_meta_data = jsonb_set(
        COALESCE(raw_app_meta_data, '{}'::jsonb),
        '{providers}',
        '["email", "phone"]'::jsonb
      ),
      updated_at = NOW(),
      phone_confirmed_at = NOW()
  WHERE id = user_id;

    -- Cria entrada em auth identities
    INSERT INTO auth.identities (
        id,
        provider_id,
        user_id,
        identity_data,
        provider,
        updated_at,
        last_sign_in_at,
        created_at
    )
    VALUES (
        gen_random_uuid(),
        user_id,
        user_id,
        jsonb_build_object(
            'sub', user_id,
            'phone', areacode || telefone,
            'email_verified', false,
            'phone_verified', true
        ),
        'phone',
        NOW(),
        NOW(),
        NOW()
    );

  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    RAISE EXCEPTION 'Erro: %', SQLERRM;
END;
$$;


ALTER FUNCTION "public"."update_phone_forotp"("user_id" "uuid", "areacodeindex" integer, "telefone" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_total_candidaturas"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.vagas
        SET total_candidaturas = total_candidaturas + 1
        WHERE id = NEW.vagas_id;
    ELSIF TG_OP = 'DELETE' THEN
        BEGIN
            UPDATE public.vagas
            SET total_candidaturas = GREATEST(total_candidaturas - 1, 0)
            WHERE id = OLD.vagas_id;
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Erro ao atualizar vagas durante exclusão: %', SQLERRM;
        END;
    END IF;
    RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."update_total_candidaturas"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_total_plantoes_medico"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
BEGIN
    IF NEW.status = 'CONFIRMADO' THEN
        UPDATE medicos 
        SET total_plantoes = total_plantoes + 1
        WHERE medico_id = NEW.medico_id;
    END IF;
    RETURN NULL;
END;
$$;


ALTER FUNCTION "public"."update_total_plantoes_medico"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."updatethisuser"("user_id" "uuid", "e_mail" "text", "p_phone" "text") RETURNS "void"
    LANGUAGE "sql" SECURITY DEFINER
    AS $$update auth.users
     set email = e_mail,
         phone = p_phone
   where id = user_id;$$;


ALTER FUNCTION "public"."updatethisuser"("user_id" "uuid", "e_mail" "text", "p_phone" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."validar_localizacao_medico"("p_hospital_id" "uuid", "p_latitude" numeric, "p_longitude" numeric) RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    config_hospital RECORD;
    distancia DECIMAL;
BEGIN
    -- Buscar configuração do hospital
    SELECT latitude, longitude, raio_metros, ativo
    INTO config_hospital
    FROM hospital_geofencing 
    WHERE hospital_id = p_hospital_id AND ativo = true;
    
    -- Se não há configuração, assume válido
    IF NOT FOUND THEN
        RETURN true;
    END IF;
    
    -- Calcular distância
    distancia := calcular_distancia(
        config_hospital.latitude, config_hospital.longitude,
        p_latitude, p_longitude
    );
    
    -- Retornar se está dentro do raio
    RETURN distancia <= config_hospital.raio_metros;
END;
$$;


ALTER FUNCTION "public"."validar_localizacao_medico"("p_hospital_id" "uuid", "p_latitude" numeric, "p_longitude" numeric) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."validate_checkin_timing"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    vaga_start_time TIME;
    vaga_end_time TIME;
    vaga_date DATE;
    plantao_inicio TIMESTAMP;
    janela_inicio TIMESTAMP;
    plantao_fim TIMESTAMP;
    janela_fim TIMESTAMP;
    current_role TEXT;
    candidatura_aprovada BOOLEAN;
BEGIN
    -- Verificar o role atual do usuário
    SELECT auth.role() INTO current_role;
    
    -- Só aplicar verificação de conflito para usuários authenticated
    -- Roles de serviço podem trabalhar sem amarras
    IF current_role = 'service_role' THEN
        RETURN NEW;
    END IF;

    -- Verificar se é um usuário autenticado
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'ERRO Usuário não autenticado.';
    END IF;

    -- Buscar informações da vaga
    SELECT v.data, v.hora_inicio, v.hora_fim
    INTO vaga_date, vaga_start_time, vaga_end_time
    FROM vagas v 
    WHERE v.id = NEW.vaga_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'ERRO Vaga não encontrado.';
    END IF;

    -- Verificar se o médico tem candidatura aprovada para esta vaga
    SELECT EXISTS(
        SELECT 1 
        FROM candidaturas c 
        WHERE c.vagas_id = NEW.vaga_id 
        AND c.medico_id = NEW.medico_id 
        AND c.status = 'APROVADO'
    ) INTO candidatura_aprovada;

    IF NOT candidatura_aprovada THEN
        RAISE EXCEPTION 'ERRO Médico não possui candidatura aprovada para esta vaga.';
    END IF;

    -- Verificar se já existe check-in para esta combinação médico/vaga
    IF EXISTS(
        SELECT 1 
        FROM checkin_checkout cc 
        WHERE cc.vaga_id = NEW.vaga_id 
        AND cc.medico_id = NEW.medico_id
    ) THEN
        RAISE EXCEPTION 'ERRO Check-in já realizado para esta vaga.';
    END IF;

    -- Construir o timestamp completo do início do plantão
    -- Convertendo para timestamp with timezone usando timezone local
    plantao_inicio := (vaga_date::TIMESTAMP + vaga_start_time::TIME);
    plantao_fim := (vaga_date::TIMESTAMP + vaga_end_time::TIME);

    -- Definir janela de check-in (15 minutos antes até 15 minutos depois)
    janela_inicio := plantao_inicio - INTERVAL '15 minutes';
    janela_fim := plantao_inicio + INTERVAL '15 minutes';

    -- Verificar se está dentro da janela permitida
    IF NOW() BETWEEN janela_inicio AND janela_fim THEN
        -- Dentro da janela: permitir sem justificativa
        RETURN NEW;
    ELSE
        -- Fora da janela: exigir justificativa
        IF NEW.checkin_justificativa IS NULL OR TRIM(NEW.checkin_justificativa) = '' THEN
            RAISE EXCEPTION 'ERRO Horário requer justificativa obrigatória.';
        END IF;
        
        -- Verificar se não é muito cedo (antes da janela permitida)
        IF NOW() < janela_inicio OR NOW() > plantao_fim THEN
            RAISE EXCEPTION 'ERRO Horário não permitido para fazer Check-in.';
        END IF;
        
        RETURN NEW;
    END IF;
END;
$$;


ALTER FUNCTION "public"."validate_checkin_timing"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."validate_checkout_timing"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    vaga_start_time TIME;
    vaga_end_time TIME;
    vaga_date DATE;
    plantao_inicio TIMESTAMP;
    janela_inicio TIMESTAMP;
    plantao_fim TIMESTAMP;
    janela_fim TIMESTAMP;
    current_role TEXT;
    candidatura_aprovada BOOLEAN;
BEGIN
    -- Verificar o role atual do usuário
    SELECT auth.role() INTO current_role;
    
    -- Só aplicar verificação de conflito para usuários authenticated
    -- Roles de serviço podem trabalhar sem amarras
    IF current_role = 'service_role' THEN
        RETURN NEW;
    END IF;

    -- Verificar se é um usuário autenticado
    IF auth.uid() IS NULL THEN
        RAISE EXCEPTION 'ERRO Usuário não autenticado.';
    END IF;

    -- Buscar informações da vaga
    SELECT v.data, v.hora_inicio, v.hora_fim
    INTO vaga_date, vaga_start_time, vaga_end_time
    FROM vagas v 
    WHERE v.id = NEW.vaga_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'ERRO Vaga não encontrado.';
    END IF;

    -- Verificar se o médico tem candidatura aprovada para esta vaga
    SELECT EXISTS(
        SELECT 1 
        FROM candidaturas c 
        WHERE c.vagas_id = NEW.vaga_id 
        AND c.medico_id = NEW.medico_id 
        AND c.status = 'APROVADO'
    ) INTO candidatura_aprovada;

    IF NOT candidatura_aprovada THEN
        RAISE EXCEPTION 'ERRO Médico não possui candidatura aprovada para esta vaga.';
    END IF;

    -- Verificar se existe check-in para esta combinação médico/vaga
    IF NOT EXISTS(
        SELECT 1 
        FROM checkin_checkout cc 
        WHERE cc.vaga_id = NEW.vaga_id 
        AND cc.medico_id = NEW.medico_id
    ) THEN
        RAISE EXCEPTION 'ERRO Check-in ainda não realizado para esta vaga.';
    END IF;

    -- Construir o timestamp completo do início do plantão
    -- Convertendo para timestamp with timezone usando timezone local
    plantao_inicio := (vaga_date::TIMESTAMP + vaga_start_time::TIME);
    plantao_fim := (vaga_date::TIMESTAMP + vaga_end_time::TIME);

    -- Definir janela de check-out (15 minutos antes até 15 minutos depois do final)
    janela_inicio := plantao_fim - INTERVAL '15 minutes';
    janela_fim := plantao_fim + INTERVAL '15 minutes';

    -- Verificar se está dentro da janela permitida
    IF NOW() BETWEEN janela_inicio AND janela_fim THEN
        -- Dentro da janela: permitir sem justificativa
        RETURN NEW;
    ELSE
        -- Fora da janela: exigir justificativa
        IF NEW.checkin_justificativa IS NULL OR TRIM(NEW.checkin_justificativa) = '' THEN
            RAISE EXCEPTION 'ERRO Horário requer justificativa obrigatória.';
        END IF;
        
        -- Verificar se não é muito cedo (antes da janela permitida)
        IF NOW() < janela_inicio THEN
            RAISE EXCEPTION 'ERRO Horário não permitido para fazer Check-out.';
        END IF;
        
        RETURN NEW;
    END IF;
END;
$$;


ALTER FUNCTION "public"."validate_checkout_timing"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."verificar_conflito_antes_candidatura"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    medico_userid uuid;
    conflito_encontrado boolean := false;
    vaga_data date;
    vaga_inicio time;
    vaga_fim time;
    vaga_conflitante_info text;
    current_user_id uuid;
    current_user_role text;
    
    -- Adicionar variáveis para timestamps
    vaga_inicio_ts timestamp;
    vaga_fim_ts timestamp;
BEGIN
    
    -- Verificar o role atual do usuário
    current_user_id := auth.uid();
    RAISE NOTICE 'Usuário atual: %', current_user_id;

    -- Verificar se o usuário existe no user_profile
    SELECT role INTO current_user_role
    FROM user_profile
    WHERE id = current_user_id;

    -- Buscar dados da vaga
    SELECT 
        -- Determinar qual medico_id usar baseado na lógica do sistema
        CASE 
            WHEN NEW.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid AND NEW.medico_precadastro_id IS NOT NULL 
            THEN NEW.medico_precadastro_id
            ELSE NEW.medico_id
        END,
        v.data, 
        v.hora_inicio, 
        v.hora_fim
    INTO medico_userid, vaga_data, vaga_inicio, vaga_fim
    FROM vagas v
    WHERE v.id = NEW.vagas_id;
    
    -- CONVERTER para timestamps considerando turnos noturnos
    vaga_inicio_ts := vaga_data + vaga_inicio;
    
    -- Se hora fim <= hora início, é turno noturno (vai para o dia seguinte)
    IF vaga_fim <= vaga_inicio THEN
        vaga_fim_ts := (vaga_data + INTERVAL '1 day') + vaga_fim;
    ELSE
        vaga_fim_ts := vaga_data + vaga_fim;
    END IF;
    
    -- VERIFICAÇÃO 1: Impedir candidatura em vagas com data passada
    IF vaga_data < CURRENT_DATE AND current_user_role = 'free' THEN
        RAISE EXCEPTION 'CANDIDATURA BLOQUEADA: Não é possível se candidatar em vaga com data passada. Data da vaga: %', vaga_data;
    END IF;
    
    -- VERIFICAÇÃO 2: Verificar conflitos de horário considerando medico_id e medico_precadastro_id
    SELECT 
        EXISTS (
            SELECT 1
            FROM candidaturas c
            JOIN vagas v ON c.vagas_id = v.id
            WHERE (
                -- Para médicos normais
                (c.medico_id = medico_userid AND c.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid)
                OR
                -- Para médicos pré-cadastrados
                (c.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid AND c.medico_precadastro_id = medico_userid)
            )
            AND c.status = 'APROVADO'
            AND (
                -- Usar OVERLAPS com timestamps calculados
                (v.data + v.hora_inicio, 
                 CASE 
                     WHEN v.hora_fim <= v.hora_inicio 
                     THEN (v.data + INTERVAL '1 day') + v.hora_fim
                     ELSE v.data + v.hora_fim
                 END
                ) OVERLAPS 
                (vaga_inicio_ts, vaga_fim_ts)
            )
        ),
        (
            SELECT 'Plantão já aprovado: ' || v.data || ' das ' || v.hora_inicio || ' às ' || v.hora_fim ||
                   CASE WHEN v.hora_fim <= v.hora_inicio THEN ' (madrugada)' ELSE '' END
            FROM candidaturas c
            JOIN vagas v ON c.vagas_id = v.id
            WHERE (
                -- Para médicos normais
                (c.medico_id = medico_userid AND c.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid)
                OR
                -- Para médicos pré-cadastrados
                (c.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid AND c.medico_precadastro_id = medico_userid)
            )
            AND c.status = 'APROVADO'
            AND (
                (v.data + v.hora_inicio, 
                 CASE 
                     WHEN v.hora_fim <= v.hora_inicio 
                     THEN (v.data + INTERVAL '1 day') + v.hora_fim
                     ELSE v.data + v.hora_fim
                 END
                ) OVERLAPS 
                (vaga_inicio_ts, vaga_fim_ts)
            )
            LIMIT 1
        )
    INTO conflito_encontrado, vaga_conflitante_info;
           
    -- Bloquear se houver conflito de horário
    IF conflito_encontrado THEN
        RAISE EXCEPTION 'CONFLITO DE HORÁRIO DETECTADO: %', vaga_conflitante_info;
    END IF;
    
    -- Se chegou até aqui, as validações passaram
    RETURN NEW;  -- Para trigger
    
END;
$$;


ALTER FUNCTION "public"."verificar_conflito_antes_candidatura"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."verificar_conflito_vaga_designada"("p_medico_id" "uuid", "p_data" "date", "p_hora_inicio" time without time zone, "p_hora_fim" time without time zone) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  medico_userid uuid;
  conflito_encontrado boolean := false;
  vaga_data date;
  vaga_inicio time;
  vaga_fim time;
  vaga_conflitante_info text;
  current_user_id uuid;
  current_user_role text;
  
  -- Adicionar variáveis para timestamps
  vaga_inicio_ts timestamp;
  vaga_fim_ts timestamp;

BEGIN
  
  medico_userid := p_medico_id;
  vaga_data := p_data;
  vaga_inicio := p_hora_inicio;
  vaga_fim := p_hora_fim;

  -- CONVERTER para timestamps considerando turnos noturnos
  vaga_inicio_ts := vaga_data + vaga_inicio;
  
  -- Se hora fim <= hora início, é turno noturno (vai para o dia seguinte)
  IF vaga_fim <= vaga_inicio THEN
      vaga_fim_ts := (vaga_data + INTERVAL '1 day') + vaga_fim;
  ELSE
      vaga_fim_ts := vaga_data + vaga_fim;
  END IF;
  
  -- Verificar conflitos de horário considerando medico_id e medico_precadastro_id
  SELECT 
      EXISTS (
          SELECT 1
          FROM candidaturas c
          JOIN vagas v ON c.vagas_id = v.vagas_id
          WHERE (
              -- Para médicos normais
              (c.medico_id = medico_userid AND c.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid)
              OR
              -- Para médicos pré-cadastrados
              (c.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid AND c.medico_precadastro_id = medico_userid)
          )
          AND c.candidatura_status = 'APROVADO'
          AND (
              -- Usar OVERLAPS com timestamps calculados
              (v.vagas_data + v.vagas_horainicio, 
               CASE 
                   WHEN v.vagas_horafim <= v.vagas_horainicio 
                   THEN (v.vagas_data + INTERVAL '1 day') + v.vagas_horafim
                   ELSE v.vagas_data + v.vagas_horafim
               END
              ) OVERLAPS 
              (vaga_inicio_ts, vaga_fim_ts)
          )
      ),
      (
          SELECT 'Plantão já aprovado: ' || v.vagas_data || ' das ' || v.vagas_horainicio || ' às ' || v.vagas_horafim ||
                 CASE WHEN v.vagas_horafim <= v.vagas_horainicio THEN ' (madrugada)' ELSE '' END
          FROM candidaturas c
          JOIN vagas v ON c.vagas_id = v.vagas_id
          WHERE (
              -- Para médicos normais
              (c.medico_id = medico_userid AND c.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid)
              OR
              -- Para médicos pré-cadastrados
              (c.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid AND c.medico_precadastro_id = medico_userid)
          )
          AND c.candidatura_status = 'APROVADO'
          AND (
              (v.vagas_data + v.vagas_horainicio, 
               CASE 
                   WHEN v.vagas_horafim <= v.vagas_horainicio 
                   THEN (v.vagas_data + INTERVAL '1 day') + v.vagas_horafim
                   ELSE v.vagas_data + v.vagas_horafim
               END
              ) OVERLAPS 
              (vaga_inicio_ts, vaga_fim_ts)
          )
          LIMIT 1
      )
  INTO conflito_encontrado, vaga_conflitante_info;
         
  -- Bloquear se houver conflito de horário
  IF conflito_encontrado THEN
      RAISE EXCEPTION 'CONFLITO DE HORÁRIO DETECTADO: %', vaga_conflitante_info;
  END IF;

END;
$$;


ALTER FUNCTION "public"."verificar_conflito_vaga_designada"("p_medico_id" "uuid", "p_data" "date", "p_hora_inicio" time without time zone, "p_hora_fim" time without time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."verificar_consistencia_status_vagas"() RETURNS TABLE("problema" "text", "quantidade" integer, "detalhes" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
    -- Verificar vagas fechadas sem candidaturas (problema que corrigimos)
    RETURN QUERY 
    SELECT 
        'Vagas fechadas incorretamente (sem candidaturas)'::TEXT as problema,
        COUNT(*)::INTEGER as quantidade,
        'Vagas que deveriam estar canceladas, não fechadas'::TEXT as detalhes
    FROM vagas v
    WHERE v.vagas_status = 'fechada' 
    AND v.vagas_totalcandidaturas = 0
    AND NOT EXISTS (
        SELECT 1 FROM candidaturas c 
        WHERE c.vagas_id = v.vagas_id
    );
    
    -- Verificar vagas abertas expiradas
    RETURN QUERY 
    SELECT 
        'Vagas abertas expiradas'::TEXT as problema,
        COUNT(*)::INTEGER as quantidade,
        'Vagas que deveriam ter status atualizado'::TEXT as detalhes
    FROM vagas v
    WHERE v.vagas_data < CURRENT_DATE 
    AND v.vagas_status = 'aberta';
    
    -- Verificar candidaturas pendentes em vagas fechadas/canceladas
    RETURN QUERY 
    SELECT 
        'Candidaturas pendentes em vagas encerradas'::TEXT as problema,
        COUNT(*)::INTEGER as quantidade,
        'Candidaturas que deveriam estar reprovadas'::TEXT as detalhes
    FROM candidaturas c
    JOIN vagas v ON c.vagas_id = v.vagas_id
    WHERE c.candidatura_status = 'PENDENTE'
    AND v.vagas_status IN ('fechada', 'cancelada');
    
END;
$$;


ALTER FUNCTION "public"."verificar_consistencia_status_vagas"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."banner_mkt" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "page_index" smallint,
    "imgpath" "text" DEFAULT 'http://'::"text",
    "description" "text" DEFAULT 'adicione uma descrição'::"text",
    "url" "text"
);


ALTER TABLE "public"."banner_mkt" OWNER TO "postgres";


ALTER TABLE "public"."banner_mkt" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."bannerMKT_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."beneficios" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "nome" character varying NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."beneficios" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."candidaturas" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"(),
    "data_confirmacao" "date" DEFAULT "now"(),
    "medico_id" "uuid" NOT NULL,
    "vagas_id" "uuid" NOT NULL,
    "status" "text" NOT NULL,
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "updated_by" "text",
    "vagas_valor" integer DEFAULT 100 NOT NULL,
    "medico_precadastro_id" "uuid",
    CONSTRAINT "candidatura_status_check" CHECK (("status" = ANY (ARRAY['PENDENTE'::"text", 'APROVADO'::"text", 'REPROVADO'::"text"]))),
    CONSTRAINT "candidaturas_vagas_valor_check" CHECK ((("vagas_valor")::numeric > (0)::numeric)),
    CONSTRAINT "chk_one_medico_type_candidaturas" CHECK (((("medico_id" = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::"uuid") AND ("medico_precadastro_id" IS NOT NULL)) OR (("medico_id" <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::"uuid") AND ("medico_precadastro_id" IS NULL))))
);


ALTER TABLE "public"."candidaturas" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."carteira_digital" (
    "carteira_id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "medico_id" "uuid" NOT NULL,
    "carteira_createdate" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "carteira_diploma" character varying DEFAULT 'AGUARDANDO'::character varying NOT NULL,
    "carteira_crm" character varying DEFAULT 'AGUARDANDO'::character varying NOT NULL,
    "carteira_cpf" character varying DEFAULT 'AGUARDANDO'::character varying NOT NULL,
    "carteira_rg" character varying DEFAULT 'AGUARDANDO'::character varying NOT NULL,
    "carteira_especializacaodiploma" character varying DEFAULT 'AGUARDANDO'::character varying NOT NULL,
    "carteira_anuidadecrm" character varying DEFAULT 'AGUARDANDO'::character varying NOT NULL,
    "carteira_eticoprofissional" character varying DEFAULT 'AGUARDANDO'::character varying NOT NULL,
    "carteira_comprovanteresidencia" character varying DEFAULT 'AGUARDANDO'::character varying NOT NULL,
    "carteira_foto" character varying DEFAULT 'AGUARDANDO'::character varying NOT NULL,
    "carteira_comprovantevacina" character varying DEFAULT 'AGUARDANDO'::character varying,
    "carteira_status" boolean,
    "carteira_diploma_status" boolean DEFAULT false,
    "carteira_crm_status" boolean DEFAULT false,
    "carteira_cpf_status" boolean DEFAULT false,
    "carteira_rg_status" boolean DEFAULT false,
    "carteira_especializacaodiploma_status" boolean DEFAULT false,
    "carteira_anuidadecrm_status" boolean DEFAULT false,
    "carteira_eticoprofissional_status" boolean DEFAULT false,
    "carteira_comprovanteresidencia_status" boolean DEFAULT false,
    "carteira_foto_status" boolean DEFAULT false,
    "carteira_comprovantevacina_status" boolean DEFAULT false,
    "carteira_diploma_updatedate" timestamp without time zone,
    "carteira_crm_updatedate" timestamp without time zone,
    "carteira_cpf_updatedate" timestamp without time zone,
    "carteira_rg_updatedate" timestamp without time zone,
    "carteira_especializacaodiploma_updatedate" timestamp without time zone,
    "carteira_anuidadecrm_updatedate" timestamp without time zone,
    "carteira_eticoprofissional_updatedate" timestamp without time zone,
    "carteira_comprovanteresidencia_updatedate" timestamp without time zone,
    "carteira_foto_updatedate" timestamp without time zone,
    "carteira_comprovantevacina_updatedate" timestamp without time zone,
    "carteira_diploma_updateuserid" "uuid",
    "carteira_crm_updateuserid" "uuid",
    "carteira_cpf_updateuserid" "uuid",
    "carteira_rg_updateuserid" "uuid",
    "carteira_especializacaodiploma_updateuserid" "uuid",
    "carteira_anuidadecrm_updateuserid" "uuid",
    "carteira_eticoprofissional_updateuserid" "uuid",
    "carteira_comprovanteresidencia_updateuserid" "uuid",
    "carteira_foto_updateuserid" "uuid",
    "carteira_comprovantevacina_updateuserid" "uuid"
);


ALTER TABLE "public"."carteira_digital" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."checkin_checkout" (
    "id" smallint NOT NULL,
    "vaga_id" "uuid",
    "medico_id" "uuid",
    "checkin" timestamp without time zone NOT NULL,
    "checkout" timestamp without time zone,
    "checkin_latitude" numeric(10,8),
    "checkin_longitude" numeric(11,8),
    "checkout_latitude" numeric(10,8),
    "checkout_longitude" numeric(11,8),
    "checkin_justificativa" "text",
    "checkout_justificativa" "text",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "updated_at" timestamp without time zone DEFAULT "now"(),
    "updated_by" "uuid" DEFAULT "auth"."uid"()
);


ALTER TABLE "public"."checkin_checkout" OWNER TO "postgres";


ALTER TABLE "public"."checkin_checkout" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."checkin_checkout_index_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."checkin_checkout_nofitications" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "title" "text" NOT NULL,
    "body" "text" NOT NULL,
    "recipient_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "is_read" boolean DEFAULT false NOT NULL,
    "message_id" "text",
    "read_at" timestamp with time zone,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "route" "text",
    "extra_data" "jsonb"
);


ALTER TABLE "public"."checkin_checkout_nofitications" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."clean_hospital" (
    "terms" "text",
    "id" smallint NOT NULL,
    CONSTRAINT "clean_hospital_id_check" CHECK (("id" > 0))
);


ALTER TABLE "public"."clean_hospital" OWNER TO "postgres";


ALTER TABLE "public"."clean_hospital" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."clean_hospital_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."codigos_area" (
    "index" smallint NOT NULL,
    "pais" "text" NOT NULL,
    "codigo" "text",
    "formato" "text",
    "caracteres_max" smallint,
    "lista" "text"
);


ALTER TABLE "public"."codigos_area" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."email_verification_tokens" (
    "id" bigint NOT NULL,
    "email" "text",
    "token" "text",
    "expires_at" timestamp with time zone,
    "verified" boolean,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "firstname" "text",
    "lastname" "text",
    "phone" "text"
);


ALTER TABLE "public"."email_verification_tokens" OWNER TO "postgres";


ALTER TABLE "public"."email_verification_tokens" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."email_verification_tokens_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."equipes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nome" "text" NOT NULL,
    "grupo_id" "uuid" NOT NULL,
    "cor" character varying(7) NOT NULL,
    "updated_by" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."equipes" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."equipes_medicos" (
    "equipes_id" "uuid",
    "medico_id" "uuid" NOT NULL,
    "grupo_id" "uuid" NOT NULL,
    "updated_by" "uuid",
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "medico_precadastro_id" "uuid",
    CONSTRAINT "chk_one_medico_type" CHECK (((("medico_id" = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::"uuid") AND ("medico_precadastro_id" IS NOT NULL)) OR (("medico_id" <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::"uuid") AND ("medico_precadastro_id" IS NULL))))
);


ALTER TABLE "public"."equipes_medicos" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."escalistas" (
    "auth_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nome" character varying NOT NULL,
    "telefone" character varying NOT NULL,
    "email" character varying,
    "grupo_id" "uuid",
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "update_at" timestamp with time zone DEFAULT ("now"() AT TIME ZONE 'utc'::"text") NOT NULL,
    "update_by" "uuid" DEFAULT "auth"."uid"(),
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "public"."escalistas" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."especialidades" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "nome" character varying,
    "index" smallint
);


ALTER TABLE "public"."especialidades" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."estados_brasil" (
    "id" bigint NOT NULL,
    "nome" "text",
    "sigla" "text",
    "lista" "text"
);


ALTER TABLE "public"."estados_brasil" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."formas_recebimento" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "forma_recebimento" "text"
);


ALTER TABLE "public"."formas_recebimento" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."grades" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "grupo_id" "uuid" NOT NULL,
    "nome" character varying(255) NOT NULL,
    "especialidade_id" "uuid",
    "setor_id" "uuid",
    "hospital_id" "uuid",
    "cor" character varying(7) NOT NULL,
    "horario_inicial" integer DEFAULT 7,
    "configuracao" "jsonb" DEFAULT '{}'::"jsonb",
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "created_by" "uuid",
    "updated_by" "uuid"
);


ALTER TABLE "public"."grades" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."grupos" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "nome" character varying NOT NULL,
    "responsavel" character varying,
    "telefone" character varying,
    "email" character varying,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."grupos" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."hospitais" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "nome" "text" NOT NULL,
    "logradouro" "text" NOT NULL,
    "numero" "text" NOT NULL,
    "cidade" "text" NOT NULL,
    "bairro" "text" NOT NULL,
    "estado" "text" NOT NULL,
    "pais" "text" NOT NULL,
    "cep" "text" NOT NULL,
    "latitude" numeric(10,6),
    "longitude" numeric(10,6),
    "endereco_formatado" "text",
    "avatar" "text" DEFAULT ''::"text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."hospitais" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."hospital_geofencing" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "hospital_id" "uuid",
    "latitude" numeric(10,8) NOT NULL,
    "longitude" numeric(11,8) NOT NULL,
    "raio_metros" integer DEFAULT 100,
    "ativo" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."hospital_geofencing" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."medicos" (
    "id" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "rqe" "text" DEFAULT 'Não informado'::"text",
    "genero" "text",
    "cpf" "text",
    "rg" "text",
    "crm" "text",
    "nome_faculdade" "text",
    "tipo_faculdade" "text",
    "primeiro_nome" "text",
    "sobrenome" "text",
    "email" "text",
    "telefone" "text",
    "data_nascimento" "date",
    "logradouro" "text",
    "numero" "text",
    "bairro" "text",
    "cidade" "text",
    "estado" "text",
    "pais" "text",
    "cep" "text",
    "created_at" timestamp without time zone DEFAULT "now"(),
    "update_at" timestamp with time zone,
    "update_by" "text" DEFAULT ''::"text",
    "delete_at" timestamp without time zone,
    "status" "text",
    "total_plantoes" integer DEFAULT 0,
    "especialidade_id" "uuid" DEFAULT '6404fc30-f292-4005-ae81-da1111a8822d'::"uuid",
    "ano_termino_especializacao" integer,
    "ano_formatura" integer,
    "tracking_privacy" boolean,
    "especialidade_nome" "text",
    "razao_social" "text",
    "cnpj" "text",
    "banco_agencia" "text",
    "banco_digito" "text",
    "banco_conta" "text",
    "banco_pix" "text",
    CONSTRAINT "medicos_medico_cep_check" CHECK (("cep" ~ '^\d{5}-\d{3}$$'::"text")),
    CONSTRAINT "medicos_medico_status_check" CHECK (("status" = ANY (ARRAY['ativo'::"text", 'inativo'::"text", 'suspenso'::"text"])))
);


ALTER TABLE "public"."medicos" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."medicos_favoritos" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "escalista_id" "uuid" NOT NULL,
    "medico_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "grupo_id" "uuid"
);


ALTER TABLE "public"."medicos_favoritos" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."medicos_precadastro" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "primeiro_nome" character varying(255) NOT NULL,
    "sobrenome" character varying(255) NOT NULL,
    "crm" character varying(50) NOT NULL,
    "cpf" character varying(14),
    "email" character varying(255),
    "telefone" character varying(20),
    "especialidade_id" "uuid",
    "created_by" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "estado" "text",
    "razao_social" "text",
    "cnpj" "text",
    "banco_agencia" "text",
    "banco_digito" "text",
    "banco_conta" "text",
    "banco_pix" "text"
);


ALTER TABLE "public"."medicos_precadastro" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "title" "text" NOT NULL,
    "body" "text" NOT NULL,
    "recipient_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "is_read" boolean DEFAULT false NOT NULL,
    "message_id" "text",
    "read_at" timestamp with time zone,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "route" "text",
    "extra_data" "jsonb"
);


ALTER TABLE "public"."notifications" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."pagamentos" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "medico_id" "uuid",
    "candidaturas_id" "uuid",
    "valor" integer NOT NULL,
    "vagas_id" "uuid",
    "medicos_id" "uuid"
);


ALTER TABLE "public"."pagamentos" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."periodos" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "nome" "text",
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."periodos" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."requisitos" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "nome" "text" NOT NULL
);


ALTER TABLE "public"."requisitos" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."setores" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "nome" character varying NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."setores" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."tipos_vaga" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "nome" "text",
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."tipos_vaga" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user_profile" (
    "id" "uuid" NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "role" "text" DEFAULT 'signup'::"text",
    "profilepicture" "text",
    "displayname" "text",
    "gender" "text",
    "areacode_index" smallint DEFAULT '0'::smallint NOT NULL,
    "uf_index" smallint DEFAULT '0'::smallint NOT NULL,
    "specialty_index" smallint DEFAULT '0'::smallint NOT NULL,
    "fcm_token" "text",
    "platform" "text",
    "apn_token" "text"
);


ALTER TABLE "public"."user_profile" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."vagas" (
    "id" "uuid" DEFAULT "extensions"."uuid_generate_v4"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "hospital_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "data" "date",
    "periodo_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "hora_inicio" time without time zone NOT NULL,
    "hora_fim" time without time zone NOT NULL,
    "valor" integer NOT NULL,
    "data_pagamento" "date" NOT NULL,
    "tipos_vaga_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "observacoes" character varying,
    "setor_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "escalista_id" "uuid" DEFAULT 'ada3a79a-6437-4e27-9e22-40c08c36c59b'::"uuid" NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "updated_by" "uuid" DEFAULT 'ada3a79a-6437-4e27-9e22-40c08c36c59b'::"uuid" NOT NULL,
    "deleted_at" timestamp with time zone DEFAULT "now"(),
    "status" character varying,
    "total_candidaturas" integer DEFAULT 0,
    "especialidade_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "grupo_id" "uuid" DEFAULT '59f5120a-ac2a-4c5f-a7f3-b5083982b5c6'::"uuid",
    "index" smallint NOT NULL,
    "forma_recebimento_id" "uuid",
    "recorrencia_id" "uuid",
    "grade_id" "uuid",
    CONSTRAINT "vagas_vagas_status_check" CHECK ((("status")::"text" = ANY (ARRAY[('aberta'::character varying)::"text", ('fechada'::character varying)::"text", ('cancelada'::character varying)::"text", ('anunciada'::character varying)::"text"]))),
    CONSTRAINT "vagas_vagas_valor_check" CHECK ((("valor")::numeric > (0)::numeric))
);


ALTER TABLE "public"."vagas" OWNER TO "postgres";


ALTER TABLE "public"."vagas" ALTER COLUMN "index" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."vagas_Index_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."vagas_beneficios" (
    "vaga_id" "uuid" NOT NULL,
    "beneficio_tipo_id" "uuid" NOT NULL,
    "id" smallint NOT NULL
);


ALTER TABLE "public"."vagas_beneficios" OWNER TO "postgres";


ALTER TABLE "public"."vagas_beneficios" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."vagas_beneficio_Index_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE OR REPLACE VIEW "public"."vagas_completo" WITH ("security_invoker"='on') AS
 SELECT "v"."id" AS "vagas_id",
    "v"."created_at" AS "vagas_createdate",
    "v"."data" AS "vagas_data",
    "v"."hora_inicio" AS "vagas_horainicio",
    "v"."hora_fim" AS "vagas_horafim",
    "v"."valor" AS "vagas_valor",
    "v"."data_pagamento" AS "vagas_datapagamento",
    "fr"."forma_recebimento" AS "vagas_formarecebimento",
    "v"."observacoes" AS "vagas_observacoes",
    "h"."nome" AS "hospital_nome",
    "s"."nome" AS "setor_nome",
    "p"."nome" AS "periodo_nome",
    "t"."nome" AS "tipo_nome",
    "esp"."nome" AS "especialidade_nome",
    "g"."id" AS "grupo_id",
    "g"."nome" AS "grupo_nome",
    "g"."responsavel" AS "grupo_responsavel",
    "g"."telefone" AS "grupo_telefone",
    "g"."email" AS "grupo_email",
    "v"."status" AS "vagas_status",
    "e"."nome" AS "escalista_nome",
    "e"."id" AS "escalista_id",
    "e"."telefone" AS "escalista_telefone",
    "e"."email" AS "escalista_email",
    "h"."latitude" AS "hospital_lat",
    "h"."longitude" AS "hospital_log",
    "h"."endereco_formatado" AS "hospital_end",
    "h"."avatar" AS "hospital_avatar"
   FROM (((((((("public"."vagas" "v"
     LEFT JOIN "public"."hospitais" "h" ON (("v"."hospital_id" = "h"."id")))
     LEFT JOIN "public"."setores" "s" ON (("v"."setor_id" = "s"."id")))
     LEFT JOIN "public"."periodos" "p" ON (("v"."periodo_id" = "p"."id")))
     LEFT JOIN "public"."tipos_vaga" "t" ON (("v"."tipos_vaga_id" = "t"."id")))
     LEFT JOIN "public"."escalistas" "e" ON (("v"."escalista_id" = "e"."id")))
     LEFT JOIN "public"."especialidades" "esp" ON (("v"."especialidade_id" = "esp"."id")))
     LEFT JOIN "public"."grupos" "g" ON (("v"."grupo_id" = "g"."id")))
     LEFT JOIN "public"."formas_recebimento" "fr" ON (("v"."forma_recebimento_id" = "fr"."id")));


ALTER TABLE "public"."vagas_completo" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."vagas_recorrencias" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "created_by" "uuid",
    "data_inicio" "date" NOT NULL,
    "data_fim" "date" NOT NULL,
    "dias_semana" integer[] NOT NULL,
    "observacoes" "text"
);


ALTER TABLE "public"."vagas_recorrencias" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."vagas_requisitos" (
    "vagas_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "requisito_tipo_id" "uuid" NOT NULL
);


ALTER TABLE "public"."vagas_requisitos" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."vagas_salvas" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "vagas_id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "medico_id" "uuid" DEFAULT "auth"."uid"() NOT NULL
);


ALTER TABLE "public"."vagas_salvas" OWNER TO "postgres";


ALTER TABLE "public"."vagas_salvas" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."vagas_salvas_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE OR REPLACE VIEW "public"."vw_folha_pagamento" AS
 SELECT "v"."id" AS "vagas_id",
    "v"."data" AS "vagas_data",
    "p"."nome" AS "periodo_nome",
    "v"."hora_inicio" AS "horario_inicio",
    "v"."hora_fim" AS "horario_fim",
    "v"."valor" AS "vagas_valor",
    "v"."data_pagamento" AS "vagas_datapagamento",
    "fr"."forma_recebimento",
    "h"."id" AS "hospital_id",
    "h"."nome" AS "hospital_nome",
    "e"."id" AS "especialidade_id",
    "e"."nome" AS "vagas_especialidade",
    "s"."id" AS "setor_id",
    "s"."nome" AS "setor_nome",
    "c"."id" AS "candidaturas_id",
    "c"."medico_id",
    "c"."medico_precadastro_id",
    "c"."status" AS "candidatura_status",
    "c"."data_confirmacao" AS "candidatos_dataconfirmacao",
    COALESCE("m"."primeiro_nome", ("mp"."primeiro_nome")::"text") AS "medico_primeironome",
    COALESCE("m"."sobrenome", ("mp"."sobrenome")::"text") AS "medico_sobrenome",
    COALESCE("m"."cpf", ("mp"."cpf")::"text") AS "medico_cpf",
    COALESCE("m"."crm", ("mp"."crm")::"text") AS "medico_crm",
    COALESCE("me"."nome", "mpe"."nome") AS "medico_especialidade",
    COALESCE("m"."razao_social", "mp"."razao_social") AS "razao_social",
    COALESCE("m"."cnpj", "mp"."cnpj") AS "cnpj",
    COALESCE("m"."banco_agencia", "mp"."banco_agencia") AS "banco_agencia",
    COALESCE("m"."banco_digito", "mp"."banco_digito") AS "banco_digito",
    COALESCE("m"."banco_conta", "mp"."banco_conta") AS "banco_conta",
    COALESCE("m"."banco_pix", "mp"."banco_pix") AS "banco_pix",
    "cc"."checkin",
    "cc"."checkout",
    "cc"."checkin_latitude",
    "cc"."checkin_longitude",
    "cc"."checkout_latitude",
    "cc"."checkout_longitude",
    "cc"."checkin_justificativa",
    "cc"."checkout_justificativa"
   FROM ((((((((((("public"."vagas" "v"
     JOIN "public"."candidaturas" "c" ON (("c"."vagas_id" = "v"."id")))
     LEFT JOIN "public"."medicos" "m" ON ((("m"."id" = "c"."medico_id") AND ("c"."medico_precadastro_id" IS NULL))))
     LEFT JOIN "public"."medicos_precadastro" "mp" ON (("mp"."id" = "c"."medico_precadastro_id")))
     LEFT JOIN "public"."checkin_checkout" "cc" ON ((("cc"."vaga_id" = "v"."id") AND (("cc"."medico_id" = "m"."id") OR ("cc"."medico_id" = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::"uuid")))))
     LEFT JOIN "public"."hospitais" "h" ON (("h"."id" = "v"."hospital_id")))
     LEFT JOIN "public"."especialidades" "e" ON (("e"."id" = "v"."especialidade_id")))
     LEFT JOIN "public"."especialidades" "me" ON (("me"."id" = "m"."especialidade_id")))
     LEFT JOIN "public"."especialidades" "mpe" ON (("mpe"."id" = "mp"."especialidade_id")))
     LEFT JOIN "public"."setores" "s" ON (("s"."id" = "v"."setor_id")))
     LEFT JOIN "public"."periodos" "p" ON (("p"."id" = "v"."periodo_id")))
     LEFT JOIN "public"."formas_recebimento" "fr" ON (("fr"."id" = "v"."forma_recebimento_id")))
  WHERE ((("v"."status")::"text" = 'fechada'::"text") AND ("c"."status" = 'APROVADO'::"text"));


ALTER TABLE "public"."vw_folha_pagamento" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."vw_vagas_candidaturas" AS
 SELECT "row_number"() OVER (ORDER BY "combined_data"."vagas_id", "combined_data"."effective_medico_id", "combined_data"."candidaturas_id") AS "idx",
    "combined_data"."vagas_id",
    "combined_data"."vagas_data",
    "combined_data"."vagas_createdate",
    "combined_data"."vagas_status",
    "combined_data"."vagas_valor",
    "combined_data"."vagas_horainicio",
    "combined_data"."vagas_horafim",
    "combined_data"."vagas_datapagamento",
    "combined_data"."vagas_periodo",
    "combined_data"."vagas_periodo_nome",
    "combined_data"."vagas_tipo",
    "combined_data"."vagas_tipo_nome",
    "combined_data"."vagas_formarecebimento",
    "combined_data"."vagas_formarecebimento_nome",
    "combined_data"."vagas_observacoes",
    "combined_data"."hospital_id",
    "combined_data"."hospital_nome",
    "combined_data"."hospital_estado",
    "combined_data"."hospital_lat",
    "combined_data"."hospital_log",
    "combined_data"."hospital_end",
    "combined_data"."hospital_avatar",
    "combined_data"."especialidade_id",
    "combined_data"."especialidade_nome",
    "combined_data"."setor_id",
    "combined_data"."setor_nome",
    "combined_data"."escalista_id",
    "combined_data"."escalista_nome",
    "combined_data"."escalista_email",
    "combined_data"."escalista_telefone",
    "combined_data"."grupo_id",
    "combined_data"."grupo_nome",
    "combined_data"."candidaturas_id",
    "combined_data"."total_candidaturas",
    "combined_data"."candidatura_status",
    "combined_data"."candidatura_createdate",
    "combined_data"."candidatura_updateby",
    "combined_data"."candidatura_updatedat",
    "combined_data"."effective_medico_id" AS "medico_id",
    "combined_data"."medico_primeiro_nome",
    "combined_data"."medico_sobrenome",
    "combined_data"."medico_crm",
    "combined_data"."medico_cpf",
    "combined_data"."medico_estado",
    "combined_data"."medico_email",
    "combined_data"."medico_telefone",
    "combined_data"."medico_precadastro_id",
    "combined_data"."recorrencia_id",
    "combined_data"."vaga_salva",
    "combined_data"."medico_favorito",
    "combined_data"."checkin",
    "combined_data"."checkout",
    "combined_data"."pagamento_valor",
    "combined_data"."grade_id",
    "combined_data"."grade_nome",
    "combined_data"."grade_cor"
   FROM ( SELECT DISTINCT "v"."id" AS "vagas_id",
            "v"."data" AS "vagas_data",
            "v"."created_at" AS "vagas_createdate",
            "v"."status" AS "vagas_status",
            "v"."valor" AS "vagas_valor",
            "v"."hora_inicio" AS "vagas_horainicio",
            "v"."hora_fim" AS "vagas_horafim",
            "v"."data_pagamento" AS "vagas_datapagamento",
            "v"."periodo_id" AS "vagas_periodo",
            "p"."nome" AS "vagas_periodo_nome",
            "v"."tipos_vaga_id" AS "vagas_tipo",
            "t"."nome" AS "vagas_tipo_nome",
            "v"."forma_recebimento_id" AS "vagas_formarecebimento",
            "f"."forma_recebimento" AS "vagas_formarecebimento_nome",
            "v"."observacoes" AS "vagas_observacoes",
            "v"."hospital_id",
            "h"."nome" AS "hospital_nome",
            "h"."estado" AS "hospital_estado",
            "h"."latitude" AS "hospital_lat",
            "h"."longitude" AS "hospital_log",
            "h"."endereco_formatado" AS "hospital_end",
            "h"."avatar" AS "hospital_avatar",
            "v"."especialidade_id",
            "e"."nome" AS "especialidade_nome",
            "v"."setor_id",
            "s"."nome" AS "setor_nome",
            "v"."escalista_id",
            "esc"."nome" AS "escalista_nome",
            "esc"."email" AS "escalista_email",
            "esc"."telefone" AS "escalista_telefone",
            "v"."grupo_id",
            "g"."nome" AS "grupo_nome",
            "c"."id" AS "candidaturas_id",
            "public"."count_candidaturas_total"("v"."id") AS "total_candidaturas",
            "c"."status" AS "candidatura_status",
            "c"."created_at" AS "candidatura_createdate",
            "c"."updated_by" AS "candidatura_updateby",
            "c"."updated_at" AS "candidatura_updatedat",
                CASE
                    WHEN (("c"."medico_id" = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::"uuid") AND ("c"."medico_precadastro_id" IS NOT NULL)) THEN "c"."medico_precadastro_id"
                    ELSE "vm"."medico_id"
                END AS "effective_medico_id",
            COALESCE("m"."primeiro_nome", ("mp"."primeiro_nome")::"text") AS "medico_primeiro_nome",
            COALESCE("m"."sobrenome", ("mp"."sobrenome")::"text") AS "medico_sobrenome",
            COALESCE("m"."crm", ("mp"."crm")::"text") AS "medico_crm",
            COALESCE("m"."cpf", ("mp"."cpf")::"text") AS "medico_cpf",
            COALESCE("m"."estado", "mp"."estado") AS "medico_estado",
            COALESCE("m"."email", ("mp"."email")::"text") AS "medico_email",
            COALESCE("m"."telefone", ("mp"."telefone")::"text") AS "medico_telefone",
            "c"."medico_precadastro_id",
            "v"."recorrencia_id",
                CASE
                    WHEN (("vs"."medico_id" IS NOT NULL) OR ("vsp"."medico_id" IS NOT NULL)) THEN true
                    ELSE false
                END AS "vaga_salva",
            "public"."current_user_is_favorito"("v"."grupo_id") AS "medico_favorito",
            COALESCE("cc"."checkin", "ccp"."checkin") AS "checkin",
            COALESCE("cc"."checkout", "ccp"."checkout") AS "checkout",
            "pg"."valor" AS "pagamento_valor",
            "v"."grade_id",
            "gr"."nome" AS "grade_nome",
            "gr"."cor" AS "grade_cor"
           FROM (((((((((((((((((("public"."vagas" "v"
             JOIN "public"."hospitais" "h" ON (("v"."hospital_id" = "h"."id")))
             JOIN "public"."especialidades" "e" ON (("v"."especialidade_id" = "e"."id")))
             JOIN "public"."setores" "s" ON (("v"."setor_id" = "s"."id")))
             LEFT JOIN "public"."escalistas" "esc" ON (("v"."escalista_id" = "esc"."id")))
             LEFT JOIN "public"."grupos" "g" ON (("v"."grupo_id" = "g"."id")))
             LEFT JOIN "public"."periodos" "p" ON (("v"."periodo_id" = "p"."id")))
             LEFT JOIN "public"."tipos_vaga" "t" ON (("v"."tipos_vaga_id" = "t"."id")))
             LEFT JOIN "public"."formas_recebimento" "f" ON (("v"."forma_recebimento_id" = "f"."id")))
             LEFT JOIN "public"."grades" "gr" ON (("v"."grade_id" = "gr"."id")))
             LEFT JOIN ( SELECT "candidaturas"."vagas_id",
                    "candidaturas"."medico_id"
                   FROM "public"."candidaturas"
                  WHERE (("candidaturas"."medico_id" IS NOT NULL) AND ("candidaturas"."medico_id" <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::"uuid"))
                UNION
                 SELECT "candidaturas"."vagas_id",
                    "candidaturas"."medico_precadastro_id" AS "medico_id"
                   FROM "public"."candidaturas"
                  WHERE (("candidaturas"."medico_id" = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::"uuid") AND ("candidaturas"."medico_precadastro_id" IS NOT NULL))
                UNION
                 SELECT "vagas_salvas"."vagas_id",
                    "vagas_salvas"."medico_id"
                   FROM "public"."vagas_salvas"
                  WHERE ("vagas_salvas"."medico_id" IS NOT NULL)) "vm" ON (("vm"."vagas_id" = "v"."id")))
             LEFT JOIN "public"."candidaturas" "c" ON ((("c"."vagas_id" = "v"."id") AND ((("c"."medico_id" = "vm"."medico_id") AND ("c"."medico_id" <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::"uuid")) OR (("c"."medico_id" = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::"uuid") AND ("c"."medico_precadastro_id" = "vm"."medico_id"))))))
             LEFT JOIN "public"."medicos" "m" ON ((("c"."medico_id" = "m"."id") AND ("c"."medico_id" <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::"uuid"))))
             LEFT JOIN "public"."medicos_precadastro" "mp" ON (("c"."medico_precadastro_id" = "mp"."id")))
             LEFT JOIN "public"."vagas_salvas" "vs" ON ((("vs"."vagas_id" = "v"."id") AND ("vs"."medico_id" = "vm"."medico_id"))))
             LEFT JOIN "public"."vagas_salvas" "vsp" ON ((("vsp"."vagas_id" = "v"."id") AND ("vsp"."medico_id" = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::"uuid"))))
             LEFT JOIN "public"."checkin_checkout" "cc" ON ((("cc"."vaga_id" = "v"."id") AND ("cc"."medico_id" = "vm"."medico_id"))))
             LEFT JOIN "public"."checkin_checkout" "ccp" ON ((("ccp"."vaga_id" = "v"."id") AND ("ccp"."medico_id" =
                CASE
                    WHEN ("c"."medico_id" = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::"uuid") THEN "c"."medico_precadastro_id"
                    ELSE "vm"."medico_id"
                END))))
             LEFT JOIN "public"."pagamentos" "pg" ON (("pg"."candidaturas_id" = "c"."id")))) "combined_data";


ALTER TABLE "public"."vw_vagas_candidaturas" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."whatsapp_number" (
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "number" "text" DEFAULT '5511969193194'::"text"
);


ALTER TABLE "public"."whatsapp_number" OWNER TO "postgres";


ALTER TABLE ONLY "public"."tipos_vaga"
    ADD CONSTRAINT "TipoVaga_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."banner_mkt"
    ADD CONSTRAINT "bannerMKT_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."beneficios"
    ADD CONSTRAINT "beneficio_tipo_beneficio_id_key" UNIQUE ("id");



ALTER TABLE ONLY "public"."beneficios"
    ADD CONSTRAINT "beneficio_tipo_beneficio_nome_key" UNIQUE ("nome");



ALTER TABLE ONLY "public"."beneficios"
    ADD CONSTRAINT "beneficio_tipo_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."candidaturas"
    ADD CONSTRAINT "candidaturas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."carteira_digital"
    ADD CONSTRAINT "carteira_digital_pkey" PRIMARY KEY ("carteira_id");



ALTER TABLE ONLY "public"."checkin_checkout"
    ADD CONSTRAINT "checkin_checkout_index_key" UNIQUE ("id");



ALTER TABLE ONLY "public"."checkin_checkout_nofitications"
    ADD CONSTRAINT "checkin_checkout_nofitications_id_key" UNIQUE ("id");



ALTER TABLE ONLY "public"."checkin_checkout_nofitications"
    ADD CONSTRAINT "checkin_checkout_nofitications_message_id_key" UNIQUE ("message_id");



ALTER TABLE ONLY "public"."checkin_checkout_nofitications"
    ADD CONSTRAINT "checkin_checkout_nofitications_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."checkin_checkout"
    ADD CONSTRAINT "checkin_checkout_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."checkin_checkout"
    ADD CONSTRAINT "checkin_checkout_vagas_id_key" UNIQUE ("vaga_id");



ALTER TABLE ONLY "public"."clean_hospital"
    ADD CONSTRAINT "clean_hospital_id_key" UNIQUE ("id");



ALTER TABLE ONLY "public"."clean_hospital"
    ADD CONSTRAINT "clean_hospital_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."codigos_area"
    ADD CONSTRAINT "codigosdearea_pkey" PRIMARY KEY ("pais");



ALTER TABLE ONLY "public"."email_verification_tokens"
    ADD CONSTRAINT "email_verification_tokens_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."equipes_medicos"
    ADD CONSTRAINT "equipes_medicos_id_key" UNIQUE ("id");



ALTER TABLE ONLY "public"."equipes_medicos"
    ADD CONSTRAINT "equipes_medicos_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."equipes"
    ADD CONSTRAINT "equipes_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."escalistas"
    ADD CONSTRAINT "escalista_id-de-escalista_key" UNIQUE ("id");



ALTER TABLE ONLY "public"."escalistas"
    ADD CONSTRAINT "escalista_id_key" UNIQUE ("id");



ALTER TABLE ONLY "public"."escalistas"
    ADD CONSTRAINT "escalista_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."especialidades"
    ADD CONSTRAINT "especialidades_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."estados_brasil"
    ADD CONSTRAINT "estadosBrasil_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."formas_recebimento"
    ADD CONSTRAINT "formas_recebimento_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."grades"
    ADD CONSTRAINT "grades_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."grupos"
    ADD CONSTRAINT "grupo_grupo_nome_key" UNIQUE ("nome");



ALTER TABLE ONLY "public"."grupos"
    ADD CONSTRAINT "grupo_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."hospital_geofencing"
    ADD CONSTRAINT "hospital_geofencing_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."hospitais"
    ADD CONSTRAINT "hospital_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."medicos_favoritos"
    ADD CONSTRAINT "medicos_favoritos_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."medicos"
    ADD CONSTRAINT "medicos_medico_cpf_key" UNIQUE ("cpf");



ALTER TABLE ONLY "public"."medicos"
    ADD CONSTRAINT "medicos_medico_crm_key" UNIQUE ("crm");



ALTER TABLE ONLY "public"."medicos"
    ADD CONSTRAINT "medicos_medico_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."medicos"
    ADD CONSTRAINT "medicos_medico_rg_key" UNIQUE ("rg");



ALTER TABLE ONLY "public"."medicos"
    ADD CONSTRAINT "medicos_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."medicos_precadastro"
    ADD CONSTRAINT "medicos_precadastro_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_id_key" UNIQUE ("id");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_notification_id_key" UNIQUE ("message_id");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pagamentos"
    ADD CONSTRAINT "pagamentos_candidaturas_id_key" UNIQUE ("candidaturas_id");



ALTER TABLE ONLY "public"."pagamentos"
    ADD CONSTRAINT "pagamentos_medico_vaga_unique" UNIQUE ("medico_id", "vagas_id");



ALTER TABLE ONLY "public"."pagamentos"
    ADD CONSTRAINT "pagamentos_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."pagamentos"
    ADD CONSTRAINT "pagamentos_vagas_id_key" UNIQUE ("vagas_id");



ALTER TABLE ONLY "public"."periodos"
    ADD CONSTRAINT "periodo_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."requisitos"
    ADD CONSTRAINT "requisito_tipo_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."setores"
    ADD CONSTRAINT "setores_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."medicos_favoritos"
    ADD CONSTRAINT "unique_escalista_medico" UNIQUE ("escalista_id", "medico_id");



ALTER TABLE ONLY "public"."user_profile"
    ADD CONSTRAINT "user_profile_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."vagas"
    ADD CONSTRAINT "vagas_Index_key" UNIQUE ("index");



ALTER TABLE ONLY "public"."vagas_beneficios"
    ADD CONSTRAINT "vagas_beneficio_Index_key" UNIQUE ("id");



ALTER TABLE ONLY "public"."vagas_beneficios"
    ADD CONSTRAINT "vagas_beneficio_index_key" UNIQUE ("id");



ALTER TABLE ONLY "public"."vagas_beneficios"
    ADD CONSTRAINT "vagas_beneficio_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."vagas"
    ADD CONSTRAINT "vagas_index_key" UNIQUE ("index");



ALTER TABLE ONLY "public"."vagas"
    ADD CONSTRAINT "vagas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."vagas_recorrencias"
    ADD CONSTRAINT "vagas_recorrencia_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."vagas_salvas"
    ADD CONSTRAINT "vagas_salvas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."whatsapp_number"
    ADD CONSTRAINT "whatsappnumber_pkey" PRIMARY KEY ("updated_at");



CREATE INDEX "idx_beneficio_nome" ON "public"."beneficios" USING "btree" ("nome");



CREATE INDEX "idx_candidatura_medico" ON "public"."candidaturas" USING "btree" ("medico_id");



CREATE INDEX "idx_candidatura_status" ON "public"."candidaturas" USING "btree" ("vagas_id", "status");



CREATE INDEX "idx_candidatura_vaga" ON "public"."candidaturas" USING "btree" ("vagas_id");



CREATE INDEX "idx_candidaturas_medico_precadastro_id" ON "public"."candidaturas" USING "btree" ("medico_precadastro_id");



CREATE INDEX "idx_candidaturas_medico_vaga" ON "public"."candidaturas" USING "btree" ("medico_id", "vagas_id");



CREATE INDEX "idx_candidaturas_status" ON "public"."candidaturas" USING "btree" ("status");



CREATE INDEX "idx_carteira_medico" ON "public"."carteira_digital" USING "btree" ("medico_id");



CREATE INDEX "idx_escalista_grupo" ON "public"."escalistas" USING "btree" ("grupo_id");



CREATE INDEX "idx_escalista_nome" ON "public"."escalistas" USING "btree" ("nome");



CREATE INDEX "idx_grades_configuracao" ON "public"."grades" USING "gin" ("configuracao");



CREATE INDEX "idx_grades_created_by" ON "public"."grades" USING "btree" ("created_by");



CREATE INDEX "idx_grades_especialidade_id" ON "public"."grades" USING "btree" ("especialidade_id");



CREATE INDEX "idx_grades_grupo_id" ON "public"."grades" USING "btree" ("grupo_id");



CREATE INDEX "idx_grades_hospital_id" ON "public"."grades" USING "btree" ("hospital_id");



CREATE INDEX "idx_grades_setor_id" ON "public"."grades" USING "btree" ("setor_id");



CREATE INDEX "idx_grupo_nome" ON "public"."grupos" USING "btree" ("nome");



CREATE INDEX "idx_hospital_nome" ON "public"."hospitais" USING "btree" ("nome");



CREATE INDEX "idx_medico_cpf" ON "public"."medicos" USING "btree" ("cpf");



CREATE INDEX "idx_medico_crm" ON "public"."medicos" USING "btree" ("crm");



CREATE INDEX "idx_medico_localidade" ON "public"."medicos" USING "btree" ("cidade", "estado");



CREATE INDEX "idx_medico_nome" ON "public"."medicos" USING "btree" ("primeiro_nome", "sobrenome");



CREATE INDEX "idx_medicos_cpf" ON "public"."medicos" USING "btree" ("cpf");



CREATE INDEX "idx_medicos_crm" ON "public"."medicos" USING "btree" ("crm");



CREATE INDEX "idx_medicos_email" ON "public"."medicos" USING "btree" ("email");



CREATE INDEX "idx_medicos_especialidade" ON "public"."medicos" USING "btree" ("especialidade_id");



CREATE INDEX "idx_medicos_favoritos_escalista" ON "public"."medicos_favoritos" USING "btree" ("escalista_id");



CREATE INDEX "idx_medicos_favoritos_medico" ON "public"."medicos_favoritos" USING "btree" ("medico_id");



CREATE INDEX "idx_medicos_precadastro_cpf" ON "public"."medicos_precadastro" USING "btree" ("cpf");



CREATE INDEX "idx_medicos_precadastro_created_by" ON "public"."medicos_precadastro" USING "btree" ("created_by");



CREATE INDEX "idx_medicos_precadastro_crm" ON "public"."medicos_precadastro" USING "btree" ("crm");



CREATE INDEX "idx_medicos_precadastro_nome" ON "public"."medicos_precadastro" USING "btree" ("primeiro_nome", "sobrenome");



CREATE INDEX "idx_medicos_status" ON "public"."medicos" USING "btree" ("status");



CREATE INDEX "idx_setor_nome" ON "public"."setores" USING "btree" ("nome");



CREATE INDEX "idx_vaga_escalista" ON "public"."vagas" USING "btree" ("escalista_id");



CREATE INDEX "idx_vaga_hospital" ON "public"."vagas" USING "btree" ("hospital_id");



CREATE INDEX "idx_vaga_periodo" ON "public"."vagas" USING "btree" ("data", "periodo_id");



CREATE INDEX "idx_vaga_setor" ON "public"."vagas" USING "btree" ("setor_id");



CREATE INDEX "idx_vagas_data" ON "public"."vagas" USING "btree" ("data");



CREATE INDEX "idx_vagas_especialidade" ON "public"."vagas" USING "btree" ("especialidade_id");



CREATE INDEX "idx_vagas_grade_id" ON "public"."vagas" USING "btree" ("grade_id");



CREATE INDEX "idx_vagas_hospital" ON "public"."vagas" USING "btree" ("hospital_id");



CREATE INDEX "idx_vagas_recorrencia_id" ON "public"."vagas" USING "btree" ("recorrencia_id");



CREATE INDEX "idx_vagas_status" ON "public"."vagas" USING "btree" ("status");



CREATE UNIQUE INDEX "unique_equipe_medico_precadastro" ON "public"."equipes_medicos" USING "btree" ("equipes_id", "medico_precadastro_id") WHERE ("medico_precadastro_id" IS NOT NULL);



CREATE UNIQUE INDEX "unique_equipe_medico_real" ON "public"."equipes_medicos" USING "btree" ("equipes_id", "medico_id") WHERE ("medico_precadastro_id" IS NULL);



CREATE OR REPLACE TRIGGER "candidaturas_1_verificar_conflito_horario" BEFORE INSERT ON "public"."candidaturas" FOR EACH ROW EXECUTE FUNCTION "public"."verificar_conflito_antes_candidatura"();



CREATE OR REPLACE TRIGGER "candidaturas_2_auto_aprovar_favoritos" BEFORE INSERT ON "public"."candidaturas" FOR EACH ROW EXECUTE FUNCTION "public"."aprovacao_automatica_favoritos"();



CREATE OR REPLACE TRIGGER "candidaturas_3_atualizar_contador_vagas" AFTER INSERT OR DELETE ON "public"."candidaturas" FOR EACH ROW EXECUTE FUNCTION "public"."update_total_candidaturas"();



CREATE OR REPLACE TRIGGER "candidaturas_4_fechar_vaga_ao_aprovar" AFTER UPDATE ON "public"."candidaturas" FOR EACH ROW WHEN (("new"."status" = 'APROVADO'::"text")) EXECUTE FUNCTION "public"."atualizar_vagas_status"();



CREATE OR REPLACE TRIGGER "candidaturas_5_contar_plantoes_medico" AFTER UPDATE ON "public"."candidaturas" FOR EACH ROW WHEN (("old"."status" IS DISTINCT FROM "new"."status")) EXECUTE FUNCTION "public"."update_total_plantoes_medico"();



CREATE OR REPLACE TRIGGER "checkin_checkout_1_validar_timing" BEFORE INSERT ON "public"."checkin_checkout" FOR EACH ROW EXECUTE FUNCTION "public"."validate_checkin_timing"();



CREATE OR REPLACE TRIGGER "checkin_checkout_2_validar_timing" BEFORE UPDATE ON "public"."checkin_checkout" FOR EACH ROW EXECUTE FUNCTION "public"."validate_checkout_timing"();



CREATE OR REPLACE TRIGGER "especialidades_1_setar_coluna_nome" BEFORE INSERT OR UPDATE ON "public"."medicos" FOR EACH ROW EXECUTE FUNCTION "public"."update_especialidade_nome"();



CREATE OR REPLACE TRIGGER "medicos_1_cleanup_precadastro" AFTER INSERT ON "public"."medicos" FOR EACH ROW EXECUTE FUNCTION "public"."cleanup_medicos_precadastro"();



CREATE OR REPLACE TRIGGER "trigger_grades_updated_at" BEFORE UPDATE ON "public"."grades" FOR EACH ROW EXECUTE FUNCTION "public"."handle_grades_updated_at"();



CREATE OR REPLACE TRIGGER "vagas_1_reprovar_candidaturas_ao_cancelar" AFTER UPDATE OF "status" ON "public"."vagas" FOR EACH ROW EXECUTE FUNCTION "public"."atualizar_candidaturas_vaga_cancelada"();



ALTER TABLE ONLY "public"."candidaturas"
    ADD CONSTRAINT "candidaturas_medico_id_fkey" FOREIGN KEY ("medico_id") REFERENCES "public"."medicos"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."candidaturas"
    ADD CONSTRAINT "candidaturas_vagas_id_fkey" FOREIGN KEY ("vagas_id") REFERENCES "public"."vagas"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."carteira_digital"
    ADD CONSTRAINT "carteira_digital_medico_id_fkey" FOREIGN KEY ("medico_id") REFERENCES "public"."medicos"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."checkin_checkout"
    ADD CONSTRAINT "checkin_checkout_medico_id_fkey" FOREIGN KEY ("medico_id") REFERENCES "public"."medicos"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."checkin_checkout_nofitications"
    ADD CONSTRAINT "checkin_checkout_nofitications_recipient_id_fkey" FOREIGN KEY ("recipient_id") REFERENCES "public"."user_profile"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."checkin_checkout"
    ADD CONSTRAINT "checkin_checkout_vagas_id_fkey" FOREIGN KEY ("vaga_id") REFERENCES "public"."vagas"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."equipes_medicos"
    ADD CONSTRAINT "equipes_medicos_equipes_id_fkey" FOREIGN KEY ("equipes_id") REFERENCES "public"."equipes"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."equipes_medicos"
    ADD CONSTRAINT "equipes_medicos_grupo_id_fkey" FOREIGN KEY ("grupo_id") REFERENCES "public"."grupos"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."escalistas"
    ADD CONSTRAINT "escalista_escalista_auth_id_fkey" FOREIGN KEY ("auth_id") REFERENCES "public"."user_profile"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."escalistas"
    ADD CONSTRAINT "escalista_grupo_id_fkey" FOREIGN KEY ("grupo_id") REFERENCES "public"."grupos"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."equipes"
    ADD CONSTRAINT "fk_grupo_id" FOREIGN KEY ("grupo_id") REFERENCES "public"."grupos"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."equipes_medicos"
    ADD CONSTRAINT "fk_medico" FOREIGN KEY ("medico_id") REFERENCES "public"."medicos"("id");



ALTER TABLE ONLY "public"."equipes_medicos"
    ADD CONSTRAINT "fk_medico_precadastro" FOREIGN KEY ("medico_precadastro_id") REFERENCES "public"."medicos_precadastro"("id");



ALTER TABLE ONLY "public"."candidaturas"
    ADD CONSTRAINT "fk_medico_precadastro_candidaturas" FOREIGN KEY ("medico_precadastro_id") REFERENCES "public"."medicos_precadastro"("id");



ALTER TABLE ONLY "public"."medicos_favoritos"
    ADD CONSTRAINT "fk_medicos_favoritos_escalista" FOREIGN KEY ("escalista_id") REFERENCES "public"."escalistas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."medicos_favoritos"
    ADD CONSTRAINT "fk_medicos_favoritos_medico" FOREIGN KEY ("medico_id") REFERENCES "public"."medicos"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vagas"
    ADD CONSTRAINT "fk_vagas_grade" FOREIGN KEY ("grade_id") REFERENCES "public"."grades"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."grades"
    ADD CONSTRAINT "grades_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."grades"
    ADD CONSTRAINT "grades_especialidade_id_fkey" FOREIGN KEY ("especialidade_id") REFERENCES "public"."especialidades"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."grades"
    ADD CONSTRAINT "grades_grupo_id_fkey" FOREIGN KEY ("grupo_id") REFERENCES "public"."grupos"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."grades"
    ADD CONSTRAINT "grades_hospital_id_fkey" FOREIGN KEY ("hospital_id") REFERENCES "public"."hospitais"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."grades"
    ADD CONSTRAINT "grades_setor_id_fkey" FOREIGN KEY ("setor_id") REFERENCES "public"."setores"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."grades"
    ADD CONSTRAINT "grades_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."hospital_geofencing"
    ADD CONSTRAINT "hospital_geofencing_hospital_id_fkey" FOREIGN KEY ("hospital_id") REFERENCES "public"."hospitais"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."medicos_favoritos"
    ADD CONSTRAINT "medicos_favoritos_grupo_id_fkey" FOREIGN KEY ("grupo_id") REFERENCES "public"."grupos"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."medicos"
    ADD CONSTRAINT "medicos_id_fkey" FOREIGN KEY ("id") REFERENCES "public"."user_profile"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."medicos"
    ADD CONSTRAINT "medicos_medico_especialidade_fkey" FOREIGN KEY ("especialidade_id") REFERENCES "public"."especialidades"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."medicos_precadastro"
    ADD CONSTRAINT "medicos_precadastro_medico_especialidade_fkey" FOREIGN KEY ("especialidade_id") REFERENCES "public"."especialidades"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("recipient_id") REFERENCES "public"."user_profile"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pagamentos"
    ADD CONSTRAINT "pagamentos_candidaturas_id_fkey" FOREIGN KEY ("candidaturas_id") REFERENCES "public"."candidaturas"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pagamentos"
    ADD CONSTRAINT "pagamentos_medico_id_fkey" FOREIGN KEY ("medico_id") REFERENCES "public"."medicos"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pagamentos"
    ADD CONSTRAINT "pagamentos_medicos_id_fkey" FOREIGN KEY ("medicos_id") REFERENCES "public"."medicos"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."pagamentos"
    ADD CONSTRAINT "pagamentos_vagas_id_fkey" FOREIGN KEY ("vagas_id") REFERENCES "public"."vagas"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_profile"
    ADD CONSTRAINT "user_profile_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vagas_beneficios"
    ADD CONSTRAINT "vagas_beneficio_beneficio_id_fkey" FOREIGN KEY ("beneficio_tipo_id") REFERENCES "public"."beneficios"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vagas_beneficios"
    ADD CONSTRAINT "vagas_beneficio_vaga_id_fkey" FOREIGN KEY ("vaga_id") REFERENCES "public"."vagas"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vagas"
    ADD CONSTRAINT "vagas_formarecebimento_fkey" FOREIGN KEY ("forma_recebimento_id") REFERENCES "public"."formas_recebimento"("id");



ALTER TABLE ONLY "public"."vagas"
    ADD CONSTRAINT "vagas_grupo_id_fkey" FOREIGN KEY ("grupo_id") REFERENCES "public"."grupos"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vagas"
    ADD CONSTRAINT "vagas_recorrencia_id_fkey" FOREIGN KEY ("recorrencia_id") REFERENCES "public"."vagas_recorrencias"("id");



ALTER TABLE ONLY "public"."vagas_requisitos"
    ADD CONSTRAINT "vagas_requisito_requisito_id_fkey" FOREIGN KEY ("requisito_tipo_id") REFERENCES "public"."requisitos"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vagas_requisitos"
    ADD CONSTRAINT "vagas_requisito_vagas_id_fkey" FOREIGN KEY ("vagas_id") REFERENCES "public"."vagas"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vagas_salvas"
    ADD CONSTRAINT "vagas_salvas_medico_id_fkey" FOREIGN KEY ("medico_id") REFERENCES "public"."medicos"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vagas_salvas"
    ADD CONSTRAINT "vagas_salvas_vagas_id_fkey" FOREIGN KEY ("vagas_id") REFERENCES "public"."vagas"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."vagas"
    ADD CONSTRAINT "vagas_vaga_especialidade_fkey" FOREIGN KEY ("especialidade_id") REFERENCES "public"."especialidades"("id");



ALTER TABLE ONLY "public"."vagas"
    ADD CONSTRAINT "vagas_vagas_escalista_fkey" FOREIGN KEY ("escalista_id") REFERENCES "public"."escalistas"("id") ON UPDATE CASCADE ON DELETE SET DEFAULT;



ALTER TABLE ONLY "public"."vagas"
    ADD CONSTRAINT "vagas_vagas_hospital_fkey" FOREIGN KEY ("hospital_id") REFERENCES "public"."hospitais"("id");



ALTER TABLE ONLY "public"."vagas"
    ADD CONSTRAINT "vagas_vagas_periodo_fkey" FOREIGN KEY ("periodo_id") REFERENCES "public"."periodos"("id");



ALTER TABLE ONLY "public"."vagas"
    ADD CONSTRAINT "vagas_vagas_setor_fkey" FOREIGN KEY ("setor_id") REFERENCES "public"."setores"("id");



ALTER TABLE ONLY "public"."vagas"
    ADD CONSTRAINT "vagas_vagas_tipo_fkey" FOREIGN KEY ("tipos_vaga_id") REFERENCES "public"."tipos_vaga"("id");



CREATE POLICY "Apenas usuários autorizados podem aprovar documentos" ON "public"."carteira_digital" FOR UPDATE TO "authenticated" USING (true) WITH CHECK (true);



CREATE POLICY "Delete policy" ON "public"."equipes" FOR DELETE TO "authenticated" USING (("grupo_id" = "public"."get_current_user_grupo_id"()));



CREATE POLICY "Delete policy" ON "public"."equipes_medicos" FOR DELETE TO "authenticated" USING (("grupo_id" = "public"."get_current_user_grupo_id"()));



CREATE POLICY "Documentos visíveis para usuários autenticados" ON "public"."carteira_digital" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Enable access to authenticated users" ON "public"."clean_hospital" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Enable authenticated users to read all data" ON "public"."setores" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Enable escalista and astronauta users update medicos data" ON "public"."medicos" FOR UPDATE TO "authenticated" USING (( SELECT (EXISTS ( SELECT 1
           FROM "public"."user_profile"
          WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = ANY (ARRAY['escalista'::"text", 'astronauta'::"text"]))))) AS "exists"));



CREATE POLICY "Enable escalista users read all data" ON "public"."medicos" FOR SELECT TO "authenticated" USING (( SELECT ("auth"."uid"() IN ( SELECT "escalistas"."auth_id" AS "escalista_id"
           FROM "public"."escalistas"))));



CREATE POLICY "Enable full access to astronauta user" ON "public"."escalistas" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text")))));



CREATE POLICY "Enable full access to astronauta users" ON "public"."vagas_beneficios" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text")))));



CREATE POLICY "Enable full access to astronauta users" ON "public"."vagas_recorrencias" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text")))));



CREATE POLICY "Enable full access to astronauta users" ON "public"."vagas_requisitos" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text")))));



CREATE POLICY "Enable full acess to astronauta user" ON "public"."grupos" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text")))));



CREATE POLICY "Enable full acess to astronauta users" ON "public"."hospitais" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text")))));



CREATE POLICY "Enable insert to escalista users" ON "public"."hospitais" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'escalista'::"text")))));



CREATE POLICY "Enable medico user full access to their own data" ON "public"."pagamentos" TO "authenticated" USING ((("auth"."uid"() = "medico_id") OR ("auth"."uid"() = "medicos_id"))) WITH CHECK ((("auth"."uid"() = "medico_id") OR ("auth"."uid"() = "medicos_id")));



CREATE POLICY "Enable medico users full access to their own data" ON "public"."checkin_checkout" TO "authenticated" USING (("medico_id" = ( SELECT "medicos"."id"
   FROM "public"."medicos"
  WHERE ("medicos"."id" = "auth"."uid"())))) WITH CHECK (("medico_id" = ( SELECT "medicos"."id"
   FROM "public"."medicos"
  WHERE ("medicos"."id" = "auth"."uid"()))));



CREATE POLICY "Enable medico users full access to their own data" ON "public"."vagas_salvas" TO "authenticated" USING (("auth"."uid"() = "medico_id")) WITH CHECK (("auth"."uid"() = "medico_id"));



CREATE POLICY "Enable medico users update their own data only" ON "public"."medicos" FOR UPDATE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "id"));



CREATE POLICY "Enable medicos users insert their own data only" ON "public"."medicos" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "auth"."uid"() AS "uid") = "id"));



CREATE POLICY "Enable medicos users to view their own data only" ON "public"."medicos" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Enable read access for all authenticated users" ON "public"."escalistas" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."banner_mkt" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."codigos_area" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."especialidades" FOR SELECT TO "authenticated", "anon" USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."estados_brasil" FOR SELECT USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."formas_recebimento" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Enable read access for all users" ON "public"."vagas_beneficios" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Enable read access for anon" ON "public"."user_profile" FOR SELECT TO "anon" USING (true);



CREATE POLICY "Enable read access for authenticated users" ON "public"."beneficios" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Enable read access for authenticated users" ON "public"."hospitais" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Enable read access for authenticated users" ON "public"."periodos" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Enable read access for authenticated users" ON "public"."tipos_vaga" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Enable read access for authenticated users" ON "public"."whatsapp_number" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Enable read access to escalista users" ON "public"."checkin_checkout" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = ANY (ARRAY['astronauta'::"text", 'escalista'::"text"]))))));



CREATE POLICY "Enable read for authenticated users" ON "public"."vagas_requisitos" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Enable read to anon" ON "public"."email_verification_tokens" FOR SELECT TO "anon" USING (true);



CREATE POLICY "Enable read to astronauta and escalista users" ON "public"."vagas_salvas" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text") AND ("user_profile"."role" = 'escalista'::"text")))));



CREATE POLICY "Enable read to authenticated users" ON "public"."requisitos" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Enable read to authenticated users" ON "public"."user_profile" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Enable read to medico users" ON "public"."grupos" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'free'::"text")))));



CREATE POLICY "Enable update for users based on user_id" ON "public"."user_profile" FOR UPDATE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "id"));



CREATE POLICY "Enable update to anon" ON "public"."email_verification_tokens" FOR UPDATE USING (true) WITH CHECK (true);



CREATE POLICY "Enable update to escalista users" ON "public"."hospitais" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'escalista'::"text"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'escalista'::"text")))));



CREATE POLICY "Insert policy" ON "public"."equipes" FOR INSERT TO "authenticated" WITH CHECK (("grupo_id" = "public"."get_current_user_grupo_id"()));



CREATE POLICY "Insert policy" ON "public"."equipes_medicos" FOR INSERT TO "authenticated" WITH CHECK (("grupo_id" = "public"."get_current_user_grupo_id"()));



CREATE POLICY "Insert policy" ON "public"."medicos_precadastro" FOR INSERT TO "authenticated" WITH CHECK (((( SELECT "e"."id" AS "escalista_id"
   FROM "public"."escalistas" "e"
  WHERE ("e"."auth_id" = "auth"."uid"())) = "created_by") OR (EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text"))))));



CREATE POLICY "Read policy" ON "public"."equipes" FOR SELECT TO "authenticated" USING (("grupo_id" = "public"."get_current_user_grupo_id"()));



CREATE POLICY "Read policy" ON "public"."equipes_medicos" FOR SELECT TO "authenticated" USING (("grupo_id" = "public"."get_current_user_grupo_id"()));



CREATE POLICY "Select policy" ON "public"."medicos_precadastro" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Service role can insert notifications" ON "public"."notifications" FOR INSERT TO "service_role" WITH CHECK (true);



CREATE POLICY "Service role can update notifications" ON "public"."notifications" FOR UPDATE TO "service_role" WITH CHECK (true);



CREATE POLICY "Update policy" ON "public"."equipes" FOR UPDATE TO "authenticated" USING (("grupo_id" = "public"."get_current_user_grupo_id"()));



CREATE POLICY "Update policy" ON "public"."equipes_medicos" FOR UPDATE TO "authenticated" USING (("grupo_id" = "public"."get_current_user_grupo_id"()));



CREATE POLICY "Update policy" ON "public"."medicos_precadastro" FOR UPDATE TO "authenticated" USING (((( SELECT "e"."id" AS "escalista_id"
   FROM "public"."escalistas" "e"
  WHERE ("e"."auth_id" = "auth"."uid"())) = "created_by") OR (EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text")))))) WITH CHECK (((( SELECT "e"."id" AS "escalista_id"
   FROM "public"."escalistas" "e"
  WHERE ("e"."auth_id" = "auth"."uid"())) = "created_by") OR (EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text"))))));



CREATE POLICY "Users can update own notifications read status" ON "public"."notifications" FOR UPDATE TO "authenticated" USING (("recipient_id" = "auth"."uid"())) WITH CHECK (("recipient_id" = "auth"."uid"()));



CREATE POLICY "Users can view own notifications" ON "public"."notifications" FOR SELECT TO "authenticated" USING (("recipient_id" = "auth"."uid"()));



CREATE POLICY "astronauts_can_delete_grades" ON "public"."grades" FOR DELETE USING ((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text")))));



CREATE POLICY "astronauts_can_insert_grades" ON "public"."grades" FOR INSERT WITH CHECK (((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text")))) AND ("auth"."uid"() = "created_by")));



CREATE POLICY "astronauts_can_select_grades" ON "public"."grades" FOR SELECT USING ((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text")))));



CREATE POLICY "astronauts_can_update_grades" ON "public"."grades" FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text")))));



ALTER TABLE "public"."banner_mkt" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."beneficios" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."candidaturas" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "candidaturas_delete_policy" ON "public"."candidaturas" FOR DELETE TO "authenticated" USING (((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text")))) OR (("public"."get_current_user_grupo_id"() IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM "public"."vagas" "v"
  WHERE (("v"."id" = "candidaturas"."vagas_id") AND ("v"."grupo_id" = "public"."get_current_user_grupo_id"()))))) OR ((EXISTS ( SELECT 1
   FROM ("public"."user_profile" "up"
     JOIN "public"."medicos" "m" ON (("m"."id" = "up"."id")))
  WHERE (("up"."id" = "auth"."uid"()) AND ("up"."role" = 'free'::"text")))) AND ("medico_id" = "auth"."uid"()))));



CREATE POLICY "candidaturas_insert_policy" ON "public"."candidaturas" FOR INSERT TO "authenticated" WITH CHECK (((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text")))) OR (("public"."get_current_user_grupo_id"() IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM "public"."vagas" "v"
  WHERE (("v"."id" = "candidaturas"."vagas_id") AND ("v"."grupo_id" = "public"."get_current_user_grupo_id"()))))) OR ((EXISTS ( SELECT 1
   FROM ("public"."user_profile" "up"
     JOIN "public"."medicos" "m" ON (("m"."id" = "up"."id")))
  WHERE (("up"."id" = "auth"."uid"()) AND ("up"."role" = 'free'::"text")))) AND ("medico_id" = "auth"."uid"()))));



CREATE POLICY "candidaturas_select_policy" ON "public"."candidaturas" FOR SELECT TO "authenticated" USING (((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text")))) OR (("public"."get_current_user_grupo_id"() IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM "public"."vagas" "v"
  WHERE (("v"."id" = "candidaturas"."vagas_id") AND ("v"."grupo_id" = "public"."get_current_user_grupo_id"()))))) OR ((EXISTS ( SELECT 1
   FROM ("public"."user_profile" "up"
     JOIN "public"."medicos" "m" ON (("m"."id" = "up"."id")))
  WHERE (("up"."id" = "auth"."uid"()) AND ("up"."role" = 'free'::"text")))) AND ("medico_id" = "auth"."uid"())) OR ((EXISTS ( SELECT 1
   FROM ("public"."user_profile" "up"
     JOIN "public"."medicos_precadastro" "mp" ON (("mp"."id" = "up"."id")))
  WHERE (("up"."id" = "auth"."uid"()) AND ("up"."role" = 'free'::"text")))) AND ("medico_precadastro_id" = "auth"."uid"())) OR ((EXISTS ( SELECT 1
   FROM ("public"."user_profile" "up"
     JOIN "public"."medicos" "m" ON (("m"."id" = "up"."id")))
  WHERE (("up"."id" = "auth"."uid"()) AND ("up"."role" = 'free'::"text")))) AND "public"."pode_ver_candidatura_colega"("id")) OR ((EXISTS ( SELECT 1
   FROM ("public"."user_profile" "up"
     JOIN "public"."medicos_precadastro" "mp" ON (("mp"."id" = "up"."id")))
  WHERE (("up"."id" = "auth"."uid"()) AND ("up"."role" = 'free'::"text")))) AND "public"."pode_ver_candidatura_colega"("id"))));



CREATE POLICY "candidaturas_update_policy" ON "public"."candidaturas" FOR UPDATE TO "authenticated" USING (((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text")))) OR (("public"."get_current_user_grupo_id"() IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM "public"."vagas" "v"
  WHERE (("v"."id" = "candidaturas"."vagas_id") AND ("v"."grupo_id" = "public"."get_current_user_grupo_id"()))))) OR ((EXISTS ( SELECT 1
   FROM ("public"."user_profile" "up"
     JOIN "public"."medicos" "m" ON (("m"."id" = "up"."id")))
  WHERE (("up"."id" = "auth"."uid"()) AND ("up"."role" = 'free'::"text")))) AND ("medico_id" = "auth"."uid"())))) WITH CHECK (((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text")))) OR (("public"."get_current_user_grupo_id"() IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM "public"."vagas" "v"
  WHERE (("v"."id" = "candidaturas"."vagas_id") AND ("v"."grupo_id" = "public"."get_current_user_grupo_id"()))))) OR ((EXISTS ( SELECT 1
   FROM ("public"."user_profile" "up"
     JOIN "public"."medicos" "m" ON (("m"."id" = "up"."id")))
  WHERE (("up"."id" = "auth"."uid"()) AND ("up"."role" = 'free'::"text")))) AND ("medico_id" = "auth"."uid"()))));



ALTER TABLE "public"."carteira_digital" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."checkin_checkout" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."checkin_checkout_nofitications" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."clean_hospital" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."codigos_area" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."email_verification_tokens" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."equipes" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."equipes_medicos" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "escalista_policy" ON "public"."escalistas" TO "authenticated" USING (
CASE
    WHEN ("public"."get_current_user_grupo_id"() IS NULL) THEN true
    ELSE ("grupo_id" = "public"."get_current_user_grupo_id"())
END);



CREATE POLICY "escalista_read_own_grupo" ON "public"."grupos" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM ("public"."user_profile" "up"
     JOIN "public"."escalistas" "e" ON (("e"."auth_id" = "up"."id")))
  WHERE (("up"."id" = "auth"."uid"()) AND ("up"."role" = 'escalista'::"text") AND ("e"."grupo_id" = "grupos"."id")))));



ALTER TABLE "public"."escalistas" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."especialidades" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."estados_brasil" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."formas_recebimento" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."grades" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "grades_delete_by_group" ON "public"."grades" FOR DELETE USING (("grupo_id" = "public"."get_current_user_grupo_id"()));



CREATE POLICY "grades_insert_by_group" ON "public"."grades" FOR INSERT WITH CHECK (("grupo_id" = "public"."get_current_user_grupo_id"()));



CREATE POLICY "grades_select_by_group" ON "public"."grades" FOR SELECT USING (("grupo_id" = "public"."get_current_user_grupo_id"()));



CREATE POLICY "grades_update_by_group" ON "public"."grades" FOR UPDATE USING (("grupo_id" = "public"."get_current_user_grupo_id"())) WITH CHECK (("grupo_id" = "public"."get_current_user_grupo_id"()));



ALTER TABLE "public"."grupos" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."hospitais" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."hospital_geofencing" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."medicos" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."medicos_favoritos" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "medicos_favoritos_grupo_policy" ON "public"."medicos_favoritos" TO "authenticated" USING (((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE ((("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text")) OR (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'free'::"text"))))) OR ("grupo_id" = "public"."get_current_user_grupo_id"()))) WITH CHECK (((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE ((("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text")) OR (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'free'::"text"))))) OR ("grupo_id" = "public"."get_current_user_grupo_id"())));



ALTER TABLE "public"."medicos_precadastro" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."pagamentos" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "pagamentos_escalista_policy" ON "public"."pagamentos" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."vagas" "v"
  WHERE (("v"."id" = "pagamentos"."vagas_id") AND
        CASE
            WHEN ("public"."get_current_user_grupo_id"() IS NULL) THEN true
            ELSE ("v"."grupo_id" = "public"."get_current_user_grupo_id"())
        END))));



ALTER TABLE "public"."periodos" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."requisitos" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."setores" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."tipos_vaga" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_profile" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."vagas" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "vagas_beneficio_escalista_policy" ON "public"."vagas_beneficios" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."vagas" "v"
  WHERE (("v"."id" = "vagas_beneficios"."vaga_id") AND
        CASE
            WHEN ("public"."get_current_user_grupo_id"() IS NULL) THEN true
            ELSE ("v"."grupo_id" = "public"."get_current_user_grupo_id"())
        END)))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."vagas" "v"
  WHERE (("v"."id" = "vagas_beneficios"."vaga_id") AND
        CASE
            WHEN ("public"."get_current_user_grupo_id"() IS NULL) THEN true
            ELSE ("v"."grupo_id" = "public"."get_current_user_grupo_id"())
        END))));



ALTER TABLE "public"."vagas_beneficios" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "vagas_delete_policy" ON "public"."vagas" FOR DELETE TO "authenticated" USING (((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text")))) OR (("public"."get_current_user_grupo_id"() IS NOT NULL) AND ("grupo_id" = "public"."get_current_user_grupo_id"()))));



CREATE POLICY "vagas_insert_policy" ON "public"."vagas" FOR INSERT TO "authenticated" WITH CHECK (((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text")))) OR (("public"."get_current_user_grupo_id"() IS NOT NULL) AND ("grupo_id" = "public"."get_current_user_grupo_id"()))));



CREATE POLICY "vagas_recorrencia_escalista_policy" ON "public"."vagas_recorrencias" TO "authenticated" USING (((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text")))) OR ("created_by" = "auth"."uid"()) OR (EXISTS ( SELECT 1
   FROM ("public"."vagas" "v"
     JOIN "public"."escalistas" "e" ON (("e"."grupo_id" = "v"."grupo_id")))
  WHERE (("v"."recorrencia_id" = "vagas_recorrencias"."id") AND ("e"."auth_id" = "auth"."uid"())))))) WITH CHECK (((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text")))) OR ("created_by" = "auth"."uid"())));



ALTER TABLE "public"."vagas_recorrencias" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "vagas_requisito_escalista_policy" ON "public"."vagas_requisitos" TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."vagas" "v"
  WHERE (("v"."id" = "vagas_requisitos"."vagas_id") AND
        CASE
            WHEN ("public"."get_current_user_grupo_id"() IS NULL) THEN true
            ELSE ("v"."grupo_id" = "public"."get_current_user_grupo_id"())
        END)))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."vagas" "v"
  WHERE (("v"."id" = "vagas_requisitos"."vagas_id") AND
        CASE
            WHEN ("public"."get_current_user_grupo_id"() IS NULL) THEN true
            ELSE ("v"."grupo_id" = "public"."get_current_user_grupo_id"())
        END))));



ALTER TABLE "public"."vagas_requisitos" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."vagas_salvas" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "vagas_select_policy" ON "public"."vagas" FOR SELECT TO "authenticated" USING (((EXISTS ( SELECT 1
   FROM "public"."user_profile"
  WHERE ((("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'astronauta'::"text")) OR (("user_profile"."id" = "auth"."uid"()) AND ("user_profile"."role" = 'free'::"text"))))) OR ("grupo_id" = "public"."get_current_user_grupo_id"())));



CREATE POLICY "vagas_update_policy" ON "public"."vagas" FOR UPDATE TO "authenticated" USING (((( SELECT "user_profile"."role"
   FROM "public"."user_profile"
  WHERE ("user_profile"."id" = "auth"."uid"())) = 'astronauta'::"text") OR (( SELECT "user_profile"."role"
   FROM "public"."user_profile"
  WHERE ("user_profile"."id" = "auth"."uid"())) = 'free'::"text") OR ((( SELECT "user_profile"."role"
   FROM "public"."user_profile"
  WHERE ("user_profile"."id" = "auth"."uid"())) = 'escalista'::"text") AND ("grupo_id" = ( SELECT "escalistas"."grupo_id"
   FROM "public"."escalistas"
  WHERE ("escalistas"."auth_id" = "auth"."uid"()))))));



ALTER TABLE "public"."whatsapp_number" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";





GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_in"("cstring") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_in"("cstring") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_in"("cstring") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_in"("cstring") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_out"("public"."gtrgm") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_out"("public"."gtrgm") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_out"("public"."gtrgm") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_out"("public"."gtrgm") TO "service_role";










































































































































































































































GRANT ALL ON FUNCTION "public"."aprovacao_automatica_favoritos"() TO "anon";
GRANT ALL ON FUNCTION "public"."aprovacao_automatica_favoritos"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."aprovacao_automatica_favoritos"() TO "service_role";



GRANT ALL ON FUNCTION "public"."aprovar_todos_documentos"("p_carteira_id" "uuid", "p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."aprovar_todos_documentos"("p_carteira_id" "uuid", "p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."aprovar_todos_documentos"("p_carteira_id" "uuid", "p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."aretheytester"("user_id" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."aretheytester"("user_id" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."aretheytester"("user_id" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."atualizar_candidaturas_vaga_cancelada"() TO "anon";
GRANT ALL ON FUNCTION "public"."atualizar_candidaturas_vaga_cancelada"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."atualizar_candidaturas_vaga_cancelada"() TO "service_role";



GRANT ALL ON FUNCTION "public"."atualizar_status_vagas_expiradas"() TO "anon";
GRANT ALL ON FUNCTION "public"."atualizar_status_vagas_expiradas"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."atualizar_status_vagas_expiradas"() TO "service_role";



GRANT ALL ON FUNCTION "public"."atualizar_urls_documentos"("p_carteira_id" "uuid", "p_base_url" character varying, "p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."atualizar_urls_documentos"("p_carteira_id" "uuid", "p_base_url" character varying, "p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."atualizar_urls_documentos"("p_carteira_id" "uuid", "p_base_url" character varying, "p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."atualizar_vagas_status"() TO "anon";
GRANT ALL ON FUNCTION "public"."atualizar_vagas_status"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."atualizar_vagas_status"() TO "service_role";



GRANT ALL ON FUNCTION "public"."calcular_dias_pagamento"("data_plantao" "date", "data_pagamento" "date") TO "anon";
GRANT ALL ON FUNCTION "public"."calcular_dias_pagamento"("data_plantao" "date", "data_pagamento" "date") TO "authenticated";
GRANT ALL ON FUNCTION "public"."calcular_dias_pagamento"("data_plantao" "date", "data_pagamento" "date") TO "service_role";



GRANT ALL ON FUNCTION "public"."calcular_distancia"("lat1" numeric, "lon1" numeric, "lat2" numeric, "lon2" numeric) TO "anon";
GRANT ALL ON FUNCTION "public"."calcular_distancia"("lat1" numeric, "lon1" numeric, "lat2" numeric, "lon2" numeric) TO "authenticated";
GRANT ALL ON FUNCTION "public"."calcular_distancia"("lat1" numeric, "lon1" numeric, "lat2" numeric, "lon2" numeric) TO "service_role";



GRANT ALL ON FUNCTION "public"."cleanup_medicos_precadastro"() TO "anon";
GRANT ALL ON FUNCTION "public"."cleanup_medicos_precadastro"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."cleanup_medicos_precadastro"() TO "service_role";



GRANT ALL ON FUNCTION "public"."contar_linhas_duplo"("nome_tabela" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."contar_linhas_duplo"("nome_tabela" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."contar_linhas_duplo"("nome_tabela" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."corrigir_inconsistencias_vagas"() TO "anon";
GRANT ALL ON FUNCTION "public"."corrigir_inconsistencias_vagas"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."corrigir_inconsistencias_vagas"() TO "service_role";



GRANT ALL ON FUNCTION "public"."count_candidaturas_total"("vaga_id_param" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."count_candidaturas_total"("vaga_id_param" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."count_candidaturas_total"("vaga_id_param" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."criar_carteira_digital"("p_medico_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."criar_carteira_digital"("p_medico_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."criar_carteira_digital"("p_medico_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."criar_escalista"() TO "anon";
GRANT ALL ON FUNCTION "public"."criar_escalista"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."criar_escalista"() TO "service_role";



GRANT ALL ON FUNCTION "public"."criar_recorrencia_com_vagas"("p_data_inicio" "date", "p_data_fim" "date", "p_dias_semana" integer[], "p_vaga_base" "jsonb", "p_created_by" "uuid", "p_medico_id" "uuid", "p_observacoes" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."criar_recorrencia_com_vagas"("p_data_inicio" "date", "p_data_fim" "date", "p_dias_semana" integer[], "p_vaga_base" "jsonb", "p_created_by" "uuid", "p_medico_id" "uuid", "p_observacoes" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."criar_recorrencia_com_vagas"("p_data_inicio" "date", "p_data_fim" "date", "p_dias_semana" integer[], "p_vaga_base" "jsonb", "p_created_by" "uuid", "p_medico_id" "uuid", "p_observacoes" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."criar_recorrencia_com_vagas"("p_data_inicio" "date", "p_data_fim" "date", "p_dias_semana" integer[], "p_vaga_base" "jsonb", "p_created_by" "uuid", "p_medico_id" "uuid", "p_observacoes" "text", "p_beneficios" "text"[], "p_requisitos" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."criar_recorrencia_com_vagas"("p_data_inicio" "date", "p_data_fim" "date", "p_dias_semana" integer[], "p_vaga_base" "jsonb", "p_created_by" "uuid", "p_medico_id" "uuid", "p_observacoes" "text", "p_beneficios" "text"[], "p_requisitos" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."criar_recorrencia_com_vagas"("p_data_inicio" "date", "p_data_fim" "date", "p_dias_semana" integer[], "p_vaga_base" "jsonb", "p_created_by" "uuid", "p_medico_id" "uuid", "p_observacoes" "text", "p_beneficios" "text"[], "p_requisitos" "text"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."current_user_is_favorito"("p_grupo_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."current_user_is_favorito"("p_grupo_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."current_user_is_favorito"("p_grupo_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."deletar_vagas_recorrencia"("p_recorrencia_id" "uuid", "p_updateby" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."deletar_vagas_recorrencia"("p_recorrencia_id" "uuid", "p_updateby" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."deletar_vagas_recorrencia"("p_recorrencia_id" "uuid", "p_updateby" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."deletethisuser"("user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."deletethisuser"("user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."deletethisuser"("user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."editar_vagas_recorrencia"("p_recorrencia_id" "uuid", "p_update" "jsonb", "p_updateby" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."editar_vagas_recorrencia"("p_recorrencia_id" "uuid", "p_update" "jsonb", "p_updateby" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."editar_vagas_recorrencia"("p_recorrencia_id" "uuid", "p_update" "jsonb", "p_updateby" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."editar_vagas_recorrencia"("p_recorrencia_id" "uuid", "p_update" "jsonb", "p_updateby" "uuid", "p_beneficios" "text"[], "p_requisitos" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."editar_vagas_recorrencia"("p_recorrencia_id" "uuid", "p_update" "jsonb", "p_updateby" "uuid", "p_beneficios" "text"[], "p_requisitos" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."editar_vagas_recorrencia"("p_recorrencia_id" "uuid", "p_update" "jsonb", "p_updateby" "uuid", "p_beneficios" "text"[], "p_requisitos" "text"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."editar_vagas_recorrencia"("p_recorrencia_id" "uuid", "p_update" "jsonb", "p_updateby" "uuid", "p_beneficios" "text"[], "p_requisitos" "text"[], "p_dias_pagamento" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."editar_vagas_recorrencia"("p_recorrencia_id" "uuid", "p_update" "jsonb", "p_updateby" "uuid", "p_beneficios" "text"[], "p_requisitos" "text"[], "p_dias_pagamento" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."editar_vagas_recorrencia"("p_recorrencia_id" "uuid", "p_update" "jsonb", "p_updateby" "uuid", "p_beneficios" "text"[], "p_requisitos" "text"[], "p_dias_pagamento" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."excluir_vagas_lote"("vagas_ids" "uuid"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."excluir_vagas_lote"("vagas_ids" "uuid"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."excluir_vagas_lote"("vagas_ids" "uuid"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."gerar_vagas_recorrentes"("p_recorrencia_id" "uuid", "p_vaga_base_id" "uuid", "p_medico_id" "uuid", "p_created_by" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."gerar_vagas_recorrentes"("p_recorrencia_id" "uuid", "p_vaga_base_id" "uuid", "p_medico_id" "uuid", "p_created_by" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gerar_vagas_recorrentes"("p_recorrencia_id" "uuid", "p_vaga_base_id" "uuid", "p_medico_id" "uuid", "p_created_by" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."gerar_vagas_recorrentes"("p_recorrencia_id" "uuid", "p_vaga_base_id" "uuid", "p_medico_id" "uuid", "p_created_by" "uuid", "p_beneficios" "text"[], "p_requisitos" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."gerar_vagas_recorrentes"("p_recorrencia_id" "uuid", "p_vaga_base_id" "uuid", "p_medico_id" "uuid", "p_created_by" "uuid", "p_beneficios" "text"[], "p_requisitos" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."gerar_vagas_recorrentes"("p_recorrencia_id" "uuid", "p_vaga_base_id" "uuid", "p_medico_id" "uuid", "p_created_by" "uuid", "p_beneficios" "text"[], "p_requisitos" "text"[]) TO "service_role";



GRANT ALL ON FUNCTION "public"."get_applications_paginated"("page_number" integer, "page_size" integer, "hospital_ids" "uuid"[], "specialty_ids" "uuid"[], "sector_ids" "uuid"[], "start_date" "date", "end_date" "date", "min_value" numeric, "max_value" numeric, "period_ids" "uuid"[], "type_ids" "uuid"[], "group_ids" "uuid"[], "search_text" "text", "doctor_ids" "uuid"[], "application_status_filter" "text"[], "job_status_filter" "text"[], "grade_ids" "uuid"[], "order_by" "text", "order_direction" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_applications_paginated"("page_number" integer, "page_size" integer, "hospital_ids" "uuid"[], "specialty_ids" "uuid"[], "sector_ids" "uuid"[], "start_date" "date", "end_date" "date", "min_value" numeric, "max_value" numeric, "period_ids" "uuid"[], "type_ids" "uuid"[], "group_ids" "uuid"[], "search_text" "text", "doctor_ids" "uuid"[], "application_status_filter" "text"[], "job_status_filter" "text"[], "grade_ids" "uuid"[], "order_by" "text", "order_direction" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_applications_paginated"("page_number" integer, "page_size" integer, "hospital_ids" "uuid"[], "specialty_ids" "uuid"[], "sector_ids" "uuid"[], "start_date" "date", "end_date" "date", "min_value" numeric, "max_value" numeric, "period_ids" "uuid"[], "type_ids" "uuid"[], "group_ids" "uuid"[], "search_text" "text", "doctor_ids" "uuid"[], "application_status_filter" "text"[], "job_status_filter" "text"[], "grade_ids" "uuid"[], "order_by" "text", "order_direction" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_cpf"("cpf_input" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_cpf"("cpf_input" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_cpf"("cpf_input" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_crm"("crm_input" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_crm"("crm_input" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_crm"("crm_input" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_current_user_grupo_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_current_user_grupo_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_current_user_grupo_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_documento_historico"("p_carteira_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_documento_historico"("p_carteira_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_documento_historico"("p_carteira_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_documento_historico"("p_carteira_id" "uuid", "p_tipo" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_documento_historico"("p_carteira_id" "uuid", "p_tipo" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_documento_historico"("p_carteira_id" "uuid", "p_tipo" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_documentos_pendentes"("p_carteira_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_documentos_pendentes"("p_carteira_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_documentos_pendentes"("p_carteira_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_email"("e_mail" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_email"("e_mail" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_email"("e_mail" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_medicos_com_documentos"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_medicos_com_documentos"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_medicos_com_documentos"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_medicos_documentacao_pendente"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_medicos_documentacao_pendente"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_medicos_documentacao_pendente"() TO "service_role";



GRANT ALL ON FUNCTION "public"."get_percentual_conclusao"("p_carteira_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_percentual_conclusao"("p_carteira_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_percentual_conclusao"("p_carteira_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_phonenumber"("p_phone" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_phonenumber"("p_phone" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_phonenumber"("p_phone" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_urls_pendentes"("p_carteira_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_urls_pendentes"("p_carteira_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_urls_pendentes"("p_carteira_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_vagas_paginated"("page_number" integer, "page_size" integer, "hospital_ids" "uuid"[], "specialty_ids" "uuid"[], "sector_ids" "uuid"[], "start_date" "date", "end_date" "date", "min_value" numeric, "max_value" numeric, "period_ids" "uuid"[], "type_ids" "uuid"[], "group_ids" "uuid"[], "search_text" "text", "doctor_ids" "uuid"[], "application_status_filter" "text"[], "job_status_filter" "text"[], "grade_ids" "uuid"[], "order_by" "text", "order_direction" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."get_vagas_paginated"("page_number" integer, "page_size" integer, "hospital_ids" "uuid"[], "specialty_ids" "uuid"[], "sector_ids" "uuid"[], "start_date" "date", "end_date" "date", "min_value" numeric, "max_value" numeric, "period_ids" "uuid"[], "type_ids" "uuid"[], "group_ids" "uuid"[], "search_text" "text", "doctor_ids" "uuid"[], "application_status_filter" "text"[], "job_status_filter" "text"[], "grade_ids" "uuid"[], "order_by" "text", "order_direction" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_vagas_paginated"("page_number" integer, "page_size" integer, "hospital_ids" "uuid"[], "specialty_ids" "uuid"[], "sector_ids" "uuid"[], "start_date" "date", "end_date" "date", "min_value" numeric, "max_value" numeric, "period_ids" "uuid"[], "type_ids" "uuid"[], "group_ids" "uuid"[], "search_text" "text", "doctor_ids" "uuid"[], "application_status_filter" "text"[], "job_status_filter" "text"[], "grade_ids" "uuid"[], "order_by" "text", "order_direction" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."getidfromemail"("e_mail" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."getidfromemail"("e_mail" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."getidfromemail"("e_mail" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."getidfromphone"("p_phone" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."getidfromphone"("p_phone" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."getidfromphone"("p_phone" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."getuserprofile"("user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."getuserprofile"("user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."getuserprofile"("user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."gin_extract_query_trgm"("text", "internal", smallint, "internal", "internal", "internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gin_extract_query_trgm"("text", "internal", smallint, "internal", "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gin_extract_query_trgm"("text", "internal", smallint, "internal", "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gin_extract_query_trgm"("text", "internal", smallint, "internal", "internal", "internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gin_extract_value_trgm"("text", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gin_extract_value_trgm"("text", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gin_extract_value_trgm"("text", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gin_extract_value_trgm"("text", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gin_trgm_consistent"("internal", smallint, "text", integer, "internal", "internal", "internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gin_trgm_consistent"("internal", smallint, "text", integer, "internal", "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gin_trgm_consistent"("internal", smallint, "text", integer, "internal", "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gin_trgm_consistent"("internal", smallint, "text", integer, "internal", "internal", "internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gin_trgm_triconsistent"("internal", smallint, "text", integer, "internal", "internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gin_trgm_triconsistent"("internal", smallint, "text", integer, "internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gin_trgm_triconsistent"("internal", smallint, "text", integer, "internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gin_trgm_triconsistent"("internal", smallint, "text", integer, "internal", "internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_compress"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_compress"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_compress"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_compress"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_consistent"("internal", "text", smallint, "oid", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_consistent"("internal", "text", smallint, "oid", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_consistent"("internal", "text", smallint, "oid", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_consistent"("internal", "text", smallint, "oid", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_decompress"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_decompress"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_decompress"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_decompress"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_distance"("internal", "text", smallint, "oid", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_distance"("internal", "text", smallint, "oid", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_distance"("internal", "text", smallint, "oid", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_distance"("internal", "text", smallint, "oid", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_options"("internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_options"("internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_options"("internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_options"("internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_penalty"("internal", "internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_penalty"("internal", "internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_penalty"("internal", "internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_penalty"("internal", "internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_picksplit"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_picksplit"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_picksplit"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_picksplit"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_same"("public"."gtrgm", "public"."gtrgm", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_same"("public"."gtrgm", "public"."gtrgm", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_same"("public"."gtrgm", "public"."gtrgm", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_same"("public"."gtrgm", "public"."gtrgm", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."gtrgm_union"("internal", "internal") TO "postgres";
GRANT ALL ON FUNCTION "public"."gtrgm_union"("internal", "internal") TO "anon";
GRANT ALL ON FUNCTION "public"."gtrgm_union"("internal", "internal") TO "authenticated";
GRANT ALL ON FUNCTION "public"."gtrgm_union"("internal", "internal") TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_grades_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_grades_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_grades_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."inserir_carteira_digital"() TO "anon";
GRANT ALL ON FUNCTION "public"."inserir_carteira_digital"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."inserir_carteira_digital"() TO "service_role";



GRANT ALL ON FUNCTION "public"."inserir_validacao_documentos"() TO "anon";
GRANT ALL ON FUNCTION "public"."inserir_validacao_documentos"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."inserir_validacao_documentos"() TO "service_role";



GRANT ALL ON FUNCTION "public"."pode_ver_candidatura_colega"("candidatura_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."pode_ver_candidatura_colega"("candidatura_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pode_ver_candidatura_colega"("candidatura_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."pode_ver_candidatura_colega_debug"("candidatura_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."pode_ver_candidatura_colega_debug"("candidatura_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."pode_ver_candidatura_colega_debug"("candidatura_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."refresh_dashboard_metrics"() TO "anon";
GRANT ALL ON FUNCTION "public"."refresh_dashboard_metrics"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."refresh_dashboard_metrics"() TO "service_role";



GRANT ALL ON FUNCTION "public"."refresh_vw_vagas_disponiveis"() TO "anon";
GRANT ALL ON FUNCTION "public"."refresh_vw_vagas_disponiveis"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."refresh_vw_vagas_disponiveis"() TO "service_role";



GRANT ALL ON FUNCTION "public"."reprovar_documento"("p_carteira_id" "uuid", "p_tipo" "text", "p_motivo" "text", "p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."reprovar_documento"("p_carteira_id" "uuid", "p_tipo" "text", "p_motivo" "text", "p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."reprovar_documento"("p_carteira_id" "uuid", "p_tipo" "text", "p_motivo" "text", "p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."set_limit"(real) TO "postgres";
GRANT ALL ON FUNCTION "public"."set_limit"(real) TO "anon";
GRANT ALL ON FUNCTION "public"."set_limit"(real) TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_limit"(real) TO "service_role";



GRANT ALL ON FUNCTION "public"."show_limit"() TO "postgres";
GRANT ALL ON FUNCTION "public"."show_limit"() TO "anon";
GRANT ALL ON FUNCTION "public"."show_limit"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."show_limit"() TO "service_role";



GRANT ALL ON FUNCTION "public"."show_trgm"("text") TO "postgres";
GRANT ALL ON FUNCTION "public"."show_trgm"("text") TO "anon";
GRANT ALL ON FUNCTION "public"."show_trgm"("text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."show_trgm"("text") TO "service_role";



GRANT ALL ON FUNCTION "public"."similarity"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."similarity"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."similarity"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."similarity"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."similarity_dist"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."similarity_dist"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."similarity_dist"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."similarity_dist"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."similarity_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."similarity_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."similarity_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."similarity_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."strict_word_similarity"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."strict_word_similarity"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."strict_word_similarity_commutator_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_commutator_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_commutator_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_commutator_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_commutator_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_commutator_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_commutator_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_commutator_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_dist_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."strict_word_similarity_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."strict_word_similarity_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_pagamentos_medico_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_pagamentos_medico_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_pagamentos_medico_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_user_profile"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_user_profile"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_user_profile"() TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_vagas_beneficio_vaga_id"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_vagas_beneficio_vaga_id"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_vagas_beneficio_vaga_id"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_documento_status"("p_carteira_id" "uuid", "p_tipo" "text", "p_status" boolean, "p_user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."update_documento_status"("p_carteira_id" "uuid", "p_tipo" "text", "p_status" boolean, "p_user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_documento_status"("p_carteira_id" "uuid", "p_tipo" "text", "p_status" boolean, "p_user_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_documento_url"("p_carteira_id" "uuid", "p_tipo" "text", "p_url" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_documento_url"("p_carteira_id" "uuid", "p_tipo" "text", "p_url" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_documento_url"("p_carteira_id" "uuid", "p_tipo" "text", "p_url" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_especialidade_nome"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_especialidade_nome"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_especialidade_nome"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_phone_forotp"("user_id" "uuid", "areacodeindex" integer, "telefone" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_phone_forotp"("user_id" "uuid", "areacodeindex" integer, "telefone" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_phone_forotp"("user_id" "uuid", "areacodeindex" integer, "telefone" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_total_candidaturas"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_total_candidaturas"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_total_candidaturas"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_total_plantoes_medico"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_total_plantoes_medico"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_total_plantoes_medico"() TO "service_role";



GRANT ALL ON FUNCTION "public"."updatethisuser"("user_id" "uuid", "e_mail" "text", "p_phone" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."updatethisuser"("user_id" "uuid", "e_mail" "text", "p_phone" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."updatethisuser"("user_id" "uuid", "e_mail" "text", "p_phone" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."validar_localizacao_medico"("p_hospital_id" "uuid", "p_latitude" numeric, "p_longitude" numeric) TO "anon";
GRANT ALL ON FUNCTION "public"."validar_localizacao_medico"("p_hospital_id" "uuid", "p_latitude" numeric, "p_longitude" numeric) TO "authenticated";
GRANT ALL ON FUNCTION "public"."validar_localizacao_medico"("p_hospital_id" "uuid", "p_latitude" numeric, "p_longitude" numeric) TO "service_role";



GRANT ALL ON FUNCTION "public"."validate_checkin_timing"() TO "anon";
GRANT ALL ON FUNCTION "public"."validate_checkin_timing"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."validate_checkin_timing"() TO "service_role";



GRANT ALL ON FUNCTION "public"."validate_checkout_timing"() TO "anon";
GRANT ALL ON FUNCTION "public"."validate_checkout_timing"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."validate_checkout_timing"() TO "service_role";



GRANT ALL ON FUNCTION "public"."verificar_conflito_antes_candidatura"() TO "anon";
GRANT ALL ON FUNCTION "public"."verificar_conflito_antes_candidatura"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."verificar_conflito_antes_candidatura"() TO "service_role";



GRANT ALL ON FUNCTION "public"."verificar_conflito_vaga_designada"("p_medico_id" "uuid", "p_data" "date", "p_hora_inicio" time without time zone, "p_hora_fim" time without time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."verificar_conflito_vaga_designada"("p_medico_id" "uuid", "p_data" "date", "p_hora_inicio" time without time zone, "p_hora_fim" time without time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."verificar_conflito_vaga_designada"("p_medico_id" "uuid", "p_data" "date", "p_hora_inicio" time without time zone, "p_hora_fim" time without time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."verificar_consistencia_status_vagas"() TO "anon";
GRANT ALL ON FUNCTION "public"."verificar_consistencia_status_vagas"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."verificar_consistencia_status_vagas"() TO "service_role";



GRANT ALL ON FUNCTION "public"."word_similarity"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."word_similarity"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."word_similarity_commutator_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."word_similarity_commutator_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity_commutator_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity_commutator_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."word_similarity_dist_commutator_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_commutator_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_commutator_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_commutator_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."word_similarity_dist_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity_dist_op"("text", "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."word_similarity_op"("text", "text") TO "postgres";
GRANT ALL ON FUNCTION "public"."word_similarity_op"("text", "text") TO "anon";
GRANT ALL ON FUNCTION "public"."word_similarity_op"("text", "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."word_similarity_op"("text", "text") TO "service_role";


















GRANT ALL ON TABLE "public"."banner_mkt" TO "anon";
GRANT ALL ON TABLE "public"."banner_mkt" TO "authenticated";
GRANT ALL ON TABLE "public"."banner_mkt" TO "service_role";



GRANT ALL ON SEQUENCE "public"."bannerMKT_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."bannerMKT_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."bannerMKT_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."beneficios" TO "anon";
GRANT ALL ON TABLE "public"."beneficios" TO "authenticated";
GRANT ALL ON TABLE "public"."beneficios" TO "service_role";



GRANT ALL ON TABLE "public"."candidaturas" TO "anon";
GRANT ALL ON TABLE "public"."candidaturas" TO "authenticated";
GRANT ALL ON TABLE "public"."candidaturas" TO "service_role";



GRANT ALL ON TABLE "public"."carteira_digital" TO "anon";
GRANT ALL ON TABLE "public"."carteira_digital" TO "authenticated";
GRANT ALL ON TABLE "public"."carteira_digital" TO "service_role";



GRANT ALL ON TABLE "public"."checkin_checkout" TO "anon";
GRANT ALL ON TABLE "public"."checkin_checkout" TO "authenticated";
GRANT ALL ON TABLE "public"."checkin_checkout" TO "service_role";



GRANT ALL ON SEQUENCE "public"."checkin_checkout_index_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."checkin_checkout_index_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."checkin_checkout_index_seq" TO "service_role";



GRANT ALL ON TABLE "public"."checkin_checkout_nofitications" TO "anon";
GRANT ALL ON TABLE "public"."checkin_checkout_nofitications" TO "authenticated";
GRANT ALL ON TABLE "public"."checkin_checkout_nofitications" TO "service_role";



GRANT ALL ON TABLE "public"."clean_hospital" TO "anon";
GRANT ALL ON TABLE "public"."clean_hospital" TO "authenticated";
GRANT ALL ON TABLE "public"."clean_hospital" TO "service_role";



GRANT ALL ON SEQUENCE "public"."clean_hospital_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."clean_hospital_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."clean_hospital_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."codigos_area" TO "anon";
GRANT ALL ON TABLE "public"."codigos_area" TO "authenticated";
GRANT ALL ON TABLE "public"."codigos_area" TO "service_role";



GRANT ALL ON TABLE "public"."email_verification_tokens" TO "anon";
GRANT ALL ON TABLE "public"."email_verification_tokens" TO "authenticated";
GRANT ALL ON TABLE "public"."email_verification_tokens" TO "service_role";



GRANT ALL ON SEQUENCE "public"."email_verification_tokens_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."email_verification_tokens_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."email_verification_tokens_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."equipes" TO "anon";
GRANT ALL ON TABLE "public"."equipes" TO "authenticated";
GRANT ALL ON TABLE "public"."equipes" TO "service_role";



GRANT ALL ON TABLE "public"."equipes_medicos" TO "anon";
GRANT ALL ON TABLE "public"."equipes_medicos" TO "authenticated";
GRANT ALL ON TABLE "public"."equipes_medicos" TO "service_role";



GRANT ALL ON TABLE "public"."escalistas" TO "anon";
GRANT ALL ON TABLE "public"."escalistas" TO "authenticated";
GRANT ALL ON TABLE "public"."escalistas" TO "service_role";



GRANT ALL ON TABLE "public"."especialidades" TO "anon";
GRANT ALL ON TABLE "public"."especialidades" TO "authenticated";
GRANT ALL ON TABLE "public"."especialidades" TO "service_role";



GRANT ALL ON TABLE "public"."estados_brasil" TO "anon";
GRANT ALL ON TABLE "public"."estados_brasil" TO "authenticated";
GRANT ALL ON TABLE "public"."estados_brasil" TO "service_role";



GRANT ALL ON TABLE "public"."formas_recebimento" TO "anon";
GRANT ALL ON TABLE "public"."formas_recebimento" TO "authenticated";
GRANT ALL ON TABLE "public"."formas_recebimento" TO "service_role";



GRANT ALL ON TABLE "public"."grades" TO "anon";
GRANT ALL ON TABLE "public"."grades" TO "authenticated";
GRANT ALL ON TABLE "public"."grades" TO "service_role";



GRANT ALL ON TABLE "public"."grupos" TO "anon";
GRANT ALL ON TABLE "public"."grupos" TO "authenticated";
GRANT ALL ON TABLE "public"."grupos" TO "service_role";



GRANT ALL ON TABLE "public"."hospitais" TO "anon";
GRANT ALL ON TABLE "public"."hospitais" TO "authenticated";
GRANT ALL ON TABLE "public"."hospitais" TO "service_role";



GRANT ALL ON TABLE "public"."hospital_geofencing" TO "anon";
GRANT ALL ON TABLE "public"."hospital_geofencing" TO "authenticated";
GRANT ALL ON TABLE "public"."hospital_geofencing" TO "service_role";



GRANT ALL ON TABLE "public"."medicos" TO "anon";
GRANT ALL ON TABLE "public"."medicos" TO "authenticated";
GRANT ALL ON TABLE "public"."medicos" TO "service_role";



GRANT ALL ON TABLE "public"."medicos_favoritos" TO "anon";
GRANT ALL ON TABLE "public"."medicos_favoritos" TO "authenticated";
GRANT ALL ON TABLE "public"."medicos_favoritos" TO "service_role";



GRANT ALL ON TABLE "public"."medicos_precadastro" TO "anon";
GRANT ALL ON TABLE "public"."medicos_precadastro" TO "authenticated";
GRANT ALL ON TABLE "public"."medicos_precadastro" TO "service_role";



GRANT ALL ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";



GRANT ALL ON TABLE "public"."pagamentos" TO "anon";
GRANT ALL ON TABLE "public"."pagamentos" TO "authenticated";
GRANT ALL ON TABLE "public"."pagamentos" TO "service_role";



GRANT ALL ON TABLE "public"."periodos" TO "anon";
GRANT ALL ON TABLE "public"."periodos" TO "authenticated";
GRANT ALL ON TABLE "public"."periodos" TO "service_role";



GRANT ALL ON TABLE "public"."requisitos" TO "anon";
GRANT ALL ON TABLE "public"."requisitos" TO "authenticated";
GRANT ALL ON TABLE "public"."requisitos" TO "service_role";



GRANT ALL ON TABLE "public"."setores" TO "anon";
GRANT ALL ON TABLE "public"."setores" TO "authenticated";
GRANT ALL ON TABLE "public"."setores" TO "service_role";



GRANT ALL ON TABLE "public"."tipos_vaga" TO "anon";
GRANT ALL ON TABLE "public"."tipos_vaga" TO "authenticated";
GRANT ALL ON TABLE "public"."tipos_vaga" TO "service_role";



GRANT ALL ON TABLE "public"."user_profile" TO "anon";
GRANT ALL ON TABLE "public"."user_profile" TO "authenticated";
GRANT ALL ON TABLE "public"."user_profile" TO "service_role";



GRANT ALL ON TABLE "public"."vagas" TO "anon";
GRANT ALL ON TABLE "public"."vagas" TO "authenticated";
GRANT ALL ON TABLE "public"."vagas" TO "service_role";



GRANT ALL ON SEQUENCE "public"."vagas_Index_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."vagas_Index_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."vagas_Index_seq" TO "service_role";



GRANT ALL ON TABLE "public"."vagas_beneficios" TO "anon";
GRANT ALL ON TABLE "public"."vagas_beneficios" TO "authenticated";
GRANT ALL ON TABLE "public"."vagas_beneficios" TO "service_role";



GRANT ALL ON SEQUENCE "public"."vagas_beneficio_Index_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."vagas_beneficio_Index_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."vagas_beneficio_Index_seq" TO "service_role";



GRANT ALL ON TABLE "public"."vagas_completo" TO "anon";
GRANT ALL ON TABLE "public"."vagas_completo" TO "authenticated";
GRANT ALL ON TABLE "public"."vagas_completo" TO "service_role";



GRANT ALL ON TABLE "public"."vagas_recorrencias" TO "anon";
GRANT ALL ON TABLE "public"."vagas_recorrencias" TO "authenticated";
GRANT ALL ON TABLE "public"."vagas_recorrencias" TO "service_role";



GRANT ALL ON TABLE "public"."vagas_requisitos" TO "anon";
GRANT ALL ON TABLE "public"."vagas_requisitos" TO "authenticated";
GRANT ALL ON TABLE "public"."vagas_requisitos" TO "service_role";



GRANT ALL ON TABLE "public"."vagas_salvas" TO "anon";
GRANT ALL ON TABLE "public"."vagas_salvas" TO "authenticated";
GRANT ALL ON TABLE "public"."vagas_salvas" TO "service_role";



GRANT ALL ON SEQUENCE "public"."vagas_salvas_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."vagas_salvas_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."vagas_salvas_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."vw_folha_pagamento" TO "anon";
GRANT ALL ON TABLE "public"."vw_folha_pagamento" TO "authenticated";
GRANT ALL ON TABLE "public"."vw_folha_pagamento" TO "service_role";



GRANT ALL ON TABLE "public"."vw_vagas_candidaturas" TO "anon";
GRANT ALL ON TABLE "public"."vw_vagas_candidaturas" TO "authenticated";
GRANT ALL ON TABLE "public"."vw_vagas_candidaturas" TO "service_role";



GRANT ALL ON TABLE "public"."whatsapp_number" TO "anon";
GRANT ALL ON TABLE "public"."whatsapp_number" TO "authenticated";
GRANT ALL ON TABLE "public"."whatsapp_number" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";






























RESET ALL;
