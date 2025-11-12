-- ARQUIVO rename_colunas_ordenado.sql
-- Versão ordenada para aplicação no Supabase
-- Ordem baseada nas dependências de foreign keys

-- =====================================================
-- FASE 1: TABELAS BASE (sem dependências externas)
-- =====================================================

--
-- tabela: user_profile
--

ALTER TABLE public.user_profile
    RENAME COLUMN "areacodeIndex" TO areacode_index;

ALTER TABLE public.user_profile
    RENAME COLUMN "UFindex" TO uf_index;

ALTER TABLE public.user_profile
    RENAME COLUMN "specialtyIndex" TO specialty_index;


--
-- tabela: estados_brasil
--

alter table public.estados_brasil 
    rename column "Nome" to nome;

alter table public.estados_brasil 
    rename column "Sigla" to sigla;

alter table public.estados_brasil 
    rename column "Lista" to lista;


--
-- tabela: codigos_de_area
--

alter table public.codigos_de_area 
    rename "Index" to index;

alter table public.codigos_de_area 
    rename "País" to pais;

alter table public.codigos_de_area 
    rename "Código" to codigo;

alter table public.codigos_de_area 
    rename "Formato" to formato;

alter table public.codigos_de_area 
    rename  "Caracteres Máx" to caracteres_max;

alter table public.codigos_de_area 
    rename "Lista" to lista;

--refatorar constraint
ALTER TABLE public.codigos_de_area
    DROP CONSTRAINT IF EXISTS codigosdearea_pkey;

ALTER TABLE public.codigos_de_area
    ADD CONSTRAINT codigosdearea_pkey PRIMARY KEY (pais);


--
-- tabela: bannerMKT
--

-- 1) Renomear colunas
ALTER TABLE public.banner_mkt RENAME COLUMN "page index" TO page_index;
ALTER TABLE public.banner_mkt RENAME COLUMN "URL" TO "url";


--
-- tabela: beneficio_tipo
--

-- 0) Primeiro remover foreign keys que dependem desta tabela
ALTER TABLE public.vagas_beneficio
    DROP CONSTRAINT IF EXISTS vagas_beneficio_beneficio_id_fkey;

-- 1) Remover constraints e índices que dependem dos nomes antigos
 ALTER TABLE public.beneficio_tipo
   DROP CONSTRAINT IF EXISTS beneficio_tipo_pkey,
   DROP CONSTRAINT IF EXISTS beneficio_tipo_beneficio_id_key,
   DROP CONSTRAINT IF EXISTS beneficio_tipo_beneficio_nome_key;

 DROP INDEX IF EXISTS idx_beneficio_nome;

-- 2) Renomear colunas
ALTER TABLE public.beneficio_tipo
  RENAME COLUMN beneficio_id TO id;

ALTER TABLE public.beneficio_tipo
  RENAME COLUMN beneficio_nome TO nome;

-- 3) Recriar constraints com os novos nomes
 ALTER TABLE public.beneficio_tipo
   ADD CONSTRAINT beneficio_tipo_pkey PRIMARY KEY (id),
   ADD CONSTRAINT beneficio_tipo_beneficio_id_key UNIQUE (id),
   ADD CONSTRAINT beneficio_tipo_beneficio_nome_key UNIQUE (nome);

-- 4) Recriar índice com novo nome de coluna
 CREATE INDEX IF NOT EXISTS idx_beneficio_nome
   ON public.beneficio_tipo USING btree (nome);

-- 5) Adicionar coluna created_at
ALTER TABLE public.beneficio_tipo
  ADD COLUMN created_at timestamptz NOT NULL DEFAULT now();


--
-- tabela: especialidades
--

-- renomear a PK
alter table public.especialidades 
    rename column especialidade_id to id;

alter table public.especialidades 
    rename column especialidade_created_at to created_at;

alter table public.especialidades 
    rename column especialidade_index to index;

alter table public.especialidades 
    rename column especialidade_nome to nome;

-- mudar tipo para timestampz com fuso horario
alter table public.especialidades 
    alter column created_at type timestamptz
    USING created_at AT TIME ZONE 'America/Sao_Paulo';


--
-- tabela: grupo
-- 

-- 0) Primeiro remover todas as foreign keys que dependem desta tabela
ALTER TABLE public.equipes
    DROP CONSTRAINT IF EXISTS fk_grupo_id;

ALTER TABLE public.equipes_medicos
    DROP CONSTRAINT IF EXISTS equipes_medicos_grupo_id_fkey;

ALTER TABLE public.escalista
    DROP CONSTRAINT IF EXISTS escalista_grupo_id_fkey;

ALTER TABLE public.grades
    DROP CONSTRAINT IF EXISTS grades_grupo_id_fkey;

ALTER TABLE public.medicos_favoritos
    DROP CONSTRAINT IF EXISTS medicos_favoritos_grupo_id_fkey;

ALTER TABLE public.vagas
    DROP CONSTRAINT IF EXISTS vagas_grupo_id_fkey;

-- 1) renomear a PK
alter table public.grupo 
    rename column grupo_id to id;

alter table public.grupo 
    rename column grupo_nome to nome;

alter table public.grupo 
    rename column grupo_responsavel to responsavel;

alter table public.grupo 
    rename column grupo_telefone to telefone;

alter table public.grupo 
    rename column grupo_email to email;

alter table public.grupo 
    rename column grupo_createdate to created_at;

-- mudar tipo para timestampz com fuso horario
alter table public.grupo 
    alter column created_at type timestamptz
    USING created_at AT TIME ZONE 'America/Sao_Paulo';

-- criar coluna upaded_at
alter table public.grupo 
    add column updated_at timestamptz NOT NULL DEFAULT now();

-- Remover possíveis primary keys existentes
ALTER TABLE public.grupo DROP CONSTRAINT IF EXISTS grupo_pkey;
ALTER TABLE public.grupo DROP CONSTRAINT IF EXISTS grupo_grupo_nome_key;

ALTER TABLE public.grupo
    ADD CONSTRAINT grupo_pkey PRIMARY KEY (id),
    ADD CONSTRAINT grupo_grupo_nome_key UNIQUE (nome);

-- recriar indice
DROP INDEX IF EXISTS idx_grupo_nome;
CREATE INDEX IF NOT EXISTS idx_grupo_nome ON public.grupo USING btree (nome) TABLESPACE pg_default;


--
-- tabela: hospital
--

-- 0) Primeiro remover todas as foreign keys que dependem desta tabela
ALTER TABLE public.vagas
    DROP CONSTRAINT IF EXISTS vagas_vagas_hospital_fkey;

ALTER TABLE public.grades
    DROP CONSTRAINT IF EXISTS grades_hospital_id_fkey;

ALTER TABLE public.hospital_geofencing
    DROP CONSTRAINT IF EXISTS hospital_geofencing_hospital_id_fkey;

-- 1) renomear a PK
ALTER TABLE public.hospital 
    RENAME COLUMN hospital_id TO id;

ALTER TABLE public.hospital 
    RENAME COLUMN hospital_nome TO nome;

ALTER TABLE public.hospital 
    RENAME COLUMN hospital_logradouro TO logradouro;

ALTER TABLE public.hospital 
    RENAME COLUMN hospital_numero TO numero;

ALTER TABLE public.hospital 
    RENAME COLUMN hospital_cidade TO cidade;

ALTER TABLE public.hospital 
    RENAME COLUMN hospital_bairro TO bairro;

ALTER TABLE public.hospital 
    RENAME COLUMN hospital_estado TO estado;

ALTER TABLE public.hospital 
    RENAME COLUMN hospital_pais TO pais;

ALTER TABLE public.hospital 
    RENAME COLUMN hospital_cep TO cep;

ALTER TABLE public.hospital 
    RENAME COLUMN hospital_avatar TO avatar;

-- criar coluna created_at e upaded_at
alter table public.hospital 
    add column created_at timestamptz NOT NULL DEFAULT now();

alter table public.hospital 
    add column updated_at timestamptz NOT NULL DEFAULT now();

-- mudar constraints
-- Remover possíveis primary keys existentes
ALTER TABLE public.hospital DROP CONSTRAINT IF EXISTS hospital_pkey;

ALTER TABLE public.hospital
    ADD CONSTRAINT hospital_pkey PRIMARY KEY (id);

-- recriar indice
DROP INDEX IF EXISTS idx_hospital_nome;
CREATE INDEX IF NOT EXISTS idx_hospital_nome ON public.hospital USING btree (nome) TABLESPACE pg_default;


--
-- tabela: setores
--

-- PRIMEIRO: Remover foreign keys que dependem da primary key de setores antes de alterá-la
ALTER TABLE grades DROP CONSTRAINT IF EXISTS grades_setor_id_fkey;
ALTER TABLE vagas DROP CONSTRAINT IF EXISTS vagas_vagas_setor_fkey;

ALTER TABLE public.setores
    RENAME COLUMN setor_id TO id;

ALTER TABLE public.setores
    RENAME COLUMN setor_nome TO nome;

-- Remover possíveis primary keys existentes
ALTER TABLE public.setores DROP CONSTRAINT IF EXISTS setores_pkey;

ALTER TABLE public.setores
    ADD CONSTRAINT setores_pkey PRIMARY KEY (id);

-- recriar index
DROP INDEX IF EXISTS idx_setor_nome;
CREATE INDEX IF NOT EXISTS idx_setor_nome ON public.setores USING btree (nome) TABLESPACE pg_default;


--
-- tabela: periodo
--

-- PRIMEIRO: Remover foreign keys que dependem da primary key de periodo antes de alterá-la
ALTER TABLE vagas DROP CONSTRAINT IF EXISTS vagas_vagas_periodo_fkey;

ALTER TABLE public.periodo
    RENAME COLUMN periodo_id TO id;

-- recriar a PK
ALTER TABLE public.periodo
    DROP CONSTRAINT IF EXISTS periodo_pkey;

ALTER TABLE public.periodo
    ADD CONSTRAINT periodo_pkey PRIMARY KEY (id);


-- 
-- tabela: requisito_tipo
-- 

-- PRIMEIRO: Remover foreign keys que dependem da primary key de requisito_tipo antes de alterá-la
ALTER TABLE vagas_requisito DROP CONSTRAINT IF EXISTS vagas_requisito_requisito_id_fkey;

ALTER TABLE public.requisito_tipo
    RENAME COLUMN requisito_id TO id;

ALTER TABLE public.requisito_tipo
    RENAME COLUMN requisito_nome TO nome;

ALTER TABLE public.requisito_tipo
    DROP CONSTRAINT IF EXISTS requisito_tipo_pkey;

ALTER TABLE public.requisito_tipo
    ADD CONSTRAINT requisito_tipo_pkey PRIMARY KEY (id);

--
-- tabela: vagas_recorrencia
--

-- PRIMEIRO: Remover foreign keys que dependem da primary key de vagas_recorrencia antes de alterá-la
ALTER TABLE public.vagas DROP CONSTRAINT IF EXISTS vagas_recorrencia_id_fkey;

ALTER TABLE public.vagas_recorrencia
    RENAME COLUMN recorrencia_id TO id;

ALTER TABLE public.vagas_recorrencia
    DROP CONSTRAINT IF EXISTS vagas_recorrencia_pkey;

ALTER TABLE public.vagas_recorrencia
    ADD CONSTRAINT vagas_recorrencia_pkey PRIMARY KEY (id);


-- =====================================================
-- FASE 2: TABELAS QUE DEPENDEM DE user_profile
-- =====================================================

--
-- tabela: escalista
--

-- PRIMEIRO: Remover foreign keys que dependem da primary key de escalista antes de alterá-la
ALTER TABLE vagas DROP CONSTRAINT IF EXISTS vagas_vagas_escalista_fkey;
ALTER TABLE medicos_favoritos DROP CONSTRAINT IF EXISTS fk_medicos_favoritos_escalista;

-- renomear a PK
alter table public.escalista 
    rename column escalista_id to id;

alter table public.escalista 
    rename column escalista_auth_id to auth_id;

alter table public.escalista 
    rename column escalista_nome to nome;

alter table public.escalista 
    rename column escalista_telefone to telefone;

alter table public.escalista 
    rename column escalista_email to email;

alter table public.escalista 
    rename column escalista_createdate to created_at;

alter table public.escalista 
    rename column escalista_updateat to update_at;

alter table public.escalista 
    rename column escalista_updateby to update_by;

-- mudar tipo para timestampz com fuso horario
alter table public.escalista 
    alter column created_at type timestamptz
    USING created_at AT TIME ZONE 'America/Sao_Paulo';

alter table public.escalista 
    alter column update_at type timestamptz
    USING update_at AT TIME ZONE 'America/Sao_Paulo';

-- Remover possíveis primary keys existentes
ALTER TABLE public.escalista DROP CONSTRAINT IF EXISTS escalista_pkey;
ALTER TABLE public.escalista
    DROP CONSTRAINT IF EXISTS escalista_escalista_auth_id_fkey;
    -- escalista_grupo_id_fkey já removida anteriormente na seção grupo

ALTER TABLE public.escalista
    ADD CONSTRAINT escalista_pkey PRIMARY KEY (id),
    ADD CONSTRAINT escalista_id_key UNIQUE (id),
    ADD CONSTRAINT escalista_escalista_auth_id_fkey FOREIGN KEY (auth_id) REFERENCES user_profile (id) ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT escalista_grupo_id_fkey FOREIGN KEY (grupo_id) REFERENCES grupo (id) ON UPDATE CASCADE ON DELETE CASCADE;

-- recriar indice
DROP INDEX IF EXISTS idx_escalista_nome;
CREATE INDEX IF NOT EXISTS idx_escalista_nome ON public.escalista USING btree (nome) TABLESPACE pg_default;


-- =====================================================
-- FASE 3: TABELA medicos (precisa vir antes de tabelas dependentes)
-- =====================================================

--
-- tabela: medicos
--

ALTER TABLE public.medicos RENAME COLUMN medico_rqe TO rqe;
ALTER TABLE public.medicos RENAME COLUMN medico_genero TO genero;
ALTER TABLE public.medicos RENAME COLUMN medico_cpf TO cpf;
ALTER TABLE public.medicos RENAME COLUMN medico_rg TO rg;
ALTER TABLE public.medicos RENAME COLUMN medico_crm TO crm;
ALTER TABLE public.medicos RENAME COLUMN medico_nomedafaculdade TO nome_faculdade;
ALTER TABLE public.medicos RENAME COLUMN medico_tipofaculdade TO tipo_faculdade;
ALTER TABLE public.medicos RENAME COLUMN medico_primeironome TO primeiro_nome;
ALTER TABLE public.medicos RENAME COLUMN medico_sobrenome TO sobrenome;
ALTER TABLE public.medicos RENAME COLUMN medico_email TO email;
ALTER TABLE public.medicos RENAME COLUMN medico_telefone TO telefone;
ALTER TABLE public.medicos RENAME COLUMN medico_datanascimento TO data_nascimento;
ALTER TABLE public.medicos RENAME COLUMN medico_logradouro TO logradouro;
ALTER TABLE public.medicos RENAME COLUMN medico_numero TO numero;
ALTER TABLE public.medicos RENAME COLUMN medico_bairro TO bairro;
ALTER TABLE public.medicos RENAME COLUMN medico_cidade TO cidade;
ALTER TABLE public.medicos RENAME COLUMN medico_estado TO estado;
ALTER TABLE public.medicos RENAME COLUMN medico_pais TO pais;
ALTER TABLE public.medicos RENAME COLUMN medico_cep TO cep;
ALTER TABLE public.medicos RENAME COLUMN medico_updateat TO update_at;
ALTER TABLE public.medicos RENAME COLUMN medico_updateby TO update_by;
ALTER TABLE public.medicos RENAME COLUMN medico_deleteat TO delete_at;
ALTER TABLE public.medicos RENAME COLUMN medico_status TO status;
ALTER TABLE public.medicos RENAME COLUMN medico_totalplantoes TO total_plantoes;
ALTER TABLE public.medicos RENAME COLUMN medico_especialidade TO especialidade_id;
ALTER TABLE public.medicos RENAME COLUMN medico_anoterminoespecializacao TO ano_termino_especializacao;
ALTER TABLE public.medicos RENAME COLUMN medico_anoformatura TO ano_formatura;

-- 1) Remover constraints antigas
ALTER TABLE public.medicos
    DROP CONSTRAINT IF EXISTS medicos_medico_cpf_key;
ALTER TABLE public.medicos
    DROP CONSTRAINT IF EXISTS medicos_medico_crm_key;
ALTER TABLE public.medicos
    DROP CONSTRAINT IF EXISTS medicos_medico_email_key;
ALTER TABLE public.medicos
    DROP CONSTRAINT IF EXISTS medicos_medico_rg_key;

-- 2) Criar constraints 
ALTER TABLE public.medicos
    ADD CONSTRAINT medicos_medico_cpf_key UNIQUE (cpf),
    ADD CONSTRAINT medicos_medico_crm_key UNIQUE (crm),
    ADD CONSTRAINT medicos_medico_email_key UNIQUE (email),
    ADD CONSTRAINT medicos_medico_rg_key UNIQUE (rg);

ALTER TABLE public.medicos
    DROP CONSTRAINT IF EXISTS medicos_medico_especialidade_fkey;

ALTER TABLE public.medicos
    ADD CONSTRAINT medicos_medico_especialidade_fkey
    FOREIGN KEY (especialidade_id) REFERENCES especialidades (id)
    ON UPDATE CASCADE ON DELETE CASCADE;

Alter TABLE public.medicos
    DROP CONSTRAINT IF EXISTS medicos_medico_status_check;

ALTER TABLE public.medicos
    ADD CONSTRAINT medicos_medico_status_check CHECK (
        status = ANY (
        ARRAY[
            'ativo'::text,
            'inativo'::text,
            'suspenso'::text
        ]
        )
    );

-- drop index antigas
drop index if exists idx_medico_cpf;
drop index if exists idx_medico_crm;
drop index if exists idx_medico_localidade;
drop index if exists idx_medico_nome;
drop index if exists idx_medicos_cpf;
drop index if exists idx_medicos_crm;
drop index if exists idx_medicos_email;
drop index if exists idx_medicos_especialidade;
drop index if exists idx_medicos_status;

-- recriar indexs
create index IF not exists idx_medico_cpf on public.medicos using btree (cpf) TABLESPACE pg_default;
create index IF not exists idx_medico_crm on public.medicos using btree (crm) TABLESPACE pg_default;
create index IF not exists idx_medico_localidade on public.medicos using btree (cidade, estado) TABLESPACE pg_default;
create index IF not exists idx_medico_nome on public.medicos using btree (primeiro_nome, sobrenome) TABLESPACE pg_default; 
create index IF not exists idx_medicos_cpf on public.medicos using btree (cpf) TABLESPACE pg_default;
create index IF not exists idx_medicos_crm on public.medicos using btree (crm) TABLESPACE pg_default;
create index IF not exists idx_medicos_email on public.medicos using btree (email) TABLESPACE pg_default;
create index IF not exists idx_medicos_especialidade on public.medicos using btree (especialidade_id) TABLESPACE pg_default;
create index IF not exists idx_medicos_status on public.medicos using btree (status) TABLESPACE pg_default;

-- funcoes
CREATE OR REPLACE FUNCTION update_especialidade_nome ()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
    SELECT esp.nome INTO NEW.especialidade_nome
    FROM public.especialidades esp
    WHERE esp.id = NEW.especialidade_id;
    RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION cleanup_medicos_precadastro ()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
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
$function$;


-- =====================================================
-- FASE 4: TABELA vagas (principal, usada por muitas outras)
-- =====================================================

--
-- tabela: vagas
--

-- PRIMEIRO: Remover foreign keys que dependem da primary key de vagas antes de alterá-la
ALTER TABLE candidaturas DROP CONSTRAINT IF EXISTS candidaturas_vagas_id_fkey;
ALTER TABLE checkin_checkout DROP CONSTRAINT IF EXISTS checkin_checkout_vagas_id_fkey;
ALTER TABLE pagamentos DROP CONSTRAINT IF EXISTS pagamentos_vagas_id_fkey;
ALTER TABLE vagas_beneficio DROP CONSTRAINT IF EXISTS vagas_beneficio_vaga_id_fkey;
ALTER TABLE vagas_requisito DROP CONSTRAINT IF EXISTS vagas_requisito_vagas_id_fkey;
ALTER TABLE vagas_salvas DROP CONSTRAINT IF EXISTS vagas_salvas_vagas_id_fkey;

-- 1. Renomear colunas
ALTER TABLE public.vagas RENAME column vagas_id TO id;
ALTER TABLE public.vagas RENAME column vagas_createdate TO created_at;
ALTER TABLE public.vagas RENAME column vagas_updateat TO updated_at;
ALTER TABLE public.vagas RENAME column vagas_updateby TO updated_by;
ALTER TABLE public.vagas RENAME column vagas_deleteat TO deleted_at;
ALTER TABLE public.vagas RENAME column vagas_data TO data;
ALTER TABLE public.vagas RENAME column vagas_hospital TO hospital_id;
ALTER TABLE public.vagas RENAME column vaga_especialidade TO especialidade_id;
ALTER TABLE public.vagas RENAME column vagas_setor TO setor_id;
ALTER TABLE public.vagas RENAME column vagas_periodo TO periodo_id;
ALTER TABLE public.vagas RENAME column vagas_escalista TO escalista_id;
ALTER TABLE public.vagas RENAME column vagas_tipo TO tipo_id;
ALTER TABLE public.vagas RENAME column vagas_datapagamento TO data_pagamento;
ALTER TABLE public.vagas RENAME column vagas_horainicio TO hora_inicio;
ALTER TABLE public.vagas RENAME column vagas_horafim TO hora_fim;
ALTER TABLE public.vagas RENAME column vagas_valor TO valor;
ALTER TABLE public.vagas RENAME column vagas_observacoes TO observacoes;
ALTER TABLE public.vagas RENAME column vagas_status TO status;
ALTER TABLE public.vagas RENAME column vagas_totalcandidaturas TO total_candidaturas;
ALTER TABLE public.vagas RENAME column vagas_formarecebimento TO forma_recebimento_id;
ALTER TABLE public.vagas RENAME column "Index" TO "index";

-- 1.5. Remover views que dependem das colunas da tabela vagas antes de alterar os tipos
DROP VIEW IF EXISTS "public"."vw_vagas_candidaturas" CASCADE;
DROP VIEW IF EXISTS "public"."vagas_completo" CASCADE;
DROP VIEW IF EXISTS "public"."vw_vagas_abertas" CASCADE;

-- 2. Alterar tipos de colunas para timestamptz (mantendo valores existentes)
ALTER TABLE public.vagas alter column created_at type timestamptz using created_at at time zone 'America/Sao_Paulo';
ALTER TABLE public.vagas alter column updated_at type timestamptz using updated_at at time zone 'America/Sao_Paulo';
ALTER TABLE public.vagas alter column deleted_at type timestamptz using deleted_at at time zone 'America/Sao_Paulo';

-- 3. Remover constraints antigas (vagas_grupo_id_fkey já removida anteriormente na seção grupo)
-- Remover possíveis primary keys existentes com nomes diferentes
alter table public.vagas drop constraint if exists vagas_pkey;
-- vagas_recorrencia_id_fkey já removida anteriormente na seção vagas_recorrencia
alter table public.vagas drop constraint if exists vagas_vaga_especialidade_fkey;
-- vagas_vagas_escalista_fkey já removida anteriormente na seção escalista
-- vagas_vagas_hospital_fkey já removida anteriormente na seção hospital
-- vagas_vagas_periodo_fkey já removida anteriormente na seção periodo
-- vagas_vagas_setor_fkey já removida anteriormente na seção setores
alter table public.vagas drop constraint if exists vagas_formarecebimento_fkey;
alter table public.vagas drop constraint if exists vagas_vagas_tipo_fkey;
alter table public.vagas drop constraint if exists vagas_vagas_valor_check;
alter table public.vagas drop constraint if exists vagas_vagas_status_check;

-- 4. Recriar constraints com nomes originais, mas referenciando sempre "id"
alter table public.vagas 
  add constraint vagas_pkey primary key (id),
  add constraint vagas_grupo_id_fkey foreign key (grupo_id) references grupo (id) on update cascade on delete cascade,
  add constraint vagas_recorrencia_id_fkey foreign key (recorrencia_id) references vagas_recorrencia (id),
  add constraint vagas_vaga_especialidade_fkey foreign key (especialidade_id) references especialidades (id),
  add constraint vagas_vagas_escalista_fkey foreign key (escalista_id) references escalista (id) on update cascade on delete set default,
  add constraint vagas_vagas_hospital_fkey foreign key (hospital_id) references hospital (id),
  add constraint vagas_vagas_periodo_fkey foreign key (periodo_id) references periodo (id),
  add constraint vagas_vagas_setor_fkey foreign key (setor_id) references setores (id),
  add constraint vagas_formarecebimento_fkey foreign key (forma_recebimento_id) references formas_recebimento (id),
  add constraint vagas_vagas_tipo_fkey foreign key (tipo_id) references tipo_vaga (id),
  add constraint vagas_vagas_valor_check check (((valor)::numeric > (0)::numeric)),
  add constraint vagas_vagas_status_check 
  check (
    (
      (status)::text = any (
        array[
          ('aberta'::character varying)::text,
          ('fechada'::character varying)::text,
          ('cancelada'::character varying)::text,
          ('anunciada'::character varying)::text
        ]
      )
    )
  );

DROP INDEX IF EXISTS idx_vaga_escalista;
DROP INDEX IF EXISTS idx_vaga_hospital;
DROP INDEX IF EXISTS idx_vaga_periodo;
DROP INDEX IF EXISTS idx_vaga_setor;
DROP INDEX IF EXISTS idx_vagas_especialidade;
DROP INDEX IF EXISTS idx_vagas_hospital;
DROP INDEX IF EXISTS idx_vagas_status;

CREATE INDEX IF NOT EXISTS idx_vaga_escalista ON public.vagas USING btree (escalista_id) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_vaga_hospital ON public.vagas USING btree (hospital_id) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_vaga_periodo ON public.vagas USING btree (data, periodo_id) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_vaga_setor ON public.vagas USING btree (setor_id) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_vagas_especialidade ON public.vagas USING btree (especialidade_id) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_vagas_hospital ON public.vagas USING btree (hospital_id) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_vagas_status ON public.vagas USING btree (status) TABLESPACE pg_default;

-- 1. Dropar a trigger antiga
drop trigger if exists vagas_1_reprovar_candidaturas_ao_cancelar on vagas;

-- 2. Criar novamente apontando para a coluna nova "status"
create trigger vagas_1_reprovar_candidaturas_ao_cancelar
after update of status on vagas
for each row
execute function atualizar_candidaturas_vaga_cancelada();

-- funcoes
CREATE OR REPLACE FUNCTION atualizar_candidaturas_vaga_cancelada()
RETURNS trigger
LANGUAGE plpgsql
-- SECURITY DEFINER
SET search_path TO 'public'
AS $function$
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
$function$;
create or replace view "public"."vagas_completo"
with (security_invoker = on)
as  SELECT v.id AS vagas_id,
    v.created_at AS vagas_createdate,
    v.data AS vagas_data,
    v.hora_inicio AS vagas_horainicio,
    v.hora_fim AS vagas_horafim,
    v.valor AS vagas_valor,
    v.data_pagamento AS vagas_datapagamento,
    fr.forma_recebimento AS vagas_formarecebimento,
    v.observacoes AS vagas_observacoes,
    h.nome AS hospital_nome,
    s.nome AS setor_nome,
    p.periodo AS periodo_nome,
    t.tipo AS tipo_nome,
    esp.nome AS especialidade_nome,
    g.id AS grupo_id,
    g.nome AS grupo_nome,
    g.responsavel AS grupo_responsavel,
    g.telefone AS grupo_telefone,
    g.email AS grupo_email,
    v.status AS vagas_status,
    e.nome AS escalista_nome,
    e.id AS escalista_id,
    e.telefone AS escalista_telefone,
    e.email AS escalista_email,
    h.latitude AS hospital_lat,
    h.longitude AS hospital_log,
    h.endereco_formatado AS hospital_end,
    h.avatar AS hospital_avatar
   FROM ((((((((vagas v
     LEFT JOIN hospital h ON ((v.hospital_id = h.id)))
     LEFT JOIN setores s ON ((v.setor_id = s.id)))
     LEFT JOIN periodo p ON ((v.periodo_id = p.id)))
     LEFT JOIN tipo_vaga t ON ((v.tipo_id = t.id)))
     LEFT JOIN escalista e ON ((v.escalista_id = e.id)))
     LEFT JOIN especialidades esp ON ((v.especialidade_id = esp.id)))
     LEFT JOIN grupo g ON ((v.grupo_id = g.id)))
     LEFT JOIN formas_recebimento fr ON ((v.forma_recebimento_id = fr.id)));

-- =====================================================
-- FASE 5: TABELAS QUE DEPENDEM DE vagas
-- =====================================================

--
-- tabela candidaturas
--

-- renomear a PK
alter table public.candidaturas 
    rename column candidaturas_id to id;

-- renomear colunas de atualização
alter table public.candidaturas 
    rename column candidaturas_updateat to updated_at;

alter table public.candidaturas 
    rename column candidaturas_updateby to updated_by;

alter table public.candidaturas 
    rename column candidatura_status to status;

alter table public.candidaturas 
    rename candidatos_dataconfirmacao to data_confirmacao;

alter table public.candidaturas 
    rename candidatos_createdate to created_at;

-- Remover foreign key dependente antes de alterar a primary key
ALTER TABLE public.pagamentos 
    DROP CONSTRAINT IF EXISTS pagamentos_candidaturas_id_fkey;

alter table public.candidaturas 
    drop constraint if exists candidaturas_pkey;

alter table public.candidaturas 
    add constraint candidaturas_pkey primary key (id);

-- candidaturas_vagas_id_fkey já removida anteriormente na seção vagas
-- alter table public.candidaturas 
--     drop constraint candidaturas_vagas_id_fkey;

alter table public.candidaturas 
    add constraint candidaturas_vagas_id_fkey foreign KEY (vagas_id) references vagas (id) on update CASCADE on delete CASCADE;

alter table public.candidaturas 
    drop constraint if exists candidatura_status_check;

ALTER TABLE public.candidaturas
    ADD CONSTRAINT candidatura_status_check CHECK (
        status = ANY (
        ARRAY[
            'PENDENTE'::text,
            'APROVADO'::text,
            'REPROVADO'::text
        ]
        )
    );

-- 1. Dropar índices antigos se existirem
drop index if exists idx_candidatura_status;
drop index if exists idx_candidaturas_status;

-- 2. Criar índices novos apontando para "id" da tabela vagas
create index idx_candidatura_status on public.candidaturas using btree (vagas_id, status) tablespace pg_default;
create index idx_candidaturas_status on public.candidaturas using btree (status) tablespace pg_default;

-- funcoes

CREATE OR REPLACE FUNCTION verificar_conflito_antes_candidatura ()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
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
$function$;

CREATE OR REPLACE FUNCTION aprovacao_automatica_favoritos ()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
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
$function$;

CREATE OR REPLACE FUNCTION update_total_candidaturas ()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
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
$function$;

CREATE OR REPLACE FUNCTION atualizar_vagas_status ()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
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
$function$;

-- FUNCTION update_total_plantoes_medico ();

DROP trigger if exists candidaturas_5_contar_plantoes_medico on candidaturas;

create trigger candidaturas_5_contar_plantoes_medico
after
update on candidaturas for EACH row when (
  old.status is distinct from new.status
)
execute FUNCTION update_total_plantoes_medico ();

CREATE OR REPLACE FUNCTION update_total_plantoes_medico()
 RETURNS trigger
 LANGUAGE plpgsql
-- SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
    IF NEW.status = 'CONFIRMADO' THEN
        UPDATE medicos 
        SET total_plantoes = total_plantoes + 1
        WHERE medico_id = NEW.medico_id;
    END IF;
    RETURN NULL;
END;
$function$;


--
-- tabela: checkin_checkout
--

ALTER TABLE public.checkin_checkout
    RENAME COLUMN index TO id;

ALTER TABLE public.checkin_checkout
    RENAME COLUMN vagas_id TO vaga_id;

ALTER TABLE public.checkin_checkout
    DROP CONSTRAINT IF EXISTS checkin_checkout_pkey;
ALTER TABLE public.checkin_checkout
    DROP CONSTRAINT IF EXISTS checkin_checkout_index_key;
ALTER TABLE public.checkin_checkout
    DROP CONSTRAINT IF EXISTS checkin_checkout_vagas_id_key;
    -- checkin_checkout_vagas_id_fkey já removida anteriormente na seção vagas

ALTER TABLE public.checkin_checkout
    ADD CONSTRAINT checkin_checkout_pkey PRIMARY KEY (id),
    ADD CONSTRAINT checkin_checkout_index_key UNIQUE (id),
    ADD CONSTRAINT checkin_checkout_vagas_id_key UNIQUE (vaga_id),
    ADD CONSTRAINT checkin_checkout_vagas_id_fkey FOREIGN KEY (vaga_id) REFERENCES vagas (id) ON UPDATE CASCADE ON DELETE SET NULL;

-- funçoes
CREATE OR REPLACE FUNCTION validate_checkin_timing ()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
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
$function$;

CREATE OR REPLACE FUNCTION validate_checkout_timing ()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
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
$function$;


--
-- tabela: pagamentos
--

ALTER TABLE public.pagamentos
    RENAME COLUMN pagamento_id TO id;

-- Constraint já removida anteriormente na seção candidaturas
-- ALTER TABLE public.pagamentos
--     DROP CONSTRAINT IF EXISTS pagamentos_candidaturas_id_fkey;
    -- pagamentos_vagas_id_fkey já removida anteriormente na seção vagas

ALTER TABLE public.pagamentos
    ADD CONSTRAINT pagamentos_candidaturas_id_fkey FOREIGN KEY (candidaturas_id) REFERENCES candidaturas (id) ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT pagamentos_vagas_id_fkey FOREIGN KEY (vagas_id) REFERENCES vagas (id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- tabela: vagas_beneficio
--  

ALTER TABLE public.vagas_beneficio
    RENAME COLUMN "Index" TO id;

ALTER TABLE public.vagas_beneficio
    RENAME COLUMN vagas_id TO vaga_id;

ALTER TABLE public.vagas_beneficio
    RENAME COLUMN beneficio_id TO beneficio_tipo_id;

ALTER TABLE vagas_beneficio 
DROP CONSTRAINT IF EXISTS vagas_beneficio_pkey;

ALTER TABLE vagas_beneficio
ADD CONSTRAINT vagas_beneficio_pkey PRIMARY KEY (id);

-- Foreign key já removida anteriormente na seção beneficio_tipo

ALTER TABLE public.vagas_beneficio
    ADD CONSTRAINT vagas_beneficio_beneficio_id_fkey FOREIGN KEY (beneficio_tipo_id) REFERENCES beneficio_tipo (id) ON UPDATE CASCADE ON DELETE CASCADE;

-- vagas_beneficio_vaga_id_fkey já removida anteriormente na seção vagas

ALTER TABLE public.vagas_beneficio
    ADD CONSTRAINT vagas_beneficio_vaga_id_fkey FOREIGN KEY (vaga_id) REFERENCES vagas (id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- tabela: vagas_requisito
--

ALTER TABLE public.vagas_requisito
    RENAME COLUMN requisito_id TO requisito_tipo_id;

-- vagas_requisito_requisito_id_fkey já removida anteriormente na seção requisito_tipo

ALTER TABLE public.vagas_requisito
    ADD CONSTRAINT vagas_requisito_requisito_id_fkey FOREIGN KEY (requisito_tipo_id) REFERENCES requisito_tipo (id) ON UPDATE CASCADE ON DELETE CASCADE;

-- vagas_requisito_vagas_id_fkey já removida anteriormente na seção vagas

ALTER TABLE public.vagas_requisito
    ADD CONSTRAINT vagas_requisito_vagas_id_fkey FOREIGN KEY (vagas_id) REFERENCES vagas (id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- tabela: vagas_salvas
--

-- vagas_salvas_vagas_id_fkey já removida anteriormente na seção vagas

ALTER TABLE public.vagas_salvas
    ADD CONSTRAINT vagas_salvas_vagas_id_fkey FOREIGN KEY (vagas_id) REFERENCES vagas (id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- tabela: grades
--

ALTER TABLE public.grades
    DROP CONSTRAINT grades_especialidade_id_fkey;
    -- grades_grupo_id_fkey já removida anteriormente na seção grupo
    -- grades_setor_id_fkey já removida anteriormente na seção setores
    -- grades_hospital_id_fkey já removida anteriormente na seção hospital

ALTER TABLE public.grades
    ADD CONSTRAINT grades_especialidade_id_fkey FOREIGN KEY (especialidade_id) REFERENCES especialidades (id) ON DELETE RESTRICT,
    ADD CONSTRAINT grades_grupo_id_fkey FOREIGN KEY (grupo_id) REFERENCES grupo (id) ON UPDATE CASCADE ON DELETE CASCADE,
    ADD CONSTRAINT grades_setor_id_fkey FOREIGN KEY (setor_id) REFERENCES setores (id) ON DELETE RESTRICT,
    ADD CONSTRAINT grades_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES hospital (id) ON DELETE RESTRICT;

-- funcoes
CREATE OR REPLACE FUNCTION handle_grades_updated_at ()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
  NEW.updated_at = TIMEZONE('utc'::text, NOW());
  NEW.updated_by = auth.uid();
  RETURN NEW;
END;
$function$;


-- =====================================================
-- FASE 6: TABELAS QUE DEPENDEM DE medicos/escalista
-- =====================================================

--
-- tabela: medicos_favoritos
--

-- 1) Remover constraints antigas (medicos_favoritos_grupo_id_fkey já removida anteriormente na seção grupo)
-- fk_medicos_favoritos_escalista já removida anteriormente na seção escalista

-- 2) Criar constraints novas apontando para as PK renomeadas
ALTER TABLE medicos_favoritos
  ADD CONSTRAINT fk_medicos_favoritos_escalista
    FOREIGN KEY (escalista_id) REFERENCES escalista (id) ON DELETE CASCADE,
  ADD CONSTRAINT medicos_favoritos_grupo_id_fkey
    FOREIGN KEY (grupo_id) REFERENCES grupo (id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- tabela: medicos_precadastro
--

ALTER TABLE public.medicos_precadastro
    RENAME COLUMN medico_primeironome TO primeiro_nome;

ALTER TABLE public.medicos_precadastro
    RENAME COLUMN medico_sobrenome TO sobrenome;

ALTER TABLE public.medicos_precadastro
    RENAME COLUMN medico_crm TO crm;

ALTER TABLE public.medicos_precadastro
    RENAME COLUMN medico_cpf TO cpf;

ALTER TABLE public.medicos_precadastro
    RENAME COLUMN medico_email TO email;

ALTER TABLE public.medicos_precadastro
    RENAME COLUMN medico_telefone TO telefone;

ALTER TABLE public.medicos_precadastro
    RENAME COLUMN medico_especialidade TO especialidade_id;

ALTER TABLE public.medicos_precadastro
    RENAME COLUMN medico_estado TO estado;

-- Remover constraint antiga
ALTER TABLE public.medicos_precadastro
    DROP CONSTRAINT medicos_precadastro_medico_especialidade_fkey;

-- Criar constraint nova apontando para especialidades.id
ALTER TABLE public.medicos_precadastro
    ADD CONSTRAINT medicos_precadastro_medico_especialidade_fkey
    FOREIGN KEY (especialidade_id)
    REFERENCES especialidades (id)
    ON UPDATE CASCADE ON DELETE CASCADE;

-- Remover index antigo
DROP INDEX IF EXISTS idx_medicos_precadastro_cpf;
DROP INDEX IF EXISTS idx_medicos_precadastro_crm;
DROP INDEX IF EXISTS idx_medicos_precadastro_nome;

-- Criar index novo
CREATE INDEX IF NOT EXISTS idx_medicos_precadastro_cpf ON public.medicos_precadastro USING btree (cpf) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_medicos_precadastro_crm ON public.medicos_precadastro USING btree (crm) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_medicos_precadastro_nome ON public.medicos_precadastro USING btree (primeiro_nome, sobrenome) TABLESPACE pg_default;


-- =====================================================
-- FASE 7: TABELAS FINAIS (equipes)
-- =====================================================

-- tabela: equipes

-- PRIMEIRO: Remover foreign keys que dependem da primary key de equipes antes de alterá-la
ALTER TABLE equipes_medicos DROP CONSTRAINT IF EXISTS equipes_medicos_equipes_id_fkey;

-- renomear a PK
alter table public.equipes 
    rename column equipes_id to id;

ALTER TABLE public.equipes
    DROP CONSTRAINT equipes_pkey;
ALTER TABLE public.equipes
    ADD CONSTRAINT equipes_pkey PRIMARY KEY (id);
-- Foreign key já removida anteriormente na seção grupo
ALTER TABLE public.equipes
    ADD CONSTRAINT fk_grupo_id FOREIGN KEY (grupo_id) REFERENCES grupo (id) ON DELETE CASCADE;


--
-- tabela: equipes_medicos
--

-- Foreign key já removida anteriormente na seção grupo

ALTER TABLE public.equipes_medicos
    ADD CONSTRAINT equipes_medicos_grupo_id_fkey FOREIGN KEY (grupo_id) REFERENCES grupo (id) ON UPDATE CASCADE ON DELETE CASCADE;

-- equipes_medicos_equipes_id_fkey já removida anteriormente na seção equipes

ALTER TABLE public.equipes_medicos
    ADD CONSTRAINT equipes_medicos_equipes_id_fkey FOREIGN KEY (equipes_id) REFERENCES equipes (id) ON UPDATE CASCADE ON DELETE CASCADE;


-- =====================================================
-- FASE 8: TABELA DE GEOFENCING (final)
-- =====================================================

--
-- tabela: hospital_geofencing
--

-- hospital_geofencing_hospital_id_fkey já removida anteriormente na seção hospital

ALTER TABLE public.hospital_geofencing
    ADD CONSTRAINT hospital_geofencing_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES hospital (id) ON DELETE CASCADE;


-- =====================================================
-- CRIAÇÃO DE TRIGGERS (após todas as tabelas e funções)
-- =====================================================

-- Triggers para candidaturas
DROP TRIGGER IF EXISTS candidaturas_1_verificar_conflito_horario ON candidaturas;
CREATE TRIGGER candidaturas_1_verificar_conflito_horario 
    BEFORE INSERT ON candidaturas 
    FOR EACH ROW
    EXECUTE FUNCTION verificar_conflito_antes_candidatura();

DROP TRIGGER IF EXISTS candidaturas_2_auto_aprovar_favoritos ON candidaturas;
CREATE TRIGGER candidaturas_2_auto_aprovar_favoritos 
    BEFORE INSERT ON candidaturas 
    FOR EACH ROW
    EXECUTE FUNCTION aprovacao_automatica_favoritos();

DROP TRIGGER IF EXISTS candidaturas_3_atualizar_contador_vagas ON candidaturas;
CREATE TRIGGER candidaturas_3_atualizar_contador_vagas
    AFTER INSERT OR DELETE ON candidaturas 
    FOR EACH ROW
    EXECUTE FUNCTION update_total_candidaturas();

DROP TRIGGER IF EXISTS candidaturas_4_fechar_vaga_ao_aprovar ON candidaturas;
CREATE TRIGGER candidaturas_4_fechar_vaga_ao_aprovar
    AFTER UPDATE ON candidaturas 
    FOR EACH ROW 
    WHEN (NEW.status = 'APROVADO'::text)
    EXECUTE FUNCTION atualizar_vagas_status();

DROP TRIGGER IF EXISTS candidaturas_5_contar_plantoes_medico ON candidaturas;
CREATE TRIGGER candidaturas_5_contar_plantoes_medico
    AFTER UPDATE ON candidaturas 
    FOR EACH ROW 
    WHEN (OLD.status IS DISTINCT FROM NEW.status)
    EXECUTE FUNCTION update_total_plantoes_medico();

-- Triggers para checkin_checkout
DROP TRIGGER IF EXISTS checkin_checkout_1_validar_timing ON checkin_checkout;
CREATE TRIGGER checkin_checkout_1_validar_timing 
    BEFORE INSERT ON checkin_checkout 
    FOR EACH ROW
    EXECUTE FUNCTION validate_checkin_timing();

DROP TRIGGER IF EXISTS checkin_checkout_2_validar_timing ON checkin_checkout;
CREATE TRIGGER checkin_checkout_2_validar_timing 
    BEFORE UPDATE ON checkin_checkout 
    FOR EACH ROW
    EXECUTE FUNCTION validate_checkout_timing();

-- Triggers para grades
DROP TRIGGER IF EXISTS trigger_grades_updated_at ON grades;
CREATE TRIGGER trigger_grades_updated_at 
    BEFORE UPDATE ON grades 
    FOR EACH ROW
    EXECUTE FUNCTION handle_grades_updated_at();

-- Triggers para medicos
DROP TRIGGER IF EXISTS especialidades_1_setar_coluna_nome ON medicos;
CREATE TRIGGER especialidades_1_setar_coluna_nome 
    BEFORE INSERT OR UPDATE ON medicos 
    FOR EACH ROW
    EXECUTE FUNCTION update_especialidade_nome();

DROP TRIGGER IF EXISTS medicos_1_cleanup_precadastro ON medicos;
CREATE TRIGGER medicos_1_cleanup_precadastro
    AFTER INSERT ON medicos 
    FOR EACH ROW
    EXECUTE FUNCTION cleanup_medicos_precadastro();

-- Triggers para vagas
DROP TRIGGER IF EXISTS vagas_1_reprovar_candidaturas_ao_cancelar ON vagas;
CREATE TRIGGER vagas_1_reprovar_candidaturas_ao_cancelar
    AFTER UPDATE OF status ON vagas 
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_candidaturas_vaga_cancelada();

-- =====================================================
-- RECRIAR VIEWS APÓS TODAS AS MODIFICAÇÕES
-- =====================================================

-- 2.5. Recriar views que foram removidas anteriormente, agora com as colunas renomeadas
create or replace view "public"."vagas_completo"
with (security_invoker = on)
as  SELECT v.id AS vagas_id,
    v.created_at AS vagas_createdate,
    v.data AS vagas_data,
    v.hora_inicio AS vagas_horainicio,
    v.hora_fim AS vagas_horafim,
    v.valor AS vagas_valor,
    v.data_pagamento AS vagas_datapagamento,
    fr.forma_recebimento AS vagas_formarecebimento,
    v.observacoes AS vagas_observacoes,
    h.nome AS hospital_nome,
    s.nome AS setor_nome,
    p.periodo AS periodo_nome,
    t.tipo AS tipo_nome,
    esp.nome AS especialidade_nome,
    g.id AS grupo_id,
    g.nome AS grupo_nome,
    g.responsavel AS grupo_responsavel,
    g.telefone AS grupo_telefone,
    g.email AS grupo_email,
    v.status AS vagas_status,
    e.nome AS escalista_nome,
    e.id AS escalista_id,
    e.telefone AS escalista_telefone,
    e.email AS escalista_email,
    h.latitude AS hospital_lat,
    h.longitude AS hospital_log,
    h.endereco_formatado AS hospital_end,
    h.avatar AS hospital_avatar
   FROM ((((((((vagas v
     LEFT JOIN hospital h ON ((v.hospital_id = h.id)))
     LEFT JOIN setores s ON ((v.setor_id = s.id)))
     LEFT JOIN periodo p ON ((v.periodo_id = p.id)))
     LEFT JOIN tipo_vaga t ON ((v.tipo_id = t.id)))
     LEFT JOIN escalista e ON ((v.escalista_id = e.id)))
     LEFT JOIN especialidades esp ON ((v.especialidade_id = esp.id)))
     LEFT JOIN grupo g ON ((v.grupo_id = g.id)))
     LEFT JOIN formas_recebimento fr ON ((v.forma_recebimento_id = fr.id)));

create or replace view "public"."vw_vagas_por_mes"
as SELECT date_trunc('month'::text, (vagas_completo.vagas_data)::timestamp without time zone) AS mes,
    count(vagas_completo.vagas_id) AS total_vagas
   FROM vagas_completo
  GROUP BY (date_trunc('month'::text, (vagas_completo.vagas_data)::timestamp without time zone))
  ORDER BY (date_trunc('month'::text, (vagas_completo.vagas_data)::timestamp without time zone));

-- =====================================================
-- VIEWS REFATORADAS
-- =====================================================

create view public.vw_vagas_candidaturas as
select
  row_number() over (
    order by
      combined_data.vagas_id,
      combined_data.effective_medico_id,
      combined_data.candidaturas_id
  ) as idx,
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
  combined_data.candidatos_createdate,
  combined_data.candidaturas_updateby,
  combined_data.candidaturas_updateat,
  combined_data.effective_medico_id as medico_id,
  combined_data.medico_primeironome,
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
from
  (
    select distinct
      v.id as vagas_id,
      v.data as vagas_data,
      v.created_at as vagas_createdate,
      v.status as vagas_status,
      v.valor as vagas_valor,
      v.hora_inicio as vagas_horainicio,
      v.hora_fim as vagas_horafim,
      v.data_pagamento as vagas_datapagamento,
      v.periodo_id as vagas_periodo,
      p.periodo as vagas_periodo_nome,
      v.tipo_id as vagas_tipo,
      t.tipo as vagas_tipo_nome,
      v.forma_recebimento_id as vagas_formarecebimento,
      f.forma_recebimento as vagas_formarecebimento_nome,
      v.observacoes as vagas_observacoes,
      h.id as hospital_id,
      h.nome as hospital_nome,
      h.estado as hospital_estado,
      h.latitude as hospital_lat,
      h.longitude as hospital_log,
      h.endereco_formatado as hospital_end,
      h.avatar as hospital_avatar,
      e.id as especialidade_id,
      e.nome as especialidade_nome,
      s.id as setor_id,
      s.nome as setor_nome,
      esc.id as escalista_id,
      esc.nome as escalista_nome,
      esc.email as escalista_email,
      esc.telefone as escalista_telefone,
      g.id as grupo_id,
      g.nome as grupo_nome,
      c.id as candidaturas_id,
      count_candidaturas_total (v.id) as total_candidaturas,
      c.status as candidatura_status,
      c.created_at as candidatos_createdate,
      c.updated_by as candidaturas_updateby,
      c.updated_at as candidaturas_updateat,
      case
        when c.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
        and c.medico_precadastro_id is not null then c.medico_precadastro_id
        else vm.medico_id
      end as effective_medico_id,
      COALESCE(
        m.primeiro_nome,
        (mp.primeiro_nome)::text
      ) as medico_primeironome,
      COALESCE(m.sobrenome, (mp.sobrenome)::text) as medico_sobrenome,
      COALESCE(m.crm, (mp.crm)::text) as medico_crm,
      COALESCE(m.cpf, (mp.cpf)::text) as medico_cpf,
      COALESCE(m.estado, mp.estado) as medico_estado,
      COALESCE(m.email, (mp.email)::text) as medico_email,
      COALESCE(m.telefone, (mp.telefone)::text) as medico_telefone,
      c.medico_precadastro_id,
      v.recorrencia_id,
      case
        when vs.medico_id is not null
        or vsp.medico_id is not null then true
        else false
      end as vaga_salva,
      current_user_is_favorito (v.grupo_id) as medico_favorito,
      COALESCE(cc.checkin, ccp.checkin) as checkin,
      COALESCE(cc.checkout, ccp.checkout) as checkout,
      pg.valor as pagamento_valor,
      v.grade_id,
      gr.nome as grade_nome,
      gr.cor as grade_cor
    from
      vagas v
      join hospital h on v.hospital_id = h.id
      join especialidades e on v.especialidade_id = e.id
      join setores s on v.setor_id = s.id
      left join escalista esc on v.escalista_id = esc.id
      left join grupo g on v.grupo_id = g.id
      left join periodo p on v.periodo_id = p.id
      left join tipo_vaga t on v.tipo_id = t.id
      left join formas_recebimento f on v.forma_recebimento_id = f.id
      left join grades gr on v.grade_id = gr.id
      left join (
        select
          candidaturas.vagas_id,
          candidaturas.medico_id
        from
          candidaturas
        where
          candidaturas.medico_id is not null
          and candidaturas.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
        union
        select
          candidaturas.vagas_id,
          candidaturas.medico_precadastro_id as medico_id
        from
          candidaturas
        where
          candidaturas.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
          and candidaturas.medico_precadastro_id is not null
        union
        select
          vagas_salvas.vagas_id,
          vagas_salvas.medico_id
        from
          vagas_salvas
        where
          vagas_salvas.medico_id is not null
      ) vm on vm.vagas_id = v.id
      left join candidaturas c on c.vagas_id = v.id
      and (
        c.medico_id = vm.medico_id
        and c.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
        or c.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
        and c.medico_precadastro_id = vm.medico_id
      )
      left join medicos m on c.medico_id = m.id
      and c.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
      left join medicos_precadastro mp on c.medico_precadastro_id = mp.id
      left join vagas_salvas vs on vs.vagas_id = v.id
      and vs.medico_id = vm.medico_id
      left join vagas_salvas vsp on vsp.vagas_id = v.id
      and vsp.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
      left join checkin_checkout cc on cc.vaga_id = v.id
      and cc.medico_id = vm.medico_id
      left join checkin_checkout ccp on ccp.vaga_id = v.id
      and ccp.medico_id = case
        when c.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid then c.medico_precadastro_id
        else vm.medico_id
      end
      left join pagamentos pg on pg.candidaturas_id = c.id
  ) combined_data;

-- =====================================================
-- FIM DO SCRIPT ORDENADO
-- =====================================================