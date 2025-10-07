-- MIGRAÇÃO: Renomear tabelas para o plural
-- Versão ordenada para aplicação no Supabase
-- Ordem baseada nas dependências de foreign keys

-- =====================================================
-- PRIMEIRO: REMOVER VIEWS QUE SERÃO AFETADAS
-- =====================================================

DROP VIEW IF EXISTS "public"."vw_relatorio_folhapagamento" CASCADE;
DROP VIEW IF EXISTS "public"."vw_vagas_por_mes" CASCADE;

-- =====================================================
-- FASE 1: TABELAS BASE (sem dependências externas)
-- =====================================================

--
-- beneficio_tipo → beneficios
--

-- PRIMEIRO: Remover foreign keys que dependem desta tabela
ALTER TABLE public.vagas_beneficio
    DROP CONSTRAINT IF EXISTS vagas_beneficio_beneficio_id_fkey;

-- Renomear a tabela
ALTER TABLE public.beneficio_tipo RENAME TO beneficios;

-- Recriar foreign key com novo nome da tabela
ALTER TABLE public.vagas_beneficio
    ADD CONSTRAINT vagas_beneficio_beneficio_id_fkey 
    FOREIGN KEY (beneficio_tipo_id) REFERENCES beneficios (id) 
    ON UPDATE CASCADE ON DELETE CASCADE;

--
-- codigos_de_area → codigos_de_areas
--

ALTER TABLE public.codigos_de_area RENAME TO codigos_de_areas;

--
-- formas_recebimento → formas_recebimentos
--

-- PRIMEIRO: Remover foreign keys que dependem desta tabela
ALTER TABLE public.vagas
    DROP CONSTRAINT IF EXISTS vagas_formarecebimento_fkey;

-- Renomear a tabela
ALTER TABLE public.formas_recebimento RENAME TO formas_recebimentos;

-- Recriar foreign key com novo nome da tabela
ALTER TABLE public.vagas
    ADD CONSTRAINT vagas_formarecebimento_fkey 
    FOREIGN KEY (forma_recebimento_id) REFERENCES formas_recebimentos (id);

--
-- periodo → periodos
-- Adicionar colunas created_at e updated_at
-- Renomear coluna periodo para nome
--

-- PRIMEIRO: Remover foreign keys que dependem desta tabela
ALTER TABLE public.vagas
    DROP CONSTRAINT IF EXISTS vagas_vagas_periodo_fkey;

-- Renomear a tabela
ALTER TABLE public.periodo RENAME TO periodos;

-- Renomear a coluna periodo para nome
ALTER TABLE public.periodos
    RENAME COLUMN periodo TO nome;

-- Adicionar colunas created_at e updated_at (apenas se não existirem)
ALTER TABLE public.periodos
    ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now(),
    ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

-- Recriar foreign key com novo nome da tabela
ALTER TABLE public.vagas
    ADD CONSTRAINT vagas_vagas_periodo_fkey 
    FOREIGN KEY (periodo_id) REFERENCES periodos (id);

--
-- requisito_tipo → requisitos
--

-- PRIMEIRO: Remover foreign keys que dependem desta tabela
ALTER TABLE public.vagas_requisito
    DROP CONSTRAINT IF EXISTS vagas_requisito_requisito_id_fkey;

-- Renomear a tabela
ALTER TABLE public.requisito_tipo RENAME TO requisitos;

-- Recriar foreign key com novo nome da tabela
ALTER TABLE public.vagas_requisito
    ADD CONSTRAINT vagas_requisito_requisito_id_fkey 
    FOREIGN KEY (requisito_tipo_id) REFERENCES requisitos (id) 
    ON UPDATE CASCADE ON DELETE CASCADE;

--
-- tipo_vaga → tipo_vagas
-- Renomear coluna tipo para nome
-- Adicionar colunas created_at e updated_at
--

-- PRIMEIRO: Remover foreign keys que dependem desta tabela
ALTER TABLE public.vagas
    DROP CONSTRAINT IF EXISTS vagas_vagas_tipo_fkey;

-- Renomear a tabela
ALTER TABLE public.tipo_vaga RENAME TO tipo_vagas;

-- Renomear a coluna tipo para nome
ALTER TABLE public.tipo_vagas
    RENAME COLUMN tipo TO nome;

-- Adicionar colunas created_at e updated_at (apenas se não existirem)
ALTER TABLE public.tipo_vagas
    ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now(),
    ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

-- Recriar foreign key com novo nome da tabela
ALTER TABLE public.vagas
    ADD CONSTRAINT vagas_vagas_tipo_fkey 
    FOREIGN KEY (tipo_id) REFERENCES tipo_vagas (id);

--
-- vagas_recorrencia → vagas_recorrencias
--

-- PRIMEIRO: Remover foreign keys que dependem desta tabela
ALTER TABLE public.vagas
    DROP CONSTRAINT IF EXISTS vagas_recorrencia_id_fkey;

-- Renomear a tabela
ALTER TABLE public.vagas_recorrencia RENAME TO vagas_recorrencias;

-- Recriar foreign key com novo nome da tabela
ALTER TABLE public.vagas
    ADD CONSTRAINT vagas_recorrencia_id_fkey 
    FOREIGN KEY (recorrencia_id) REFERENCES vagas_recorrencias (id);

-- =====================================================
-- FASE 2: TABELAS DE SEGUNDO NÍVEL
-- =====================================================

--
-- grupo → grupos
--

-- PRIMEIRO: Remover todas as foreign keys que dependem desta tabela
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

-- Renomear a tabela
ALTER TABLE public.grupo RENAME TO grupos;

-- Recriar foreign keys com novo nome da tabela
ALTER TABLE public.equipes
    ADD CONSTRAINT fk_grupo_id 
    FOREIGN KEY (grupo_id) REFERENCES grupos (id) ON DELETE CASCADE;

ALTER TABLE public.equipes_medicos
    ADD CONSTRAINT equipes_medicos_grupo_id_fkey 
    FOREIGN KEY (grupo_id) REFERENCES grupos (id) 
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE public.escalista
    ADD CONSTRAINT escalista_grupo_id_fkey 
    FOREIGN KEY (grupo_id) REFERENCES grupos (id) 
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE public.grades
    ADD CONSTRAINT grades_grupo_id_fkey 
    FOREIGN KEY (grupo_id) REFERENCES grupos (id) 
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE public.medicos_favoritos
    ADD CONSTRAINT medicos_favoritos_grupo_id_fkey 
    FOREIGN KEY (grupo_id) REFERENCES grupos (id) 
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE public.vagas
    ADD CONSTRAINT vagas_grupo_id_fkey 
    FOREIGN KEY (grupo_id) REFERENCES grupos (id) 
    ON UPDATE CASCADE ON DELETE CASCADE;

--
-- hospital → hospitais
--

-- PRIMEIRO: Remover todas as foreign keys que dependem desta tabela
ALTER TABLE public.vagas
    DROP CONSTRAINT IF EXISTS vagas_vagas_hospital_fkey;

ALTER TABLE public.grades
    DROP CONSTRAINT IF EXISTS grades_hospital_id_fkey;

ALTER TABLE public.hospital_geofencing
    DROP CONSTRAINT IF EXISTS hospital_geofencing_hospital_id_fkey;

-- Renomear a tabela
ALTER TABLE public.hospital RENAME TO hospitais;

-- Recriar foreign keys com novo nome da tabela
ALTER TABLE public.vagas
    ADD CONSTRAINT vagas_vagas_hospital_fkey 
    FOREIGN KEY (hospital_id) REFERENCES hospitais (id);

ALTER TABLE public.grades
    ADD CONSTRAINT grades_hospital_id_fkey 
    FOREIGN KEY (hospital_id) REFERENCES hospitais (id) ON DELETE RESTRICT;

ALTER TABLE public.hospital_geofencing
    ADD CONSTRAINT hospital_geofencing_hospital_id_fkey 
    FOREIGN KEY (hospital_id) REFERENCES hospitais (id) ON DELETE CASCADE;

--
-- setores (adicionar created_at e updated_at)
--

-- PRIMEIRO: Remover foreign keys que dependem desta tabela
ALTER TABLE public.grades
    DROP CONSTRAINT IF EXISTS grades_setor_id_fkey;

ALTER TABLE public.vagas
    DROP CONSTRAINT IF EXISTS vagas_vagas_setor_fkey;

-- Adicionar colunas created_at e updated_at (apenas se não existirem)
ALTER TABLE public.setores
    ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now(),
    ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

-- Recriar foreign keys
ALTER TABLE public.grades
    ADD CONSTRAINT grades_setor_id_fkey 
    FOREIGN KEY (setor_id) REFERENCES setores (id) ON DELETE RESTRICT;

ALTER TABLE public.vagas
    ADD CONSTRAINT vagas_vagas_setor_fkey 
    FOREIGN KEY (setor_id) REFERENCES setores (id);

-- =====================================================
-- FASE 3: ESCALISTA → ESCALISTAS
-- =====================================================

--
-- escalista → escalistas
--

-- PRIMEIRO: Remover foreign keys que dependem desta tabela
ALTER TABLE public.vagas
    DROP CONSTRAINT IF EXISTS vagas_vagas_escalista_fkey;

ALTER TABLE public.medicos_favoritos
    DROP CONSTRAINT IF EXISTS fk_medicos_favoritos_escalista;

-- Renomear a tabela
ALTER TABLE public.escalista RENAME TO escalistas;

-- Recriar foreign keys com novo nome da tabela
ALTER TABLE public.vagas
    ADD CONSTRAINT vagas_vagas_escalista_fkey 
    FOREIGN KEY (escalista_id) REFERENCES escalistas (id) 
    ON UPDATE CASCADE ON DELETE SET DEFAULT;

ALTER TABLE public.medicos_favoritos
    ADD CONSTRAINT fk_medicos_favoritos_escalista 
    FOREIGN KEY (escalista_id) REFERENCES escalistas (id) ON DELETE CASCADE;

-- =====================================================
-- FASE 4: TABELAS DE RELACIONAMENTO
-- =====================================================

--
-- vagas_beneficio → vagas_beneficios
--

-- PRIMEIRO: Remover foreign keys que dependem desta tabela
ALTER TABLE public.vagas_beneficio
    DROP CONSTRAINT IF EXISTS vagas_beneficio_vaga_id_fkey;

-- Renomear a tabela
ALTER TABLE public.vagas_beneficio RENAME TO vagas_beneficios;

-- Recriar foreign key com novo nome da tabela
ALTER TABLE public.vagas_beneficios
    ADD CONSTRAINT vagas_beneficio_vaga_id_fkey 
    FOREIGN KEY (vaga_id) REFERENCES vagas (id) 
    ON UPDATE CASCADE ON DELETE CASCADE;

--
-- vagas_requisito → vagas_requisitos
--

-- PRIMEIRO: Remover foreign keys que dependem desta tabela
ALTER TABLE public.vagas_requisito
    DROP CONSTRAINT IF EXISTS vagas_requisito_vagas_id_fkey;

-- Renomear a tabela
ALTER TABLE public.vagas_requisito RENAME TO vagas_requisitos;

-- Recriar foreign key com novo nome da tabela
ALTER TABLE public.vagas_requisitos
    ADD CONSTRAINT vagas_requisito_vagas_id_fkey 
    FOREIGN KEY (vagas_id) REFERENCES vagas (id) 
    ON UPDATE CASCADE ON DELETE CASCADE;

-- =====================================================
-- FASE 5: CLEAN_HOSPITAL → CLEAN_HOSPITAIS
-- =====================================================

--
-- clean_hospital → clean_hospitais (se existir)
--

ALTER TABLE IF EXISTS public.clean_hospital RENAME TO clean_hospitais;

-- =====================================================
-- FASE 6: ALTERAR COLUNA NA TABELA VAGAS
-- =====================================================

--
-- vagas: alterar tipo_id para tipo_vagas_id
--

-- Primeiro remover a constraint
ALTER TABLE public.vagas
    DROP CONSTRAINT IF EXISTS vagas_vagas_tipo_fkey;

-- Renomear a coluna
ALTER TABLE public.vagas
    RENAME COLUMN tipo_id TO tipo_vagas_id;

-- Recriar a constraint com o novo nome da coluna
ALTER TABLE public.vagas
    ADD CONSTRAINT vagas_vagas_tipo_fkey 
    FOREIGN KEY (tipo_vagas_id) REFERENCES tipo_vagas (id);

-- =====================================================
-- FASE 7: ATUALIZAR ÍNDICES
-- =====================================================

-- Atualizar índices que referenciam as tabelas renomeadas

-- Índices de grupo → grupos
DROP INDEX IF EXISTS idx_grupo_nome;
CREATE INDEX IF NOT EXISTS idx_grupo_nome 
ON public.grupos USING btree (nome) TABLESPACE pg_default;

-- Índices de hospital → hospitais  
DROP INDEX IF EXISTS idx_hospital_nome;
CREATE INDEX IF NOT EXISTS idx_hospital_nome 
ON public.hospitais USING btree (nome) TABLESPACE pg_default;

-- Índices de escalista → escalistas
DROP INDEX IF EXISTS idx_escalista_nome;
CREATE INDEX IF NOT EXISTS idx_escalista_nome 
ON public.escalistas USING btree (nome) TABLESPACE pg_default;

-- =====================================================
-- FASE 8: ATUALIZAR FUNÇÕES E TRIGGERS
-- =====================================================

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

-- =====================================================
-- FASE 9: RECRIAR VIEWS (se necessário)
-- =====================================================

-- Atualizar view vagas_completo para usar os novos nomes das tabelas
DROP VIEW IF EXISTS "public"."vagas_completo" CASCADE;

CREATE OR REPLACE VIEW "public"."vagas_completo"
WITH (security_invoker = on)
AS SELECT v.id AS vagas_id,
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
    p.nome AS periodo_nome,
    t.nome AS tipo_nome,
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
     LEFT JOIN hospitais h ON ((v.hospital_id = h.id)))
     LEFT JOIN setores s ON ((v.setor_id = s.id)))
     LEFT JOIN periodos p ON ((v.periodo_id = p.id)))
     LEFT JOIN tipo_vagas t ON ((v.tipo_vagas_id = t.id)))
     LEFT JOIN escalistas e ON ((v.escalista_id = e.id)))
     LEFT JOIN especialidades esp ON ((v.especialidade_id = esp.id)))
     LEFT JOIN grupos g ON ((v.grupo_id = g.id)))
     LEFT JOIN formas_recebimentos fr ON ((v.forma_recebimento_id = fr.id)));

-- Recriar view vw_vagas_candidaturas com os novos nomes das tabelas
DROP VIEW IF EXISTS "public"."vw_vagas_candidaturas" CASCADE;

-- Atualizando todas as referências para as tabelas no plural
CREATE VIEW public.vw_vagas_candidaturas AS
SELECT
  row_number() OVER (
    ORDER BY 
      combined_data.vagas_id,
      combined_data.effective_medico_id,
      combined_data.candidaturas_id
  ) AS idx,
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
  combined_data.setor_id,
  combined_data.setor_nome,
  combined_data.escalista_id,
  combined_data.escalista_nome,
  combined_data.escalista_telefone,
  combined_data.escalista_email,
  combined_data.grupo_id,
  combined_data.grupo_nome,
  combined_data.grupo_responsavel,
  combined_data.grupo_telefone,
  combined_data.grupo_email,
  combined_data.especialidade_id,
  combined_data.especialidade_nome,
  combined_data.candidaturas_id,
  combined_data.candidatura_status,
  combined_data.candidatura_createdate,
  combined_data.candidatura_data_confirmacao,
  combined_data.candidatura_updatedat,
  combined_data.candidatura_updateby,
  combined_data.effective_medico_id,
  combined_data.medico_id,
  combined_data.medico_precadastro_id,
  combined_data.medico_primeiro_nome,
  combined_data.medico_sobrenome,
  combined_data.medico_crm,
  combined_data.medico_cpf,
  combined_data.medico_email,
  combined_data.medico_telefone,
  combined_data.medico_especialidade_nome,
  combined_data.medico_estado,
  combined_data.vaga_salva,
  combined_data.medico_favorito,
  combined_data.checkin,
  combined_data.checkout,
  combined_data.pagamento_valor,
  combined_data.grade_id,
  combined_data.grade_nome,
  combined_data.grade_cor
FROM (
  SELECT
    v.id AS vagas_id,
    v.data AS vagas_data,
    v.created_at AS vagas_createdate,
    v.status AS vagas_status,
    v.valor AS vagas_valor,
    v.hora_inicio AS vagas_horainicio,
    v.hora_fim AS vagas_horafim,
    v.data_pagamento AS vagas_datapagamento,
    v.periodo_id AS vagas_periodo,
    p.nome AS vagas_periodo_nome,
    v.tipo_vagas_id AS vagas_tipo,
    t.nome AS vagas_tipo_nome,
    v.forma_recebimento_id AS vagas_formarecebimento,
    f.forma_recebimento AS vagas_formarecebimento_nome,
    v.observacoes AS vagas_observacoes,
    v.hospital_id,
    h.nome AS hospital_nome,
    v.setor_id,
    s.nome AS setor_nome,
    v.escalista_id,
    esc.nome AS escalista_nome,
    esc.telefone AS escalista_telefone,
    esc.email AS escalista_email,
    v.grupo_id,
    g.nome AS grupo_nome,
    g.responsavel AS grupo_responsavel,
    g.telefone AS grupo_telefone,
    g.email AS grupo_email,
    v.especialidade_id,
    e.nome AS especialidade_nome,
    c.id AS candidaturas_id,
    c.status AS candidatura_status,
    c.created_at AS candidatura_createdate,
    c.data_confirmacao AS candidatura_data_confirmacao,
    c.updated_at AS candidatura_updatedat,
    c.updated_by AS candidatura_updateby,
    vm.medico_id AS effective_medico_id,
    COALESCE(m.id, mp.id) AS medico_id,
    c.medico_precadastro_id,
    COALESCE(m.primeiro_nome, mp.primeiro_nome) AS medico_primeiro_nome,
    COALESCE(m.sobrenome, mp.sobrenome) AS medico_sobrenome,
    COALESCE(m.crm, mp.crm) AS medico_crm,
    COALESCE(m.cpf, mp.cpf) AS medico_cpf,
    COALESCE(m.email, mp.email) AS medico_email,
    COALESCE(m.telefone, mp.telefone) AS medico_telefone,
    COALESCE(me.nome, mep.nome) AS medico_especialidade_nome,
    COALESCE(m.estado, mp.estado) AS medico_estado,
    CASE
      WHEN vs.medico_id IS NOT NULL OR vsp.medico_id IS NOT NULL THEN true
      ELSE false
    END AS vaga_salva,
    current_user_is_favorito(v.grupo_id) AS medico_favorito,
    COALESCE(cc.checkin, ccp.checkin) AS checkin,
    COALESCE(cc.checkout, ccp.checkout) AS checkout,
    pg.valor AS pagamento_valor,
    v.grade_id,
    gr.nome AS grade_nome,
    gr.cor AS grade_cor
  FROM vagas v
  JOIN hospitais h ON v.hospital_id = h.id
  JOIN especialidades e ON v.especialidade_id = e.id
  JOIN setores s ON v.setor_id = s.id
  LEFT JOIN escalistas esc ON v.escalista_id = esc.id
  LEFT JOIN grupos g ON v.grupo_id = g.id
  LEFT JOIN periodos p ON v.periodo_id = p.id
  LEFT JOIN tipo_vagas t ON v.tipo_vagas_id = t.id
  LEFT JOIN formas_recebimentos f ON v.forma_recebimento_id = f.id
  LEFT JOIN grades gr ON v.grade_id = gr.id
  LEFT JOIN (
    SELECT
      candidaturas.vagas_id,
      candidaturas.medico_id
    FROM candidaturas
    WHERE candidaturas.medico_id IS NOT NULL
      AND candidaturas.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
    UNION
    SELECT
      candidaturas.vagas_id,
      candidaturas.medico_precadastro_id AS medico_id
    FROM candidaturas
    WHERE candidaturas.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
      AND candidaturas.medico_precadastro_id IS NOT NULL
    UNION
    SELECT
      vagas_salvas.vagas_id,
      vagas_salvas.medico_id
    FROM vagas_salvas
    WHERE vagas_salvas.medico_id IS NOT NULL
  ) vm ON vm.vagas_id = v.id
  LEFT JOIN candidaturas c ON c.vagas_id = v.id
    AND (
      (c.medico_id = vm.medico_id AND c.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid)
      OR (c.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid AND c.medico_precadastro_id = vm.medico_id)
    )
  LEFT JOIN medicos m ON c.medico_id = m.id
    AND c.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
  LEFT JOIN medicos_precadastro mp ON c.medico_precadastro_id = mp.id
  LEFT JOIN especialidades me ON m.especialidade_id = me.id
  LEFT JOIN especialidades mep ON mp.especialidade_id = mep.id
  LEFT JOIN vagas_salvas vs ON vs.vagas_id = v.id AND vs.medico_id = vm.medico_id
  LEFT JOIN vagas_salvas vsp ON vsp.vagas_id = v.id AND vsp.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
  LEFT JOIN checkin_checkout cc ON cc.vaga_id = v.id AND cc.medico_id = vm.medico_id
  LEFT JOIN checkin_checkout ccp ON ccp.vaga_id = v.id
    AND ccp.medico_id = CASE
      WHEN c.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid THEN c.medico_precadastro_id
      ELSE vm.medico_id
    END
  LEFT JOIN pagamentos pg ON pg.candidaturas_id = c.id
) combined_data;
