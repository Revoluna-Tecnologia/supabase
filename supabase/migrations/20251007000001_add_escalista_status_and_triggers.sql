-- =========================================================================
-- MIGRATION: Adicionar sistema de status e automação para escalistas
-- Data: 2025-10-07
-- Descrição: Adiciona campo de status, triggers e funções para automação
-- =========================================================================

-- Adicionar campo de status na tabela escalista
ALTER TABLE public.escalista 
ADD COLUMN IF NOT EXISTS escalista_status character varying not null default 'ativo';

-- Criar índice para o status
CREATE INDEX IF NOT EXISTS idx_escalista_status ON public.escalista USING btree (escalista_status);

-- Criar enum para status (opcional, para validação)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'escalista_status_enum') THEN
        CREATE TYPE escalista_status_enum AS ENUM ('pendente', 'ativo', 'inativo', 'suspenso');
    END IF;
END $$;

-- Atualizar escalistas existentes para status 'ativo' (assumindo que já confirmaram)
UPDATE public.escalista 
SET escalista_status = 'ativo' 
WHERE escalista_updateby IS NOT NULL;

-- =========================================================================
-- FUNÇÕES PRINCIPAIS
-- =========================================================================



-- Função para ativar escalista quando email é confirmado
CREATE OR REPLACE FUNCTION activate_escalista_on_confirmation()
RETURNS TRIGGER AS $$
DECLARE
    log_prefix TEXT := '[ACTIVATE_ESCALISTA]';
    affected_rows INTEGER;
BEGIN
    -- Log para debug
    RAISE NOTICE '%: Verificando confirmação de email: %', log_prefix, NEW.email;
    
    -- Só processa se email foi confirmado (mudou de NULL para data)
    IF NEW.invited_at IS NOT NULL 
       AND OLD.email_confirmed_at IS NULL 
       AND NEW.email_confirmed_at IS NOT NULL THEN
        
        RAISE NOTICE '%: Email confirmado, ativando escalista...', log_prefix;
        
        -- Atualizar status para ativo
        UPDATE public.escalista 
        SET 
            escalista_status = 'ativo',
            escalista_updateat = CURRENT_TIMESTAMP
        WHERE escalista_email = NEW.email 
          AND escalista_status = 'pendente';
        
        GET DIAGNOSTICS affected_rows = ROW_COUNT;
        
        IF affected_rows > 0 THEN
            RAISE NOTICE '%: ✅ Escalista ativado: %', log_prefix, NEW.email;
        ELSE
            RAISE NOTICE '%: ⚠️ Nenhum escalista pendente encontrado para: %', log_prefix, NEW.email;
        END IF;
    END IF;
    
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '%: Erro ao ativar escalista: %', log_prefix, SQLERRM;
        RETURN NEW;  -- Não falha a operação principal
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =========================================================================
-- TRIGGERS
-- =========================================================================

-- Remove triggers antigas se existirem
DROP TRIGGER IF EXISTS escalista_new_user_trigger ON auth.users;
DROP TRIGGER IF EXISTS escalista_new_user_trigger_v2 ON auth.users;
DROP TRIGGER IF EXISTS escalista_invite_accepted_trigger ON auth.users;
DROP TRIGGER IF EXISTS escalista_invite_sent_trigger ON auth.users;

-- Trigger 2: Ativa escalista quando email é confirmado
CREATE TRIGGER activate_escalista_on_email_confirmation
    AFTER UPDATE OF email_confirmed_at ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION activate_escalista_on_confirmation();

-- =========================================================================
-- FUNÇÕES UTILITÁRIAS
-- =========================================================================

-- Função para criar escalista diretamente a partir de email
CREATE OR REPLACE FUNCTION create_escalista_from_user_email(user_email TEXT)
RETURNS TABLE(
    success BOOLEAN,
    created_escalista_id UUID,
    message TEXT,
    user_data JSONB
) AS $$
DECLARE
    user_record RECORD;
    escalista_exists BOOLEAN;
    new_escalista_id UUID;
    user_name TEXT;
    user_phone TEXT;
    user_metadata JSONB;
    group_id UUID := NULL; -- Pode ser ajustado conforme necessidade
BEGIN
    RAISE NOTICE '[CREATE_ESCALISTA] Processando email: %', user_email;
    
    -- Buscar dados do usuário
    SELECT 
        id, email, invited_at, email_confirmed_at, 
        raw_user_meta_data, created_at
    INTO user_record
    FROM auth.users
    WHERE email = user_email
    LIMIT 1;
    
    -- Verificar se usuário existe
    IF NOT FOUND THEN
        success := FALSE;
        created_escalista_id := NULL;
        message := 'Usuário não encontrado: ' || user_email;
        user_data := NULL;
        RETURN NEXT;
        RETURN;
    END IF;
    
    -- Verificar se escalista já existe
    SELECT EXISTS(
        SELECT 1 FROM public.escalista WHERE escalista_email = user_email
    ) INTO escalista_exists;
    
    IF escalista_exists THEN
        SELECT e.escalista_id INTO new_escalista_id
        FROM public.escalista e
        WHERE e.escalista_email = user_email
        LIMIT 1;
        
        success := TRUE;
        created_escalista_id := new_escalista_id;
        message := 'Escalista já existe para este email';
        user_data := user_record.raw_user_meta_data;
        RETURN NEXT;
        RETURN;
    END IF;
    
    -- Extrair dados do metadata
    user_metadata := COALESCE(user_record.raw_user_meta_data, '{}'::jsonb);
    
    user_name := COALESCE(
        user_metadata->>'display_name',
        user_metadata->>'name',
        user_metadata->>'full_name',
        user_metadata->>'nome',
        split_part(user_email, '@', 1)
    );
    
    user_phone := COALESCE(
        user_metadata->>'phone',
        user_metadata->>'telefone',
        user_metadata->>'phone_number',
        '(00) 00000-0000'
    );
    group_id := COALESCE(
        user_metadata->>'group_id',
        NULL
    )::UUID;
    
    -- Verificar/criar user_profile
    IF NOT EXISTS (SELECT 1 FROM public.user_profile WHERE id = user_record.id) THEN
        INSERT INTO public.user_profile (
            id, created_at, role, displayname
        ) VALUES (
            user_record.id,
            COALESCE(user_record.created_at, CURRENT_TIMESTAMP),
            'escalista',
            user_name
        );
    END IF;
    
    -- Inserir escalista
    INSERT INTO public.escalista (
        id,
        escalista_nome,
        escalista_telefone,
        escalista_email,
        escalista_status,
        grupo_id,
        escalista_createdate,
        escalista_updateat,
        escalista_updateby
    ) VALUES (
        user_record.id,
        user_name,
        user_phone,
        user_email,
        CASE 
            WHEN user_record.email_confirmed_at IS NOT NULL THEN 'ativo'
            ELSE 'pendente'
        END,
        group_id,
        COALESCE(user_record.created_at, CURRENT_TIMESTAMP),
        CURRENT_TIMESTAMP,
        user_record.id
    ) RETURNING id INTO new_escalista_id;
    
    -- Inserir na tabela houston.user_roles
    INSERT INTO houston.user_roles (
        user_id,
        role,
        group_ids,
        hospital_ids,
        setor_ids
    ) VALUES (
        user_record.id,
        'escalista',
        CASE 
            WHEN group_id IS NOT NULL THEN ARRAY[group_id]
            ELSE '{}'::uuid[]
        END,
        '{}',  -- hospital_ids vazio por padrão
        '{}'   -- setor_ids vazio por padrão
    )
    ON CONFLICT (user_id, role) DO UPDATE SET
        group_ids = CASE 
            WHEN group_id IS NOT NULL THEN ARRAY[group_id]
            ELSE '{}'::uuid[]
        END;
    
    RAISE NOTICE '[CREATE_ESCALISTA] Role de escalista adicionado na tabela houston.user_roles para user_id: % com group_id: %', user_record.id, group_id;
    
    -- Retornar sucesso
    success := TRUE;
    created_escalista_id := new_escalista_id;
    message := format('Escalista criado: %s (%s)', 
        user_name,
        CASE WHEN user_record.email_confirmed_at IS NOT NULL THEN 'ativo' ELSE 'pendente' END
    );
    user_data := user_metadata;
    
    RETURN NEXT;
    RETURN;
    
EXCEPTION
    WHEN OTHERS THEN
        success := FALSE;
        created_escalista_id := NULL;
        message := 'Erro ao criar escalista: ' || SQLERRM;
        user_data := NULL;
        RETURN NEXT;
        RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para processar todos os usuários convidados sem escalista
CREATE OR REPLACE FUNCTION create_escalistas_for_all_invited_users()
RETURNS TABLE(
    email TEXT,
    status TEXT,
    escalista_id UUID,
    message TEXT
) AS $$
DECLARE
    user_record RECORD;
    result RECORD;
BEGIN
    FOR user_record IN (
        SELECT u.email
        FROM auth.users u
        LEFT JOIN public.escalista e ON e.escalista_email = u.email
        WHERE u.invited_at IS NOT NULL 
          AND e.id IS NULL
        ORDER BY u.invited_at DESC
    ) LOOP
        
        SELECT * INTO result
        FROM create_escalista_from_user_email(user_record.email);
        
        email := user_record.email;
        status := CASE WHEN result.success THEN 'SUCCESS' ELSE 'FAILED' END;
        escalista_id := result.created_escalista_id;
        message := result.message;
        
        RETURN NEXT;
    END LOOP;
    
    RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para verificar status dos convites e escalistas
CREATE OR REPLACE FUNCTION check_escalista_invite_status()
RETURNS TABLE(
    email TEXT,
    user_status TEXT,
    escalista_status TEXT,
    invited_at TIMESTAMPTZ,
    confirmed_at TIMESTAMPTZ,
    escalista_nome TEXT,
    escalista_id UUID,
    observacoes TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.email::TEXT,
        CASE 
            WHEN u.invited_at IS NULL THEN 'SEM_CONVITE'
            WHEN u.email_confirmed_at IS NULL THEN 'CONVITE_PENDENTE'
            ELSE 'CONVITE_ACEITO'
        END::TEXT as user_status,
        COALESCE(e.escalista_status, 'NAO_EXISTE')::TEXT as escalista_status,
        u.invited_at,
        u.email_confirmed_at,
        e.escalista_nome::TEXT,
        e.escalista_id,
        CASE 
            WHEN u.invited_at IS NOT NULL AND e.escalista_id IS NULL THEN 'Convite enviado mas escalista não criado'
            WHEN u.email_confirmed_at IS NOT NULL AND e.escalista_status = 'pendente' THEN 'Convite aceito mas escalista ainda pendente'
            WHEN u.email_confirmed_at IS NOT NULL AND e.escalista_status = 'ativo' THEN 'Funcionando corretamente'
            WHEN u.invited_at IS NULL AND e.escalista_id IS NOT NULL THEN 'Escalista existe mas sem convite registrado'
            ELSE 'Status normal'
        END::TEXT as observacoes
    FROM auth.users u
    LEFT JOIN public.escalista e ON e.escalista_email = u.email
    WHERE u.invited_at IS NOT NULL OR e.escalista_id IS NOT NULL
    ORDER BY u.invited_at DESC NULLS LAST;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;



-- =========================================================================
-- PERMISSÕES
-- =========================================================================

-- Conceder permissões necessárias
GRANT USAGE ON SCHEMA auth TO postgres, service_role;
GRANT SELECT ON auth.users TO postgres, service_role;
GRANT INSERT, UPDATE, SELECT ON public.escalista TO postgres, service_role;
GRANT INSERT, UPDATE, SELECT ON public.user_profile TO postgres, service_role;

-- =========================================================================
-- VERIFICAÇÃO FINAL
-- =========================================================================

-- Verificar s