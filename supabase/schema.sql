--
-- PostgreSQL database dump
--

\restrict Pdei6QR1zvvmrJSp0ybcGx6g6OMqwHnY8vHCNtjCgdZjWyj8m9ctwmlrHeBSPH5

-- Dumped from database version 15.8
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: _realtime; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA _realtime;


ALTER SCHEMA _realtime OWNER TO postgres;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO supabase_admin;

--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA extensions;


ALTER SCHEMA extensions OWNER TO postgres;

--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql;


ALTER SCHEMA graphql OWNER TO supabase_admin;

--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql_public;


ALTER SCHEMA graphql_public OWNER TO supabase_admin;

--
-- Name: pg_net; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_net; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_net IS 'Async HTTP';


--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: pgbouncer
--

CREATE SCHEMA pgbouncer;


ALTER SCHEMA pgbouncer OWNER TO pgbouncer;

--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA realtime;


ALTER SCHEMA realtime OWNER TO supabase_admin;

--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA storage;


ALTER SCHEMA storage OWNER TO supabase_admin;

--
-- Name: supabase_functions; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA supabase_functions;


ALTER SCHEMA supabase_functions OWNER TO supabase_admin;

--
-- Name: supabase_migrations; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA supabase_migrations;


ALTER SCHEMA supabase_migrations OWNER TO postgres;

--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA vault;


ALTER SCHEMA vault OWNER TO supabase_admin;

--
-- Name: http; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS http WITH SCHEMA extensions;


--
-- Name: EXTENSION http; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION http IS 'HTTP client for PostgreSQL, allows web page retrieval inside the database.';


--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_graphql WITH SCHEMA graphql;


--
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: pgjwt; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgjwt WITH SCHEMA extensions;


--
-- Name: EXTENSION pgjwt; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgjwt IS 'JSON Web Token API for Postgresql';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


ALTER TYPE auth.aal_level OWNER TO supabase_auth_admin;

--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


ALTER TYPE auth.code_challenge_method OWNER TO supabase_auth_admin;

--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


ALTER TYPE auth.factor_status OWNER TO supabase_auth_admin;

--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


ALTER TYPE auth.factor_type OWNER TO supabase_auth_admin;

--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


ALTER TYPE auth.oauth_registration_type OWNER TO supabase_auth_admin;

--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


ALTER TYPE auth.one_time_token_type OWNER TO supabase_auth_admin;

--
-- Name: app_permission; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.app_permission AS ENUM (
    'channels.delete',
    'messages.delete'
);


ALTER TYPE public.app_permission OWNER TO postgres;

--
-- Name: app_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.app_role AS ENUM (
    'admin',
    'moderator'
);


ALTER TYPE public.app_role OWNER TO postgres;

--
-- Name: action; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


ALTER TYPE realtime.action OWNER TO supabase_admin;

--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


ALTER TYPE realtime.equality_op OWNER TO supabase_admin;

--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


ALTER TYPE realtime.user_defined_filter OWNER TO supabase_admin;

--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


ALTER TYPE realtime.wal_column OWNER TO supabase_admin;

--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


ALTER TYPE realtime.wal_rls OWNER TO supabase_admin;

--
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS'
);


ALTER TYPE storage.buckettype OWNER TO supabase_storage_admin;

--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


ALTER FUNCTION auth.email() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


ALTER FUNCTION auth.jwt() OWNER TO supabase_auth_admin;

--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


ALTER FUNCTION auth.role() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


ALTER FUNCTION auth.uid() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_cron_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


ALTER FUNCTION extensions.grant_pg_graphql_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
    ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

    ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
    ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

    REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
    REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

    GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_net_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_ddl_watch() OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_drop_watch() OWNER TO supabase_admin;

--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


ALTER FUNCTION extensions.set_graphql_placeholder() OWNER TO supabase_admin;

--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: supabase_admin
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $_$
begin
    raise debug 'PgBouncer auth request: %', p_usename;

    return query
    select 
        rolname::text, 
        case when rolvaliduntil < now() 
            then null 
            else rolpassword::text 
        end 
    from pg_authid 
    where rolname=$1 and rolcanlogin;
end;
$_$;


ALTER FUNCTION pgbouncer.get_auth(p_usename text) OWNER TO supabase_admin;

--
-- Name: aprovacao_automatica_favoritos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.aprovacao_automatica_favoritos() RETURNS trigger
    LANGUAGE plpgsql
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


ALTER FUNCTION public.aprovacao_automatica_favoritos() OWNER TO postgres;

--
-- Name: aprovar_todos_documentos(uuid, uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.aprovar_todos_documentos(p_carteira_id uuid, p_user_id uuid) RETURNS TABLE(success boolean, message text, documentos_atualizados integer)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.aprovar_todos_documentos(p_carteira_id uuid, p_user_id uuid) OWNER TO postgres;

--
-- Name: aretheytester(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.aretheytester(user_id text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$BEGIN
    RETURN user_id = ANY(ARRAY[
        '276f5e38-82bc-445b-940c-20ee81454b7c'
    ]);
END;$$;


ALTER FUNCTION public.aretheytester(user_id text) OWNER TO postgres;

--
-- Name: atualizar_candidaturas_vaga_cancelada(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.atualizar_candidaturas_vaga_cancelada() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'public'
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


ALTER FUNCTION public.atualizar_candidaturas_vaga_cancelada() OWNER TO postgres;

--
-- Name: atualizar_status_vagas_expiradas(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.atualizar_status_vagas_expiradas() RETURNS TABLE(vagas_atualizadas_canceladas integer, vagas_atualizadas_fechadas integer, candidaturas_reprovadas integer)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


ALTER FUNCTION public.atualizar_status_vagas_expiradas() OWNER TO postgres;

--
-- Name: atualizar_urls_documentos(uuid, character varying, uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.atualizar_urls_documentos(p_carteira_id uuid, p_base_url character varying, p_user_id uuid) RETURNS TABLE(documento character varying, url_antiga character varying, url_nova character varying, sucesso boolean)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.atualizar_urls_documentos(p_carteira_id uuid, p_base_url character varying, p_user_id uuid) OWNER TO postgres;

--
-- Name: atualizar_vagas_status(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.atualizar_vagas_status() RETURNS trigger
    LANGUAGE plpgsql
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


ALTER FUNCTION public.atualizar_vagas_status() OWNER TO postgres;

--
-- Name: calcular_dias_pagamento(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calcular_dias_pagamento(data_plantao date, data_pagamento date) RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF data_pagamento IS NULL OR data_plantao IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN (data_pagamento - data_plantao);
END;
$$;


ALTER FUNCTION public.calcular_dias_pagamento(data_plantao date, data_pagamento date) OWNER TO postgres;

--
-- Name: calcular_distancia(numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calcular_distancia(lat1 numeric, lon1 numeric, lat2 numeric, lon2 numeric) RETURNS numeric
    LANGUAGE plpgsql
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


ALTER FUNCTION public.calcular_distancia(lat1 numeric, lon1 numeric, lat2 numeric, lon2 numeric) OWNER TO postgres;

--
-- Name: cleanup_medicos_precadastro(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.cleanup_medicos_precadastro() RETURNS trigger
    LANGUAGE plpgsql
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


ALTER FUNCTION public.cleanup_medicos_precadastro() OWNER TO postgres;

--
-- Name: contar_linhas_duplo(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.contar_linhas_duplo(nome_tabela text) RETURNS TABLE(total_linhas bigint, total_menos_um bigint)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.contar_linhas_duplo(nome_tabela text) OWNER TO postgres;

--
-- Name: corrigir_inconsistencias_vagas(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.corrigir_inconsistencias_vagas() RETURNS TABLE(acao text, quantidade integer)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


ALTER FUNCTION public.corrigir_inconsistencias_vagas() OWNER TO postgres;

--
-- Name: count_candidaturas_total(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.count_candidaturas_total(vaga_id_param uuid) RETURNS integer
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT COUNT(*)::INTEGER 
  FROM candidaturas 
  WHERE vagas_id = vaga_id_param;
$$;


ALTER FUNCTION public.count_candidaturas_total(vaga_id_param uuid) OWNER TO postgres;

--
-- Name: criar_carteira_digital(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.criar_carteira_digital(p_medico_id uuid) RETURNS TABLE(success boolean, message text, new_carteira_id uuid)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.criar_carteira_digital(p_medico_id uuid) OWNER TO postgres;

--
-- Name: criar_escalista(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.criar_escalista() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
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


ALTER FUNCTION public.criar_escalista() OWNER TO postgres;

--
-- Name: criar_recorrencia_com_vagas(date, date, integer[], jsonb, uuid, uuid, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.criar_recorrencia_com_vagas(p_data_inicio date, p_data_fim date, p_dias_semana integer[], p_vaga_base jsonb, p_created_by uuid, p_medico_id uuid DEFAULT NULL::uuid, p_observacoes text DEFAULT NULL::text) RETURNS uuid
    LANGUAGE plpgsql
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


ALTER FUNCTION public.criar_recorrencia_com_vagas(p_data_inicio date, p_data_fim date, p_dias_semana integer[], p_vaga_base jsonb, p_created_by uuid, p_medico_id uuid, p_observacoes text) OWNER TO postgres;

--
-- Name: criar_recorrencia_com_vagas(date, date, integer[], jsonb, uuid, uuid, text, text[], text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.criar_recorrencia_com_vagas(p_data_inicio date, p_data_fim date, p_dias_semana integer[], p_vaga_base jsonb, p_created_by uuid, p_medico_id uuid DEFAULT NULL::uuid, p_observacoes text DEFAULT NULL::text, p_beneficios text[] DEFAULT ARRAY[]::text[], p_requisitos text[] DEFAULT ARRAY[]::text[]) RETURNS uuid
    LANGUAGE plpgsql
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


ALTER FUNCTION public.criar_recorrencia_com_vagas(p_data_inicio date, p_data_fim date, p_dias_semana integer[], p_vaga_base jsonb, p_created_by uuid, p_medico_id uuid, p_observacoes text, p_beneficios text[], p_requisitos text[]) OWNER TO postgres;

--
-- Name: current_user_is_favorito(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.current_user_is_favorito(p_grupo_id uuid) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
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


ALTER FUNCTION public.current_user_is_favorito(p_grupo_id uuid) OWNER TO postgres;

--
-- Name: deletar_vagas_recorrencia(uuid, uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deletar_vagas_recorrencia(p_recorrencia_id uuid, p_updateby uuid) RETURNS void
    LANGUAGE plpgsql
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


ALTER FUNCTION public.deletar_vagas_recorrencia(p_recorrencia_id uuid, p_updateby uuid) OWNER TO postgres;

--
-- Name: deletethisuser(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.deletethisuser(user_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  delete from auth.users
  where id = user_id;
end;
$$;


ALTER FUNCTION public.deletethisuser(user_id uuid) OWNER TO postgres;

--
-- Name: editar_vagas_recorrencia(uuid, jsonb, uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid) RETURNS void
    LANGUAGE plpgsql
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


ALTER FUNCTION public.editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid) OWNER TO postgres;

--
-- Name: editar_vagas_recorrencia(uuid, jsonb, uuid, text[], text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid, p_beneficios text[] DEFAULT ARRAY[]::text[], p_requisitos text[] DEFAULT ARRAY[]::text[]) RETURNS void
    LANGUAGE plpgsql
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


ALTER FUNCTION public.editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid, p_beneficios text[], p_requisitos text[]) OWNER TO postgres;

--
-- Name: editar_vagas_recorrencia(uuid, jsonb, uuid, text[], text[], integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid, p_beneficios text[] DEFAULT ARRAY[]::text[], p_requisitos text[] DEFAULT ARRAY[]::text[], p_dias_pagamento integer DEFAULT NULL::integer) RETURNS void
    LANGUAGE plpgsql
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


ALTER FUNCTION public.editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid, p_beneficios text[], p_requisitos text[], p_dias_pagamento integer) OWNER TO postgres;

--
-- Name: excluir_vagas_lote(uuid[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.excluir_vagas_lote(vagas_ids uuid[]) RETURNS integer
    LANGUAGE plpgsql
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


ALTER FUNCTION public.excluir_vagas_lote(vagas_ids uuid[]) OWNER TO postgres;

--
-- Name: FUNCTION excluir_vagas_lote(vagas_ids uuid[]); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.excluir_vagas_lote(vagas_ids uuid[]) IS 'Função para excluir múltiplas vagas em uma operação, evitando problemas de URL muito longa no cliente Supabase';


--
-- Name: gerar_vagas_recorrentes(uuid, uuid, uuid, uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gerar_vagas_recorrentes(p_recorrencia_id uuid, p_vaga_base_id uuid, p_medico_id uuid DEFAULT NULL::uuid, p_created_by uuid DEFAULT NULL::uuid) RETURNS void
    LANGUAGE plpgsql
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


ALTER FUNCTION public.gerar_vagas_recorrentes(p_recorrencia_id uuid, p_vaga_base_id uuid, p_medico_id uuid, p_created_by uuid) OWNER TO postgres;

--
-- Name: gerar_vagas_recorrentes(uuid, uuid, uuid, uuid, text[], text[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gerar_vagas_recorrentes(p_recorrencia_id uuid, p_vaga_base_id uuid, p_medico_id uuid DEFAULT NULL::uuid, p_created_by uuid DEFAULT NULL::uuid, p_beneficios text[] DEFAULT ARRAY[]::text[], p_requisitos text[] DEFAULT ARRAY[]::text[]) RETURNS void
    LANGUAGE plpgsql
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


ALTER FUNCTION public.gerar_vagas_recorrentes(p_recorrencia_id uuid, p_vaga_base_id uuid, p_medico_id uuid, p_created_by uuid, p_beneficios text[], p_requisitos text[]) OWNER TO postgres;

--
-- Name: get_applications_paginated(integer, integer, uuid[], uuid[], uuid[], date, date, numeric, numeric, uuid[], uuid[], uuid[], text, uuid[], text[], text[], uuid[], text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_applications_paginated(page_number integer DEFAULT 1, page_size integer DEFAULT 10, hospital_ids uuid[] DEFAULT NULL::uuid[], specialty_ids uuid[] DEFAULT NULL::uuid[], sector_ids uuid[] DEFAULT NULL::uuid[], start_date date DEFAULT NULL::date, end_date date DEFAULT NULL::date, min_value numeric DEFAULT NULL::numeric, max_value numeric DEFAULT NULL::numeric, period_ids uuid[] DEFAULT NULL::uuid[], type_ids uuid[] DEFAULT NULL::uuid[], group_ids uuid[] DEFAULT NULL::uuid[], search_text text DEFAULT NULL::text, doctor_ids uuid[] DEFAULT NULL::uuid[], application_status_filter text[] DEFAULT NULL::text[], job_status_filter text[] DEFAULT NULL::text[], grade_ids uuid[] DEFAULT NULL::uuid[], order_by text DEFAULT 'candidatura_createdate'::text, order_direction text DEFAULT 'DESC'::text) RETURNS TABLE(data jsonb, pagination jsonb)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


ALTER FUNCTION public.get_applications_paginated(page_number integer, page_size integer, hospital_ids uuid[], specialty_ids uuid[], sector_ids uuid[], start_date date, end_date date, min_value numeric, max_value numeric, period_ids uuid[], type_ids uuid[], group_ids uuid[], search_text text, doctor_ids uuid[], application_status_filter text[], job_status_filter text[], grade_ids uuid[], order_by text, order_direction text) OWNER TO postgres;

--
-- Name: FUNCTION get_applications_paginated(page_number integer, page_size integer, hospital_ids uuid[], specialty_ids uuid[], sector_ids uuid[], start_date date, end_date date, min_value numeric, max_value numeric, period_ids uuid[], type_ids uuid[], group_ids uuid[], search_text text, doctor_ids uuid[], application_status_filter text[], job_status_filter text[], grade_ids uuid[], order_by text, order_direction text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.get_applications_paginated(page_number integer, page_size integer, hospital_ids uuid[], specialty_ids uuid[], sector_ids uuid[], start_date date, end_date date, min_value numeric, max_value numeric, period_ids uuid[], type_ids uuid[], group_ids uuid[], search_text text, doctor_ids uuid[], application_status_filter text[], job_status_filter text[], grade_ids uuid[], order_by text, order_direction text) IS 'Busca candidaturas individuais (não agrupadas) com filtros opcionais usando arrays em snake_case. Filtros disponíveis: hospital_ids[], specialty_ids[], sector_ids[], period_ids[], type_ids[], group_ids[], doctor_ids[], application_status_filter[PENDENTE,APROVADO,REPROVADO], job_status_filter[aberta,fechada,cancelada,anunciada], grade_ids[], além de filtros de data, valor e texto. Parâmetros de ordenação: order_by[candidatura_createdate,vagas_createdate,vagas_data,vagas_valor,medico_primeiro_nome,hospital_nome,setor_nome,especialidade_nome,vagas_periodo_nome,vagas_status,candidatura_status], order_direction[ASC,DESC]. Retorna cada candidatura separadamente com informações completas da vaga e médico associados.';


--
-- Name: get_cpf(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_cpf(cpf_input text) RETURNS boolean
    LANGUAGE plpgsql
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


ALTER FUNCTION public.get_cpf(cpf_input text) OWNER TO postgres;

--
-- Name: get_crm(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_crm(crm_input text) RETURNS boolean
    LANGUAGE plpgsql
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


ALTER FUNCTION public.get_crm(crm_input text) OWNER TO postgres;

--
-- Name: get_current_user_grupo_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_current_user_grupo_id() RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
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


ALTER FUNCTION public.get_current_user_grupo_id() OWNER TO postgres;

--
-- Name: get_documento_historico(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_documento_historico(p_carteira_id uuid) RETURNS TABLE(tipo text, status boolean, updated_at timestamp without time zone, updated_by uuid)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.get_documento_historico(p_carteira_id uuid) OWNER TO postgres;

--
-- Name: get_documento_historico(uuid, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_documento_historico(p_carteira_id uuid, p_tipo text) RETURNS TABLE(data_atualizacao timestamp without time zone, status boolean, url character varying, usuario_id uuid)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.get_documento_historico(p_carteira_id uuid, p_tipo text) OWNER TO postgres;

--
-- Name: get_documentos_pendentes(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_documentos_pendentes(p_carteira_id uuid) RETURNS TABLE(tipo character varying, label character varying, status boolean, url character varying, ultima_atualizacao timestamp without time zone, atualizado_por uuid)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.get_documentos_pendentes(p_carteira_id uuid) OWNER TO postgres;

--
-- Name: get_email(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_email(e_mail text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
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


ALTER FUNCTION public.get_email(e_mail text) OWNER TO postgres;

--
-- Name: get_medicos_com_documentos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_medicos_com_documentos() RETURNS TABLE(id uuid, nome character varying, crm character varying, medico_especialidade character varying, especialidade_nome character varying, status boolean, createdate timestamp without time zone, documentos jsonb)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.get_medicos_com_documentos() OWNER TO postgres;

--
-- Name: get_medicos_documentacao_pendente(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_medicos_documentacao_pendente() RETURNS TABLE(medico_id uuid, nome character varying, crm character varying, especialidade_id uuid, percentual_conclusao numeric, documentos_pendentes json)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.get_medicos_documentacao_pendente() OWNER TO postgres;

--
-- Name: get_percentual_conclusao(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_percentual_conclusao(p_carteira_id uuid) RETURNS TABLE(total_documentos bigint, documentos_aprovados bigint, percentual numeric, status_geral boolean)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.get_percentual_conclusao(p_carteira_id uuid) OWNER TO postgres;

--
-- Name: get_phonenumber(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_phonenumber(p_phone text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
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


ALTER FUNCTION public.get_phonenumber(p_phone text) OWNER TO postgres;

--
-- Name: get_urls_pendentes(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_urls_pendentes(p_carteira_id uuid) RETURNS TABLE(tipo character varying, label character varying, status boolean, url character varying, situacao character varying)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.get_urls_pendentes(p_carteira_id uuid) OWNER TO postgres;

--
-- Name: get_vagas_paginated(integer, integer, uuid[], uuid[], uuid[], date, date, numeric, numeric, uuid[], uuid[], uuid[], text, uuid[], text[], text[], uuid[], text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_vagas_paginated(page_number integer DEFAULT 1, page_size integer DEFAULT 10, hospital_ids uuid[] DEFAULT NULL::uuid[], specialty_ids uuid[] DEFAULT NULL::uuid[], sector_ids uuid[] DEFAULT NULL::uuid[], start_date date DEFAULT NULL::date, end_date date DEFAULT NULL::date, min_value numeric DEFAULT NULL::numeric, max_value numeric DEFAULT NULL::numeric, period_ids uuid[] DEFAULT NULL::uuid[], type_ids uuid[] DEFAULT NULL::uuid[], group_ids uuid[] DEFAULT NULL::uuid[], search_text text DEFAULT NULL::text, doctor_ids uuid[] DEFAULT NULL::uuid[], application_status_filter text[] DEFAULT NULL::text[], job_status_filter text[] DEFAULT NULL::text[], grade_ids uuid[] DEFAULT NULL::uuid[], order_by text DEFAULT 'vagas_data'::text, order_direction text DEFAULT 'DESC'::text) RETURNS TABLE(data jsonb, pagination jsonb)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


ALTER FUNCTION public.get_vagas_paginated(page_number integer, page_size integer, hospital_ids uuid[], specialty_ids uuid[], sector_ids uuid[], start_date date, end_date date, min_value numeric, max_value numeric, period_ids uuid[], type_ids uuid[], group_ids uuid[], search_text text, doctor_ids uuid[], application_status_filter text[], job_status_filter text[], grade_ids uuid[], order_by text, order_direction text) OWNER TO postgres;

--
-- Name: FUNCTION get_vagas_paginated(page_number integer, page_size integer, hospital_ids uuid[], specialty_ids uuid[], sector_ids uuid[], start_date date, end_date date, min_value numeric, max_value numeric, period_ids uuid[], type_ids uuid[], group_ids uuid[], search_text text, doctor_ids uuid[], application_status_filter text[], job_status_filter text[], grade_ids uuid[], order_by text, order_direction text); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.get_vagas_paginated(page_number integer, page_size integer, hospital_ids uuid[], specialty_ids uuid[], sector_ids uuid[], start_date date, end_date date, min_value numeric, max_value numeric, period_ids uuid[], type_ids uuid[], group_ids uuid[], search_text text, doctor_ids uuid[], application_status_filter text[], job_status_filter text[], grade_ids uuid[], order_by text, order_direction text) IS 'Busca vagas agrupadas com suas candidaturas usando filtros opcionais. Filtros disponíveis: hospital_ids[], specialty_ids[], sector_ids[], period_ids[], type_ids[], group_ids[], doctor_ids[], application_status_filter[PENDENTE,APROVADO,REPROVADO], job_status_filter[aberta,fechada,cancelada,anunciada], grade_ids[], além de filtros de data, valor e texto. Parâmetros de ordenação: order_by[vagas_createdate,vagas_data,vagas_valor,hospital_nome,setor_nome,especialidade_nome,vagas_periodo_nome,vagas_status,total_candidaturas], order_direction[ASC,DESC]. Retorna vagas agrupadas com array de candidaturas associadas.';


--
-- Name: getidfromemail(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getidfromemail(e_mail text) RETURNS uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  select id
  from auth.users
  where email = e_mail
  limit 1;
$$;


ALTER FUNCTION public.getidfromemail(e_mail text) OWNER TO postgres;

--
-- Name: getidfromphone(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getidfromphone(p_phone text) RETURNS uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  select id
  from auth.users
  where phone = p_phone
  limit 1;
$$;


ALTER FUNCTION public.getidfromphone(p_phone text) OWNER TO postgres;

--
-- Name: getuserprofile(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getuserprofile(user_id uuid) RETURNS text
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  select role
    from public.user_profile
   where id = user_id
   limit 1;
$$;


ALTER FUNCTION public.getuserprofile(user_id uuid) OWNER TO postgres;

--
-- Name: handle_grades_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_grades_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc'::text, NOW());
  NEW.updated_by = auth.uid();
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.handle_grades_updated_at() OWNER TO postgres;

--
-- Name: inserir_carteira_digital(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.inserir_carteira_digital() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Inserir nova linha na tabela carteira_digital
    INSERT INTO carteira_digital (medicos_id)
    VALUES (NEW.medico_id);
    -- Retorna o valor da nova linha inserida
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.inserir_carteira_digital() OWNER TO postgres;

--
-- Name: inserir_validacao_documentos(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.inserir_validacao_documentos() RETURNS trigger
    LANGUAGE plpgsql
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


ALTER FUNCTION public.inserir_validacao_documentos() OWNER TO postgres;

--
-- Name: pode_ver_candidatura_colega(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.pode_ver_candidatura_colega(candidatura_id uuid) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
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


ALTER FUNCTION public.pode_ver_candidatura_colega(candidatura_id uuid) OWNER TO postgres;

--
-- Name: pode_ver_candidatura_colega_debug(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.pode_ver_candidatura_colega_debug(candidatura_id uuid) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
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


ALTER FUNCTION public.pode_ver_candidatura_colega_debug(candidatura_id uuid) OWNER TO postgres;

--
-- Name: refresh_dashboard_metrics(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.refresh_dashboard_metrics() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY vw_dashboard_metrics;
END;
$$;


ALTER FUNCTION public.refresh_dashboard_metrics() OWNER TO postgres;

--
-- Name: refresh_vw_vagas_disponiveis(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.refresh_vw_vagas_disponiveis() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY vw_vagas_disponiveis;
    RETURN NULL;
END;
$$;


ALTER FUNCTION public.refresh_vw_vagas_disponiveis() OWNER TO postgres;

--
-- Name: reprovar_documento(uuid, text, text, uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.reprovar_documento(p_carteira_id uuid, p_tipo text, p_motivo text, p_user_id uuid) RETURNS TABLE(success boolean, message text)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.reprovar_documento(p_carteira_id uuid, p_tipo text, p_motivo text, p_user_id uuid) OWNER TO postgres;

--
-- Name: sync_pagamentos_medico_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sync_pagamentos_medico_id() RETURNS trigger
    LANGUAGE plpgsql
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


ALTER FUNCTION public.sync_pagamentos_medico_id() OWNER TO postgres;

--
-- Name: sync_user_profile(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sync_user_profile() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
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


ALTER FUNCTION public.sync_user_profile() OWNER TO postgres;

--
-- Name: sync_vagas_beneficio_vaga_id(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sync_vagas_beneficio_vaga_id() RETURNS trigger
    LANGUAGE plpgsql
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


ALTER FUNCTION public.sync_vagas_beneficio_vaga_id() OWNER TO postgres;

--
-- Name: update_documento_status(uuid, text, boolean, uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_documento_status(p_carteira_id uuid, p_tipo text, p_status boolean, p_user_id uuid) RETURNS TABLE(success boolean, message text)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.update_documento_status(p_carteira_id uuid, p_tipo text, p_status boolean, p_user_id uuid) OWNER TO postgres;

--
-- Name: update_documento_url(uuid, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_documento_url(p_carteira_id uuid, p_tipo text, p_url text) RETURNS TABLE(success boolean, message text)
    LANGUAGE plpgsql
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


ALTER FUNCTION public.update_documento_url(p_carteira_id uuid, p_tipo text, p_url text) OWNER TO postgres;

--
-- Name: update_especialidade_nome(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_especialidade_nome() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    SELECT esp.nome INTO NEW.especialidade_nome
    FROM public.especialidades esp
    WHERE esp.id = NEW.especialidade_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_especialidade_nome() OWNER TO postgres;

--
-- Name: update_phone_forotp(uuid, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_phone_forotp(user_id uuid, areacodeindex integer, telefone text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
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


ALTER FUNCTION public.update_phone_forotp(user_id uuid, areacodeindex integer, telefone text) OWNER TO postgres;

--
-- Name: update_total_candidaturas(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_total_candidaturas() RETURNS trigger
    LANGUAGE plpgsql
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


ALTER FUNCTION public.update_total_candidaturas() OWNER TO postgres;

--
-- Name: update_total_plantoes_medico(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_total_plantoes_medico() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'public'
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


ALTER FUNCTION public.update_total_plantoes_medico() OWNER TO postgres;

--
-- Name: updatethisuser(uuid, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updatethisuser(user_id uuid, e_mail text, p_phone text) RETURNS void
    LANGUAGE sql SECURITY DEFINER
    AS $$update auth.users
     set email = e_mail,
         phone = p_phone
   where id = user_id;$$;


ALTER FUNCTION public.updatethisuser(user_id uuid, e_mail text, p_phone text) OWNER TO postgres;

--
-- Name: validar_localizacao_medico(uuid, numeric, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validar_localizacao_medico(p_hospital_id uuid, p_latitude numeric, p_longitude numeric) RETURNS boolean
    LANGUAGE plpgsql
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


ALTER FUNCTION public.validar_localizacao_medico(p_hospital_id uuid, p_latitude numeric, p_longitude numeric) OWNER TO postgres;

--
-- Name: validate_checkin_timing(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validate_checkin_timing() RETURNS trigger
    LANGUAGE plpgsql
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


ALTER FUNCTION public.validate_checkin_timing() OWNER TO postgres;

--
-- Name: validate_checkout_timing(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validate_checkout_timing() RETURNS trigger
    LANGUAGE plpgsql
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


ALTER FUNCTION public.validate_checkout_timing() OWNER TO postgres;

--
-- Name: verificar_conflito_antes_candidatura(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.verificar_conflito_antes_candidatura() RETURNS trigger
    LANGUAGE plpgsql
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


ALTER FUNCTION public.verificar_conflito_antes_candidatura() OWNER TO postgres;

--
-- Name: verificar_conflito_vaga_designada(uuid, date, time without time zone, time without time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.verificar_conflito_vaga_designada(p_medico_id uuid, p_data date, p_hora_inicio time without time zone, p_hora_fim time without time zone) RETURNS void
    LANGUAGE plpgsql
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


ALTER FUNCTION public.verificar_conflito_vaga_designada(p_medico_id uuid, p_data date, p_hora_inicio time without time zone, p_hora_fim time without time zone) OWNER TO postgres;

--
-- Name: verificar_consistencia_status_vagas(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.verificar_consistencia_status_vagas() RETURNS TABLE(problema text, quantidade integer, detalhes text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


ALTER FUNCTION public.verificar_consistencia_status_vagas() OWNER TO postgres;

--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_;

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


ALTER FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


ALTER FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) OWNER TO supabase_admin;

--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


ALTER FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) OWNER TO supabase_admin;

--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


ALTER FUNCTION realtime."cast"(val text, type_ regtype) OWNER TO supabase_admin;

--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


ALTER FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) OWNER TO supabase_admin;

--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


ALTER FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) OWNER TO supabase_admin;

--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


ALTER FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


ALTER FUNCTION realtime.quote_wal2json(entity regclass) OWNER TO supabase_admin;

--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  BEGIN
    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (payload, event, topic, private, extension)
    VALUES (payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      RAISE WARNING 'ErrorSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


ALTER FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) OWNER TO supabase_admin;

--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


ALTER FUNCTION realtime.subscription_check_filters() OWNER TO supabase_admin;

--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


ALTER FUNCTION realtime.to_regrole(role_name text) OWNER TO supabase_admin;

--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


ALTER FUNCTION realtime.topic() OWNER TO supabase_realtime_admin;

--
-- Name: add_prefixes(text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.add_prefixes(_bucket_id text, _name text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    prefixes text[];
BEGIN
    prefixes := "storage"."get_prefixes"("_name");

    IF array_length(prefixes, 1) > 0 THEN
        INSERT INTO storage.prefixes (name, bucket_id)
        SELECT UNNEST(prefixes) as name, "_bucket_id" ON CONFLICT DO NOTHING;
    END IF;
END;
$$;


ALTER FUNCTION storage.add_prefixes(_bucket_id text, _name text) OWNER TO supabase_storage_admin;

--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


ALTER FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) OWNER TO supabase_storage_admin;

--
-- Name: delete_leaf_prefixes(text[], text[]); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.delete_leaf_prefixes(bucket_ids text[], names text[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_rows_deleted integer;
BEGIN
    LOOP
        WITH candidates AS (
            SELECT DISTINCT t.bucket_id,
                unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        ),
        uniq AS (
            SELECT bucket_id,
                   name,
                   storage.get_level(name) AS level
             FROM candidates
             WHERE name <> ''
             GROUP BY bucket_id, name
        ),
        leaf AS (
            SELECT p.bucket_id, p.name, p.level
            FROM storage.prefixes AS p
            JOIN uniq AS u
              ON u.bucket_id = p.bucket_id
                  AND u.name = p.name
                  AND u.level = p.level
            WHERE NOT EXISTS (
                SELECT 1
                FROM storage.objects AS o
                WHERE o.bucket_id = p.bucket_id
                  AND storage.get_level(o.name) = p.level + 1
                  AND o.name COLLATE "C" LIKE p.name || '/%'
            )
            AND NOT EXISTS (
                SELECT 1
                FROM storage.prefixes AS c
                WHERE c.bucket_id = p.bucket_id
                  AND c.level = p.level + 1
                  AND c.name COLLATE "C" LIKE p.name || '/%'
            )
        )
        DELETE FROM storage.prefixes AS p
        USING leaf AS l
        WHERE p.bucket_id = l.bucket_id
          AND p.name = l.name
          AND p.level = l.level;

        GET DIAGNOSTICS v_rows_deleted = ROW_COUNT;
        EXIT WHEN v_rows_deleted = 0;
    END LOOP;
END;
$$;


ALTER FUNCTION storage.delete_leaf_prefixes(bucket_ids text[], names text[]) OWNER TO supabase_storage_admin;

--
-- Name: delete_prefix(text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.delete_prefix(_bucket_id text, _name text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    -- Check if we can delete the prefix
    IF EXISTS(
        SELECT FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name") + 1
          AND "prefixes"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    )
    OR EXISTS(
        SELECT FROM "storage"."objects"
        WHERE "objects"."bucket_id" = "_bucket_id"
          AND "storage"."get_level"("objects"."name") = "storage"."get_level"("_name") + 1
          AND "objects"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    ) THEN
    -- There are sub-objects, skip deletion
    RETURN false;
    ELSE
        DELETE FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name")
          AND "prefixes"."name" = "_name";
        RETURN true;
    END IF;
END;
$$;


ALTER FUNCTION storage.delete_prefix(_bucket_id text, _name text) OWNER TO supabase_storage_admin;

--
-- Name: delete_prefix_hierarchy_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.delete_prefix_hierarchy_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    prefix text;
BEGIN
    prefix := "storage"."get_prefix"(OLD."name");

    IF coalesce(prefix, '') != '' THEN
        PERFORM "storage"."delete_prefix"(OLD."bucket_id", prefix);
    END IF;

    RETURN OLD;
END;
$$;


ALTER FUNCTION storage.delete_prefix_hierarchy_trigger() OWNER TO supabase_storage_admin;

--
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


ALTER FUNCTION storage.enforce_bucket_name_length() OWNER TO supabase_storage_admin;

--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    SELECT string_to_array(name, '/') INTO _parts;
    SELECT _parts[array_length(_parts,1)] INTO _filename;
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


ALTER FUNCTION storage.extension(name text) OWNER TO supabase_storage_admin;

--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


ALTER FUNCTION storage.filename(name text) OWNER TO supabase_storage_admin;

--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


ALTER FUNCTION storage.foldername(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_level(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_level(name text) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
SELECT array_length(string_to_array("name", '/'), 1);
$$;


ALTER FUNCTION storage.get_level(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_prefix(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_prefix(name text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
SELECT
    CASE WHEN strpos("name", '/') > 0 THEN
             regexp_replace("name", '[\/]{1}[^\/]+\/?$', '')
         ELSE
             ''
        END;
$_$;


ALTER FUNCTION storage.get_prefix(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_prefixes(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_prefixes(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
DECLARE
    parts text[];
    prefixes text[];
    prefix text;
BEGIN
    -- Split the name into parts by '/'
    parts := string_to_array("name", '/');
    prefixes := '{}';

    -- Construct the prefixes, stopping one level below the last part
    FOR i IN 1..array_length(parts, 1) - 1 LOOP
            prefix := array_to_string(parts[1:i], '/');
            prefixes := array_append(prefixes, prefix);
    END LOOP;

    RETURN prefixes;
END;
$$;


ALTER FUNCTION storage.get_prefixes(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


ALTER FUNCTION storage.get_size_by_bucket() OWNER TO supabase_storage_admin;

--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


ALTER FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, next_key_token text, next_upload_token text) OWNER TO supabase_storage_admin;

--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


ALTER FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, start_after text, next_token text) OWNER TO supabase_storage_admin;

--
-- Name: lock_top_prefixes(text[], text[]); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.lock_top_prefixes(bucket_ids text[], names text[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket text;
    v_top text;
BEGIN
    FOR v_bucket, v_top IN
        SELECT DISTINCT t.bucket_id,
            split_part(t.name, '/', 1) AS top
        FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        WHERE t.name <> ''
        ORDER BY 1, 2
        LOOP
            PERFORM pg_advisory_xact_lock(hashtextextended(v_bucket || '/' || v_top, 0));
        END LOOP;
END;
$$;


ALTER FUNCTION storage.lock_top_prefixes(bucket_ids text[], names text[]) OWNER TO supabase_storage_admin;

--
-- Name: objects_delete_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_delete_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


ALTER FUNCTION storage.objects_delete_cleanup() OWNER TO supabase_storage_admin;

--
-- Name: objects_insert_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_insert_prefix_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    NEW.level := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.objects_insert_prefix_trigger() OWNER TO supabase_storage_admin;

--
-- Name: objects_update_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_update_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    -- NEW - OLD (destinations to create prefixes for)
    v_add_bucket_ids text[];
    v_add_names      text[];

    -- OLD - NEW (sources to prune)
    v_src_bucket_ids text[];
    v_src_names      text[];
BEGIN
    IF TG_OP <> 'UPDATE' THEN
        RETURN NULL;
    END IF;

    -- 1) Compute NEW−OLD (added paths) and OLD−NEW (moved-away paths)
    WITH added AS (
        SELECT n.bucket_id, n.name
        FROM new_rows n
        WHERE n.name <> '' AND position('/' in n.name) > 0
        EXCEPT
        SELECT o.bucket_id, o.name FROM old_rows o WHERE o.name <> ''
    ),
    moved AS (
         SELECT o.bucket_id, o.name
         FROM old_rows o
         WHERE o.name <> ''
         EXCEPT
         SELECT n.bucket_id, n.name FROM new_rows n WHERE n.name <> ''
    )
    SELECT
        -- arrays for ADDED (dest) in stable order
        COALESCE( (SELECT array_agg(a.bucket_id ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        COALESCE( (SELECT array_agg(a.name      ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        -- arrays for MOVED (src) in stable order
        COALESCE( (SELECT array_agg(m.bucket_id ORDER BY m.bucket_id, m.name) FROM moved m), '{}' ),
        COALESCE( (SELECT array_agg(m.name      ORDER BY m.bucket_id, m.name) FROM moved m), '{}' )
    INTO v_add_bucket_ids, v_add_names, v_src_bucket_ids, v_src_names;

    -- Nothing to do?
    IF (array_length(v_add_bucket_ids, 1) IS NULL) AND (array_length(v_src_bucket_ids, 1) IS NULL) THEN
        RETURN NULL;
    END IF;

    -- 2) Take per-(bucket, top) locks: ALL prefixes in consistent global order to prevent deadlocks
    DECLARE
        v_all_bucket_ids text[];
        v_all_names text[];
    BEGIN
        -- Combine source and destination arrays for consistent lock ordering
        v_all_bucket_ids := COALESCE(v_src_bucket_ids, '{}') || COALESCE(v_add_bucket_ids, '{}');
        v_all_names := COALESCE(v_src_names, '{}') || COALESCE(v_add_names, '{}');

        -- Single lock call ensures consistent global ordering across all transactions
        IF array_length(v_all_bucket_ids, 1) IS NOT NULL THEN
            PERFORM storage.lock_top_prefixes(v_all_bucket_ids, v_all_names);
        END IF;
    END;

    -- 3) Create destination prefixes (NEW−OLD) BEFORE pruning sources
    IF array_length(v_add_bucket_ids, 1) IS NOT NULL THEN
        WITH candidates AS (
            SELECT DISTINCT t.bucket_id, unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(v_add_bucket_ids, v_add_names) AS t(bucket_id, name)
            WHERE name <> ''
        )
        INSERT INTO storage.prefixes (bucket_id, name)
        SELECT c.bucket_id, c.name
        FROM candidates c
        ON CONFLICT DO NOTHING;
    END IF;

    -- 4) Prune source prefixes bottom-up for OLD−NEW
    IF array_length(v_src_bucket_ids, 1) IS NOT NULL THEN
        -- re-entrancy guard so DELETE on prefixes won't recurse
        IF current_setting('storage.gc.prefixes', true) <> '1' THEN
            PERFORM set_config('storage.gc.prefixes', '1', true);
        END IF;

        PERFORM storage.delete_leaf_prefixes(v_src_bucket_ids, v_src_names);
    END IF;

    RETURN NULL;
END;
$$;


ALTER FUNCTION storage.objects_update_cleanup() OWNER TO supabase_storage_admin;

--
-- Name: objects_update_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_update_prefix_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    old_prefixes TEXT[];
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Retrieve old prefixes
        old_prefixes := "storage"."get_prefixes"(OLD."name");

        -- Remove old prefixes that are only used by this object
        WITH all_prefixes as (
            SELECT unnest(old_prefixes) as prefix
        ),
        can_delete_prefixes as (
             SELECT prefix
             FROM all_prefixes
             WHERE NOT EXISTS (
                 SELECT 1 FROM "storage"."objects"
                 WHERE "bucket_id" = OLD."bucket_id"
                   AND "name" <> OLD."name"
                   AND "name" LIKE (prefix || '%')
             )
         )
        DELETE FROM "storage"."prefixes" WHERE name IN (SELECT prefix FROM can_delete_prefixes);

        -- Add new prefixes
        PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    END IF;
    -- Set the new level
    NEW."level" := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.objects_update_prefix_trigger() OWNER TO supabase_storage_admin;

--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


ALTER FUNCTION storage.operation() OWNER TO supabase_storage_admin;

--
-- Name: prefixes_delete_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.prefixes_delete_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


ALTER FUNCTION storage.prefixes_delete_cleanup() OWNER TO supabase_storage_admin;

--
-- Name: prefixes_insert_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.prefixes_insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.prefixes_insert_trigger() OWNER TO supabase_storage_admin;

--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql
    AS $$
declare
    can_bypass_rls BOOLEAN;
begin
    SELECT rolbypassrls
    INTO can_bypass_rls
    FROM pg_roles
    WHERE rolname = coalesce(nullif(current_setting('role', true), 'none'), current_user);

    IF can_bypass_rls THEN
        RETURN QUERY SELECT * FROM storage.search_v1_optimised(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    ELSE
        RETURN QUERY SELECT * FROM storage.search_legacy_v1(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    END IF;
end;
$$;


ALTER FUNCTION storage.search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: search_legacy_v1(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_legacy_v1(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select path_tokens[$1] as folder
           from storage.objects
             where objects.name ilike $2 || $3 || ''%''
               and bucket_id = $4
               and array_length(objects.path_tokens, 1) <> $1
           group by folder
           order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION storage.search_legacy_v1(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: search_v1_optimised(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_v1_optimised(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select (string_to_array(name, ''/''))[level] as name
           from storage.prefixes
             where lower(prefixes.name) like lower($2 || $3) || ''%''
               and bucket_id = $4
               and level = $1
           order by name ' || v_sort_order || '
     )
     (select name,
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[level] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where lower(objects.name) like lower($2 || $3) || ''%''
       and bucket_id = $4
       and level = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION storage.search_v1_optimised(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: search_v2(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    sort_col text;
    sort_ord text;
    cursor_op text;
    cursor_expr text;
    sort_expr text;
BEGIN
    -- Validate sort_order
    sort_ord := lower(sort_order);
    IF sort_ord NOT IN ('asc', 'desc') THEN
        sort_ord := 'asc';
    END IF;

    -- Determine cursor comparison operator
    IF sort_ord = 'asc' THEN
        cursor_op := '>';
    ELSE
        cursor_op := '<';
    END IF;
    
    sort_col := lower(sort_column);
    -- Validate sort column  
    IF sort_col IN ('updated_at', 'created_at') THEN
        cursor_expr := format(
            '($5 = '''' OR ROW(date_trunc(''milliseconds'', %I), name COLLATE "C") %s ROW(COALESCE(NULLIF($6, '''')::timestamptz, ''epoch''::timestamptz), $5))',
            sort_col, cursor_op
        );
        sort_expr := format(
            'COALESCE(date_trunc(''milliseconds'', %I), ''epoch''::timestamptz) %s, name COLLATE "C" %s',
            sort_col, sort_ord, sort_ord
        );
    ELSE
        cursor_expr := format('($5 = '''' OR name COLLATE "C" %s $5)', cursor_op);
        sort_expr := format('name COLLATE "C" %s', sort_ord);
    END IF;

    RETURN QUERY EXECUTE format(
        $sql$
        SELECT * FROM (
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    NULL::uuid AS id,
                    updated_at,
                    created_at,
                    NULL::timestamptz AS last_accessed_at,
                    NULL::jsonb AS metadata
                FROM storage.prefixes
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
            UNION ALL
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    id,
                    updated_at,
                    created_at,
                    last_accessed_at,
                    metadata
                FROM storage.objects
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
        ) obj
        ORDER BY %s
        LIMIT $3
        $sql$,
        cursor_expr,    -- prefixes WHERE
        sort_expr,      -- prefixes ORDER BY
        cursor_expr,    -- objects WHERE
        sort_expr,      -- objects ORDER BY
        sort_expr       -- final ORDER BY
    )
    USING prefix, bucket_name, limits, levels, start_after, sort_column_after;
END;
$_$;


ALTER FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer, levels integer, start_after text, sort_order text, sort_column text, sort_column_after text) OWNER TO supabase_storage_admin;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


ALTER FUNCTION storage.update_updated_at_column() OWNER TO supabase_storage_admin;

--
-- Name: http_request(); Type: FUNCTION; Schema: supabase_functions; Owner: supabase_functions_admin
--

CREATE FUNCTION supabase_functions.http_request() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'supabase_functions'
    AS $$
  DECLARE
    request_id bigint;
    payload jsonb;
    url text := TG_ARGV[0]::text;
    method text := TG_ARGV[1]::text;
    headers jsonb DEFAULT '{}'::jsonb;
    params jsonb DEFAULT '{}'::jsonb;
    timeout_ms integer DEFAULT 1000;
  BEGIN
    IF url IS NULL OR url = 'null' THEN
      RAISE EXCEPTION 'url argument is missing';
    END IF;

    IF method IS NULL OR method = 'null' THEN
      RAISE EXCEPTION 'method argument is missing';
    END IF;

    IF TG_ARGV[2] IS NULL OR TG_ARGV[2] = 'null' THEN
      headers = '{"Content-Type": "application/json"}'::jsonb;
    ELSE
      headers = TG_ARGV[2]::jsonb;
    END IF;

    IF TG_ARGV[3] IS NULL OR TG_ARGV[3] = 'null' THEN
      params = '{}'::jsonb;
    ELSE
      params = TG_ARGV[3]::jsonb;
    END IF;

    IF TG_ARGV[4] IS NULL OR TG_ARGV[4] = 'null' THEN
      timeout_ms = 1000;
    ELSE
      timeout_ms = TG_ARGV[4]::integer;
    END IF;

    CASE
      WHEN method = 'GET' THEN
        SELECT http_get INTO request_id FROM net.http_get(
          url,
          params,
          headers,
          timeout_ms
        );
      WHEN method = 'POST' THEN
        payload = jsonb_build_object(
          'old_record', OLD,
          'record', NEW,
          'type', TG_OP,
          'table', TG_TABLE_NAME,
          'schema', TG_TABLE_SCHEMA
        );

        SELECT http_post INTO request_id FROM net.http_post(
          url,
          payload,
          params,
          headers,
          timeout_ms
        );
      ELSE
        RAISE EXCEPTION 'method argument % is invalid', method;
    END CASE;

    INSERT INTO supabase_functions.hooks
      (hook_table_id, hook_name, request_id)
    VALUES
      (TG_RELID, TG_NAME, request_id);

    RETURN NEW;
  END
$$;


ALTER FUNCTION supabase_functions.http_request() OWNER TO supabase_functions_admin;

--
-- Name: http_request(text, text, jsonb, jsonb, integer); Type: FUNCTION; Schema: supabase_functions; Owner: postgres
--

CREATE FUNCTION supabase_functions.http_request(url text, method text, headers jsonb, payload jsonb, timeout_ms integer) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
    -- This is a placeholder function for local development
    -- In production, Supabase provides this function for Edge Functions integration
    return jsonb_build_object('status', 'success', 'message', 'Edge function call simulated');
end;
$$;


ALTER FUNCTION supabase_functions.http_request(url text, method text, headers jsonb, payload jsonb, timeout_ms integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: extensions; Type: TABLE; Schema: _realtime; Owner: supabase_admin
--

CREATE TABLE _realtime.extensions (
    id uuid NOT NULL,
    type text,
    settings jsonb,
    tenant_external_id text,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE _realtime.extensions OWNER TO supabase_admin;

--
-- Name: schema_migrations; Type: TABLE; Schema: _realtime; Owner: supabase_admin
--

CREATE TABLE _realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE _realtime.schema_migrations OWNER TO supabase_admin;

--
-- Name: tenants; Type: TABLE; Schema: _realtime; Owner: supabase_admin
--

CREATE TABLE _realtime.tenants (
    id uuid NOT NULL,
    name text,
    external_id text,
    jwt_secret text,
    max_concurrent_users integer DEFAULT 200 NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    max_events_per_second integer DEFAULT 100 NOT NULL,
    postgres_cdc_default text DEFAULT 'postgres_cdc_rls'::text,
    max_bytes_per_second integer DEFAULT 100000 NOT NULL,
    max_channels_per_client integer DEFAULT 100 NOT NULL,
    max_joins_per_second integer DEFAULT 500 NOT NULL,
    suspend boolean DEFAULT false,
    jwt_jwks jsonb,
    notify_private_alpha boolean DEFAULT false,
    private_only boolean DEFAULT false NOT NULL,
    migrations_ran integer DEFAULT 0,
    broadcast_adapter character varying(255) DEFAULT 'gen_rpc'::character varying,
    max_presence_events_per_second integer DEFAULT 10000,
    max_payload_size_in_kb integer DEFAULT 3000
);


ALTER TABLE _realtime.tenants OWNER TO supabase_admin;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE auth.audit_log_entries OWNER TO supabase_auth_admin;

--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text NOT NULL,
    code_challenge_method auth.code_challenge_method NOT NULL,
    code_challenge text NOT NULL,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone
);


ALTER TABLE auth.flow_state OWNER TO supabase_auth_admin;

--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE auth.identities OWNER TO supabase_auth_admin;

--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE auth.instances OWNER TO supabase_auth_admin;

--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


ALTER TABLE auth.mfa_amr_claims OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


ALTER TABLE auth.mfa_challenges OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid
);


ALTER TABLE auth.mfa_factors OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_id text NOT NULL,
    client_secret_hash text NOT NULL,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048))
);


ALTER TABLE auth.oauth_clients OWNER TO supabase_auth_admin;

--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


ALTER TABLE auth.one_time_tokens OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


ALTER TABLE auth.refresh_tokens OWNER TO supabase_auth_admin;

--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: supabase_auth_admin
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.refresh_tokens_id_seq OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: supabase_auth_admin
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


ALTER TABLE auth.saml_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


ALTER TABLE auth.saml_relay_states OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE auth.schema_migrations OWNER TO supabase_auth_admin;

--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text
);


ALTER TABLE auth.sessions OWNER TO supabase_auth_admin;

--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


ALTER TABLE auth.sso_domains OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


ALTER TABLE auth.sso_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


ALTER TABLE auth.users OWNER TO supabase_auth_admin;

--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: banner_mkt; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.banner_mkt (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    page_index smallint,
    imgpath text DEFAULT 'http://'::text,
    description text DEFAULT 'adicione uma descrição'::text,
    url text
);


ALTER TABLE public.banner_mkt OWNER TO postgres;

--
-- Name: bannerMKT_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.banner_mkt ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."bannerMKT_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: beneficios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.beneficios (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    nome character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.beneficios OWNER TO postgres;

--
-- Name: candidaturas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.candidaturas (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    data_confirmacao date DEFAULT now(),
    medico_id uuid NOT NULL,
    vagas_id uuid NOT NULL,
    status text NOT NULL,
    updated_at timestamp without time zone DEFAULT now(),
    updated_by text,
    vagas_valor integer DEFAULT 100 NOT NULL,
    medico_precadastro_id uuid,
    CONSTRAINT candidatura_status_check CHECK ((status = ANY (ARRAY['PENDENTE'::text, 'APROVADO'::text, 'REPROVADO'::text]))),
    CONSTRAINT candidaturas_vagas_valor_check CHECK (((vagas_valor)::numeric > (0)::numeric)),
    CONSTRAINT chk_one_medico_type_candidaturas CHECK ((((medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid) AND (medico_precadastro_id IS NOT NULL)) OR ((medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid) AND (medico_precadastro_id IS NULL))))
);


ALTER TABLE public.candidaturas OWNER TO postgres;

--
-- Name: carteira_digital; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.carteira_digital (
    carteira_id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    medico_id uuid NOT NULL,
    carteira_createdate timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    carteira_diploma character varying DEFAULT 'AGUARDANDO'::character varying NOT NULL,
    carteira_crm character varying DEFAULT 'AGUARDANDO'::character varying NOT NULL,
    carteira_cpf character varying DEFAULT 'AGUARDANDO'::character varying NOT NULL,
    carteira_rg character varying DEFAULT 'AGUARDANDO'::character varying NOT NULL,
    carteira_especializacaodiploma character varying DEFAULT 'AGUARDANDO'::character varying NOT NULL,
    carteira_anuidadecrm character varying DEFAULT 'AGUARDANDO'::character varying NOT NULL,
    carteira_eticoprofissional character varying DEFAULT 'AGUARDANDO'::character varying NOT NULL,
    carteira_comprovanteresidencia character varying DEFAULT 'AGUARDANDO'::character varying NOT NULL,
    carteira_foto character varying DEFAULT 'AGUARDANDO'::character varying NOT NULL,
    carteira_comprovantevacina character varying DEFAULT 'AGUARDANDO'::character varying,
    carteira_status boolean,
    carteira_diploma_status boolean DEFAULT false,
    carteira_crm_status boolean DEFAULT false,
    carteira_cpf_status boolean DEFAULT false,
    carteira_rg_status boolean DEFAULT false,
    carteira_especializacaodiploma_status boolean DEFAULT false,
    carteira_anuidadecrm_status boolean DEFAULT false,
    carteira_eticoprofissional_status boolean DEFAULT false,
    carteira_comprovanteresidencia_status boolean DEFAULT false,
    carteira_foto_status boolean DEFAULT false,
    carteira_comprovantevacina_status boolean DEFAULT false,
    carteira_diploma_updatedate timestamp without time zone,
    carteira_crm_updatedate timestamp without time zone,
    carteira_cpf_updatedate timestamp without time zone,
    carteira_rg_updatedate timestamp without time zone,
    carteira_especializacaodiploma_updatedate timestamp without time zone,
    carteira_anuidadecrm_updatedate timestamp without time zone,
    carteira_eticoprofissional_updatedate timestamp without time zone,
    carteira_comprovanteresidencia_updatedate timestamp without time zone,
    carteira_foto_updatedate timestamp without time zone,
    carteira_comprovantevacina_updatedate timestamp without time zone,
    carteira_diploma_updateuserid uuid,
    carteira_crm_updateuserid uuid,
    carteira_cpf_updateuserid uuid,
    carteira_rg_updateuserid uuid,
    carteira_especializacaodiploma_updateuserid uuid,
    carteira_anuidadecrm_updateuserid uuid,
    carteira_eticoprofissional_updateuserid uuid,
    carteira_comprovanteresidencia_updateuserid uuid,
    carteira_foto_updateuserid uuid,
    carteira_comprovantevacina_updateuserid uuid
);


ALTER TABLE public.carteira_digital OWNER TO postgres;

--
-- Name: checkin_checkout; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.checkin_checkout (
    id smallint NOT NULL,
    vaga_id uuid,
    medico_id uuid,
    checkin timestamp without time zone NOT NULL,
    checkout timestamp without time zone,
    checkin_latitude numeric(10,8),
    checkin_longitude numeric(11,8),
    checkout_latitude numeric(10,8),
    checkout_longitude numeric(11,8),
    checkin_justificativa text,
    checkout_justificativa text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    updated_by uuid DEFAULT auth.uid()
);


ALTER TABLE public.checkin_checkout OWNER TO postgres;

--
-- Name: checkin_checkout_index_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.checkin_checkout ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.checkin_checkout_index_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: checkin_checkout_nofitications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.checkin_checkout_nofitications (
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    title text NOT NULL,
    body text NOT NULL,
    recipient_id uuid DEFAULT gen_random_uuid() NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    message_id text,
    read_at timestamp with time zone,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    route text,
    extra_data jsonb
);


ALTER TABLE public.checkin_checkout_nofitications OWNER TO postgres;

--
-- Name: clean_hospital; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clean_hospital (
    terms text,
    id smallint NOT NULL,
    CONSTRAINT clean_hospital_id_check CHECK ((id > 0))
);


ALTER TABLE public.clean_hospital OWNER TO postgres;

--
-- Name: clean_hospital_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.clean_hospital ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.clean_hospital_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: codigos_area; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.codigos_area (
    index smallint NOT NULL,
    pais text NOT NULL,
    codigo text,
    formato text,
    caracteres_max smallint,
    lista text
);


ALTER TABLE public.codigos_area OWNER TO postgres;

--
-- Name: email_verification_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.email_verification_tokens (
    id bigint NOT NULL,
    email text,
    token text,
    expires_at timestamp with time zone,
    verified boolean,
    created_at timestamp with time zone DEFAULT now(),
    firstname text,
    lastname text,
    phone text
);


ALTER TABLE public.email_verification_tokens OWNER TO postgres;

--
-- Name: email_verification_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.email_verification_tokens ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.email_verification_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: equipes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.equipes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nome text NOT NULL,
    grupo_id uuid NOT NULL,
    cor character varying(7) NOT NULL,
    updated_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.equipes OWNER TO postgres;

--
-- Name: equipes_medicos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.equipes_medicos (
    equipes_id uuid,
    medico_id uuid NOT NULL,
    grupo_id uuid NOT NULL,
    updated_by uuid,
    updated_at timestamp with time zone DEFAULT now(),
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    medico_precadastro_id uuid,
    CONSTRAINT chk_one_medico_type CHECK ((((medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid) AND (medico_precadastro_id IS NOT NULL)) OR ((medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid) AND (medico_precadastro_id IS NULL))))
);


ALTER TABLE public.equipes_medicos OWNER TO postgres;

--
-- Name: escalistas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.escalistas (
    auth_id uuid DEFAULT gen_random_uuid() NOT NULL,
    nome character varying NOT NULL,
    telefone character varying NOT NULL,
    email character varying,
    grupo_id uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    update_at timestamp with time zone DEFAULT (now() AT TIME ZONE 'utc'::text) NOT NULL,
    update_by uuid DEFAULT auth.uid(),
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE public.escalistas OWNER TO postgres;

--
-- Name: especialidades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.especialidades (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    nome character varying,
    index smallint
);


ALTER TABLE public.especialidades OWNER TO postgres;

--
-- Name: estados_brasil; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estados_brasil (
    id bigint NOT NULL,
    nome text,
    sigla text,
    lista text
);


ALTER TABLE public.estados_brasil OWNER TO postgres;

--
-- Name: formas_recebimento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.formas_recebimento (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    forma_recebimento text
);


ALTER TABLE public.formas_recebimento OWNER TO postgres;

--
-- Name: grades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grades (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    grupo_id uuid NOT NULL,
    nome character varying(255) NOT NULL,
    especialidade_id uuid,
    setor_id uuid,
    hospital_id uuid,
    cor character varying(7) NOT NULL,
    horario_inicial integer DEFAULT 7,
    configuracao jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    created_by uuid,
    updated_by uuid
);


ALTER TABLE public.grades OWNER TO postgres;

--
-- Name: grupos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grupos (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    nome character varying NOT NULL,
    responsavel character varying,
    telefone character varying,
    email character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.grupos OWNER TO postgres;

--
-- Name: hospitais; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hospitais (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    nome text NOT NULL,
    logradouro text NOT NULL,
    numero text NOT NULL,
    cidade text NOT NULL,
    bairro text NOT NULL,
    estado text NOT NULL,
    pais text NOT NULL,
    cep text NOT NULL,
    latitude numeric(10,6),
    longitude numeric(10,6),
    endereco_formatado text,
    avatar text DEFAULT ''::text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.hospitais OWNER TO postgres;

--
-- Name: hospital_geofencing; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hospital_geofencing (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    hospital_id uuid,
    latitude numeric(10,8) NOT NULL,
    longitude numeric(11,8) NOT NULL,
    raio_metros integer DEFAULT 100,
    ativo boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.hospital_geofencing OWNER TO postgres;

--
-- Name: medicos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medicos (
    id uuid DEFAULT auth.uid() NOT NULL,
    rqe text DEFAULT 'Não informado'::text,
    genero text,
    cpf text,
    rg text,
    crm text,
    nome_faculdade text,
    tipo_faculdade text,
    primeiro_nome text,
    sobrenome text,
    email text,
    telefone text,
    data_nascimento date,
    logradouro text,
    numero text,
    bairro text,
    cidade text,
    estado text,
    pais text,
    cep text,
    created_at timestamp without time zone DEFAULT now(),
    update_at timestamp with time zone,
    update_by text DEFAULT ''::text,
    delete_at timestamp without time zone,
    status text,
    total_plantoes integer DEFAULT 0,
    especialidade_id uuid DEFAULT '6404fc30-f292-4005-ae81-da1111a8822d'::uuid,
    ano_termino_especializacao integer,
    ano_formatura integer,
    tracking_privacy boolean,
    especialidade_nome text,
    razao_social text,
    cnpj text,
    banco_agencia text,
    banco_digito text,
    banco_conta text,
    banco_pix text,
    CONSTRAINT medicos_medico_cep_check CHECK ((cep ~ '^\d{5}-\d{3}$$'::text)),
    CONSTRAINT medicos_medico_status_check CHECK ((status = ANY (ARRAY['ativo'::text, 'inativo'::text, 'suspenso'::text])))
);


ALTER TABLE public.medicos OWNER TO postgres;

--
-- Name: medicos_favoritos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medicos_favoritos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    escalista_id uuid NOT NULL,
    medico_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    grupo_id uuid
);


ALTER TABLE public.medicos_favoritos OWNER TO postgres;

--
-- Name: medicos_precadastro; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.medicos_precadastro (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    primeiro_nome character varying(255) NOT NULL,
    sobrenome character varying(255) NOT NULL,
    crm character varying(50) NOT NULL,
    cpf character varying(14),
    email character varying(255),
    telefone character varying(20),
    especialidade_id uuid,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    estado text,
    razao_social text,
    cnpj text,
    banco_agencia text,
    banco_digito text,
    banco_conta text,
    banco_pix text
);


ALTER TABLE public.medicos_precadastro OWNER TO postgres;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    title text NOT NULL,
    body text NOT NULL,
    recipient_id uuid DEFAULT gen_random_uuid() NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    message_id text,
    read_at timestamp with time zone,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    route text,
    extra_data jsonb
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: pagamentos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pagamentos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    medico_id uuid,
    candidaturas_id uuid,
    valor integer NOT NULL,
    vagas_id uuid,
    medicos_id uuid
);


ALTER TABLE public.pagamentos OWNER TO postgres;

--
-- Name: periodos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.periodos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    nome text,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.periodos OWNER TO postgres;

--
-- Name: requisitos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.requisitos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nome text NOT NULL
);


ALTER TABLE public.requisitos OWNER TO postgres;

--
-- Name: setores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.setores (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    nome character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.setores OWNER TO postgres;

--
-- Name: tipos_vaga; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tipos_vaga (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    nome text,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tipos_vaga OWNER TO postgres;

--
-- Name: user_profile; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_profile (
    id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    role text DEFAULT 'signup'::text,
    profilepicture text,
    displayname text,
    gender text,
    areacode_index smallint DEFAULT '0'::smallint NOT NULL,
    uf_index smallint DEFAULT '0'::smallint NOT NULL,
    specialty_index smallint DEFAULT '0'::smallint NOT NULL,
    fcm_token text,
    platform text,
    apn_token text
);


ALTER TABLE public.user_profile OWNER TO postgres;

--
-- Name: vagas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vagas (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    hospital_id uuid DEFAULT gen_random_uuid() NOT NULL,
    data date,
    periodo_id uuid DEFAULT gen_random_uuid() NOT NULL,
    hora_inicio time without time zone NOT NULL,
    hora_fim time without time zone NOT NULL,
    valor integer NOT NULL,
    data_pagamento date NOT NULL,
    tipos_vaga_id uuid DEFAULT gen_random_uuid() NOT NULL,
    observacoes character varying,
    setor_id uuid DEFAULT gen_random_uuid() NOT NULL,
    escalista_id uuid DEFAULT 'ada3a79a-6437-4e27-9e22-40c08c36c59b'::uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now(),
    updated_by uuid DEFAULT 'ada3a79a-6437-4e27-9e22-40c08c36c59b'::uuid NOT NULL,
    deleted_at timestamp with time zone DEFAULT now(),
    status character varying,
    total_candidaturas integer DEFAULT 0,
    especialidade_id uuid DEFAULT gen_random_uuid() NOT NULL,
    grupo_id uuid DEFAULT '59f5120a-ac2a-4c5f-a7f3-b5083982b5c6'::uuid,
    index smallint NOT NULL,
    forma_recebimento_id uuid,
    recorrencia_id uuid,
    grade_id uuid,
    CONSTRAINT vagas_vagas_status_check CHECK (((status)::text = ANY (ARRAY[('aberta'::character varying)::text, ('fechada'::character varying)::text, ('cancelada'::character varying)::text, ('anunciada'::character varying)::text]))),
    CONSTRAINT vagas_vagas_valor_check CHECK (((valor)::numeric > (0)::numeric))
);


ALTER TABLE public.vagas OWNER TO postgres;

--
-- Name: vagas_Index_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.vagas ALTER COLUMN index ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."vagas_Index_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: vagas_beneficios; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vagas_beneficios (
    vaga_id uuid NOT NULL,
    beneficio_tipo_id uuid NOT NULL,
    id smallint NOT NULL
);


ALTER TABLE public.vagas_beneficios OWNER TO postgres;

--
-- Name: vagas_beneficio_Index_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.vagas_beneficios ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."vagas_beneficio_Index_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: vagas_recorrencias; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vagas_recorrencias (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    created_by uuid,
    data_inicio date NOT NULL,
    data_fim date NOT NULL,
    dias_semana integer[] NOT NULL,
    observacoes text
);


ALTER TABLE public.vagas_recorrencias OWNER TO postgres;

--
-- Name: vagas_requisitos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vagas_requisitos (
    vagas_id uuid DEFAULT gen_random_uuid() NOT NULL,
    requisito_tipo_id uuid NOT NULL
);


ALTER TABLE public.vagas_requisitos OWNER TO postgres;

--
-- Name: vagas_salvas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vagas_salvas (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    vagas_id uuid DEFAULT gen_random_uuid() NOT NULL,
    medico_id uuid DEFAULT auth.uid() NOT NULL
);


ALTER TABLE public.vagas_salvas OWNER TO postgres;

--
-- Name: vagas_salvas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.vagas_salvas ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.vagas_salvas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: vw_folha_pagamento; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_folha_pagamento AS
 SELECT v.id AS vagas_id,
    v.data AS vagas_data,
    p.nome AS periodo_nome,
    v.hora_inicio AS horario_inicio,
    v.hora_fim AS horario_fim,
    v.valor AS vagas_valor,
    v.data_pagamento AS vagas_datapagamento,
    fr.forma_recebimento,
    h.id AS hospital_id,
    h.nome AS hospital_nome,
    e.id AS especialidade_id,
    e.nome AS vagas_especialidade,
    s.id AS setor_id,
    s.nome AS setor_nome,
    c.id AS candidaturas_id,
    c.medico_id,
    c.medico_precadastro_id,
    c.status AS candidatura_status,
    c.data_confirmacao AS candidatos_dataconfirmacao,
    COALESCE(m.primeiro_nome, (mp.primeiro_nome)::text) AS medico_primeironome,
    COALESCE(m.sobrenome, (mp.sobrenome)::text) AS medico_sobrenome,
    COALESCE(m.cpf, (mp.cpf)::text) AS medico_cpf,
    COALESCE(m.crm, (mp.crm)::text) AS medico_crm,
    COALESCE(me.nome, mpe.nome) AS medico_especialidade,
    COALESCE(m.razao_social, mp.razao_social) AS razao_social,
    COALESCE(m.cnpj, mp.cnpj) AS cnpj,
    COALESCE(m.banco_agencia, mp.banco_agencia) AS banco_agencia,
    COALESCE(m.banco_digito, mp.banco_digito) AS banco_digito,
    COALESCE(m.banco_conta, mp.banco_conta) AS banco_conta,
    COALESCE(m.banco_pix, mp.banco_pix) AS banco_pix,
    cc.checkin,
    cc.checkout,
    cc.checkin_latitude,
    cc.checkin_longitude,
    cc.checkout_latitude,
    cc.checkout_longitude,
    cc.checkin_justificativa,
    cc.checkout_justificativa
   FROM (((((((((((public.vagas v
     JOIN public.candidaturas c ON ((c.vagas_id = v.id)))
     LEFT JOIN public.medicos m ON (((m.id = c.medico_id) AND (c.medico_precadastro_id IS NULL))))
     LEFT JOIN public.medicos_precadastro mp ON ((mp.id = c.medico_precadastro_id)))
     LEFT JOIN public.checkin_checkout cc ON (((cc.vaga_id = v.id) AND ((cc.medico_id = m.id) OR (cc.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid)))))
     LEFT JOIN public.hospitais h ON ((h.id = v.hospital_id)))
     LEFT JOIN public.especialidades e ON ((e.id = v.especialidade_id)))
     LEFT JOIN public.especialidades me ON ((me.id = m.especialidade_id)))
     LEFT JOIN public.especialidades mpe ON ((mpe.id = mp.especialidade_id)))
     LEFT JOIN public.setores s ON ((s.id = v.setor_id)))
     LEFT JOIN public.periodos p ON ((p.id = v.periodo_id)))
     LEFT JOIN public.formas_recebimento fr ON ((fr.id = v.forma_recebimento_id)))
  WHERE (((v.status)::text = 'fechada'::text) AND (c.status = 'APROVADO'::text));


ALTER VIEW public.vw_folha_pagamento OWNER TO postgres;

--
-- Name: vw_vagas_candidaturas; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vw_vagas_candidaturas AS
 SELECT row_number() OVER (ORDER BY combined_data.vagas_id, combined_data.effective_medico_id, combined_data.candidaturas_id) AS idx,
    combined_data.vagas_id,
    combined_data.vagas_data,
    combined_data.vagas_createdate,
    combined_data.vagas_status,
    combined_data.vagas_valor,
    combined_data.vagas_horainicio,
    combined_data.vagas_horafim,
    combined_data.vagas_datapagamento,
    combined_data.vagas_periodo,
    combined_data.vagas_periodo_nome,
    combined_data.vagas_tipo,
    combined_data.vagas_tipo_nome,
    combined_data.vagas_formarecebimento,
    combined_data.vagas_formarecebimento_nome,
    combined_data.vagas_observacoes,
    combined_data.hospital_id,
    combined_data.hospital_nome,
    combined_data.hospital_estado,
    combined_data.hospital_lat,
    combined_data.hospital_log,
    combined_data.hospital_end,
    combined_data.hospital_avatar,
    combined_data.especialidade_id,
    combined_data.especialidade_nome,
    combined_data.setor_id,
    combined_data.setor_nome,
    combined_data.escalista_id,
    combined_data.escalista_nome,
    combined_data.escalista_email,
    combined_data.escalista_telefone,
    combined_data.grupo_id,
    combined_data.grupo_nome,
    combined_data.candidaturas_id,
    combined_data.total_candidaturas,
    combined_data.candidatura_status,
    combined_data.candidatura_createdate,
    combined_data.candidatura_updateby,
    combined_data.candidatura_updatedat,
    combined_data.effective_medico_id AS medico_id,
    combined_data.medico_primeiro_nome,
    combined_data.medico_sobrenome,
    combined_data.medico_crm,
    combined_data.medico_cpf,
    combined_data.medico_estado,
    combined_data.medico_email,
    combined_data.medico_telefone,
    combined_data.medico_precadastro_id,
    combined_data.recorrencia_id,
    combined_data.vaga_salva,
    combined_data.medico_favorito,
    combined_data.checkin,
    combined_data.checkout,
    combined_data.pagamento_valor,
    combined_data.grade_id,
    combined_data.grade_nome,
    combined_data.grade_cor
   FROM ( SELECT DISTINCT v.id AS vagas_id,
            v.data AS vagas_data,
            v.created_at AS vagas_createdate,
            v.status AS vagas_status,
            v.valor AS vagas_valor,
            v.hora_inicio AS vagas_horainicio,
            v.hora_fim AS vagas_horafim,
            v.data_pagamento AS vagas_datapagamento,
            v.periodo_id AS vagas_periodo,
            p.nome AS vagas_periodo_nome,
            v.tipos_vaga_id AS vagas_tipo,
            t.nome AS vagas_tipo_nome,
            v.forma_recebimento_id AS vagas_formarecebimento,
            f.forma_recebimento AS vagas_formarecebimento_nome,
            v.observacoes AS vagas_observacoes,
            v.hospital_id,
            h.nome AS hospital_nome,
            h.estado AS hospital_estado,
            h.latitude AS hospital_lat,
            h.longitude AS hospital_log,
            h.endereco_formatado AS hospital_end,
            h.avatar AS hospital_avatar,
            v.especialidade_id,
            e.nome AS especialidade_nome,
            v.setor_id,
            s.nome AS setor_nome,
            v.escalista_id,
            esc.nome AS escalista_nome,
            esc.email AS escalista_email,
            esc.telefone AS escalista_telefone,
            v.grupo_id,
            g.nome AS grupo_nome,
            c.id AS candidaturas_id,
            public.count_candidaturas_total(v.id) AS total_candidaturas,
            c.status AS candidatura_status,
            c.created_at AS candidatura_createdate,
            c.updated_by AS candidatura_updateby,
            c.updated_at AS candidatura_updatedat,
                CASE
                    WHEN ((c.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid) AND (c.medico_precadastro_id IS NOT NULL)) THEN c.medico_precadastro_id
                    ELSE vm.medico_id
                END AS effective_medico_id,
            COALESCE(m.primeiro_nome, (mp.primeiro_nome)::text) AS medico_primeiro_nome,
            COALESCE(m.sobrenome, (mp.sobrenome)::text) AS medico_sobrenome,
            COALESCE(m.crm, (mp.crm)::text) AS medico_crm,
            COALESCE(m.cpf, (mp.cpf)::text) AS medico_cpf,
            COALESCE(m.estado, mp.estado) AS medico_estado,
            COALESCE(m.email, (mp.email)::text) AS medico_email,
            COALESCE(m.telefone, (mp.telefone)::text) AS medico_telefone,
            c.medico_precadastro_id,
            v.recorrencia_id,
                CASE
                    WHEN ((vs.medico_id IS NOT NULL) OR (vsp.medico_id IS NOT NULL)) THEN true
                    ELSE false
                END AS vaga_salva,
            public.current_user_is_favorito(v.grupo_id) AS medico_favorito,
            COALESCE(cc.checkin, ccp.checkin) AS checkin,
            COALESCE(cc.checkout, ccp.checkout) AS checkout,
            pg.valor AS pagamento_valor,
            v.grade_id,
            gr.nome AS grade_nome,
            gr.cor AS grade_cor
           FROM ((((((((((((((((((public.vagas v
             JOIN public.hospitais h ON ((v.hospital_id = h.id)))
             JOIN public.especialidades e ON ((v.especialidade_id = e.id)))
             JOIN public.setores s ON ((v.setor_id = s.id)))
             LEFT JOIN public.escalistas esc ON ((v.escalista_id = esc.id)))
             LEFT JOIN public.grupos g ON ((v.grupo_id = g.id)))
             LEFT JOIN public.periodos p ON ((v.periodo_id = p.id)))
             LEFT JOIN public.tipos_vaga t ON ((v.tipos_vaga_id = t.id)))
             LEFT JOIN public.formas_recebimento f ON ((v.forma_recebimento_id = f.id)))
             LEFT JOIN public.grades gr ON ((v.grade_id = gr.id)))
             LEFT JOIN ( SELECT candidaturas.vagas_id,
                    candidaturas.medico_id
                   FROM public.candidaturas
                  WHERE ((candidaturas.medico_id IS NOT NULL) AND (candidaturas.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid))
                UNION
                 SELECT candidaturas.vagas_id,
                    candidaturas.medico_precadastro_id AS medico_id
                   FROM public.candidaturas
                  WHERE ((candidaturas.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid) AND (candidaturas.medico_precadastro_id IS NOT NULL))
                UNION
                 SELECT vagas_salvas.vagas_id,
                    vagas_salvas.medico_id
                   FROM public.vagas_salvas
                  WHERE (vagas_salvas.medico_id IS NOT NULL)) vm ON ((vm.vagas_id = v.id)))
             LEFT JOIN public.candidaturas c ON (((c.vagas_id = v.id) AND (((c.medico_id = vm.medico_id) AND (c.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid)) OR ((c.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid) AND (c.medico_precadastro_id = vm.medico_id))))))
             LEFT JOIN public.medicos m ON (((c.medico_id = m.id) AND (c.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid))))
             LEFT JOIN public.medicos_precadastro mp ON ((c.medico_precadastro_id = mp.id)))
             LEFT JOIN public.vagas_salvas vs ON (((vs.vagas_id = v.id) AND (vs.medico_id = vm.medico_id))))
             LEFT JOIN public.vagas_salvas vsp ON (((vsp.vagas_id = v.id) AND (vsp.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid))))
             LEFT JOIN public.checkin_checkout cc ON (((cc.vaga_id = v.id) AND (cc.medico_id = vm.medico_id))))
             LEFT JOIN public.checkin_checkout ccp ON (((ccp.vaga_id = v.id) AND (ccp.medico_id =
                CASE
                    WHEN (c.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid) THEN c.medico_precadastro_id
                    ELSE vm.medico_id
                END))))
             LEFT JOIN public.pagamentos pg ON ((pg.candidaturas_id = c.id)))) combined_data;


ALTER VIEW public.vw_vagas_candidaturas OWNER TO postgres;

--
-- Name: whatsapp_number; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.whatsapp_number (
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    number text DEFAULT '5511969193194'::text
);


ALTER TABLE public.whatsapp_number OWNER TO postgres;

--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
)
PARTITION BY RANGE (inserted_at);


ALTER TABLE realtime.messages OWNER TO supabase_realtime_admin;

--
-- Name: messages_2025_10_13; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2025_10_13 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2025_10_13 OWNER TO supabase_admin;

--
-- Name: messages_2025_10_14; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2025_10_14 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2025_10_14 OWNER TO supabase_admin;

--
-- Name: messages_2025_10_15; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2025_10_15 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2025_10_15 OWNER TO supabase_admin;

--
-- Name: messages_2025_10_16; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2025_10_16 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2025_10_16 OWNER TO supabase_admin;

--
-- Name: messages_2025_10_17; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2025_10_17 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2025_10_17 OWNER TO supabase_admin;

--
-- Name: messages_2025_10_18; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2025_10_18 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2025_10_18 OWNER TO supabase_admin;

--
-- Name: messages_2025_10_19; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2025_10_19 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2025_10_19 OWNER TO supabase_admin;

--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE realtime.schema_migrations OWNER TO supabase_admin;

--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


ALTER TABLE realtime.subscription OWNER TO supabase_admin;

--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL
);


ALTER TABLE storage.buckets OWNER TO supabase_storage_admin;

--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets_analytics (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.buckets_analytics OWNER TO supabase_storage_admin;

--
-- Name: iceberg_namespaces; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.iceberg_namespaces (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.iceberg_namespaces OWNER TO supabase_storage_admin;

--
-- Name: iceberg_tables; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.iceberg_tables (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    namespace_id uuid NOT NULL,
    bucket_id text NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    location text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.iceberg_tables OWNER TO supabase_storage_admin;

--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE storage.migrations OWNER TO supabase_storage_admin;

--
-- Name: objects; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb,
    level integer
);


ALTER TABLE storage.objects OWNER TO supabase_storage_admin;

--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: prefixes; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.prefixes (
    bucket_id text NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    level integer GENERATED ALWAYS AS (storage.get_level(name)) STORED NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE storage.prefixes OWNER TO supabase_storage_admin;

--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb
);


ALTER TABLE storage.s3_multipart_uploads OWNER TO supabase_storage_admin;

--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.s3_multipart_uploads_parts OWNER TO supabase_storage_admin;

--
-- Name: hooks; Type: TABLE; Schema: supabase_functions; Owner: supabase_functions_admin
--

CREATE TABLE supabase_functions.hooks (
    id bigint NOT NULL,
    hook_table_id integer NOT NULL,
    hook_name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    request_id bigint
);


ALTER TABLE supabase_functions.hooks OWNER TO supabase_functions_admin;

--
-- Name: TABLE hooks; Type: COMMENT; Schema: supabase_functions; Owner: supabase_functions_admin
--

COMMENT ON TABLE supabase_functions.hooks IS 'Supabase Functions Hooks: Audit trail for triggered hooks.';


--
-- Name: hooks_id_seq; Type: SEQUENCE; Schema: supabase_functions; Owner: supabase_functions_admin
--

CREATE SEQUENCE supabase_functions.hooks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE supabase_functions.hooks_id_seq OWNER TO supabase_functions_admin;

--
-- Name: hooks_id_seq; Type: SEQUENCE OWNED BY; Schema: supabase_functions; Owner: supabase_functions_admin
--

ALTER SEQUENCE supabase_functions.hooks_id_seq OWNED BY supabase_functions.hooks.id;


--
-- Name: migrations; Type: TABLE; Schema: supabase_functions; Owner: supabase_functions_admin
--

CREATE TABLE supabase_functions.migrations (
    version text NOT NULL,
    inserted_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE supabase_functions.migrations OWNER TO supabase_functions_admin;

--
-- Name: schema_migrations; Type: TABLE; Schema: supabase_migrations; Owner: postgres
--

CREATE TABLE supabase_migrations.schema_migrations (
    version text NOT NULL,
    statements text[],
    name text
);


ALTER TABLE supabase_migrations.schema_migrations OWNER TO postgres;

--
-- Name: seed_files; Type: TABLE; Schema: supabase_migrations; Owner: postgres
--

CREATE TABLE supabase_migrations.seed_files (
    path text NOT NULL,
    hash text NOT NULL
);


ALTER TABLE supabase_migrations.seed_files OWNER TO postgres;

--
-- Name: messages_2025_10_13; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_10_13 FOR VALUES FROM ('2025-10-13 00:00:00') TO ('2025-10-14 00:00:00');


--
-- Name: messages_2025_10_14; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_10_14 FOR VALUES FROM ('2025-10-14 00:00:00') TO ('2025-10-15 00:00:00');


--
-- Name: messages_2025_10_15; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_10_15 FOR VALUES FROM ('2025-10-15 00:00:00') TO ('2025-10-16 00:00:00');


--
-- Name: messages_2025_10_16; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_10_16 FOR VALUES FROM ('2025-10-16 00:00:00') TO ('2025-10-17 00:00:00');


--
-- Name: messages_2025_10_17; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_10_17 FOR VALUES FROM ('2025-10-17 00:00:00') TO ('2025-10-18 00:00:00');


--
-- Name: messages_2025_10_18; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_10_18 FOR VALUES FROM ('2025-10-18 00:00:00') TO ('2025-10-19 00:00:00');


--
-- Name: messages_2025_10_19; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2025_10_19 FOR VALUES FROM ('2025-10-19 00:00:00') TO ('2025-10-20 00:00:00');


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Name: hooks id; Type: DEFAULT; Schema: supabase_functions; Owner: supabase_functions_admin
--

ALTER TABLE ONLY supabase_functions.hooks ALTER COLUMN id SET DEFAULT nextval('supabase_functions.hooks_id_seq'::regclass);


--
-- Name: extensions extensions_pkey; Type: CONSTRAINT; Schema: _realtime; Owner: supabase_admin
--

ALTER TABLE ONLY _realtime.extensions
    ADD CONSTRAINT extensions_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: _realtime; Owner: supabase_admin
--

ALTER TABLE ONLY _realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: _realtime; Owner: supabase_admin
--

ALTER TABLE ONLY _realtime.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_client_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_client_id_key UNIQUE (client_id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: tipos_vaga TipoVaga_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tipos_vaga
    ADD CONSTRAINT "TipoVaga_pkey" PRIMARY KEY (id);


--
-- Name: banner_mkt bannerMKT_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.banner_mkt
    ADD CONSTRAINT "bannerMKT_pkey" PRIMARY KEY (id);


--
-- Name: beneficios beneficio_tipo_beneficio_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.beneficios
    ADD CONSTRAINT beneficio_tipo_beneficio_id_key UNIQUE (id);


--
-- Name: beneficios beneficio_tipo_beneficio_nome_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.beneficios
    ADD CONSTRAINT beneficio_tipo_beneficio_nome_key UNIQUE (nome);


--
-- Name: beneficios beneficio_tipo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.beneficios
    ADD CONSTRAINT beneficio_tipo_pkey PRIMARY KEY (id);


--
-- Name: candidaturas candidaturas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.candidaturas
    ADD CONSTRAINT candidaturas_pkey PRIMARY KEY (id);


--
-- Name: carteira_digital carteira_digital_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carteira_digital
    ADD CONSTRAINT carteira_digital_pkey PRIMARY KEY (carteira_id);


--
-- Name: checkin_checkout checkin_checkout_index_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkin_checkout
    ADD CONSTRAINT checkin_checkout_index_key UNIQUE (id);


--
-- Name: checkin_checkout_nofitications checkin_checkout_nofitications_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkin_checkout_nofitications
    ADD CONSTRAINT checkin_checkout_nofitications_id_key UNIQUE (id);


--
-- Name: checkin_checkout_nofitications checkin_checkout_nofitications_message_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkin_checkout_nofitications
    ADD CONSTRAINT checkin_checkout_nofitications_message_id_key UNIQUE (message_id);


--
-- Name: checkin_checkout_nofitications checkin_checkout_nofitications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkin_checkout_nofitications
    ADD CONSTRAINT checkin_checkout_nofitications_pkey PRIMARY KEY (id);


--
-- Name: checkin_checkout checkin_checkout_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkin_checkout
    ADD CONSTRAINT checkin_checkout_pkey PRIMARY KEY (id);


--
-- Name: checkin_checkout checkin_checkout_vagas_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkin_checkout
    ADD CONSTRAINT checkin_checkout_vagas_id_key UNIQUE (vaga_id);


--
-- Name: clean_hospital clean_hospital_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clean_hospital
    ADD CONSTRAINT clean_hospital_id_key UNIQUE (id);


--
-- Name: clean_hospital clean_hospital_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clean_hospital
    ADD CONSTRAINT clean_hospital_pkey PRIMARY KEY (id);


--
-- Name: codigos_area codigosdearea_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.codigos_area
    ADD CONSTRAINT codigosdearea_pkey PRIMARY KEY (pais);


--
-- Name: email_verification_tokens email_verification_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_verification_tokens
    ADD CONSTRAINT email_verification_tokens_pkey PRIMARY KEY (id);


--
-- Name: equipes_medicos equipes_medicos_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipes_medicos
    ADD CONSTRAINT equipes_medicos_id_key UNIQUE (id);


--
-- Name: equipes_medicos equipes_medicos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipes_medicos
    ADD CONSTRAINT equipes_medicos_pkey PRIMARY KEY (id);


--
-- Name: equipes equipes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipes
    ADD CONSTRAINT equipes_pkey PRIMARY KEY (id);


--
-- Name: escalistas escalista_id-de-escalista_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.escalistas
    ADD CONSTRAINT "escalista_id-de-escalista_key" UNIQUE (id);


--
-- Name: escalistas escalista_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.escalistas
    ADD CONSTRAINT escalista_id_key UNIQUE (id);


--
-- Name: escalistas escalista_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.escalistas
    ADD CONSTRAINT escalista_pkey PRIMARY KEY (id);


--
-- Name: especialidades especialidades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.especialidades
    ADD CONSTRAINT especialidades_pkey PRIMARY KEY (id);


--
-- Name: estados_brasil estadosBrasil_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estados_brasil
    ADD CONSTRAINT "estadosBrasil_pkey" PRIMARY KEY (id);


--
-- Name: formas_recebimento formas_recebimento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.formas_recebimento
    ADD CONSTRAINT formas_recebimento_pkey PRIMARY KEY (id);


--
-- Name: grades grades_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_pkey PRIMARY KEY (id);


--
-- Name: grupos grupo_grupo_nome_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grupos
    ADD CONSTRAINT grupo_grupo_nome_key UNIQUE (nome);


--
-- Name: grupos grupo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grupos
    ADD CONSTRAINT grupo_pkey PRIMARY KEY (id);


--
-- Name: hospital_geofencing hospital_geofencing_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_geofencing
    ADD CONSTRAINT hospital_geofencing_pkey PRIMARY KEY (id);


--
-- Name: hospitais hospital_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospitais
    ADD CONSTRAINT hospital_pkey PRIMARY KEY (id);


--
-- Name: medicos_favoritos medicos_favoritos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos_favoritos
    ADD CONSTRAINT medicos_favoritos_pkey PRIMARY KEY (id);


--
-- Name: medicos medicos_medico_cpf_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos
    ADD CONSTRAINT medicos_medico_cpf_key UNIQUE (cpf);


--
-- Name: medicos medicos_medico_crm_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos
    ADD CONSTRAINT medicos_medico_crm_key UNIQUE (crm);


--
-- Name: medicos medicos_medico_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos
    ADD CONSTRAINT medicos_medico_email_key UNIQUE (email);


--
-- Name: medicos medicos_medico_rg_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos
    ADD CONSTRAINT medicos_medico_rg_key UNIQUE (rg);


--
-- Name: medicos medicos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos
    ADD CONSTRAINT medicos_pkey PRIMARY KEY (id);


--
-- Name: medicos_precadastro medicos_precadastro_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos_precadastro
    ADD CONSTRAINT medicos_precadastro_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_id_key UNIQUE (id);


--
-- Name: notifications notifications_notification_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_notification_id_key UNIQUE (message_id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: pagamentos pagamentos_candidaturas_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pagamentos
    ADD CONSTRAINT pagamentos_candidaturas_id_key UNIQUE (candidaturas_id);


--
-- Name: pagamentos pagamentos_medico_vaga_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pagamentos
    ADD CONSTRAINT pagamentos_medico_vaga_unique UNIQUE (medico_id, vagas_id);


--
-- Name: pagamentos pagamentos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pagamentos
    ADD CONSTRAINT pagamentos_pkey PRIMARY KEY (id);


--
-- Name: pagamentos pagamentos_vagas_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pagamentos
    ADD CONSTRAINT pagamentos_vagas_id_key UNIQUE (vagas_id);


--
-- Name: periodos periodo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.periodos
    ADD CONSTRAINT periodo_pkey PRIMARY KEY (id);


--
-- Name: requisitos requisito_tipo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.requisitos
    ADD CONSTRAINT requisito_tipo_pkey PRIMARY KEY (id);


--
-- Name: setores setores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.setores
    ADD CONSTRAINT setores_pkey PRIMARY KEY (id);


--
-- Name: medicos_favoritos unique_escalista_medico; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos_favoritos
    ADD CONSTRAINT unique_escalista_medico UNIQUE (escalista_id, medico_id);


--
-- Name: user_profile user_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profile
    ADD CONSTRAINT user_profile_pkey PRIMARY KEY (id);


--
-- Name: vagas vagas_Index_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas
    ADD CONSTRAINT "vagas_Index_key" UNIQUE (index);


--
-- Name: vagas_beneficios vagas_beneficio_Index_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas_beneficios
    ADD CONSTRAINT "vagas_beneficio_Index_key" UNIQUE (id);


--
-- Name: vagas_beneficios vagas_beneficio_index_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas_beneficios
    ADD CONSTRAINT vagas_beneficio_index_key UNIQUE (id);


--
-- Name: vagas_beneficios vagas_beneficio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas_beneficios
    ADD CONSTRAINT vagas_beneficio_pkey PRIMARY KEY (id);


--
-- Name: vagas vagas_index_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas
    ADD CONSTRAINT vagas_index_key UNIQUE (index);


--
-- Name: vagas vagas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas
    ADD CONSTRAINT vagas_pkey PRIMARY KEY (id);


--
-- Name: vagas_recorrencias vagas_recorrencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas_recorrencias
    ADD CONSTRAINT vagas_recorrencia_pkey PRIMARY KEY (id);


--
-- Name: vagas_salvas vagas_salvas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas_salvas
    ADD CONSTRAINT vagas_salvas_pkey PRIMARY KEY (id);


--
-- Name: whatsapp_number whatsappnumber_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.whatsapp_number
    ADD CONSTRAINT whatsappnumber_pkey PRIMARY KEY (updated_at);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_10_13 messages_2025_10_13_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2025_10_13
    ADD CONSTRAINT messages_2025_10_13_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_10_14 messages_2025_10_14_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2025_10_14
    ADD CONSTRAINT messages_2025_10_14_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_10_15 messages_2025_10_15_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2025_10_15
    ADD CONSTRAINT messages_2025_10_15_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_10_16 messages_2025_10_16_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2025_10_16
    ADD CONSTRAINT messages_2025_10_16_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_10_17 messages_2025_10_17_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2025_10_17
    ADD CONSTRAINT messages_2025_10_17_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_10_18 messages_2025_10_18_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2025_10_18
    ADD CONSTRAINT messages_2025_10_18_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: messages_2025_10_19 messages_2025_10_19_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2025_10_19
    ADD CONSTRAINT messages_2025_10_19_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: iceberg_namespaces iceberg_namespaces_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.iceberg_namespaces
    ADD CONSTRAINT iceberg_namespaces_pkey PRIMARY KEY (id);


--
-- Name: iceberg_tables iceberg_tables_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.iceberg_tables
    ADD CONSTRAINT iceberg_tables_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: prefixes prefixes_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT prefixes_pkey PRIMARY KEY (bucket_id, level, name);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: hooks hooks_pkey; Type: CONSTRAINT; Schema: supabase_functions; Owner: supabase_functions_admin
--

ALTER TABLE ONLY supabase_functions.hooks
    ADD CONSTRAINT hooks_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: supabase_functions; Owner: supabase_functions_admin
--

ALTER TABLE ONLY supabase_functions.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (version);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: postgres
--

ALTER TABLE ONLY supabase_migrations.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: seed_files seed_files_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: postgres
--

ALTER TABLE ONLY supabase_migrations.seed_files
    ADD CONSTRAINT seed_files_pkey PRIMARY KEY (path);


--
-- Name: extensions_tenant_external_id_index; Type: INDEX; Schema: _realtime; Owner: supabase_admin
--

CREATE INDEX extensions_tenant_external_id_index ON _realtime.extensions USING btree (tenant_external_id);


--
-- Name: extensions_tenant_external_id_type_index; Type: INDEX; Schema: _realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX extensions_tenant_external_id_type_index ON _realtime.extensions USING btree (tenant_external_id, type);


--
-- Name: tenants_external_id_index; Type: INDEX; Schema: _realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX tenants_external_id_index ON _realtime.tenants USING btree (external_id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: oauth_clients_client_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_clients_client_id_idx ON auth.oauth_clients USING btree (client_id);


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: idx_beneficio_nome; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_beneficio_nome ON public.beneficios USING btree (nome);


--
-- Name: idx_candidatura_medico; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_candidatura_medico ON public.candidaturas USING btree (medico_id);


--
-- Name: idx_candidatura_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_candidatura_status ON public.candidaturas USING btree (vagas_id, status);


--
-- Name: idx_candidatura_vaga; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_candidatura_vaga ON public.candidaturas USING btree (vagas_id);


--
-- Name: idx_candidaturas_medico_precadastro_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_candidaturas_medico_precadastro_id ON public.candidaturas USING btree (medico_precadastro_id);


--
-- Name: idx_candidaturas_medico_vaga; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_candidaturas_medico_vaga ON public.candidaturas USING btree (medico_id, vagas_id);


--
-- Name: idx_candidaturas_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_candidaturas_status ON public.candidaturas USING btree (status);


--
-- Name: idx_carteira_medico; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_carteira_medico ON public.carteira_digital USING btree (medico_id);


--
-- Name: idx_escalista_grupo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_escalista_grupo ON public.escalistas USING btree (grupo_id);


--
-- Name: idx_escalista_nome; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_escalista_nome ON public.escalistas USING btree (nome);


--
-- Name: idx_grades_configuracao; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_grades_configuracao ON public.grades USING gin (configuracao);


--
-- Name: idx_grades_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_grades_created_by ON public.grades USING btree (created_by);


--
-- Name: idx_grades_especialidade_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_grades_especialidade_id ON public.grades USING btree (especialidade_id);


--
-- Name: idx_grades_grupo_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_grades_grupo_id ON public.grades USING btree (grupo_id);


--
-- Name: idx_grades_hospital_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_grades_hospital_id ON public.grades USING btree (hospital_id);


--
-- Name: idx_grades_setor_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_grades_setor_id ON public.grades USING btree (setor_id);


--
-- Name: idx_grupo_nome; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_grupo_nome ON public.grupos USING btree (nome);


--
-- Name: idx_hospital_nome; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_hospital_nome ON public.hospitais USING btree (nome);


--
-- Name: idx_medico_cpf; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medico_cpf ON public.medicos USING btree (cpf);


--
-- Name: idx_medico_crm; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medico_crm ON public.medicos USING btree (crm);


--
-- Name: idx_medico_localidade; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medico_localidade ON public.medicos USING btree (cidade, estado);


--
-- Name: idx_medico_nome; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medico_nome ON public.medicos USING btree (primeiro_nome, sobrenome);


--
-- Name: idx_medicos_cpf; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medicos_cpf ON public.medicos USING btree (cpf);


--
-- Name: idx_medicos_crm; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medicos_crm ON public.medicos USING btree (crm);


--
-- Name: idx_medicos_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medicos_email ON public.medicos USING btree (email);


--
-- Name: idx_medicos_especialidade; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medicos_especialidade ON public.medicos USING btree (especialidade_id);


--
-- Name: idx_medicos_favoritos_escalista; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medicos_favoritos_escalista ON public.medicos_favoritos USING btree (escalista_id);


--
-- Name: idx_medicos_favoritos_medico; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medicos_favoritos_medico ON public.medicos_favoritos USING btree (medico_id);


--
-- Name: idx_medicos_precadastro_cpf; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medicos_precadastro_cpf ON public.medicos_precadastro USING btree (cpf);


--
-- Name: idx_medicos_precadastro_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medicos_precadastro_created_by ON public.medicos_precadastro USING btree (created_by);


--
-- Name: idx_medicos_precadastro_crm; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medicos_precadastro_crm ON public.medicos_precadastro USING btree (crm);


--
-- Name: idx_medicos_precadastro_nome; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medicos_precadastro_nome ON public.medicos_precadastro USING btree (primeiro_nome, sobrenome);


--
-- Name: idx_medicos_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_medicos_status ON public.medicos USING btree (status);


--
-- Name: idx_setor_nome; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_setor_nome ON public.setores USING btree (nome);


--
-- Name: idx_vaga_escalista; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vaga_escalista ON public.vagas USING btree (escalista_id);


--
-- Name: idx_vaga_hospital; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vaga_hospital ON public.vagas USING btree (hospital_id);


--
-- Name: idx_vaga_periodo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vaga_periodo ON public.vagas USING btree (data, periodo_id);


--
-- Name: idx_vaga_setor; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vaga_setor ON public.vagas USING btree (setor_id);


--
-- Name: idx_vagas_data; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vagas_data ON public.vagas USING btree (data);


--
-- Name: idx_vagas_especialidade; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vagas_especialidade ON public.vagas USING btree (especialidade_id);


--
-- Name: idx_vagas_grade_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vagas_grade_id ON public.vagas USING btree (grade_id);


--
-- Name: idx_vagas_hospital; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vagas_hospital ON public.vagas USING btree (hospital_id);


--
-- Name: idx_vagas_recorrencia_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vagas_recorrencia_id ON public.vagas USING btree (recorrencia_id);


--
-- Name: idx_vagas_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_vagas_status ON public.vagas USING btree (status);


--
-- Name: unique_equipe_medico_precadastro; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unique_equipe_medico_precadastro ON public.equipes_medicos USING btree (equipes_id, medico_precadastro_id) WHERE (medico_precadastro_id IS NOT NULL);


--
-- Name: unique_equipe_medico_real; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unique_equipe_medico_real ON public.equipes_medicos USING btree (equipes_id, medico_id) WHERE (medico_precadastro_id IS NULL);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2025_10_13_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2025_10_13_inserted_at_topic_idx ON realtime.messages_2025_10_13 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2025_10_14_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2025_10_14_inserted_at_topic_idx ON realtime.messages_2025_10_14 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2025_10_15_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2025_10_15_inserted_at_topic_idx ON realtime.messages_2025_10_15 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2025_10_16_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2025_10_16_inserted_at_topic_idx ON realtime.messages_2025_10_16 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2025_10_17_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2025_10_17_inserted_at_topic_idx ON realtime.messages_2025_10_17 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2025_10_18_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2025_10_18_inserted_at_topic_idx ON realtime.messages_2025_10_18 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: messages_2025_10_19_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2025_10_19_inserted_at_topic_idx ON realtime.messages_2025_10_19 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: idx_iceberg_namespaces_bucket_id; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX idx_iceberg_namespaces_bucket_id ON storage.iceberg_namespaces USING btree (bucket_id, name);


--
-- Name: idx_iceberg_tables_namespace_id; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX idx_iceberg_tables_namespace_id ON storage.iceberg_tables USING btree (namespace_id, name);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_name_bucket_level_unique; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX idx_name_bucket_level_unique ON storage.objects USING btree (name COLLATE "C", bucket_id, level);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: idx_objects_lower_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_lower_name ON storage.objects USING btree ((path_tokens[level]), lower(name) text_pattern_ops, bucket_id, level);


--
-- Name: idx_prefixes_lower_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_prefixes_lower_name ON storage.prefixes USING btree (bucket_id, level, ((string_to_array(name, '/'::text))[level]), lower(name) text_pattern_ops);


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: objects_bucket_id_level_idx; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX objects_bucket_id_level_idx ON storage.objects USING btree (bucket_id, level, name COLLATE "C");


--
-- Name: supabase_functions_hooks_h_table_id_h_name_idx; Type: INDEX; Schema: supabase_functions; Owner: supabase_functions_admin
--

CREATE INDEX supabase_functions_hooks_h_table_id_h_name_idx ON supabase_functions.hooks USING btree (hook_table_id, hook_name);


--
-- Name: supabase_functions_hooks_request_id_idx; Type: INDEX; Schema: supabase_functions; Owner: supabase_functions_admin
--

CREATE INDEX supabase_functions_hooks_request_id_idx ON supabase_functions.hooks USING btree (request_id);


--
-- Name: messages_2025_10_13_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2025_10_13_inserted_at_topic_idx;


--
-- Name: messages_2025_10_13_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_10_13_pkey;


--
-- Name: messages_2025_10_14_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2025_10_14_inserted_at_topic_idx;


--
-- Name: messages_2025_10_14_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_10_14_pkey;


--
-- Name: messages_2025_10_15_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2025_10_15_inserted_at_topic_idx;


--
-- Name: messages_2025_10_15_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_10_15_pkey;


--
-- Name: messages_2025_10_16_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2025_10_16_inserted_at_topic_idx;


--
-- Name: messages_2025_10_16_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_10_16_pkey;


--
-- Name: messages_2025_10_17_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2025_10_17_inserted_at_topic_idx;


--
-- Name: messages_2025_10_17_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_10_17_pkey;


--
-- Name: messages_2025_10_18_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2025_10_18_inserted_at_topic_idx;


--
-- Name: messages_2025_10_18_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_10_18_pkey;


--
-- Name: messages_2025_10_19_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2025_10_19_inserted_at_topic_idx;


--
-- Name: messages_2025_10_19_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2025_10_19_pkey;


--
-- Name: candidaturas candidaturas_1_verificar_conflito_horario; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER candidaturas_1_verificar_conflito_horario BEFORE INSERT ON public.candidaturas FOR EACH ROW EXECUTE FUNCTION public.verificar_conflito_antes_candidatura();


--
-- Name: candidaturas candidaturas_2_auto_aprovar_favoritos; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER candidaturas_2_auto_aprovar_favoritos BEFORE INSERT ON public.candidaturas FOR EACH ROW EXECUTE FUNCTION public.aprovacao_automatica_favoritos();


--
-- Name: candidaturas candidaturas_3_atualizar_contador_vagas; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER candidaturas_3_atualizar_contador_vagas AFTER INSERT OR DELETE ON public.candidaturas FOR EACH ROW EXECUTE FUNCTION public.update_total_candidaturas();


--
-- Name: candidaturas candidaturas_4_fechar_vaga_ao_aprovar; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER candidaturas_4_fechar_vaga_ao_aprovar AFTER UPDATE ON public.candidaturas FOR EACH ROW WHEN ((new.status = 'APROVADO'::text)) EXECUTE FUNCTION public.atualizar_vagas_status();


--
-- Name: candidaturas candidaturas_5_contar_plantoes_medico; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER candidaturas_5_contar_plantoes_medico AFTER UPDATE ON public.candidaturas FOR EACH ROW WHEN ((old.status IS DISTINCT FROM new.status)) EXECUTE FUNCTION public.update_total_plantoes_medico();


--
-- Name: checkin_checkout checkin_checkout_1_validar_timing; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER checkin_checkout_1_validar_timing BEFORE INSERT ON public.checkin_checkout FOR EACH ROW EXECUTE FUNCTION public.validate_checkin_timing();


--
-- Name: checkin_checkout checkin_checkout_2_validar_timing; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER checkin_checkout_2_validar_timing BEFORE UPDATE ON public.checkin_checkout FOR EACH ROW EXECUTE FUNCTION public.validate_checkout_timing();


--
-- Name: medicos especialidades_1_setar_coluna_nome; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER especialidades_1_setar_coluna_nome BEFORE INSERT OR UPDATE ON public.medicos FOR EACH ROW EXECUTE FUNCTION public.update_especialidade_nome();


--
-- Name: medicos medicos_1_cleanup_precadastro; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER medicos_1_cleanup_precadastro AFTER INSERT ON public.medicos FOR EACH ROW EXECUTE FUNCTION public.cleanup_medicos_precadastro();


--
-- Name: grades trigger_grades_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_grades_updated_at BEFORE UPDATE ON public.grades FOR EACH ROW EXECUTE FUNCTION public.handle_grades_updated_at();


--
-- Name: vagas vagas_1_reprovar_candidaturas_ao_cancelar; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER vagas_1_reprovar_candidaturas_ao_cancelar AFTER UPDATE OF status ON public.vagas FOR EACH ROW EXECUTE FUNCTION public.atualizar_candidaturas_vaga_cancelada();


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: supabase_admin
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- Name: objects objects_delete_cleanup; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_delete_cleanup AFTER DELETE ON storage.objects REFERENCING OLD TABLE AS deleted FOR EACH STATEMENT EXECUTE FUNCTION storage.objects_delete_cleanup();


--
-- Name: objects objects_insert_create_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_insert_create_prefix BEFORE INSERT ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.objects_insert_prefix_trigger();


--
-- Name: objects objects_update_cleanup; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_update_cleanup AFTER UPDATE ON storage.objects REFERENCING OLD TABLE AS old_rows NEW TABLE AS new_rows FOR EACH STATEMENT EXECUTE FUNCTION storage.objects_update_cleanup();


--
-- Name: prefixes prefixes_create_hierarchy; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER prefixes_create_hierarchy BEFORE INSERT ON storage.prefixes FOR EACH ROW WHEN ((pg_trigger_depth() < 1)) EXECUTE FUNCTION storage.prefixes_insert_trigger();


--
-- Name: prefixes prefixes_delete_cleanup; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER prefixes_delete_cleanup AFTER DELETE ON storage.prefixes REFERENCING OLD TABLE AS deleted FOR EACH STATEMENT EXECUTE FUNCTION storage.prefixes_delete_cleanup();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: extensions extensions_tenant_external_id_fkey; Type: FK CONSTRAINT; Schema: _realtime; Owner: supabase_admin
--

ALTER TABLE ONLY _realtime.extensions
    ADD CONSTRAINT extensions_tenant_external_id_fkey FOREIGN KEY (tenant_external_id) REFERENCES _realtime.tenants(external_id) ON DELETE CASCADE;


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: candidaturas candidaturas_medico_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.candidaturas
    ADD CONSTRAINT candidaturas_medico_id_fkey FOREIGN KEY (medico_id) REFERENCES public.medicos(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: candidaturas candidaturas_vagas_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.candidaturas
    ADD CONSTRAINT candidaturas_vagas_id_fkey FOREIGN KEY (vagas_id) REFERENCES public.vagas(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: carteira_digital carteira_digital_medico_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.carteira_digital
    ADD CONSTRAINT carteira_digital_medico_id_fkey FOREIGN KEY (medico_id) REFERENCES public.medicos(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: checkin_checkout checkin_checkout_medico_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkin_checkout
    ADD CONSTRAINT checkin_checkout_medico_id_fkey FOREIGN KEY (medico_id) REFERENCES public.medicos(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: checkin_checkout_nofitications checkin_checkout_nofitications_recipient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkin_checkout_nofitications
    ADD CONSTRAINT checkin_checkout_nofitications_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES public.user_profile(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: checkin_checkout checkin_checkout_vagas_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.checkin_checkout
    ADD CONSTRAINT checkin_checkout_vagas_id_fkey FOREIGN KEY (vaga_id) REFERENCES public.vagas(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: equipes_medicos equipes_medicos_equipes_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipes_medicos
    ADD CONSTRAINT equipes_medicos_equipes_id_fkey FOREIGN KEY (equipes_id) REFERENCES public.equipes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: equipes_medicos equipes_medicos_grupo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipes_medicos
    ADD CONSTRAINT equipes_medicos_grupo_id_fkey FOREIGN KEY (grupo_id) REFERENCES public.grupos(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: escalistas escalista_escalista_auth_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.escalistas
    ADD CONSTRAINT escalista_escalista_auth_id_fkey FOREIGN KEY (auth_id) REFERENCES public.user_profile(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: escalistas escalista_grupo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.escalistas
    ADD CONSTRAINT escalista_grupo_id_fkey FOREIGN KEY (grupo_id) REFERENCES public.grupos(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: equipes fk_grupo_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipes
    ADD CONSTRAINT fk_grupo_id FOREIGN KEY (grupo_id) REFERENCES public.grupos(id) ON DELETE CASCADE;


--
-- Name: equipes_medicos fk_medico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipes_medicos
    ADD CONSTRAINT fk_medico FOREIGN KEY (medico_id) REFERENCES public.medicos(id);


--
-- Name: equipes_medicos fk_medico_precadastro; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.equipes_medicos
    ADD CONSTRAINT fk_medico_precadastro FOREIGN KEY (medico_precadastro_id) REFERENCES public.medicos_precadastro(id);


--
-- Name: candidaturas fk_medico_precadastro_candidaturas; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.candidaturas
    ADD CONSTRAINT fk_medico_precadastro_candidaturas FOREIGN KEY (medico_precadastro_id) REFERENCES public.medicos_precadastro(id);


--
-- Name: medicos_favoritos fk_medicos_favoritos_escalista; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos_favoritos
    ADD CONSTRAINT fk_medicos_favoritos_escalista FOREIGN KEY (escalista_id) REFERENCES public.escalistas(id) ON DELETE CASCADE;


--
-- Name: medicos_favoritos fk_medicos_favoritos_medico; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos_favoritos
    ADD CONSTRAINT fk_medicos_favoritos_medico FOREIGN KEY (medico_id) REFERENCES public.medicos(id) ON DELETE CASCADE;


--
-- Name: vagas fk_vagas_grade; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas
    ADD CONSTRAINT fk_vagas_grade FOREIGN KEY (grade_id) REFERENCES public.grades(id) ON DELETE SET NULL;


--
-- Name: grades grades_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id);


--
-- Name: grades grades_especialidade_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_especialidade_id_fkey FOREIGN KEY (especialidade_id) REFERENCES public.especialidades(id) ON DELETE RESTRICT;


--
-- Name: grades grades_grupo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_grupo_id_fkey FOREIGN KEY (grupo_id) REFERENCES public.grupos(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: grades grades_hospital_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospitais(id) ON DELETE RESTRICT;


--
-- Name: grades grades_setor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_setor_id_fkey FOREIGN KEY (setor_id) REFERENCES public.setores(id) ON DELETE RESTRICT;


--
-- Name: grades grades_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grades
    ADD CONSTRAINT grades_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
-- Name: hospital_geofencing hospital_geofencing_hospital_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospital_geofencing
    ADD CONSTRAINT hospital_geofencing_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospitais(id) ON DELETE CASCADE;


--
-- Name: medicos_favoritos medicos_favoritos_grupo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos_favoritos
    ADD CONSTRAINT medicos_favoritos_grupo_id_fkey FOREIGN KEY (grupo_id) REFERENCES public.grupos(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: medicos medicos_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos
    ADD CONSTRAINT medicos_id_fkey FOREIGN KEY (id) REFERENCES public.user_profile(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: medicos medicos_medico_especialidade_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos
    ADD CONSTRAINT medicos_medico_especialidade_fkey FOREIGN KEY (especialidade_id) REFERENCES public.especialidades(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: medicos_precadastro medicos_precadastro_medico_especialidade_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.medicos_precadastro
    ADD CONSTRAINT medicos_precadastro_medico_especialidade_fkey FOREIGN KEY (especialidade_id) REFERENCES public.especialidades(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (recipient_id) REFERENCES public.user_profile(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pagamentos pagamentos_candidaturas_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pagamentos
    ADD CONSTRAINT pagamentos_candidaturas_id_fkey FOREIGN KEY (candidaturas_id) REFERENCES public.candidaturas(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pagamentos pagamentos_medico_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pagamentos
    ADD CONSTRAINT pagamentos_medico_id_fkey FOREIGN KEY (medico_id) REFERENCES public.medicos(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pagamentos pagamentos_medicos_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pagamentos
    ADD CONSTRAINT pagamentos_medicos_id_fkey FOREIGN KEY (medicos_id) REFERENCES public.medicos(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: pagamentos pagamentos_vagas_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pagamentos
    ADD CONSTRAINT pagamentos_vagas_id_fkey FOREIGN KEY (vagas_id) REFERENCES public.vagas(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_profile user_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_profile
    ADD CONSTRAINT user_profile_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: vagas_beneficios vagas_beneficio_beneficio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas_beneficios
    ADD CONSTRAINT vagas_beneficio_beneficio_id_fkey FOREIGN KEY (beneficio_tipo_id) REFERENCES public.beneficios(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: vagas_beneficios vagas_beneficio_vaga_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas_beneficios
    ADD CONSTRAINT vagas_beneficio_vaga_id_fkey FOREIGN KEY (vaga_id) REFERENCES public.vagas(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: vagas vagas_formarecebimento_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas
    ADD CONSTRAINT vagas_formarecebimento_fkey FOREIGN KEY (forma_recebimento_id) REFERENCES public.formas_recebimento(id);


--
-- Name: vagas vagas_grupo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas
    ADD CONSTRAINT vagas_grupo_id_fkey FOREIGN KEY (grupo_id) REFERENCES public.grupos(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: vagas vagas_recorrencia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas
    ADD CONSTRAINT vagas_recorrencia_id_fkey FOREIGN KEY (recorrencia_id) REFERENCES public.vagas_recorrencias(id);


--
-- Name: vagas_requisitos vagas_requisito_requisito_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas_requisitos
    ADD CONSTRAINT vagas_requisito_requisito_id_fkey FOREIGN KEY (requisito_tipo_id) REFERENCES public.requisitos(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: vagas_requisitos vagas_requisito_vagas_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas_requisitos
    ADD CONSTRAINT vagas_requisito_vagas_id_fkey FOREIGN KEY (vagas_id) REFERENCES public.vagas(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: vagas_salvas vagas_salvas_medico_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas_salvas
    ADD CONSTRAINT vagas_salvas_medico_id_fkey FOREIGN KEY (medico_id) REFERENCES public.medicos(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: vagas_salvas vagas_salvas_vagas_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas_salvas
    ADD CONSTRAINT vagas_salvas_vagas_id_fkey FOREIGN KEY (vagas_id) REFERENCES public.vagas(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: vagas vagas_vaga_especialidade_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas
    ADD CONSTRAINT vagas_vaga_especialidade_fkey FOREIGN KEY (especialidade_id) REFERENCES public.especialidades(id);


--
-- Name: vagas vagas_vagas_escalista_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas
    ADD CONSTRAINT vagas_vagas_escalista_fkey FOREIGN KEY (escalista_id) REFERENCES public.escalistas(id) ON UPDATE CASCADE ON DELETE SET DEFAULT;


--
-- Name: vagas vagas_vagas_hospital_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas
    ADD CONSTRAINT vagas_vagas_hospital_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospitais(id);


--
-- Name: vagas vagas_vagas_periodo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas
    ADD CONSTRAINT vagas_vagas_periodo_fkey FOREIGN KEY (periodo_id) REFERENCES public.periodos(id);


--
-- Name: vagas vagas_vagas_setor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas
    ADD CONSTRAINT vagas_vagas_setor_fkey FOREIGN KEY (setor_id) REFERENCES public.setores(id);


--
-- Name: vagas vagas_vagas_tipo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vagas
    ADD CONSTRAINT vagas_vagas_tipo_fkey FOREIGN KEY (tipos_vaga_id) REFERENCES public.tipos_vaga(id);


--
-- Name: iceberg_namespaces iceberg_namespaces_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.iceberg_namespaces
    ADD CONSTRAINT iceberg_namespaces_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_analytics(id) ON DELETE CASCADE;


--
-- Name: iceberg_tables iceberg_tables_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.iceberg_tables
    ADD CONSTRAINT iceberg_tables_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_analytics(id) ON DELETE CASCADE;


--
-- Name: iceberg_tables iceberg_tables_namespace_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.iceberg_tables
    ADD CONSTRAINT iceberg_tables_namespace_id_fkey FOREIGN KEY (namespace_id) REFERENCES storage.iceberg_namespaces(id) ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: prefixes prefixes_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT "prefixes_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: carteira_digital Apenas usuários autorizados podem aprovar documentos; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Apenas usuários autorizados podem aprovar documentos" ON public.carteira_digital FOR UPDATE TO authenticated USING (true) WITH CHECK (true);


--
-- Name: equipes Delete policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Delete policy" ON public.equipes FOR DELETE TO authenticated USING ((grupo_id = public.get_current_user_grupo_id()));


--
-- Name: equipes_medicos Delete policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Delete policy" ON public.equipes_medicos FOR DELETE TO authenticated USING ((grupo_id = public.get_current_user_grupo_id()));


--
-- Name: carteira_digital Documentos visíveis para usuários autenticados; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Documentos visíveis para usuários autenticados" ON public.carteira_digital FOR SELECT TO authenticated USING (true);


--
-- Name: clean_hospital Enable access to authenticated users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable access to authenticated users" ON public.clean_hospital FOR SELECT TO authenticated USING (true);


--
-- Name: setores Enable authenticated users to read all data; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable authenticated users to read all data" ON public.setores FOR SELECT TO authenticated USING (true);


--
-- Name: medicos Enable escalista and astronauta users update medicos data; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable escalista and astronauta users update medicos data" ON public.medicos FOR UPDATE TO authenticated USING (( SELECT (EXISTS ( SELECT 1
           FROM public.user_profile
          WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = ANY (ARRAY['escalista'::text, 'astronauta'::text]))))) AS "exists"));


--
-- Name: medicos Enable escalista users read all data; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable escalista users read all data" ON public.medicos FOR SELECT TO authenticated USING (( SELECT (auth.uid() IN ( SELECT escalistas.auth_id AS escalista_id
           FROM public.escalistas))));


--
-- Name: escalistas Enable full access to astronauta user; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable full access to astronauta user" ON public.escalistas TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text)))));


--
-- Name: vagas_beneficios Enable full access to astronauta users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable full access to astronauta users" ON public.vagas_beneficios TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text)))));


--
-- Name: vagas_recorrencias Enable full access to astronauta users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable full access to astronauta users" ON public.vagas_recorrencias TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text)))));


--
-- Name: vagas_requisitos Enable full access to astronauta users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable full access to astronauta users" ON public.vagas_requisitos TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text)))));


--
-- Name: grupos Enable full acess to astronauta user; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable full acess to astronauta user" ON public.grupos TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text)))));


--
-- Name: hospitais Enable full acess to astronauta users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable full acess to astronauta users" ON public.hospitais TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text)))));


--
-- Name: hospitais Enable insert to escalista users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert to escalista users" ON public.hospitais FOR INSERT TO authenticated WITH CHECK ((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'escalista'::text)))));


--
-- Name: pagamentos Enable medico user full access to their own data; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable medico user full access to their own data" ON public.pagamentos TO authenticated USING (((auth.uid() = medico_id) OR (auth.uid() = medicos_id))) WITH CHECK (((auth.uid() = medico_id) OR (auth.uid() = medicos_id)));


--
-- Name: checkin_checkout Enable medico users full access to their own data; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable medico users full access to their own data" ON public.checkin_checkout TO authenticated USING ((medico_id = ( SELECT medicos.id
   FROM public.medicos
  WHERE (medicos.id = auth.uid())))) WITH CHECK ((medico_id = ( SELECT medicos.id
   FROM public.medicos
  WHERE (medicos.id = auth.uid()))));


--
-- Name: vagas_salvas Enable medico users full access to their own data; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable medico users full access to their own data" ON public.vagas_salvas TO authenticated USING ((auth.uid() = medico_id)) WITH CHECK ((auth.uid() = medico_id));


--
-- Name: medicos Enable medico users update their own data only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable medico users update their own data only" ON public.medicos FOR UPDATE TO authenticated USING ((( SELECT auth.uid() AS uid) = id));


--
-- Name: medicos Enable medicos users insert their own data only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable medicos users insert their own data only" ON public.medicos FOR INSERT TO authenticated WITH CHECK ((( SELECT auth.uid() AS uid) = id));


--
-- Name: medicos Enable medicos users to view their own data only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable medicos users to view their own data only" ON public.medicos FOR SELECT TO authenticated USING (true);


--
-- Name: escalistas Enable read access for all authenticated users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all authenticated users" ON public.escalistas FOR SELECT TO authenticated USING (true);


--
-- Name: banner_mkt Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON public.banner_mkt FOR SELECT USING (true);


--
-- Name: codigos_area Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON public.codigos_area FOR SELECT USING (true);


--
-- Name: especialidades Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON public.especialidades FOR SELECT TO authenticated, anon USING (true);


--
-- Name: estados_brasil Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON public.estados_brasil FOR SELECT USING (true);


--
-- Name: formas_recebimento Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON public.formas_recebimento FOR SELECT TO authenticated USING (true);


--
-- Name: vagas_beneficios Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON public.vagas_beneficios FOR SELECT TO authenticated USING (true);


--
-- Name: user_profile Enable read access for anon; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for anon" ON public.user_profile FOR SELECT TO anon USING (true);


--
-- Name: beneficios Enable read access for authenticated users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for authenticated users" ON public.beneficios FOR SELECT TO authenticated USING (true);


--
-- Name: hospitais Enable read access for authenticated users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for authenticated users" ON public.hospitais FOR SELECT TO authenticated USING (true);


--
-- Name: periodos Enable read access for authenticated users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for authenticated users" ON public.periodos FOR SELECT TO authenticated USING (true);


--
-- Name: tipos_vaga Enable read access for authenticated users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for authenticated users" ON public.tipos_vaga FOR SELECT TO authenticated USING (true);


--
-- Name: whatsapp_number Enable read access for authenticated users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for authenticated users" ON public.whatsapp_number FOR SELECT TO authenticated USING (true);


--
-- Name: checkin_checkout Enable read access to escalista users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access to escalista users" ON public.checkin_checkout FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = ANY (ARRAY['astronauta'::text, 'escalista'::text]))))));


--
-- Name: vagas_requisitos Enable read for authenticated users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read for authenticated users" ON public.vagas_requisitos FOR SELECT TO authenticated USING (true);


--
-- Name: email_verification_tokens Enable read to anon; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read to anon" ON public.email_verification_tokens FOR SELECT TO anon USING (true);


--
-- Name: vagas_salvas Enable read to astronauta and escalista users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read to astronauta and escalista users" ON public.vagas_salvas FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text) AND (user_profile.role = 'escalista'::text)))));


--
-- Name: requisitos Enable read to authenticated users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read to authenticated users" ON public.requisitos FOR SELECT TO authenticated USING (true);


--
-- Name: user_profile Enable read to authenticated users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read to authenticated users" ON public.user_profile FOR SELECT TO authenticated USING (true);


--
-- Name: grupos Enable read to medico users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read to medico users" ON public.grupos FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'free'::text)))));


--
-- Name: user_profile Enable update for users based on user_id; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for users based on user_id" ON public.user_profile FOR UPDATE TO authenticated USING ((( SELECT auth.uid() AS uid) = id));


--
-- Name: email_verification_tokens Enable update to anon; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update to anon" ON public.email_verification_tokens FOR UPDATE USING (true) WITH CHECK (true);


--
-- Name: hospitais Enable update to escalista users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update to escalista users" ON public.hospitais FOR UPDATE TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'escalista'::text))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'escalista'::text)))));


--
-- Name: equipes Insert policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Insert policy" ON public.equipes FOR INSERT TO authenticated WITH CHECK ((grupo_id = public.get_current_user_grupo_id()));


--
-- Name: equipes_medicos Insert policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Insert policy" ON public.equipes_medicos FOR INSERT TO authenticated WITH CHECK ((grupo_id = public.get_current_user_grupo_id()));


--
-- Name: medicos_precadastro Insert policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Insert policy" ON public.medicos_precadastro FOR INSERT TO authenticated WITH CHECK (((( SELECT e.id AS escalista_id
   FROM public.escalistas e
  WHERE (e.auth_id = auth.uid())) = created_by) OR (EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text))))));


--
-- Name: equipes Read policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Read policy" ON public.equipes FOR SELECT TO authenticated USING ((grupo_id = public.get_current_user_grupo_id()));


--
-- Name: equipes_medicos Read policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Read policy" ON public.equipes_medicos FOR SELECT TO authenticated USING ((grupo_id = public.get_current_user_grupo_id()));


--
-- Name: medicos_precadastro Select policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Select policy" ON public.medicos_precadastro FOR SELECT TO authenticated USING (true);


--
-- Name: notifications Service role can insert notifications; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Service role can insert notifications" ON public.notifications FOR INSERT TO service_role WITH CHECK (true);


--
-- Name: notifications Service role can update notifications; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Service role can update notifications" ON public.notifications FOR UPDATE TO service_role WITH CHECK (true);


--
-- Name: equipes Update policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Update policy" ON public.equipes FOR UPDATE TO authenticated USING ((grupo_id = public.get_current_user_grupo_id()));


--
-- Name: equipes_medicos Update policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Update policy" ON public.equipes_medicos FOR UPDATE TO authenticated USING ((grupo_id = public.get_current_user_grupo_id()));


--
-- Name: medicos_precadastro Update policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Update policy" ON public.medicos_precadastro FOR UPDATE TO authenticated USING (((( SELECT e.id AS escalista_id
   FROM public.escalistas e
  WHERE (e.auth_id = auth.uid())) = created_by) OR (EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text)))))) WITH CHECK (((( SELECT e.id AS escalista_id
   FROM public.escalistas e
  WHERE (e.auth_id = auth.uid())) = created_by) OR (EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text))))));


--
-- Name: notifications Users can update own notifications read status; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can update own notifications read status" ON public.notifications FOR UPDATE TO authenticated USING ((recipient_id = auth.uid())) WITH CHECK ((recipient_id = auth.uid()));


--
-- Name: notifications Users can view own notifications; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Users can view own notifications" ON public.notifications FOR SELECT TO authenticated USING ((recipient_id = auth.uid()));


--
-- Name: grades astronauts_can_delete_grades; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY astronauts_can_delete_grades ON public.grades FOR DELETE USING ((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text)))));


--
-- Name: grades astronauts_can_insert_grades; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY astronauts_can_insert_grades ON public.grades FOR INSERT WITH CHECK (((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text)))) AND (auth.uid() = created_by)));


--
-- Name: grades astronauts_can_select_grades; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY astronauts_can_select_grades ON public.grades FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text)))));


--
-- Name: grades astronauts_can_update_grades; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY astronauts_can_update_grades ON public.grades FOR UPDATE USING ((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text)))));


--
-- Name: banner_mkt; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.banner_mkt ENABLE ROW LEVEL SECURITY;

--
-- Name: beneficios; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.beneficios ENABLE ROW LEVEL SECURITY;

--
-- Name: candidaturas; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.candidaturas ENABLE ROW LEVEL SECURITY;

--
-- Name: candidaturas candidaturas_delete_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY candidaturas_delete_policy ON public.candidaturas FOR DELETE TO authenticated USING (((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text)))) OR ((public.get_current_user_grupo_id() IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM public.vagas v
  WHERE ((v.id = candidaturas.vagas_id) AND (v.grupo_id = public.get_current_user_grupo_id()))))) OR ((EXISTS ( SELECT 1
   FROM (public.user_profile up
     JOIN public.medicos m ON ((m.id = up.id)))
  WHERE ((up.id = auth.uid()) AND (up.role = 'free'::text)))) AND (medico_id = auth.uid()))));


--
-- Name: candidaturas candidaturas_insert_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY candidaturas_insert_policy ON public.candidaturas FOR INSERT TO authenticated WITH CHECK (((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text)))) OR ((public.get_current_user_grupo_id() IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM public.vagas v
  WHERE ((v.id = candidaturas.vagas_id) AND (v.grupo_id = public.get_current_user_grupo_id()))))) OR ((EXISTS ( SELECT 1
   FROM (public.user_profile up
     JOIN public.medicos m ON ((m.id = up.id)))
  WHERE ((up.id = auth.uid()) AND (up.role = 'free'::text)))) AND (medico_id = auth.uid()))));


--
-- Name: candidaturas candidaturas_select_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY candidaturas_select_policy ON public.candidaturas FOR SELECT TO authenticated USING (((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text)))) OR ((public.get_current_user_grupo_id() IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM public.vagas v
  WHERE ((v.id = candidaturas.vagas_id) AND (v.grupo_id = public.get_current_user_grupo_id()))))) OR ((EXISTS ( SELECT 1
   FROM (public.user_profile up
     JOIN public.medicos m ON ((m.id = up.id)))
  WHERE ((up.id = auth.uid()) AND (up.role = 'free'::text)))) AND (medico_id = auth.uid())) OR ((EXISTS ( SELECT 1
   FROM (public.user_profile up
     JOIN public.medicos_precadastro mp ON ((mp.id = up.id)))
  WHERE ((up.id = auth.uid()) AND (up.role = 'free'::text)))) AND (medico_precadastro_id = auth.uid())) OR ((EXISTS ( SELECT 1
   FROM (public.user_profile up
     JOIN public.medicos m ON ((m.id = up.id)))
  WHERE ((up.id = auth.uid()) AND (up.role = 'free'::text)))) AND public.pode_ver_candidatura_colega(id)) OR ((EXISTS ( SELECT 1
   FROM (public.user_profile up
     JOIN public.medicos_precadastro mp ON ((mp.id = up.id)))
  WHERE ((up.id = auth.uid()) AND (up.role = 'free'::text)))) AND public.pode_ver_candidatura_colega(id))));


--
-- Name: candidaturas candidaturas_update_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY candidaturas_update_policy ON public.candidaturas FOR UPDATE TO authenticated USING (((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text)))) OR ((public.get_current_user_grupo_id() IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM public.vagas v
  WHERE ((v.id = candidaturas.vagas_id) AND (v.grupo_id = public.get_current_user_grupo_id()))))) OR ((EXISTS ( SELECT 1
   FROM (public.user_profile up
     JOIN public.medicos m ON ((m.id = up.id)))
  WHERE ((up.id = auth.uid()) AND (up.role = 'free'::text)))) AND (medico_id = auth.uid())))) WITH CHECK (((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text)))) OR ((public.get_current_user_grupo_id() IS NOT NULL) AND (EXISTS ( SELECT 1
   FROM public.vagas v
  WHERE ((v.id = candidaturas.vagas_id) AND (v.grupo_id = public.get_current_user_grupo_id()))))) OR ((EXISTS ( SELECT 1
   FROM (public.user_profile up
     JOIN public.medicos m ON ((m.id = up.id)))
  WHERE ((up.id = auth.uid()) AND (up.role = 'free'::text)))) AND (medico_id = auth.uid()))));


--
-- Name: carteira_digital; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.carteira_digital ENABLE ROW LEVEL SECURITY;

--
-- Name: checkin_checkout; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.checkin_checkout ENABLE ROW LEVEL SECURITY;

--
-- Name: checkin_checkout_nofitications; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.checkin_checkout_nofitications ENABLE ROW LEVEL SECURITY;

--
-- Name: clean_hospital; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.clean_hospital ENABLE ROW LEVEL SECURITY;

--
-- Name: codigos_area; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.codigos_area ENABLE ROW LEVEL SECURITY;

--
-- Name: email_verification_tokens; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.email_verification_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: equipes; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.equipes ENABLE ROW LEVEL SECURITY;

--
-- Name: equipes_medicos; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.equipes_medicos ENABLE ROW LEVEL SECURITY;

--
-- Name: escalistas escalista_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY escalista_policy ON public.escalistas TO authenticated USING (
CASE
    WHEN (public.get_current_user_grupo_id() IS NULL) THEN true
    ELSE (grupo_id = public.get_current_user_grupo_id())
END);


--
-- Name: grupos escalista_read_own_grupo; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY escalista_read_own_grupo ON public.grupos FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM (public.user_profile up
     JOIN public.escalistas e ON ((e.auth_id = up.id)))
  WHERE ((up.id = auth.uid()) AND (up.role = 'escalista'::text) AND (e.grupo_id = grupos.id)))));


--
-- Name: escalistas; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.escalistas ENABLE ROW LEVEL SECURITY;

--
-- Name: especialidades; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.especialidades ENABLE ROW LEVEL SECURITY;

--
-- Name: estados_brasil; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.estados_brasil ENABLE ROW LEVEL SECURITY;

--
-- Name: formas_recebimento; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.formas_recebimento ENABLE ROW LEVEL SECURITY;

--
-- Name: grades; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.grades ENABLE ROW LEVEL SECURITY;

--
-- Name: grades grades_delete_by_group; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY grades_delete_by_group ON public.grades FOR DELETE USING ((grupo_id = public.get_current_user_grupo_id()));


--
-- Name: grades grades_insert_by_group; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY grades_insert_by_group ON public.grades FOR INSERT WITH CHECK ((grupo_id = public.get_current_user_grupo_id()));


--
-- Name: grades grades_select_by_group; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY grades_select_by_group ON public.grades FOR SELECT USING ((grupo_id = public.get_current_user_grupo_id()));


--
-- Name: grades grades_update_by_group; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY grades_update_by_group ON public.grades FOR UPDATE USING ((grupo_id = public.get_current_user_grupo_id())) WITH CHECK ((grupo_id = public.get_current_user_grupo_id()));


--
-- Name: grupos; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.grupos ENABLE ROW LEVEL SECURITY;

--
-- Name: hospitais; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.hospitais ENABLE ROW LEVEL SECURITY;

--
-- Name: hospital_geofencing; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.hospital_geofencing ENABLE ROW LEVEL SECURITY;

--
-- Name: medicos; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.medicos ENABLE ROW LEVEL SECURITY;

--
-- Name: medicos_favoritos; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.medicos_favoritos ENABLE ROW LEVEL SECURITY;

--
-- Name: medicos_favoritos medicos_favoritos_grupo_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY medicos_favoritos_grupo_policy ON public.medicos_favoritos TO authenticated USING (((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE (((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text)) OR ((user_profile.id = auth.uid()) AND (user_profile.role = 'free'::text))))) OR (grupo_id = public.get_current_user_grupo_id()))) WITH CHECK (((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE (((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text)) OR ((user_profile.id = auth.uid()) AND (user_profile.role = 'free'::text))))) OR (grupo_id = public.get_current_user_grupo_id())));


--
-- Name: medicos_precadastro; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.medicos_precadastro ENABLE ROW LEVEL SECURITY;

--
-- Name: notifications; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

--
-- Name: pagamentos; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.pagamentos ENABLE ROW LEVEL SECURITY;

--
-- Name: pagamentos pagamentos_escalista_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pagamentos_escalista_policy ON public.pagamentos TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.vagas v
  WHERE ((v.id = pagamentos.vagas_id) AND
        CASE
            WHEN (public.get_current_user_grupo_id() IS NULL) THEN true
            ELSE (v.grupo_id = public.get_current_user_grupo_id())
        END))));


--
-- Name: periodos; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.periodos ENABLE ROW LEVEL SECURITY;

--
-- Name: requisitos; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.requisitos ENABLE ROW LEVEL SECURITY;

--
-- Name: setores; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.setores ENABLE ROW LEVEL SECURITY;

--
-- Name: tipos_vaga; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.tipos_vaga ENABLE ROW LEVEL SECURITY;

--
-- Name: user_profile; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.user_profile ENABLE ROW LEVEL SECURITY;

--
-- Name: vagas; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.vagas ENABLE ROW LEVEL SECURITY;

--
-- Name: vagas_beneficios vagas_beneficio_escalista_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY vagas_beneficio_escalista_policy ON public.vagas_beneficios TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.vagas v
  WHERE ((v.id = vagas_beneficios.vaga_id) AND
        CASE
            WHEN (public.get_current_user_grupo_id() IS NULL) THEN true
            ELSE (v.grupo_id = public.get_current_user_grupo_id())
        END)))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.vagas v
  WHERE ((v.id = vagas_beneficios.vaga_id) AND
        CASE
            WHEN (public.get_current_user_grupo_id() IS NULL) THEN true
            ELSE (v.grupo_id = public.get_current_user_grupo_id())
        END))));


--
-- Name: vagas_beneficios; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.vagas_beneficios ENABLE ROW LEVEL SECURITY;

--
-- Name: vagas vagas_delete_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY vagas_delete_policy ON public.vagas FOR DELETE TO authenticated USING (((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text)))) OR ((public.get_current_user_grupo_id() IS NOT NULL) AND (grupo_id = public.get_current_user_grupo_id()))));


--
-- Name: vagas vagas_insert_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY vagas_insert_policy ON public.vagas FOR INSERT TO authenticated WITH CHECK (((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text)))) OR ((public.get_current_user_grupo_id() IS NOT NULL) AND (grupo_id = public.get_current_user_grupo_id()))));


--
-- Name: vagas_recorrencias vagas_recorrencia_escalista_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY vagas_recorrencia_escalista_policy ON public.vagas_recorrencias TO authenticated USING (((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text)))) OR (created_by = auth.uid()) OR (EXISTS ( SELECT 1
   FROM (public.vagas v
     JOIN public.escalistas e ON ((e.grupo_id = v.grupo_id)))
  WHERE ((v.recorrencia_id = vagas_recorrencias.id) AND (e.auth_id = auth.uid())))))) WITH CHECK (((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE ((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text)))) OR (created_by = auth.uid())));


--
-- Name: vagas_recorrencias; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.vagas_recorrencias ENABLE ROW LEVEL SECURITY;

--
-- Name: vagas_requisitos vagas_requisito_escalista_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY vagas_requisito_escalista_policy ON public.vagas_requisitos TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.vagas v
  WHERE ((v.id = vagas_requisitos.vagas_id) AND
        CASE
            WHEN (public.get_current_user_grupo_id() IS NULL) THEN true
            ELSE (v.grupo_id = public.get_current_user_grupo_id())
        END)))) WITH CHECK ((EXISTS ( SELECT 1
   FROM public.vagas v
  WHERE ((v.id = vagas_requisitos.vagas_id) AND
        CASE
            WHEN (public.get_current_user_grupo_id() IS NULL) THEN true
            ELSE (v.grupo_id = public.get_current_user_grupo_id())
        END))));


--
-- Name: vagas_requisitos; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.vagas_requisitos ENABLE ROW LEVEL SECURITY;

--
-- Name: vagas_salvas; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.vagas_salvas ENABLE ROW LEVEL SECURITY;

--
-- Name: vagas vagas_select_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY vagas_select_policy ON public.vagas FOR SELECT TO authenticated USING (((EXISTS ( SELECT 1
   FROM public.user_profile
  WHERE (((user_profile.id = auth.uid()) AND (user_profile.role = 'astronauta'::text)) OR ((user_profile.id = auth.uid()) AND (user_profile.role = 'free'::text))))) OR (grupo_id = public.get_current_user_grupo_id())));


--
-- Name: vagas vagas_update_policy; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY vagas_update_policy ON public.vagas FOR UPDATE TO authenticated USING (((( SELECT user_profile.role
   FROM public.user_profile
  WHERE (user_profile.id = auth.uid())) = 'astronauta'::text) OR (( SELECT user_profile.role
   FROM public.user_profile
  WHERE (user_profile.id = auth.uid())) = 'free'::text) OR ((( SELECT user_profile.role
   FROM public.user_profile
  WHERE (user_profile.id = auth.uid())) = 'escalista'::text) AND (grupo_id = ( SELECT escalistas.grupo_id
   FROM public.escalistas
  WHERE (escalistas.auth_id = auth.uid()))))));


--
-- Name: whatsapp_number; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.whatsapp_number ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- Name: iceberg_namespaces; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.iceberg_namespaces ENABLE ROW LEVEL SECURITY;

--
-- Name: iceberg_tables; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.iceberg_tables ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: prefixes; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.prefixes ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: postgres
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION supabase_realtime OWNER TO postgres;

--
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO service_role;
GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON SCHEMA auth TO dashboard_user;
GRANT USAGE ON SCHEMA auth TO postgres;


--
-- Name: SCHEMA extensions; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA extensions TO anon;
GRANT USAGE ON SCHEMA extensions TO authenticated;
GRANT USAGE ON SCHEMA extensions TO service_role;
GRANT ALL ON SCHEMA extensions TO dashboard_user;


--
-- Name: SCHEMA net; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA net TO supabase_functions_admin;
GRANT USAGE ON SCHEMA net TO postgres;
GRANT USAGE ON SCHEMA net TO anon;
GRANT USAGE ON SCHEMA net TO authenticated;
GRANT USAGE ON SCHEMA net TO service_role;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- Name: SCHEMA realtime; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA realtime TO postgres;
GRANT USAGE ON SCHEMA realtime TO anon;
GRANT USAGE ON SCHEMA realtime TO authenticated;
GRANT USAGE ON SCHEMA realtime TO service_role;
GRANT ALL ON SCHEMA realtime TO supabase_realtime_admin;


--
-- Name: SCHEMA storage; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA storage TO postgres;
GRANT USAGE ON SCHEMA storage TO anon;
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT USAGE ON SCHEMA storage TO service_role;
GRANT ALL ON SCHEMA storage TO supabase_storage_admin;
GRANT ALL ON SCHEMA storage TO dashboard_user;


--
-- Name: SCHEMA supabase_functions; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA supabase_functions TO postgres;
GRANT USAGE ON SCHEMA supabase_functions TO anon;
GRANT USAGE ON SCHEMA supabase_functions TO authenticated;
GRANT USAGE ON SCHEMA supabase_functions TO service_role;
GRANT ALL ON SCHEMA supabase_functions TO supabase_functions_admin;


--
-- Name: SCHEMA vault; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA vault TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA vault TO service_role;


--
-- Name: FUNCTION gtrgm_in(cstring); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gtrgm_in(cstring) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_in(cstring) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_in(cstring) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_in(cstring) TO service_role;


--
-- Name: FUNCTION gtrgm_out(public.gtrgm); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gtrgm_out(public.gtrgm) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_out(public.gtrgm) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_out(public.gtrgm) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_out(public.gtrgm) TO service_role;


--
-- Name: FUNCTION email(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.email() TO dashboard_user;


--
-- Name: FUNCTION jwt(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.jwt() TO postgres;
GRANT ALL ON FUNCTION auth.jwt() TO dashboard_user;


--
-- Name: FUNCTION role(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.role() TO dashboard_user;


--
-- Name: FUNCTION uid(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.uid() TO dashboard_user;


--
-- Name: FUNCTION algorithm_sign(signables text, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.algorithm_sign(signables text, secret text, algorithm text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.algorithm_sign(signables text, secret text, algorithm text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.armor(bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION bytea_to_text(data bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.bytea_to_text(data bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.crypt(text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.dearmor(text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.digest(text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_salt(text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION extensions.grant_pg_cron_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO dashboard_user;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.grant_pg_graphql_access() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION grant_pg_net_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION extensions.grant_pg_net_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO dashboard_user;


--
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION http(request extensions.http_request); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.http(request extensions.http_request) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION http_delete(uri character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.http_delete(uri character varying) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION http_delete(uri character varying, content character varying, content_type character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.http_delete(uri character varying, content character varying, content_type character varying) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION http_get(uri character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.http_get(uri character varying) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION http_get(uri character varying, data jsonb); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.http_get(uri character varying, data jsonb) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION http_head(uri character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.http_head(uri character varying) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION http_header(field character varying, value character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.http_header(field character varying, value character varying) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION http_list_curlopt(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.http_list_curlopt() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION http_patch(uri character varying, content character varying, content_type character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.http_patch(uri character varying, content character varying, content_type character varying) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION http_post(uri character varying, data jsonb); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.http_post(uri character varying, data jsonb) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION http_post(uri character varying, content character varying, content_type character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.http_post(uri character varying, content character varying, content_type character varying) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION http_put(uri character varying, content character varying, content_type character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.http_put(uri character varying, content character varying, content_type character varying) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION http_reset_curlopt(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.http_reset_curlopt() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION http_set_curlopt(curlopt character varying, value character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.http_set_curlopt(curlopt character varying, value character varying) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pg_stat_statements_reset(userid oid, dbid oid, queryid bigint); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgrst_ddl_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_ddl_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION pgrst_drop_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_drop_watch() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.set_graphql_placeholder() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION sign(payload json, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.sign(payload json, secret text, algorithm text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.sign(payload json, secret text, algorithm text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION text_to_bytea(data text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.text_to_bytea(data text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION try_cast_double(inp text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.try_cast_double(inp text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.try_cast_double(inp text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION url_decode(data text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.url_decode(data text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.url_decode(data text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION url_encode(data bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.url_encode(data bytea) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.url_encode(data bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION urlencode(string bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.urlencode(string bytea) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION urlencode(data jsonb); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.urlencode(data jsonb) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION urlencode(string character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.urlencode(string character varying) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v1(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v1mc(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v3(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v4(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_generate_v5(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_nil(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_nil() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_ns_dns(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_ns_oid(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_ns_url(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION uuid_ns_x500(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO dashboard_user;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION verify(token text, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.verify(token text, secret text, algorithm text) TO dashboard_user;
GRANT ALL ON FUNCTION extensions.verify(token text, secret text, algorithm text) TO postgres WITH GRANT OPTION;


--
-- Name: FUNCTION graphql("operationName" text, query text, variables jsonb, extensions jsonb); Type: ACL; Schema: graphql_public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO postgres;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO anon;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO authenticated;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO service_role;


--
-- Name: FUNCTION http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer); Type: ACL; Schema: net; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
GRANT ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin;
GRANT ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO postgres;
GRANT ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO anon;
GRANT ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO authenticated;
GRANT ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO service_role;


--
-- Name: FUNCTION http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer); Type: ACL; Schema: net; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
GRANT ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin;
GRANT ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO postgres;
GRANT ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO anon;
GRANT ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO authenticated;
GRANT ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO service_role;


--
-- Name: FUNCTION get_auth(p_usename text); Type: ACL; Schema: pgbouncer; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION pgbouncer.get_auth(p_usename text) FROM PUBLIC;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO pgbouncer;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO postgres;


--
-- Name: FUNCTION aprovacao_automatica_favoritos(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.aprovacao_automatica_favoritos() TO anon;
GRANT ALL ON FUNCTION public.aprovacao_automatica_favoritos() TO authenticated;
GRANT ALL ON FUNCTION public.aprovacao_automatica_favoritos() TO service_role;


--
-- Name: FUNCTION aprovar_todos_documentos(p_carteira_id uuid, p_user_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.aprovar_todos_documentos(p_carteira_id uuid, p_user_id uuid) TO anon;
GRANT ALL ON FUNCTION public.aprovar_todos_documentos(p_carteira_id uuid, p_user_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.aprovar_todos_documentos(p_carteira_id uuid, p_user_id uuid) TO service_role;


--
-- Name: FUNCTION aretheytester(user_id text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.aretheytester(user_id text) TO anon;
GRANT ALL ON FUNCTION public.aretheytester(user_id text) TO authenticated;
GRANT ALL ON FUNCTION public.aretheytester(user_id text) TO service_role;


--
-- Name: FUNCTION atualizar_candidaturas_vaga_cancelada(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.atualizar_candidaturas_vaga_cancelada() TO anon;
GRANT ALL ON FUNCTION public.atualizar_candidaturas_vaga_cancelada() TO authenticated;
GRANT ALL ON FUNCTION public.atualizar_candidaturas_vaga_cancelada() TO service_role;


--
-- Name: FUNCTION atualizar_status_vagas_expiradas(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.atualizar_status_vagas_expiradas() TO anon;
GRANT ALL ON FUNCTION public.atualizar_status_vagas_expiradas() TO authenticated;
GRANT ALL ON FUNCTION public.atualizar_status_vagas_expiradas() TO service_role;


--
-- Name: FUNCTION atualizar_urls_documentos(p_carteira_id uuid, p_base_url character varying, p_user_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.atualizar_urls_documentos(p_carteira_id uuid, p_base_url character varying, p_user_id uuid) TO anon;
GRANT ALL ON FUNCTION public.atualizar_urls_documentos(p_carteira_id uuid, p_base_url character varying, p_user_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.atualizar_urls_documentos(p_carteira_id uuid, p_base_url character varying, p_user_id uuid) TO service_role;


--
-- Name: FUNCTION atualizar_vagas_status(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.atualizar_vagas_status() TO anon;
GRANT ALL ON FUNCTION public.atualizar_vagas_status() TO authenticated;
GRANT ALL ON FUNCTION public.atualizar_vagas_status() TO service_role;


--
-- Name: FUNCTION calcular_dias_pagamento(data_plantao date, data_pagamento date); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.calcular_dias_pagamento(data_plantao date, data_pagamento date) TO anon;
GRANT ALL ON FUNCTION public.calcular_dias_pagamento(data_plantao date, data_pagamento date) TO authenticated;
GRANT ALL ON FUNCTION public.calcular_dias_pagamento(data_plantao date, data_pagamento date) TO service_role;


--
-- Name: FUNCTION calcular_distancia(lat1 numeric, lon1 numeric, lat2 numeric, lon2 numeric); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.calcular_distancia(lat1 numeric, lon1 numeric, lat2 numeric, lon2 numeric) TO anon;
GRANT ALL ON FUNCTION public.calcular_distancia(lat1 numeric, lon1 numeric, lat2 numeric, lon2 numeric) TO authenticated;
GRANT ALL ON FUNCTION public.calcular_distancia(lat1 numeric, lon1 numeric, lat2 numeric, lon2 numeric) TO service_role;


--
-- Name: FUNCTION cleanup_medicos_precadastro(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.cleanup_medicos_precadastro() TO anon;
GRANT ALL ON FUNCTION public.cleanup_medicos_precadastro() TO authenticated;
GRANT ALL ON FUNCTION public.cleanup_medicos_precadastro() TO service_role;


--
-- Name: FUNCTION contar_linhas_duplo(nome_tabela text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.contar_linhas_duplo(nome_tabela text) TO anon;
GRANT ALL ON FUNCTION public.contar_linhas_duplo(nome_tabela text) TO authenticated;
GRANT ALL ON FUNCTION public.contar_linhas_duplo(nome_tabela text) TO service_role;


--
-- Name: FUNCTION corrigir_inconsistencias_vagas(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.corrigir_inconsistencias_vagas() TO anon;
GRANT ALL ON FUNCTION public.corrigir_inconsistencias_vagas() TO authenticated;
GRANT ALL ON FUNCTION public.corrigir_inconsistencias_vagas() TO service_role;


--
-- Name: FUNCTION count_candidaturas_total(vaga_id_param uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.count_candidaturas_total(vaga_id_param uuid) TO anon;
GRANT ALL ON FUNCTION public.count_candidaturas_total(vaga_id_param uuid) TO authenticated;
GRANT ALL ON FUNCTION public.count_candidaturas_total(vaga_id_param uuid) TO service_role;


--
-- Name: FUNCTION criar_carteira_digital(p_medico_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.criar_carteira_digital(p_medico_id uuid) TO anon;
GRANT ALL ON FUNCTION public.criar_carteira_digital(p_medico_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.criar_carteira_digital(p_medico_id uuid) TO service_role;


--
-- Name: FUNCTION criar_escalista(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.criar_escalista() TO anon;
GRANT ALL ON FUNCTION public.criar_escalista() TO authenticated;
GRANT ALL ON FUNCTION public.criar_escalista() TO service_role;


--
-- Name: FUNCTION criar_recorrencia_com_vagas(p_data_inicio date, p_data_fim date, p_dias_semana integer[], p_vaga_base jsonb, p_created_by uuid, p_medico_id uuid, p_observacoes text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.criar_recorrencia_com_vagas(p_data_inicio date, p_data_fim date, p_dias_semana integer[], p_vaga_base jsonb, p_created_by uuid, p_medico_id uuid, p_observacoes text) TO anon;
GRANT ALL ON FUNCTION public.criar_recorrencia_com_vagas(p_data_inicio date, p_data_fim date, p_dias_semana integer[], p_vaga_base jsonb, p_created_by uuid, p_medico_id uuid, p_observacoes text) TO authenticated;
GRANT ALL ON FUNCTION public.criar_recorrencia_com_vagas(p_data_inicio date, p_data_fim date, p_dias_semana integer[], p_vaga_base jsonb, p_created_by uuid, p_medico_id uuid, p_observacoes text) TO service_role;


--
-- Name: FUNCTION criar_recorrencia_com_vagas(p_data_inicio date, p_data_fim date, p_dias_semana integer[], p_vaga_base jsonb, p_created_by uuid, p_medico_id uuid, p_observacoes text, p_beneficios text[], p_requisitos text[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.criar_recorrencia_com_vagas(p_data_inicio date, p_data_fim date, p_dias_semana integer[], p_vaga_base jsonb, p_created_by uuid, p_medico_id uuid, p_observacoes text, p_beneficios text[], p_requisitos text[]) TO anon;
GRANT ALL ON FUNCTION public.criar_recorrencia_com_vagas(p_data_inicio date, p_data_fim date, p_dias_semana integer[], p_vaga_base jsonb, p_created_by uuid, p_medico_id uuid, p_observacoes text, p_beneficios text[], p_requisitos text[]) TO authenticated;
GRANT ALL ON FUNCTION public.criar_recorrencia_com_vagas(p_data_inicio date, p_data_fim date, p_dias_semana integer[], p_vaga_base jsonb, p_created_by uuid, p_medico_id uuid, p_observacoes text, p_beneficios text[], p_requisitos text[]) TO service_role;


--
-- Name: FUNCTION current_user_is_favorito(p_grupo_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.current_user_is_favorito(p_grupo_id uuid) TO anon;
GRANT ALL ON FUNCTION public.current_user_is_favorito(p_grupo_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.current_user_is_favorito(p_grupo_id uuid) TO service_role;


--
-- Name: FUNCTION deletar_vagas_recorrencia(p_recorrencia_id uuid, p_updateby uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.deletar_vagas_recorrencia(p_recorrencia_id uuid, p_updateby uuid) TO anon;
GRANT ALL ON FUNCTION public.deletar_vagas_recorrencia(p_recorrencia_id uuid, p_updateby uuid) TO authenticated;
GRANT ALL ON FUNCTION public.deletar_vagas_recorrencia(p_recorrencia_id uuid, p_updateby uuid) TO service_role;


--
-- Name: FUNCTION deletethisuser(user_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.deletethisuser(user_id uuid) TO anon;
GRANT ALL ON FUNCTION public.deletethisuser(user_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.deletethisuser(user_id uuid) TO service_role;


--
-- Name: FUNCTION editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid) TO anon;
GRANT ALL ON FUNCTION public.editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid) TO authenticated;
GRANT ALL ON FUNCTION public.editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid) TO service_role;


--
-- Name: FUNCTION editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid, p_beneficios text[], p_requisitos text[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid, p_beneficios text[], p_requisitos text[]) TO anon;
GRANT ALL ON FUNCTION public.editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid, p_beneficios text[], p_requisitos text[]) TO authenticated;
GRANT ALL ON FUNCTION public.editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid, p_beneficios text[], p_requisitos text[]) TO service_role;


--
-- Name: FUNCTION editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid, p_beneficios text[], p_requisitos text[], p_dias_pagamento integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid, p_beneficios text[], p_requisitos text[], p_dias_pagamento integer) TO anon;
GRANT ALL ON FUNCTION public.editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid, p_beneficios text[], p_requisitos text[], p_dias_pagamento integer) TO authenticated;
GRANT ALL ON FUNCTION public.editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid, p_beneficios text[], p_requisitos text[], p_dias_pagamento integer) TO service_role;


--
-- Name: FUNCTION excluir_vagas_lote(vagas_ids uuid[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.excluir_vagas_lote(vagas_ids uuid[]) TO anon;
GRANT ALL ON FUNCTION public.excluir_vagas_lote(vagas_ids uuid[]) TO authenticated;
GRANT ALL ON FUNCTION public.excluir_vagas_lote(vagas_ids uuid[]) TO service_role;


--
-- Name: FUNCTION gerar_vagas_recorrentes(p_recorrencia_id uuid, p_vaga_base_id uuid, p_medico_id uuid, p_created_by uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gerar_vagas_recorrentes(p_recorrencia_id uuid, p_vaga_base_id uuid, p_medico_id uuid, p_created_by uuid) TO anon;
GRANT ALL ON FUNCTION public.gerar_vagas_recorrentes(p_recorrencia_id uuid, p_vaga_base_id uuid, p_medico_id uuid, p_created_by uuid) TO authenticated;
GRANT ALL ON FUNCTION public.gerar_vagas_recorrentes(p_recorrencia_id uuid, p_vaga_base_id uuid, p_medico_id uuid, p_created_by uuid) TO service_role;


--
-- Name: FUNCTION gerar_vagas_recorrentes(p_recorrencia_id uuid, p_vaga_base_id uuid, p_medico_id uuid, p_created_by uuid, p_beneficios text[], p_requisitos text[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gerar_vagas_recorrentes(p_recorrencia_id uuid, p_vaga_base_id uuid, p_medico_id uuid, p_created_by uuid, p_beneficios text[], p_requisitos text[]) TO anon;
GRANT ALL ON FUNCTION public.gerar_vagas_recorrentes(p_recorrencia_id uuid, p_vaga_base_id uuid, p_medico_id uuid, p_created_by uuid, p_beneficios text[], p_requisitos text[]) TO authenticated;
GRANT ALL ON FUNCTION public.gerar_vagas_recorrentes(p_recorrencia_id uuid, p_vaga_base_id uuid, p_medico_id uuid, p_created_by uuid, p_beneficios text[], p_requisitos text[]) TO service_role;


--
-- Name: FUNCTION get_applications_paginated(page_number integer, page_size integer, hospital_ids uuid[], specialty_ids uuid[], sector_ids uuid[], start_date date, end_date date, min_value numeric, max_value numeric, period_ids uuid[], type_ids uuid[], group_ids uuid[], search_text text, doctor_ids uuid[], application_status_filter text[], job_status_filter text[], grade_ids uuid[], order_by text, order_direction text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_applications_paginated(page_number integer, page_size integer, hospital_ids uuid[], specialty_ids uuid[], sector_ids uuid[], start_date date, end_date date, min_value numeric, max_value numeric, period_ids uuid[], type_ids uuid[], group_ids uuid[], search_text text, doctor_ids uuid[], application_status_filter text[], job_status_filter text[], grade_ids uuid[], order_by text, order_direction text) TO anon;
GRANT ALL ON FUNCTION public.get_applications_paginated(page_number integer, page_size integer, hospital_ids uuid[], specialty_ids uuid[], sector_ids uuid[], start_date date, end_date date, min_value numeric, max_value numeric, period_ids uuid[], type_ids uuid[], group_ids uuid[], search_text text, doctor_ids uuid[], application_status_filter text[], job_status_filter text[], grade_ids uuid[], order_by text, order_direction text) TO authenticated;
GRANT ALL ON FUNCTION public.get_applications_paginated(page_number integer, page_size integer, hospital_ids uuid[], specialty_ids uuid[], sector_ids uuid[], start_date date, end_date date, min_value numeric, max_value numeric, period_ids uuid[], type_ids uuid[], group_ids uuid[], search_text text, doctor_ids uuid[], application_status_filter text[], job_status_filter text[], grade_ids uuid[], order_by text, order_direction text) TO service_role;


--
-- Name: FUNCTION get_cpf(cpf_input text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_cpf(cpf_input text) TO anon;
GRANT ALL ON FUNCTION public.get_cpf(cpf_input text) TO authenticated;
GRANT ALL ON FUNCTION public.get_cpf(cpf_input text) TO service_role;


--
-- Name: FUNCTION get_crm(crm_input text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_crm(crm_input text) TO anon;
GRANT ALL ON FUNCTION public.get_crm(crm_input text) TO authenticated;
GRANT ALL ON FUNCTION public.get_crm(crm_input text) TO service_role;


--
-- Name: FUNCTION get_current_user_grupo_id(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_current_user_grupo_id() TO anon;
GRANT ALL ON FUNCTION public.get_current_user_grupo_id() TO authenticated;
GRANT ALL ON FUNCTION public.get_current_user_grupo_id() TO service_role;


--
-- Name: FUNCTION get_documento_historico(p_carteira_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_documento_historico(p_carteira_id uuid) TO anon;
GRANT ALL ON FUNCTION public.get_documento_historico(p_carteira_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.get_documento_historico(p_carteira_id uuid) TO service_role;


--
-- Name: FUNCTION get_documento_historico(p_carteira_id uuid, p_tipo text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_documento_historico(p_carteira_id uuid, p_tipo text) TO anon;
GRANT ALL ON FUNCTION public.get_documento_historico(p_carteira_id uuid, p_tipo text) TO authenticated;
GRANT ALL ON FUNCTION public.get_documento_historico(p_carteira_id uuid, p_tipo text) TO service_role;


--
-- Name: FUNCTION get_documentos_pendentes(p_carteira_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_documentos_pendentes(p_carteira_id uuid) TO anon;
GRANT ALL ON FUNCTION public.get_documentos_pendentes(p_carteira_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.get_documentos_pendentes(p_carteira_id uuid) TO service_role;


--
-- Name: FUNCTION get_email(e_mail text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_email(e_mail text) TO anon;
GRANT ALL ON FUNCTION public.get_email(e_mail text) TO authenticated;
GRANT ALL ON FUNCTION public.get_email(e_mail text) TO service_role;


--
-- Name: FUNCTION get_medicos_com_documentos(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_medicos_com_documentos() TO anon;
GRANT ALL ON FUNCTION public.get_medicos_com_documentos() TO authenticated;
GRANT ALL ON FUNCTION public.get_medicos_com_documentos() TO service_role;


--
-- Name: FUNCTION get_medicos_documentacao_pendente(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_medicos_documentacao_pendente() TO anon;
GRANT ALL ON FUNCTION public.get_medicos_documentacao_pendente() TO authenticated;
GRANT ALL ON FUNCTION public.get_medicos_documentacao_pendente() TO service_role;


--
-- Name: FUNCTION get_percentual_conclusao(p_carteira_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_percentual_conclusao(p_carteira_id uuid) TO anon;
GRANT ALL ON FUNCTION public.get_percentual_conclusao(p_carteira_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.get_percentual_conclusao(p_carteira_id uuid) TO service_role;


--
-- Name: FUNCTION get_phonenumber(p_phone text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_phonenumber(p_phone text) TO anon;
GRANT ALL ON FUNCTION public.get_phonenumber(p_phone text) TO authenticated;
GRANT ALL ON FUNCTION public.get_phonenumber(p_phone text) TO service_role;


--
-- Name: FUNCTION get_urls_pendentes(p_carteira_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_urls_pendentes(p_carteira_id uuid) TO anon;
GRANT ALL ON FUNCTION public.get_urls_pendentes(p_carteira_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.get_urls_pendentes(p_carteira_id uuid) TO service_role;


--
-- Name: FUNCTION get_vagas_paginated(page_number integer, page_size integer, hospital_ids uuid[], specialty_ids uuid[], sector_ids uuid[], start_date date, end_date date, min_value numeric, max_value numeric, period_ids uuid[], type_ids uuid[], group_ids uuid[], search_text text, doctor_ids uuid[], application_status_filter text[], job_status_filter text[], grade_ids uuid[], order_by text, order_direction text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_vagas_paginated(page_number integer, page_size integer, hospital_ids uuid[], specialty_ids uuid[], sector_ids uuid[], start_date date, end_date date, min_value numeric, max_value numeric, period_ids uuid[], type_ids uuid[], group_ids uuid[], search_text text, doctor_ids uuid[], application_status_filter text[], job_status_filter text[], grade_ids uuid[], order_by text, order_direction text) TO anon;
GRANT ALL ON FUNCTION public.get_vagas_paginated(page_number integer, page_size integer, hospital_ids uuid[], specialty_ids uuid[], sector_ids uuid[], start_date date, end_date date, min_value numeric, max_value numeric, period_ids uuid[], type_ids uuid[], group_ids uuid[], search_text text, doctor_ids uuid[], application_status_filter text[], job_status_filter text[], grade_ids uuid[], order_by text, order_direction text) TO authenticated;
GRANT ALL ON FUNCTION public.get_vagas_paginated(page_number integer, page_size integer, hospital_ids uuid[], specialty_ids uuid[], sector_ids uuid[], start_date date, end_date date, min_value numeric, max_value numeric, period_ids uuid[], type_ids uuid[], group_ids uuid[], search_text text, doctor_ids uuid[], application_status_filter text[], job_status_filter text[], grade_ids uuid[], order_by text, order_direction text) TO service_role;


--
-- Name: FUNCTION getidfromemail(e_mail text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.getidfromemail(e_mail text) TO anon;
GRANT ALL ON FUNCTION public.getidfromemail(e_mail text) TO authenticated;
GRANT ALL ON FUNCTION public.getidfromemail(e_mail text) TO service_role;


--
-- Name: FUNCTION getidfromphone(p_phone text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.getidfromphone(p_phone text) TO anon;
GRANT ALL ON FUNCTION public.getidfromphone(p_phone text) TO authenticated;
GRANT ALL ON FUNCTION public.getidfromphone(p_phone text) TO service_role;


--
-- Name: FUNCTION getuserprofile(user_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.getuserprofile(user_id uuid) TO anon;
GRANT ALL ON FUNCTION public.getuserprofile(user_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.getuserprofile(user_id uuid) TO service_role;


--
-- Name: FUNCTION gin_extract_query_trgm(text, internal, smallint, internal, internal, internal, internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gin_extract_query_trgm(text, internal, smallint, internal, internal, internal, internal) TO postgres;
GRANT ALL ON FUNCTION public.gin_extract_query_trgm(text, internal, smallint, internal, internal, internal, internal) TO anon;
GRANT ALL ON FUNCTION public.gin_extract_query_trgm(text, internal, smallint, internal, internal, internal, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gin_extract_query_trgm(text, internal, smallint, internal, internal, internal, internal) TO service_role;


--
-- Name: FUNCTION gin_extract_value_trgm(text, internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gin_extract_value_trgm(text, internal) TO postgres;
GRANT ALL ON FUNCTION public.gin_extract_value_trgm(text, internal) TO anon;
GRANT ALL ON FUNCTION public.gin_extract_value_trgm(text, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gin_extract_value_trgm(text, internal) TO service_role;


--
-- Name: FUNCTION gin_trgm_consistent(internal, smallint, text, integer, internal, internal, internal, internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gin_trgm_consistent(internal, smallint, text, integer, internal, internal, internal, internal) TO postgres;
GRANT ALL ON FUNCTION public.gin_trgm_consistent(internal, smallint, text, integer, internal, internal, internal, internal) TO anon;
GRANT ALL ON FUNCTION public.gin_trgm_consistent(internal, smallint, text, integer, internal, internal, internal, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gin_trgm_consistent(internal, smallint, text, integer, internal, internal, internal, internal) TO service_role;


--
-- Name: FUNCTION gin_trgm_triconsistent(internal, smallint, text, integer, internal, internal, internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gin_trgm_triconsistent(internal, smallint, text, integer, internal, internal, internal) TO postgres;
GRANT ALL ON FUNCTION public.gin_trgm_triconsistent(internal, smallint, text, integer, internal, internal, internal) TO anon;
GRANT ALL ON FUNCTION public.gin_trgm_triconsistent(internal, smallint, text, integer, internal, internal, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gin_trgm_triconsistent(internal, smallint, text, integer, internal, internal, internal) TO service_role;


--
-- Name: FUNCTION gtrgm_compress(internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gtrgm_compress(internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_compress(internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_compress(internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_compress(internal) TO service_role;


--
-- Name: FUNCTION gtrgm_consistent(internal, text, smallint, oid, internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gtrgm_consistent(internal, text, smallint, oid, internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_consistent(internal, text, smallint, oid, internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_consistent(internal, text, smallint, oid, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_consistent(internal, text, smallint, oid, internal) TO service_role;


--
-- Name: FUNCTION gtrgm_decompress(internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gtrgm_decompress(internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_decompress(internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_decompress(internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_decompress(internal) TO service_role;


--
-- Name: FUNCTION gtrgm_distance(internal, text, smallint, oid, internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gtrgm_distance(internal, text, smallint, oid, internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_distance(internal, text, smallint, oid, internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_distance(internal, text, smallint, oid, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_distance(internal, text, smallint, oid, internal) TO service_role;


--
-- Name: FUNCTION gtrgm_options(internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gtrgm_options(internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_options(internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_options(internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_options(internal) TO service_role;


--
-- Name: FUNCTION gtrgm_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gtrgm_penalty(internal, internal, internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_penalty(internal, internal, internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_penalty(internal, internal, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_penalty(internal, internal, internal) TO service_role;


--
-- Name: FUNCTION gtrgm_picksplit(internal, internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gtrgm_picksplit(internal, internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_picksplit(internal, internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_picksplit(internal, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_picksplit(internal, internal) TO service_role;


--
-- Name: FUNCTION gtrgm_same(public.gtrgm, public.gtrgm, internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gtrgm_same(public.gtrgm, public.gtrgm, internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_same(public.gtrgm, public.gtrgm, internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_same(public.gtrgm, public.gtrgm, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_same(public.gtrgm, public.gtrgm, internal) TO service_role;


--
-- Name: FUNCTION gtrgm_union(internal, internal); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.gtrgm_union(internal, internal) TO postgres;
GRANT ALL ON FUNCTION public.gtrgm_union(internal, internal) TO anon;
GRANT ALL ON FUNCTION public.gtrgm_union(internal, internal) TO authenticated;
GRANT ALL ON FUNCTION public.gtrgm_union(internal, internal) TO service_role;


--
-- Name: FUNCTION handle_grades_updated_at(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.handle_grades_updated_at() TO anon;
GRANT ALL ON FUNCTION public.handle_grades_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.handle_grades_updated_at() TO service_role;


--
-- Name: FUNCTION inserir_carteira_digital(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.inserir_carteira_digital() TO anon;
GRANT ALL ON FUNCTION public.inserir_carteira_digital() TO authenticated;
GRANT ALL ON FUNCTION public.inserir_carteira_digital() TO service_role;


--
-- Name: FUNCTION inserir_validacao_documentos(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.inserir_validacao_documentos() TO anon;
GRANT ALL ON FUNCTION public.inserir_validacao_documentos() TO authenticated;
GRANT ALL ON FUNCTION public.inserir_validacao_documentos() TO service_role;


--
-- Name: FUNCTION pode_ver_candidatura_colega(candidatura_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pode_ver_candidatura_colega(candidatura_id uuid) TO anon;
GRANT ALL ON FUNCTION public.pode_ver_candidatura_colega(candidatura_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.pode_ver_candidatura_colega(candidatura_id uuid) TO service_role;


--
-- Name: FUNCTION pode_ver_candidatura_colega_debug(candidatura_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pode_ver_candidatura_colega_debug(candidatura_id uuid) TO anon;
GRANT ALL ON FUNCTION public.pode_ver_candidatura_colega_debug(candidatura_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.pode_ver_candidatura_colega_debug(candidatura_id uuid) TO service_role;


--
-- Name: FUNCTION refresh_dashboard_metrics(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.refresh_dashboard_metrics() TO anon;
GRANT ALL ON FUNCTION public.refresh_dashboard_metrics() TO authenticated;
GRANT ALL ON FUNCTION public.refresh_dashboard_metrics() TO service_role;


--
-- Name: FUNCTION refresh_vw_vagas_disponiveis(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.refresh_vw_vagas_disponiveis() TO anon;
GRANT ALL ON FUNCTION public.refresh_vw_vagas_disponiveis() TO authenticated;
GRANT ALL ON FUNCTION public.refresh_vw_vagas_disponiveis() TO service_role;


--
-- Name: FUNCTION reprovar_documento(p_carteira_id uuid, p_tipo text, p_motivo text, p_user_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.reprovar_documento(p_carteira_id uuid, p_tipo text, p_motivo text, p_user_id uuid) TO anon;
GRANT ALL ON FUNCTION public.reprovar_documento(p_carteira_id uuid, p_tipo text, p_motivo text, p_user_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.reprovar_documento(p_carteira_id uuid, p_tipo text, p_motivo text, p_user_id uuid) TO service_role;


--
-- Name: FUNCTION set_limit(real); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.set_limit(real) TO postgres;
GRANT ALL ON FUNCTION public.set_limit(real) TO anon;
GRANT ALL ON FUNCTION public.set_limit(real) TO authenticated;
GRANT ALL ON FUNCTION public.set_limit(real) TO service_role;


--
-- Name: FUNCTION show_limit(); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.show_limit() TO postgres;
GRANT ALL ON FUNCTION public.show_limit() TO anon;
GRANT ALL ON FUNCTION public.show_limit() TO authenticated;
GRANT ALL ON FUNCTION public.show_limit() TO service_role;


--
-- Name: FUNCTION show_trgm(text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.show_trgm(text) TO postgres;
GRANT ALL ON FUNCTION public.show_trgm(text) TO anon;
GRANT ALL ON FUNCTION public.show_trgm(text) TO authenticated;
GRANT ALL ON FUNCTION public.show_trgm(text) TO service_role;


--
-- Name: FUNCTION similarity(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.similarity(text, text) TO postgres;
GRANT ALL ON FUNCTION public.similarity(text, text) TO anon;
GRANT ALL ON FUNCTION public.similarity(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.similarity(text, text) TO service_role;


--
-- Name: FUNCTION similarity_dist(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.similarity_dist(text, text) TO postgres;
GRANT ALL ON FUNCTION public.similarity_dist(text, text) TO anon;
GRANT ALL ON FUNCTION public.similarity_dist(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.similarity_dist(text, text) TO service_role;


--
-- Name: FUNCTION similarity_op(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.similarity_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.similarity_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.similarity_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.similarity_op(text, text) TO service_role;


--
-- Name: FUNCTION strict_word_similarity(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.strict_word_similarity(text, text) TO postgres;
GRANT ALL ON FUNCTION public.strict_word_similarity(text, text) TO anon;
GRANT ALL ON FUNCTION public.strict_word_similarity(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.strict_word_similarity(text, text) TO service_role;


--
-- Name: FUNCTION strict_word_similarity_commutator_op(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.strict_word_similarity_commutator_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.strict_word_similarity_commutator_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.strict_word_similarity_commutator_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.strict_word_similarity_commutator_op(text, text) TO service_role;


--
-- Name: FUNCTION strict_word_similarity_dist_commutator_op(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.strict_word_similarity_dist_commutator_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.strict_word_similarity_dist_commutator_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.strict_word_similarity_dist_commutator_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.strict_word_similarity_dist_commutator_op(text, text) TO service_role;


--
-- Name: FUNCTION strict_word_similarity_dist_op(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.strict_word_similarity_dist_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.strict_word_similarity_dist_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.strict_word_similarity_dist_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.strict_word_similarity_dist_op(text, text) TO service_role;


--
-- Name: FUNCTION strict_word_similarity_op(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.strict_word_similarity_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.strict_word_similarity_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.strict_word_similarity_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.strict_word_similarity_op(text, text) TO service_role;


--
-- Name: FUNCTION sync_pagamentos_medico_id(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.sync_pagamentos_medico_id() TO anon;
GRANT ALL ON FUNCTION public.sync_pagamentos_medico_id() TO authenticated;
GRANT ALL ON FUNCTION public.sync_pagamentos_medico_id() TO service_role;


--
-- Name: FUNCTION sync_user_profile(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.sync_user_profile() TO anon;
GRANT ALL ON FUNCTION public.sync_user_profile() TO authenticated;
GRANT ALL ON FUNCTION public.sync_user_profile() TO service_role;


--
-- Name: FUNCTION sync_vagas_beneficio_vaga_id(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.sync_vagas_beneficio_vaga_id() TO anon;
GRANT ALL ON FUNCTION public.sync_vagas_beneficio_vaga_id() TO authenticated;
GRANT ALL ON FUNCTION public.sync_vagas_beneficio_vaga_id() TO service_role;


--
-- Name: FUNCTION update_documento_status(p_carteira_id uuid, p_tipo text, p_status boolean, p_user_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_documento_status(p_carteira_id uuid, p_tipo text, p_status boolean, p_user_id uuid) TO anon;
GRANT ALL ON FUNCTION public.update_documento_status(p_carteira_id uuid, p_tipo text, p_status boolean, p_user_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.update_documento_status(p_carteira_id uuid, p_tipo text, p_status boolean, p_user_id uuid) TO service_role;


--
-- Name: FUNCTION update_documento_url(p_carteira_id uuid, p_tipo text, p_url text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_documento_url(p_carteira_id uuid, p_tipo text, p_url text) TO anon;
GRANT ALL ON FUNCTION public.update_documento_url(p_carteira_id uuid, p_tipo text, p_url text) TO authenticated;
GRANT ALL ON FUNCTION public.update_documento_url(p_carteira_id uuid, p_tipo text, p_url text) TO service_role;


--
-- Name: FUNCTION update_especialidade_nome(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_especialidade_nome() TO anon;
GRANT ALL ON FUNCTION public.update_especialidade_nome() TO authenticated;
GRANT ALL ON FUNCTION public.update_especialidade_nome() TO service_role;


--
-- Name: FUNCTION update_phone_forotp(user_id uuid, areacodeindex integer, telefone text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_phone_forotp(user_id uuid, areacodeindex integer, telefone text) TO anon;
GRANT ALL ON FUNCTION public.update_phone_forotp(user_id uuid, areacodeindex integer, telefone text) TO authenticated;
GRANT ALL ON FUNCTION public.update_phone_forotp(user_id uuid, areacodeindex integer, telefone text) TO service_role;


--
-- Name: FUNCTION update_total_candidaturas(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_total_candidaturas() TO anon;
GRANT ALL ON FUNCTION public.update_total_candidaturas() TO authenticated;
GRANT ALL ON FUNCTION public.update_total_candidaturas() TO service_role;


--
-- Name: FUNCTION update_total_plantoes_medico(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_total_plantoes_medico() TO anon;
GRANT ALL ON FUNCTION public.update_total_plantoes_medico() TO authenticated;
GRANT ALL ON FUNCTION public.update_total_plantoes_medico() TO service_role;


--
-- Name: FUNCTION updatethisuser(user_id uuid, e_mail text, p_phone text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.updatethisuser(user_id uuid, e_mail text, p_phone text) TO anon;
GRANT ALL ON FUNCTION public.updatethisuser(user_id uuid, e_mail text, p_phone text) TO authenticated;
GRANT ALL ON FUNCTION public.updatethisuser(user_id uuid, e_mail text, p_phone text) TO service_role;


--
-- Name: FUNCTION validar_localizacao_medico(p_hospital_id uuid, p_latitude numeric, p_longitude numeric); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.validar_localizacao_medico(p_hospital_id uuid, p_latitude numeric, p_longitude numeric) TO anon;
GRANT ALL ON FUNCTION public.validar_localizacao_medico(p_hospital_id uuid, p_latitude numeric, p_longitude numeric) TO authenticated;
GRANT ALL ON FUNCTION public.validar_localizacao_medico(p_hospital_id uuid, p_latitude numeric, p_longitude numeric) TO service_role;


--
-- Name: FUNCTION validate_checkin_timing(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.validate_checkin_timing() TO anon;
GRANT ALL ON FUNCTION public.validate_checkin_timing() TO authenticated;
GRANT ALL ON FUNCTION public.validate_checkin_timing() TO service_role;


--
-- Name: FUNCTION validate_checkout_timing(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.validate_checkout_timing() TO anon;
GRANT ALL ON FUNCTION public.validate_checkout_timing() TO authenticated;
GRANT ALL ON FUNCTION public.validate_checkout_timing() TO service_role;


--
-- Name: FUNCTION verificar_conflito_antes_candidatura(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.verificar_conflito_antes_candidatura() TO anon;
GRANT ALL ON FUNCTION public.verificar_conflito_antes_candidatura() TO authenticated;
GRANT ALL ON FUNCTION public.verificar_conflito_antes_candidatura() TO service_role;


--
-- Name: FUNCTION verificar_conflito_vaga_designada(p_medico_id uuid, p_data date, p_hora_inicio time without time zone, p_hora_fim time without time zone); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.verificar_conflito_vaga_designada(p_medico_id uuid, p_data date, p_hora_inicio time without time zone, p_hora_fim time without time zone) TO anon;
GRANT ALL ON FUNCTION public.verificar_conflito_vaga_designada(p_medico_id uuid, p_data date, p_hora_inicio time without time zone, p_hora_fim time without time zone) TO authenticated;
GRANT ALL ON FUNCTION public.verificar_conflito_vaga_designada(p_medico_id uuid, p_data date, p_hora_inicio time without time zone, p_hora_fim time without time zone) TO service_role;


--
-- Name: FUNCTION verificar_consistencia_status_vagas(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.verificar_consistencia_status_vagas() TO anon;
GRANT ALL ON FUNCTION public.verificar_consistencia_status_vagas() TO authenticated;
GRANT ALL ON FUNCTION public.verificar_consistencia_status_vagas() TO service_role;


--
-- Name: FUNCTION word_similarity(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.word_similarity(text, text) TO postgres;
GRANT ALL ON FUNCTION public.word_similarity(text, text) TO anon;
GRANT ALL ON FUNCTION public.word_similarity(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.word_similarity(text, text) TO service_role;


--
-- Name: FUNCTION word_similarity_commutator_op(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.word_similarity_commutator_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.word_similarity_commutator_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.word_similarity_commutator_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.word_similarity_commutator_op(text, text) TO service_role;


--
-- Name: FUNCTION word_similarity_dist_commutator_op(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.word_similarity_dist_commutator_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.word_similarity_dist_commutator_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.word_similarity_dist_commutator_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.word_similarity_dist_commutator_op(text, text) TO service_role;


--
-- Name: FUNCTION word_similarity_dist_op(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.word_similarity_dist_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.word_similarity_dist_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.word_similarity_dist_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.word_similarity_dist_op(text, text) TO service_role;


--
-- Name: FUNCTION word_similarity_op(text, text); Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION public.word_similarity_op(text, text) TO postgres;
GRANT ALL ON FUNCTION public.word_similarity_op(text, text) TO anon;
GRANT ALL ON FUNCTION public.word_similarity_op(text, text) TO authenticated;
GRANT ALL ON FUNCTION public.word_similarity_op(text, text) TO service_role;


--
-- Name: FUNCTION apply_rls(wal jsonb, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO postgres;
GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO dashboard_user;


--
-- Name: FUNCTION build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO postgres;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO anon;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO service_role;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION "cast"(val text, type_ regtype); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO postgres;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO dashboard_user;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO anon;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO authenticated;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO service_role;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO supabase_realtime_admin;


--
-- Name: FUNCTION check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO postgres;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO anon;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO authenticated;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO service_role;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO supabase_realtime_admin;


--
-- Name: FUNCTION is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO postgres;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO anon;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO service_role;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO supabase_realtime_admin;


--
-- Name: FUNCTION list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO supabase_realtime_admin;


--
-- Name: FUNCTION quote_wal2json(entity regclass); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO postgres;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO anon;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO authenticated;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO service_role;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO supabase_realtime_admin;


--
-- Name: FUNCTION send(payload jsonb, event text, topic text, private boolean); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO postgres;
GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO dashboard_user;


--
-- Name: FUNCTION subscription_check_filters(); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO postgres;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO dashboard_user;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO anon;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO authenticated;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO service_role;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO supabase_realtime_admin;


--
-- Name: FUNCTION to_regrole(role_name text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO postgres;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO anon;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO authenticated;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO service_role;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO supabase_realtime_admin;


--
-- Name: FUNCTION topic(); Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON FUNCTION realtime.topic() TO postgres;
GRANT ALL ON FUNCTION realtime.topic() TO dashboard_user;


--
-- Name: FUNCTION http_request(); Type: ACL; Schema: supabase_functions; Owner: supabase_functions_admin
--

REVOKE ALL ON FUNCTION supabase_functions.http_request() FROM PUBLIC;
GRANT ALL ON FUNCTION supabase_functions.http_request() TO postgres;
GRANT ALL ON FUNCTION supabase_functions.http_request() TO anon;
GRANT ALL ON FUNCTION supabase_functions.http_request() TO authenticated;
GRANT ALL ON FUNCTION supabase_functions.http_request() TO service_role;


--
-- Name: FUNCTION _crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO service_role;


--
-- Name: FUNCTION create_secret(new_secret text, new_name text, new_description text, new_key_id uuid); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault.create_secret(new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault.create_secret(new_secret text, new_name text, new_description text, new_key_id uuid) TO service_role;


--
-- Name: FUNCTION update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault.update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault.update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid) TO service_role;


--
-- Name: TABLE audit_log_entries; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.audit_log_entries TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.audit_log_entries TO postgres;
GRANT SELECT ON TABLE auth.audit_log_entries TO postgres WITH GRANT OPTION;


--
-- Name: TABLE flow_state; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.flow_state TO postgres;
GRANT SELECT ON TABLE auth.flow_state TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.flow_state TO dashboard_user;


--
-- Name: TABLE identities; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.identities TO postgres;
GRANT SELECT ON TABLE auth.identities TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.identities TO dashboard_user;


--
-- Name: TABLE instances; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.instances TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.instances TO postgres;
GRANT SELECT ON TABLE auth.instances TO postgres WITH GRANT OPTION;


--
-- Name: TABLE mfa_amr_claims; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_amr_claims TO postgres;
GRANT SELECT ON TABLE auth.mfa_amr_claims TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_amr_claims TO dashboard_user;


--
-- Name: TABLE mfa_challenges; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_challenges TO postgres;
GRANT SELECT ON TABLE auth.mfa_challenges TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_challenges TO dashboard_user;


--
-- Name: TABLE mfa_factors; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_factors TO postgres;
GRANT SELECT ON TABLE auth.mfa_factors TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.mfa_factors TO dashboard_user;


--
-- Name: TABLE oauth_clients; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.oauth_clients TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.oauth_clients TO dashboard_user;


--
-- Name: TABLE one_time_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.one_time_tokens TO postgres;
GRANT SELECT ON TABLE auth.one_time_tokens TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.one_time_tokens TO dashboard_user;


--
-- Name: TABLE refresh_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.refresh_tokens TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.refresh_tokens TO postgres;
GRANT SELECT ON TABLE auth.refresh_tokens TO postgres WITH GRANT OPTION;


--
-- Name: SEQUENCE refresh_tokens_id_seq; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO dashboard_user;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO postgres;


--
-- Name: TABLE saml_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_providers TO postgres;
GRANT SELECT ON TABLE auth.saml_providers TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_providers TO dashboard_user;


--
-- Name: TABLE saml_relay_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_relay_states TO postgres;
GRANT SELECT ON TABLE auth.saml_relay_states TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.saml_relay_states TO dashboard_user;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT ON TABLE auth.schema_migrations TO postgres WITH GRANT OPTION;


--
-- Name: TABLE sessions; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sessions TO postgres;
GRANT SELECT ON TABLE auth.sessions TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sessions TO dashboard_user;


--
-- Name: TABLE sso_domains; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_domains TO postgres;
GRANT SELECT ON TABLE auth.sso_domains TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_domains TO dashboard_user;


--
-- Name: TABLE sso_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_providers TO postgres;
GRANT SELECT ON TABLE auth.sso_providers TO postgres WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.sso_providers TO dashboard_user;


--
-- Name: TABLE users; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.users TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE auth.users TO postgres;
GRANT SELECT ON TABLE auth.users TO postgres WITH GRANT OPTION;


--
-- Name: TABLE pg_stat_statements; Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE extensions.pg_stat_statements TO postgres WITH GRANT OPTION;


--
-- Name: TABLE pg_stat_statements_info; Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE extensions.pg_stat_statements_info TO postgres WITH GRANT OPTION;


--
-- Name: TABLE banner_mkt; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.banner_mkt TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.banner_mkt TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.banner_mkt TO service_role;


--
-- Name: SEQUENCE "bannerMKT_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public."bannerMKT_id_seq" TO anon;
GRANT ALL ON SEQUENCE public."bannerMKT_id_seq" TO authenticated;
GRANT ALL ON SEQUENCE public."bannerMKT_id_seq" TO service_role;


--
-- Name: TABLE beneficios; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.beneficios TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.beneficios TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.beneficios TO service_role;


--
-- Name: TABLE candidaturas; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.candidaturas TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.candidaturas TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.candidaturas TO service_role;


--
-- Name: TABLE carteira_digital; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.carteira_digital TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.carteira_digital TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.carteira_digital TO service_role;


--
-- Name: TABLE checkin_checkout; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.checkin_checkout TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.checkin_checkout TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.checkin_checkout TO service_role;


--
-- Name: SEQUENCE checkin_checkout_index_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.checkin_checkout_index_seq TO anon;
GRANT ALL ON SEQUENCE public.checkin_checkout_index_seq TO authenticated;
GRANT ALL ON SEQUENCE public.checkin_checkout_index_seq TO service_role;


--
-- Name: TABLE checkin_checkout_nofitications; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.checkin_checkout_nofitications TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.checkin_checkout_nofitications TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.checkin_checkout_nofitications TO service_role;


--
-- Name: TABLE clean_hospital; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.clean_hospital TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.clean_hospital TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.clean_hospital TO service_role;


--
-- Name: SEQUENCE clean_hospital_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.clean_hospital_id_seq TO anon;
GRANT ALL ON SEQUENCE public.clean_hospital_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.clean_hospital_id_seq TO service_role;


--
-- Name: TABLE codigos_area; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.codigos_area TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.codigos_area TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.codigos_area TO service_role;


--
-- Name: TABLE email_verification_tokens; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.email_verification_tokens TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.email_verification_tokens TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.email_verification_tokens TO service_role;


--
-- Name: SEQUENCE email_verification_tokens_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.email_verification_tokens_id_seq TO anon;
GRANT ALL ON SEQUENCE public.email_verification_tokens_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.email_verification_tokens_id_seq TO service_role;


--
-- Name: TABLE equipes; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.equipes TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.equipes TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.equipes TO service_role;


--
-- Name: TABLE equipes_medicos; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.equipes_medicos TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.equipes_medicos TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.equipes_medicos TO service_role;


--
-- Name: TABLE escalistas; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.escalistas TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.escalistas TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.escalistas TO service_role;


--
-- Name: TABLE especialidades; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.especialidades TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.especialidades TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.especialidades TO service_role;


--
-- Name: TABLE estados_brasil; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.estados_brasil TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.estados_brasil TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.estados_brasil TO service_role;


--
-- Name: TABLE formas_recebimento; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.formas_recebimento TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.formas_recebimento TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.formas_recebimento TO service_role;


--
-- Name: TABLE grades; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.grades TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.grades TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.grades TO service_role;


--
-- Name: TABLE grupos; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.grupos TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.grupos TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.grupos TO service_role;


--
-- Name: TABLE hospitais; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.hospitais TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.hospitais TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.hospitais TO service_role;


--
-- Name: TABLE hospital_geofencing; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.hospital_geofencing TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.hospital_geofencing TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.hospital_geofencing TO service_role;


--
-- Name: TABLE medicos; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.medicos TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.medicos TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.medicos TO service_role;


--
-- Name: TABLE medicos_favoritos; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.medicos_favoritos TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.medicos_favoritos TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.medicos_favoritos TO service_role;


--
-- Name: TABLE medicos_precadastro; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.medicos_precadastro TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.medicos_precadastro TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.medicos_precadastro TO service_role;


--
-- Name: TABLE notifications; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.notifications TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.notifications TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.notifications TO service_role;


--
-- Name: TABLE pagamentos; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.pagamentos TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.pagamentos TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.pagamentos TO service_role;


--
-- Name: TABLE periodos; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.periodos TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.periodos TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.periodos TO service_role;


--
-- Name: TABLE requisitos; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.requisitos TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.requisitos TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.requisitos TO service_role;


--
-- Name: TABLE setores; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.setores TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.setores TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.setores TO service_role;


--
-- Name: TABLE tipos_vaga; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.tipos_vaga TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.tipos_vaga TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.tipos_vaga TO service_role;


--
-- Name: TABLE user_profile; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.user_profile TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.user_profile TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.user_profile TO service_role;


--
-- Name: TABLE vagas; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.vagas TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.vagas TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.vagas TO service_role;


--
-- Name: SEQUENCE "vagas_Index_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public."vagas_Index_seq" TO anon;
GRANT ALL ON SEQUENCE public."vagas_Index_seq" TO authenticated;
GRANT ALL ON SEQUENCE public."vagas_Index_seq" TO service_role;


--
-- Name: TABLE vagas_beneficios; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.vagas_beneficios TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.vagas_beneficios TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.vagas_beneficios TO service_role;


--
-- Name: SEQUENCE "vagas_beneficio_Index_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public."vagas_beneficio_Index_seq" TO anon;
GRANT ALL ON SEQUENCE public."vagas_beneficio_Index_seq" TO authenticated;
GRANT ALL ON SEQUENCE public."vagas_beneficio_Index_seq" TO service_role;


--
-- Name: TABLE vagas_recorrencias; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.vagas_recorrencias TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.vagas_recorrencias TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.vagas_recorrencias TO service_role;


--
-- Name: TABLE vagas_requisitos; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.vagas_requisitos TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.vagas_requisitos TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.vagas_requisitos TO service_role;


--
-- Name: TABLE vagas_salvas; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.vagas_salvas TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.vagas_salvas TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.vagas_salvas TO service_role;


--
-- Name: SEQUENCE vagas_salvas_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.vagas_salvas_id_seq TO anon;
GRANT ALL ON SEQUENCE public.vagas_salvas_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.vagas_salvas_id_seq TO service_role;


--
-- Name: TABLE vw_folha_pagamento; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.vw_folha_pagamento TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.vw_folha_pagamento TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.vw_folha_pagamento TO service_role;


--
-- Name: TABLE vw_vagas_candidaturas; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.vw_vagas_candidaturas TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.vw_vagas_candidaturas TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.vw_vagas_candidaturas TO service_role;


--
-- Name: TABLE whatsapp_number; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.whatsapp_number TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.whatsapp_number TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE public.whatsapp_number TO service_role;


--
-- Name: TABLE messages; Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages TO dashboard_user;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO anon;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO authenticated;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO service_role;


--
-- Name: TABLE messages_2025_10_13; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_10_13 TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_10_13 TO dashboard_user;


--
-- Name: TABLE messages_2025_10_14; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_10_14 TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_10_14 TO dashboard_user;


--
-- Name: TABLE messages_2025_10_15; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_10_15 TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_10_15 TO dashboard_user;


--
-- Name: TABLE messages_2025_10_16; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_10_16 TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_10_16 TO dashboard_user;


--
-- Name: TABLE messages_2025_10_17; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_10_17 TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_10_17 TO dashboard_user;


--
-- Name: TABLE messages_2025_10_18; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_10_18 TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_10_18 TO dashboard_user;


--
-- Name: TABLE messages_2025_10_19; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_10_19 TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.messages_2025_10_19 TO dashboard_user;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.schema_migrations TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.schema_migrations TO dashboard_user;
GRANT SELECT ON TABLE realtime.schema_migrations TO anon;
GRANT SELECT ON TABLE realtime.schema_migrations TO authenticated;
GRANT SELECT ON TABLE realtime.schema_migrations TO service_role;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.schema_migrations TO supabase_realtime_admin;


--
-- Name: TABLE subscription; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.subscription TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.subscription TO dashboard_user;
GRANT SELECT ON TABLE realtime.subscription TO anon;
GRANT SELECT ON TABLE realtime.subscription TO authenticated;
GRANT SELECT ON TABLE realtime.subscription TO service_role;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE realtime.subscription TO supabase_realtime_admin;


--
-- Name: SEQUENCE subscription_id_seq; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO postgres;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO dashboard_user;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO anon;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO service_role;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO supabase_realtime_admin;


--
-- Name: TABLE buckets; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.buckets TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.buckets TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.buckets TO service_role;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.buckets TO postgres;


--
-- Name: TABLE buckets_analytics; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.buckets_analytics TO service_role;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.buckets_analytics TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.buckets_analytics TO anon;


--
-- Name: TABLE iceberg_namespaces; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.iceberg_namespaces TO service_role;
GRANT SELECT ON TABLE storage.iceberg_namespaces TO authenticated;
GRANT SELECT ON TABLE storage.iceberg_namespaces TO anon;


--
-- Name: TABLE iceberg_tables; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.iceberg_tables TO service_role;
GRANT SELECT ON TABLE storage.iceberg_tables TO authenticated;
GRANT SELECT ON TABLE storage.iceberg_tables TO anon;


--
-- Name: TABLE objects; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.objects TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.objects TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.objects TO service_role;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.objects TO postgres;


--
-- Name: TABLE prefixes; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.prefixes TO service_role;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.prefixes TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.prefixes TO anon;


--
-- Name: TABLE s3_multipart_uploads; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.s3_multipart_uploads TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO anon;


--
-- Name: TABLE s3_multipart_uploads_parts; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE storage.s3_multipart_uploads_parts TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO anon;


--
-- Name: TABLE hooks; Type: ACL; Schema: supabase_functions; Owner: supabase_functions_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE supabase_functions.hooks TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE supabase_functions.hooks TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE supabase_functions.hooks TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE supabase_functions.hooks TO service_role;


--
-- Name: SEQUENCE hooks_id_seq; Type: ACL; Schema: supabase_functions; Owner: supabase_functions_admin
--

GRANT ALL ON SEQUENCE supabase_functions.hooks_id_seq TO postgres;
GRANT ALL ON SEQUENCE supabase_functions.hooks_id_seq TO anon;
GRANT ALL ON SEQUENCE supabase_functions.hooks_id_seq TO authenticated;
GRANT ALL ON SEQUENCE supabase_functions.hooks_id_seq TO service_role;


--
-- Name: TABLE migrations; Type: ACL; Schema: supabase_functions; Owner: supabase_functions_admin
--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE supabase_functions.migrations TO postgres;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE supabase_functions.migrations TO anon;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE supabase_functions.migrations TO authenticated;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE supabase_functions.migrations TO service_role;


--
-- Name: TABLE secrets; Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT SELECT,REFERENCES,DELETE,TRUNCATE ON TABLE vault.secrets TO postgres WITH GRANT OPTION;
GRANT SELECT,DELETE ON TABLE vault.secrets TO service_role;


--
-- Name: TABLE decrypted_secrets; Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT SELECT,REFERENCES,DELETE,TRUNCATE ON TABLE vault.decrypted_secrets TO postgres WITH GRANT OPTION;
GRANT SELECT,DELETE ON TABLE vault.decrypted_secrets TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON SEQUENCES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON FUNCTIONS TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: supabase_functions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON SEQUENCES TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: supabase_functions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT ALL ON FUNCTIONS TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: supabase_functions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA supabase_functions GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO service_role;


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


ALTER EVENT TRIGGER issue_graphql_placeholder OWNER TO supabase_admin;

--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


ALTER EVENT TRIGGER issue_pg_cron_access OWNER TO supabase_admin;

--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


ALTER EVENT TRIGGER issue_pg_graphql_access OWNER TO supabase_admin;

--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


ALTER EVENT TRIGGER issue_pg_net_access OWNER TO supabase_admin;

--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


ALTER EVENT TRIGGER pgrst_ddl_watch OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


ALTER EVENT TRIGGER pgrst_drop_watch OWNER TO supabase_admin;

--
-- PostgreSQL database dump complete
--

\unrestrict Pdei6QR1zvvmrJSp0ybcGx6g6OMqwHnY8vHCNtjCgdZjWyj8m9ctwmlrHeBSPH5

