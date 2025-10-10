-- Migration: Remove user_profile dependency from escalista table
-- File: 20251008000001_escalista_remove_user_profile_dependency.sql

BEGIN;

-- 1. Remover views que dependem de escalista_id
DROP VIEW IF EXISTS public.vw_distribuicao_especialidades;  -- Depende de vagas_completo
DROP VIEW IF EXISTS public.vw_vagas_por_mes;                -- Depende de vagas_completo  
DROP VIEW IF EXISTS public.vagas_completo;                  -- Depende diretamente de escalista_id
DROP VIEW IF EXISTS public.vw_candidaturas_pendentes;
DROP VIEW IF EXISTS public.vw_todas_candidaturas;  
DROP VIEW IF EXISTS public.vw_vagas_candidaturas;

-- 2. Remover policies que dependem de escalista_auth_id
DROP POLICY IF EXISTS escalista_read_own_grupo ON public.grupo;
DROP POLICY IF EXISTS vagas_recorrencia_escalista_policy ON public.vagas_recorrencia;

-- 3. Remover constraints dependentes primeiro
-- Remover constraints das tabelas que dependem de escalista
ALTER TABLE public.medicos_favoritos 
DROP CONSTRAINT IF EXISTS fk_medicos_favoritos_escalista;

ALTER TABLE public.vagas 
DROP CONSTRAINT IF EXISTS vagas_vagas_escalista_fkey;

-- 4. Remover constraints da tabela escalista
ALTER TABLE public.escalista 
DROP CONSTRAINT IF EXISTS escalista_escalista_auth_id_fkey;

ALTER TABLE public.escalista 
DROP CONSTRAINT IF EXISTS escalista_pkey;

ALTER TABLE public.escalista 
DROP CONSTRAINT IF EXISTS "escalista_id-de-escalista_key";

-- 5. Remover índices relacionados
DROP INDEX IF EXISTS idx_escalista_nome;
DROP INDEX IF EXISTS idx_escalista_grupo;

-- 6. Adicionar nova coluna id temporariamente
ALTER TABLE public.escalista 
ADD COLUMN id_temp uuid;

-- 4. Migrar dados: usar escalista_auth_id como novo id
UPDATE public.escalista 
SET id_temp = escalista_auth_id;

-- 5. Remover colunas antigas
ALTER TABLE public.escalista 
DROP COLUMN escalista_auth_id,
DROP COLUMN escalista_id;

-- 6. Renomear coluna temporária para id
ALTER TABLE public.escalista 
RENAME COLUMN id_temp TO id;

-- 7. Definir id como NOT NULL
ALTER TABLE public.escalista 
ALTER COLUMN id SET NOT NULL;

-- 8. Criar nova primary key
ALTER TABLE public.escalista 
ADD CONSTRAINT escalista_pkey PRIMARY KEY (id);

-- 9. Criar foreign key para auth.users
ALTER TABLE public.escalista 
ADD CONSTRAINT escalista_id_fkey 
FOREIGN KEY (id) REFERENCES auth.users(id) ON UPDATE CASCADE ON DELETE CASCADE;

-- 10. Recriar índices
CREATE INDEX idx_escalista_nome ON public.escalista USING btree (escalista_nome);
CREATE INDEX idx_escalista_grupo ON public.escalista USING btree (grupo_id);
CREATE INDEX idx_escalista_id ON public.escalista USING btree (id);

-- 11. Atualizar tabelas que referenciam escalista
-- Atualizar medicos_favoritos
ALTER TABLE public.medicos_favoritos 
DROP CONSTRAINT IF EXISTS fk_medicos_favoritos_escalista;

-- Remover referências antigas e recriar com nova estrutura
UPDATE public.medicos_favoritos 
SET escalista_id = (
    SELECT e.id 
    FROM public.escalista e 
    WHERE e.escalista_nome = (
        SELECT e2.escalista_nome 
        FROM public.escalista e2 
        WHERE e2.id = medicos_favoritos.escalista_id
    )
    LIMIT 1
) 
WHERE EXISTS (
    SELECT 1 FROM public.escalista e 
    WHERE e.id = medicos_favoritos.escalista_id
);

-- Recriar constraint para medicos_favoritos
ALTER TABLE public.medicos_favoritos 
ADD CONSTRAINT fk_medicos_favoritos_escalista 
FOREIGN KEY (escalista_id) REFERENCES public.escalista(id) ON DELETE CASCADE;

-- 12. Atualizar vagas que referenciam escalista
ALTER TABLE public.vagas 
DROP CONSTRAINT IF EXISTS vagas_vagas_escalista_fkey;

-- Atualizar referências em vagas
UPDATE public.vagas 
SET vagas_escalista = (
    SELECT e.id 
    FROM public.escalista e 
    WHERE e.escalista_nome = (
        SELECT e2.escalista_nome 
        FROM public.escalista e2 
        WHERE e2.id = vagas.vagas_escalista
    )
    LIMIT 1
) 
WHERE EXISTS (
    SELECT 1 FROM public.escalista e 
    WHERE e.id = vagas.vagas_escalista
);

-- Recriar constraint para vagas
ALTER TABLE public.vagas 
ADD CONSTRAINT vagas_vagas_escalista_fkey 
FOREIGN KEY (vagas_escalista) REFERENCES public.escalista(id) ON UPDATE CASCADE ON DELETE SET DEFAULT;

-- 13. Atualizar função get_current_user_grupo_id para usar nova estrutura
CREATE OR REPLACE FUNCTION public.get_current_user_grupo_id()
RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
    current_user_id UUID;
    grupo_id_result UUID;
BEGIN
    -- Obter o ID do usuário atual
    current_user_id := auth.uid();
    
    -- Se não há usuário autenticado, retornar NULL
    IF current_user_id IS NULL THEN
        RETURN NULL;
    END IF;

    -- Buscar o grupo_id usando o novo esquema (id = auth.users.id)
    SELECT grupo_id INTO grupo_id_result
    FROM escalista
    WHERE id = current_user_id;
    
    -- Retornar o grupo_id encontrado (ou NULL se não encontrado)
    RETURN grupo_id_result;
END;
$$;

-- 14. Atualizar RLS policies que dependem da estrutura antiga
DROP POLICY IF EXISTS escalista_policy ON public.escalista;

CREATE POLICY escalista_policy ON public.escalista 
TO authenticated 
USING (
    CASE
        WHEN (public.get_current_user_grupo_id() IS NULL) THEN true
        ELSE (grupo_id = public.get_current_user_grupo_id())
    END
);

-- 15. Atualizar trigger de criação de escalista
DROP TRIGGER IF EXISTS user_profile_criar_escalista_trigger ON public.user_profile;

-- Criar nova trigger diretamente na auth.users
CREATE OR REPLACE FUNCTION public.criar_escalista_from_auth()
RETURNS TRIGGER 
LANGUAGE plpgsql SECURITY DEFINER
AS $$
DECLARE
  user_phone varchar;
  user_metadata jsonb;
  display_name text;
BEGIN
  -- Log de início da função
  RAISE NOTICE 'TRIGGER DEBUG: criar_escalista_from_auth() executada para usuário %', NEW.id;
  
  -- Verificar se o role foi definido como 'astronauta' nos metadados
  user_metadata := COALESCE(NEW.raw_user_meta_data, '{}'::jsonb);
  
  -- Log dos metadados
  RAISE NOTICE 'TRIGGER DEBUG: Metadados do usuário: %', user_metadata;
  
  -- Verificar se é um convite para escalista
  IF user_metadata->>'platform_origin' = 'houston' OR 
     user_metadata->'data'->>'platform_origin' = 'houston' THEN
    
    RAISE NOTICE 'TRIGGER DEBUG: Usuário identificado como escalista (platform_origin=houston)';
    
    -- Obter dados do usuário
    display_name := COALESCE(
      user_metadata->'data'->>'display_name',
      user_metadata->>'display_name',
      split_part(NEW.email, '@', 1)
    );
    
    -- Obter telefone dos metadados
    user_phone := COALESCE(
      user_metadata->'data'->>'phone',
      user_metadata->>'phone',
      '(00) 00000-0000'
    );
    
    -- Log dos dados extraídos
    RAISE NOTICE 'TRIGGER DEBUG: display_name=%, telefone=%, email=%', display_name, user_phone, NEW.email;
    
    -- Adicionar prefixo '55' se não existir e o telefone não for nulo
    IF user_phone IS NOT NULL AND user_phone NOT LIKE '55%' THEN
      user_phone := '55' || user_phone;
    END IF;
    
    RAISE NOTICE 'TRIGGER DEBUG: Telefone processado: %', user_phone;
    
    -- Inserir novo registro na tabela escalista
    INSERT INTO public.escalista (
      id,
      escalista_nome,
      escalista_telefone,
      escalista_email,
      escalista_createdate,
      escalista_updateat,
      escalista_updateby
    )
    VALUES (
      NEW.id,                    -- id = auth.users.id
      display_name,              -- nome do display_name
      user_phone,                -- telefone dos metadados
      NEW.email,                 -- email do auth.users
      NOW(),
      NOW(),
      NEW.id
    )
    ON CONFLICT (id) DO UPDATE SET
      escalista_nome = display_name,
      escalista_telefone = user_phone,
      escalista_email = NEW.email,
      escalista_updateat = NOW();
      
    RAISE NOTICE 'TRIGGER DEBUG: Escalista criado/atualizado com sucesso para usuário %', NEW.id;
  ELSE
    RAISE NOTICE 'TRIGGER DEBUG: Usuário % não é escalista (platform_origin não é houston)', NEW.id;
  END IF;
  
  RETURN NEW;
END;
$$;

-- Criar trigger na auth.users para criar escalista automaticamente
DROP TRIGGER IF EXISTS auth_users_criar_escalista_trigger ON auth.users;
CREATE TRIGGER auth_users_criar_escalista_trigger
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.criar_escalista_from_auth();

-- 16. Recriar policies que foram removidas (adaptadas para nova estrutura)
-- Policy para grupo - escalista pode ler grupos do seu próprio grupo
CREATE POLICY escalista_read_own_grupo ON public.grupo 
FOR SELECT TO authenticated 
USING (
  EXISTS (
    SELECT 1 
    FROM public.escalista e
    WHERE e.id = auth.uid() 
    AND e.grupo_id = grupo.grupo_id
  )
);

-- Policy para vagas_recorrencia - escalista pode acessar recorrências das suas vagas
CREATE POLICY vagas_recorrencia_escalista_policy ON public.vagas_recorrencia 
TO authenticated 
USING (
  -- Astronautas podem acessar tudo
  (EXISTS (
    SELECT 1 FROM public.user_profile
    WHERE user_profile.id = auth.uid() 
    AND user_profile.role = 'astronauta'
  )) 
  OR 
  -- Criador pode acessar
  (created_by = auth.uid()) 
  OR 
  -- Escalista pode acessar recorrências das vagas do seu grupo
  (EXISTS (
    SELECT 1 
    FROM public.vagas v
    JOIN public.escalista e ON e.grupo_id = v.grupo_id
    WHERE v.recorrencia_id = vagas_recorrencia.recorrencia_id 
    AND e.id = auth.uid()
  ))
)
WITH CHECK (
  -- Astronautas podem criar tudo
  (EXISTS (
    SELECT 1 FROM public.user_profile
    WHERE user_profile.id = auth.uid() 
    AND user_profile.role = 'astronauta'
  )) 
  OR 
  -- Escalista pode criar recorrências no seu grupo
  (EXISTS (
    SELECT 1 
    FROM public.escalista e
    WHERE e.id = auth.uid()
  ))
);

-- 17. Recriar views com nova estrutura (escalista.id em vez de escalista.escalista_id)
-- View: vagas_completo (principal - outras dependem desta)
CREATE OR REPLACE VIEW public.vagas_completo WITH (security_invoker='on') AS
SELECT 
    v.vagas_id,
    v.vagas_createdate,
    v.vagas_data,
    v.vagas_horainicio,
    v.vagas_horafim,
    v.vagas_valor,
    v.vagas_datapagamento,
    fr.forma_recebimento AS vagas_formarecebimento,
    v.vagas_observacoes,
    h.hospital_nome,
    s.setor_nome,
    p.periodo AS periodo_nome,
    t.tipo AS tipo_nome,
    esp.especialidade_nome,
    g.grupo_id,
    g.grupo_nome,
    g.grupo_responsavel,
    g.grupo_telefone,
    g.grupo_email,
    v.vagas_status,
    e.escalista_nome,
    e.id AS escalista_id,  -- Mudança aqui: e.id em vez de e.escalista_id
    e.escalista_telefone,
    e.escalista_email,
    h.latitude AS hospital_lat,
    h.longitude AS hospital_log,
    h.endereco_formatado AS hospital_end,
    h.hospital_avatar
FROM vagas v
LEFT JOIN hospital h ON v.vagas_hospital = h.hospital_id
LEFT JOIN setores s ON v.vagas_setor = s.setor_id
LEFT JOIN periodo p ON v.vagas_periodo = p.periodo_id
LEFT JOIN tipovaga t ON v.vagas_tipo = t.id
LEFT JOIN escalista e ON v.vagas_escalista = e.id  -- Mudança aqui: e.id em vez de e.escalista_id
LEFT JOIN especialidades esp ON v.vaga_especialidade = esp.especialidade_id
LEFT JOIN grupo g ON v.grupo_id = g.grupo_id
LEFT JOIN formas_recebimento fr ON v.vagas_formarecebimento = fr.id;

-- View: vw_distribuicao_especialidades (depende de vagas_completo)
CREATE OR REPLACE VIEW public.vw_distribuicao_especialidades WITH (security_invoker='on') AS
SELECT 
    vagas_completo.especialidade_nome AS especialidade,
    COUNT(*) AS total
FROM public.vagas_completo
GROUP BY vagas_completo.especialidade_nome
ORDER BY COUNT(*) DESC;

-- View: vw_candidaturas_pendentes
CREATE OR REPLACE VIEW public.vw_candidaturas_pendentes WITH (security_invoker='on') AS
SELECT 
    (m.medico_primeironome || ' ' || m.medico_sobrenome) AS nome_medico,
    m.medico_crm AS crm_medico,
    h.hospital_nome AS nome_hospital,
    v.vagas_data AS data_plantao,
    v.vagas_horainicio AS hora_inicio,
    v.vagas_horafim AS hora_fim,
    e.escalista_nome AS nome_escalista,
    e.escalista_telefone AS telefone_escalista,
    c.candidatura_status AS status_candidatura,
    c.candidaturas_id,
    c.medico_id AS medicos_id,
    c.vagas_id,
    espec_medico.especialidade_nome AS especialidade_medico,
    espec_vaga.especialidade_nome AS especialidade_vaga,
    m.medico_telefone AS telefone_medico
FROM candidaturas c
JOIN medicos m ON c.medico_id = m.id
LEFT JOIN especialidades espec_medico ON m.medico_especialidade = espec_medico.especialidade_id
JOIN vagas v ON c.vagas_id = v.vagas_id
LEFT JOIN especialidades espec_vaga ON v.vaga_especialidade = espec_vaga.especialidade_id
JOIN hospital h ON v.vagas_hospital = h.hospital_id
JOIN escalista e ON v.vagas_escalista = e.id  -- Mudança aqui: e.id em vez de e.escalista_id
WHERE c.candidatura_status = 'PENDENTE'
ORDER BY v.vagas_data, v.vagas_horainicio;

-- View: vw_todas_candidaturas  
CREATE OR REPLACE VIEW public.vw_todas_candidaturas WITH (security_invoker='on') AS
SELECT 
    (m.medico_primeironome || ' ' || m.medico_sobrenome) AS nome_medico,
    m.medico_crm AS crm_medico,
    h.hospital_nome AS nome_hospital,
    v.vagas_data AS data_plantao,
    v.vagas_horainicio AS hora_inicio,
    v.vagas_horafim AS hora_fim,
    e.escalista_nome AS nome_escalista,
    e.escalista_telefone AS telefone_escalista,
    c.candidatura_status AS status_candidatura,
    c.candidaturas_id,
    c.medico_id AS medicos_id,
    c.vagas_id,
    espec_medico.especialidade_nome AS especialidade_medico,
    espec_vaga.especialidade_nome AS especialidade_vaga,
    m.medico_telefone AS telefone_medico
FROM candidaturas c
JOIN medicos m ON c.medico_id = m.id
LEFT JOIN especialidades espec_medico ON m.medico_especialidade = espec_medico.especialidade_id
JOIN vagas v ON c.vagas_id = v.vagas_id
LEFT JOIN especialidades espec_vaga ON v.vaga_especialidade = espec_vaga.especialidade_id
JOIN hospital h ON v.vagas_hospital = h.hospital_id
JOIN escalista e ON v.vagas_escalista = e.id  -- Mudança aqui: e.id em vez de e.escalista_id
ORDER BY v.vagas_data, v.vagas_horainicio;

-- View: vw_vagas_candidaturas
CREATE OR REPLACE VIEW public.vw_vagas_candidaturas WITH (security_invoker='on') AS
SELECT 
    v.vagas_id,
    v.vagas_data,
    v.vagas_horainicio,
    v.vagas_horafim,
    v.vagas_valor,
    v.vagas_createdate,
    v.vagas_updateat,
    v.vagas_updateby,
    v.vaga_especialidade,
    v.vagas_hospital,
    v.vagas_escalista,
    v.vagas_observacoes,
    v.grupo_id,
    h.hospital_nome,
    h.hospital_logradouro,
    h.hospital_numero,
    h.hospital_cidade,
    h.hospital_bairro,
    h.hospital_estado,
    h.hospital_cep,
    e.escalista_nome,
    e.escalista_telefone,
    e.escalista_email,
    e.id AS escalista_id,  -- Mudança aqui: e.id em vez de e.escalista_id
    esp.especialidade_nome,
    COALESCE(stats.total_candidaturas, 0) AS total_candidaturas,
    COALESCE(stats.candidaturas_pendentes, 0) AS candidaturas_pendentes,
    COALESCE(stats.candidaturas_aceitas, 0) AS candidaturas_aceitas,
    COALESCE(stats.candidaturas_rejeitadas, 0) AS candidaturas_rejeitadas
FROM vagas v
LEFT JOIN hospital h ON v.vagas_hospital = h.hospital_id
LEFT JOIN escalista e ON v.vagas_escalista = e.id  -- Mudança aqui: e.id em vez de e.escalista_id
LEFT JOIN especialidades esp ON v.vaga_especialidade = esp.especialidade_id
LEFT JOIN (
    SELECT 
        vagas_id,
        COUNT(*) AS total_candidaturas,
        COUNT(*) FILTER (WHERE candidatura_status = 'PENDENTE') AS candidaturas_pendentes,
        COUNT(*) FILTER (WHERE candidatura_status = 'ACEITA') AS candidaturas_aceitas,
        COUNT(*) FILTER (WHERE candidatura_status = 'REJEITADA') AS candidaturas_rejeitadas
    FROM candidaturas
    GROUP BY vagas_id
) stats ON v.vagas_id = stats.vagas_id;

-- View: vw_vagas_por_mes (depende de vagas_completo)
CREATE OR REPLACE VIEW public.vw_vagas_por_mes WITH (security_invoker='on') AS
SELECT 
    DATE_TRUNC('month', vagas_completo.vagas_data::timestamp without time zone) AS mes,
    COUNT(vagas_completo.vagas_id) AS total_vagas
FROM public.vagas_completo
GROUP BY DATE_TRUNC('month', vagas_completo.vagas_data::timestamp without time zone)
ORDER BY DATE_TRUNC('month', vagas_completo.vagas_data::timestamp without time zone);

-- 18. Comentários da nova estrutura
COMMENT ON TABLE public.escalista IS 'Tabela de escalistas - id agora referencia diretamente auth.users.id';
COMMENT ON COLUMN public.escalista.id IS 'ID do escalista - chave primária e foreign key para auth.users.id';

-- 19. Verificação final
DO $$
BEGIN
    -- Verificar se a estrutura foi criada corretamente
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_name = 'escalista' 
        AND constraint_name = 'escalista_pkey'
        AND constraint_type = 'PRIMARY KEY'
    ) THEN
        RAISE EXCEPTION 'Primary key não foi criada corretamente na tabela escalista';
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_name = 'escalista' 
        AND constraint_name = 'escalista_id_fkey'
        AND constraint_type = 'FOREIGN KEY'
    ) THEN
        RAISE EXCEPTION 'Foreign key para auth.users não foi criada corretamente';
    END IF;
    
    RAISE NOTICE 'Migration completed successfully - escalista table restructured';
END $$;

COMMIT;

-- Conceder uso do schema
GRANT USAGE ON SCHEMA houston TO anon, authenticated, service_role;

-- Conceder permissões na tabela user_roles
GRANT ALL ON houston.user_roles TO service_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON houston.user_roles TO authenticated;

-- Garantir que futuras tabelas também tenham permissões
ALTER DEFAULT PRIVILEGES IN SCHEMA houston
GRANT ALL ON TABLES TO service_role;