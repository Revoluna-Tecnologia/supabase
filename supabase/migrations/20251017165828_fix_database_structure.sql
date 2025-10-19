-- Migration para corrigir estrutura do banco de dados

-- 1. Alterar coluna benefico_tipo_id para beneficio_id na tabela vagas_beneficios
ALTER TABLE public.vagas_beneficios 
RENAME COLUMN beneficio_tipo_id TO beneficio_id;

-- 2. Alterar colunas na tabela vagas_requisitos

ALTER TABLE public.vagas_requisitos 
RENAME COLUMN vagas_id TO vaga_id;

ALTER TABLE public.vagas_requisitos 
RENAME COLUMN requisito_tipo_id TO requisito_id;

-- 3. Alterar colunas na tabela candidaturas
ALTER TABLE public.candidaturas 
RENAME COLUMN vagas_id TO vaga_id;

ALTER TABLE public.candidaturas 
RENAME COLUMN vagas_valor TO vaga_valor;

-- 4. Alterar coluna na tabela equipes_medicos
ALTER TABLE public.equipes_medicos 
RENAME COLUMN equipes_id TO equipe_id;

-- 5. Alterar coluna na tabela vagas_salvas
ALTER TABLE public.vagas_salvas 
RENAME COLUMN vagas_id TO vaga_id;

-- Corrigir estrutura da tabela pagamentos

--  Remover constraints que referenciam colunas antigas

ALTER TABLE public.pagamentos DROP CONSTRAINT IF EXISTS pagamentos_medico_vaga_unique;
ALTER TABLE public.pagamentos DROP CONSTRAINT IF EXISTS pagamentos_vagas_id_key;
ALTER TABLE public.pagamentos DROP CONSTRAINT IF EXISTS pagamentos_candidaturas_id_fkey;
ALTER TABLE public.pagamentos DROP CONSTRAINT IF EXISTS pagamentos_vagas_id_fkey;

-- Alterar colunas 

ALTER TABLE public.pagamentos
RENAME COLUMN vagas_id TO vaga_id;

ALTER TABLE public.pagamentos
RENAME COLUMN candidaturas_id TO candidatura_id;

--  Recriar constraints com nomes corretos
ALTER TABLE public.pagamentos 
ADD CONSTRAINT pagamentos_candidatura_id_key UNIQUE (candidatura_id);

ALTER TABLE public.pagamentos 
ADD CONSTRAINT pagamentos_vaga_id_key UNIQUE (vaga_id);

ALTER TABLE public.pagamentos 
ADD CONSTRAINT pagamentos_medico_vaga_unique UNIQUE (medico_id, vaga_id);

--  Recriar foreign keys com nomes corretos
ALTER TABLE public.pagamentos 
ADD CONSTRAINT pagamentos_candidatura_id_fkey 
FOREIGN KEY (candidatura_id) REFERENCES candidaturas (id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE public.pagamentos 
ADD CONSTRAINT pagamentos_vaga_id_fkey 
FOREIGN KEY (vaga_id) REFERENCES vagas (id) ON UPDATE CASCADE ON DELETE CASCADE;

-- 6. AJUSTAR FOREIGN KEYS que podem estar usando os nomes antigos das colunas

-- Recriar FK para vagas_beneficios.beneficio_id

    -- Dropar FK antiga se existir
    ALTER TABLE public.vagas_beneficios DROP CONSTRAINT IF EXISTS vagas_beneficio_beneficio_id_fkey;
    
    -- Recriar FK com nome correto
    ALTER TABLE public.vagas_beneficios 
    ADD CONSTRAINT vagas_beneficios_beneficio_id_fkey 
    FOREIGN KEY (beneficio_id) REFERENCES public.beneficios(id) on update CASCADE on delete CASCADE;


-- Recriar FK para vagas_requisitos
    -- Dropar FKs antigas se existirem
    ALTER TABLE public.vagas_requisitos DROP CONSTRAINT IF EXISTS vagas_requisito_vagas_id_fkey;
    ALTER TABLE public.vagas_requisitos DROP CONSTRAINT IF EXISTS vagas_requisito_requisito_id_fkey;
    
    -- Recriar FKs com nomes corretos
    ALTER TABLE public.vagas_requisitos 
    ADD CONSTRAINT vagas_requisitos_vaga_id_fkey 
    FOREIGN KEY (vaga_id) REFERENCES public.vagas(id) on update CASCADE on delete CASCADE;

    ALTER TABLE public.vagas_requisitos 
    ADD CONSTRAINT vagas_requisitos_requisito_id_fkey 
    FOREIGN KEY (requisito_id) REFERENCES public.requisitos(id) on update CASCADE on delete CASCADE;

-- Recriar FK para candidaturas
    -- Dropar FK antiga se existir
    ALTER TABLE public.candidaturas DROP CONSTRAINT IF EXISTS candidaturas_vagas_id_fkey;
    
    -- Recriar FK com nome correto
    ALTER TABLE public.candidaturas 
    ADD CONSTRAINT candidaturas_vaga_id_fkey 
    FOREIGN KEY (vaga_id) REFERENCES public.vagas(id);

-- Recriar FK para equipes_medicos

    -- Dropar FK antiga se existir
    ALTER TABLE public.equipes_medicos DROP CONSTRAINT IF EXISTS equipes_medicos_equipes_id_fkey;
    
    -- Recriar FK com nome correto
    ALTER TABLE public.equipes_medicos 
    ADD CONSTRAINT equipes_medicos_equipe_id_fkey 
    FOREIGN KEY (equipe_id) REFERENCES public.equipes(id) on update CASCADE on delete CASCADE;

-- Recriar FK para vagas_salvas

    -- Dropar FK antiga se existir
    ALTER TABLE public.vagas_salvas DROP CONSTRAINT IF EXISTS vagas_salvas_vagas_id_fkey;
    
    -- Recriar FK com nome correto
    ALTER TABLE public.vagas_salvas 
    ADD CONSTRAINT vagas_salvas_vaga_id_fkey 
    FOREIGN KEY (vaga_id) REFERENCES public.vagas(id) on update CASCADE on delete CASCADE;

-- 7. RECRIAR ÍNDICES que podem estar usando os nomes antigos das colunas

-- Índices para candidaturas
DROP INDEX IF EXISTS idx_candidatura_vaga;
CREATE INDEX IF NOT EXISTS idx_candidaturas_vaga_id ON public.candidaturas(vaga_id) TABLESPACE pg_default;

DROP INDEX IF EXISTS idx_candidaturas_medico_vaga;
create index IF not exists idx_candidaturas_medico_vaga on public.candidaturas using btree (medico_id, vaga_id) TABLESPACE pg_default;

DROP INDEX IF EXISTS idx_candidatura_status;
create index IF not exists idx_candidatura_status on public.candidaturas using btree (vaga_id, status) TABLESPACE pg_default;


-- Índices para equipes_medicos
DROP INDEX IF EXISTS unique_equipe_medico_precadastro;
DROP INDEX IF EXISTS unique_equipe_medico_real;


create unique INDEX IF not exists unique_equipe_medico_precadastro on public.equipes_medicos using btree (equipe_id, medico_precadastro_id) TABLESPACE pg_default
where
  (medico_precadastro_id is not null);

create unique INDEX IF not exists unique_equipe_medico_real on public.equipes_medicos using btree (equipe_id, medico_id) TABLESPACE pg_default
where
  (medico_precadastro_id is null);


-- 8. ATUALIZAR FUNÇÕES que podem referenciar as colunas antigas

-- Função count_candidaturas_total (se existir e usar coluna antiga)
CREATE OR REPLACE FUNCTION public.count_candidaturas_total(vaga_id_param uuid)
 RETURNS integer
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
  SELECT COUNT(*)::INTEGER 
  FROM candidaturas 
  WHERE vaga_id = vaga_id_param;
$function$
;

-- 9. Recriar view vw_vagas_candidaturas com coluna vaga_id corrigida
DROP VIEW IF EXISTS public.vw_vagas_candidaturas;

CREATE VIEW public.vw_vagas_candidaturas with (security_invoker = on)
AS
SELECT
  row_number() OVER (
    ORDER BY
      combined_data.vaga_id,
      combined_data.effective_medico_id,
      combined_data.candidatura_id
  ) AS idx,
  combined_data.vaga_id,
  combined_data.vaga_data,
  combined_data.vaga_createdate,
  combined_data.vaga_status,
  combined_data.vaga_valor,
  combined_data.vaga_horainicio,
  combined_data.vaga_horafim,
  combined_data.vaga_datapagamento,
  combined_data.vaga_periodo,
  combined_data.vaga_periodo_nome,
  combined_data.vaga_tipo,
  combined_data.vaga_tipo_nome,
  combined_data.vaga_formarecebimento,
  combined_data.vaga_formarecebimento_nome,
  combined_data.vaga_observacoes,
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
  combined_data.candidatura_id,
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
FROM (
  SELECT DISTINCT
    v.id AS vaga_id,
    v.data AS vaga_data,
    v.created_at AS vaga_createdate,
    v.status AS vaga_status,
    v.valor AS vaga_valor,
    v.hora_inicio AS vaga_horainicio,
    v.hora_fim AS vaga_horafim,
    v.data_pagamento AS vaga_datapagamento,
    v.periodo_id AS vaga_periodo,
    p.nome AS vaga_periodo_nome,
    v.tipos_vaga_id AS vaga_tipo,
    t.nome AS vaga_tipo_nome,
    v.forma_recebimento_id AS vaga_formarecebimento,
    f.forma_recebimento AS vaga_formarecebimento_nome,
    v.observacoes AS vaga_observacoes,
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
    c.id AS candidatura_id,
    count_candidaturas_total(v.id) AS total_candidaturas,
    c.status AS candidatura_status,
    c.created_at AS candidatura_createdate,
    c.updated_by AS candidatura_updateby,
    c.updated_at AS candidatura_updatedat,
    CASE
      WHEN c.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
      AND c.medico_precadastro_id IS NOT NULL THEN c.medico_precadastro_id
      ELSE vm.medico_id
    END AS effective_medico_id,
    COALESCE(
      m.primeiro_nome,
      mp.primeiro_nome::text
    ) AS medico_primeiro_nome,
    COALESCE(m.sobrenome, mp.sobrenome::text) AS medico_sobrenome,
    COALESCE(m.crm, mp.crm::text) AS medico_crm,
    COALESCE(m.cpf, mp.cpf::text) AS medico_cpf,
    COALESCE(m.estado, mp.estado) AS medico_estado,
    COALESCE(m.email, mp.email::text) AS medico_email,
    COALESCE(m.telefone, mp.telefone::text) AS medico_telefone,
    c.medico_precadastro_id,
    v.recorrencia_id,
    CASE
      WHEN vs.medico_id IS NOT NULL
      OR vsp.medico_id IS NOT NULL THEN true
      ELSE false
    END AS vaga_salva,
    current_user_is_favorito(v.grupo_id) AS medico_favorito,
    COALESCE(cc.checkin, ccp.checkin) AS checkin,
    COALESCE(cc.checkout, ccp.checkout) AS checkout,
    pg.valor AS pagamento_valor,
    v.grade_id,
    gr.nome AS grade_nome,
    gr.cor AS grade_cor
  FROM
    vagas v
    JOIN hospitais h ON v.hospital_id = h.id
    JOIN especialidades e ON v.especialidade_id = e.id
    JOIN setores s ON v.setor_id = s.id
    LEFT JOIN escalistas esc ON v.escalista_id = esc.id
    LEFT JOIN grupos g ON v.grupo_id = g.id
    LEFT JOIN periodos p ON v.periodo_id = p.id
    LEFT JOIN tipos_vaga t ON v.tipos_vaga_id = t.id
    LEFT JOIN formas_recebimento f ON v.forma_recebimento_id = f.id
    LEFT JOIN grades gr ON v.grade_id = gr.id
    LEFT JOIN (
      SELECT
        candidaturas.vaga_id,
        candidaturas.medico_id
      FROM
        candidaturas
      WHERE
        candidaturas.medico_id IS NOT NULL
        AND candidaturas.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
      UNION
      SELECT
        candidaturas.vaga_id,
        candidaturas.medico_precadastro_id AS medico_id
      FROM
        candidaturas
      WHERE
        candidaturas.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
        AND candidaturas.medico_precadastro_id IS NOT NULL
      UNION
      SELECT
        vagas_salvas.vaga_id,
        vagas_salvas.medico_id
      FROM
        vagas_salvas
      WHERE
        vagas_salvas.medico_id IS NOT NULL
    ) vm ON vm.vaga_id = v.id
    LEFT JOIN candidaturas c ON c.vaga_id = v.id
    AND (
      c.medico_id = vm.medico_id
      AND c.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
      OR c.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
      AND c.medico_precadastro_id = vm.medico_id
    )
    LEFT JOIN medicos m ON c.medico_id = m.id
    AND c.medico_id <> '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
    LEFT JOIN medicos_precadastro mp ON c.medico_precadastro_id = mp.id
    LEFT JOIN vagas_salvas vs ON vs.vaga_id = v.id
    AND vs.medico_id = vm.medico_id
    LEFT JOIN vagas_salvas vsp ON vsp.vaga_id = v.id
    AND vsp.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
    LEFT JOIN checkin_checkout cc ON cc.vaga_id = v.id
    AND cc.medico_id = vm.medico_id
    LEFT JOIN checkin_checkout ccp ON ccp.vaga_id = v.id
    AND ccp.medico_id = CASE
      WHEN c.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid THEN c.medico_precadastro_id
      ELSE vm.medico_id
    END
    LEFT JOIN pagamentos pg ON pg.candidatura_id = c.id
) combined_data;

-- 10. Recriar view vw_folha_pagamento com colunas corrigidas
DROP VIEW IF EXISTS public.vw_folha_pagamento;

create view public.vw_folha_pagamento 
with (security_invoker = on) 
as
select
  v.id as vaga_id,
  v.data as vaga_data,
  p.nome as periodo_nome,
  v.hora_inicio as horario_inicio,
  v.hora_fim as horario_fim,
  v.valor as vaga_valor,
  v.data_pagamento as vaga_datapagamento,
  fr.forma_recebimento,
  h.id as hospital_id,
  h.nome as hospital_nome,
  e.id as especialidade_id,
  e.nome as vaga_especialidade,
  s.id as setor_id,
  s.nome as setor_nome,
  c.id as candidatura_id,
  c.medico_id,
  c.medico_precadastro_id,
  c.status as candidatura_status,
  c.data_confirmacao as candidato_dataconfirmacao,
  COALESCE(m.primeiro_nome, mp.primeiro_nome::text) as medico_primeironome,
  COALESCE(m.sobrenome, mp.sobrenome::text) as medico_sobrenome,
  COALESCE(m.cpf, mp.cpf::text) as medico_cpf,
  COALESCE(m.crm, mp.crm::text) as medico_crm,
  COALESCE(me.nome, mpe.nome) as medico_especialidade,
  COALESCE(m.razao_social, mp.razao_social) as razao_social,
  COALESCE(m.cnpj, mp.cnpj) as cnpj,
  COALESCE(m.banco_agencia, mp.banco_agencia) as banco_agencia,
  COALESCE(m.banco_digito, mp.banco_digito) as banco_digito,
  COALESCE(m.banco_conta, mp.banco_conta) as banco_conta,
  COALESCE(m.banco_pix, mp.banco_pix) as banco_pix,
  cc.checkin,
  cc.checkout,
  cc.checkin_latitude,
  cc.checkin_longitude,
  cc.checkout_latitude,
  cc.checkout_longitude,
  cc.checkin_justificativa,
  cc.checkout_justificativa
from
  vagas v
  join candidaturas c on c.vaga_id = v.id
  left join medicos m on m.id = c.medico_id
  and c.medico_precadastro_id is null
  left join medicos_precadastro mp on mp.id = c.medico_precadastro_id
  left join checkin_checkout cc on cc.vaga_id = v.id
  and (
    cc.medico_id = m.id
    or cc.medico_id = '9cd29712-91b5-492f-86ff-41e38c7b03d5'::uuid
  )
  left join hospitais h on h.id = v.hospital_id
  left join especialidades e on e.id = v.especialidade_id
  left join especialidades me on me.id = m.especialidade_id
  left join especialidades mpe on mpe.id = mp.especialidade_id
  left join setores s on s.id = v.setor_id
  left join periodos p on p.id = v.periodo_id
  left join formas_recebimento fr on fr.id = v.forma_recebimento_id
where
  v.status::text = 'fechada'::text
  and c.status = 'APROVADO'::text;

-- 11. Remover tabela carteira_digital e todas as funcionalidades relacionadas

-- Remover triggers relacionados à carteira_digital

-- Remover funções relacionadas à carteira_digital

-- Remover a tabela carteira_digital (CASCADE remove dependências)
DROP TABLE public.carteira_digital CASCADE;

-- Comentário da migration
-- COMMENT ON SCHEMA public IS 'Migration aplicada em 2025-10-17: Correção de nomes de colunas, FKs, índices e remoção da carteira_digital';

-- 12. CORRIGIR FUNÇÕES AFETADAS PELAS MUDANÇAS DE COLUNAS

-- Função get_vagas_paginated - Apenas alteração dos nomes das colunas
CREATE OR REPLACE FUNCTION get_vagas_paginated(
    page_number integer DEFAULT 1,
    page_size integer DEFAULT 10,
    hospital_ids uuid [] DEFAULT NULL,
    specialty_ids uuid [] DEFAULT NULL,
    sector_ids uuid [] DEFAULT NULL,
    start_date date DEFAULT NULL,
    end_date date DEFAULT NULL,
    min_value numeric DEFAULT NULL,
    max_value numeric DEFAULT NULL,
    period_ids uuid [] DEFAULT NULL,
    type_ids uuid [] DEFAULT NULL,
    group_ids uuid [] DEFAULT NULL,
    search_text text DEFAULT NULL,
    doctor_ids uuid [] DEFAULT NULL,
    application_status_filter text [] DEFAULT NULL,
    -- Valores: ['PENDENTE', 'APROVADO', 'REPROVADO']
    job_status_filter text [] DEFAULT NULL,
    -- Valores: ['aberta', 'fechada', 'cancelada', 'anunciada']
    grade_ids uuid [] DEFAULT NULL,
    order_by text DEFAULT 'vaga_data',
    -- Valores: 'vaga_createdate', 'vaga_data', 'vaga_valor', 'hospital_nome', 'setor_nome', 'especialidade_nome', 'vaga_periodo_nome', 'vaga_status', 'total_candidaturas'
    order_direction text DEFAULT 'DESC' -- Valores: 'ASC', 'DESC'
  ) RETURNS TABLE(data jsonb, pagination jsonb) LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public AS $$
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
      'vaga_data',
      'vaga_valor',
      'hospital_nome',
      'setor_nome',
      'especialidade_nome',
      'vaga_periodo_nome',
      'vaga_status',
      'total_candidaturas'
    ) THEN order_by
    ELSE 'vaga_createdate'
  END;
  
  validated_order_direction := CASE
    WHEN UPPER(order_direction) IN ('ASC', 'DESC') THEN UPPER(order_direction)
    ELSE 'DESC'
  END;
  
  offset_value := (validated_page - 1) * validated_size;
  
  WITH vagas_filtradas AS (
    SELECT DISTINCT v.vaga_id
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
        OR v.vaga_periodo = ANY(period_ids)
      )
      AND (
        type_ids IS NULL
        OR v.vaga_tipo = ANY(type_ids)
      )
      AND (
        group_ids IS NULL
        OR v.grupo_id = ANY(group_ids)
      )
      AND (
        start_date IS NULL
        OR v.vaga_data >= start_date
      )
      AND (
        end_date IS NULL
        OR v.vaga_data <= end_date
      )
      AND (
        min_value IS NULL
        OR v.vaga_valor >= min_value
      )
      AND (
        max_value IS NULL
        OR v.vaga_valor <= max_value
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
        OR v.vaga_status = ANY(job_status_filter)
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
        OR v.vaga_observacoes ILIKE '%' || search_text || '%'
        OR v.setor_nome ILIKE '%' || search_text || '%'
      )
  )
  SELECT COUNT(*) INTO total_count
  FROM vagas_filtradas;
  
  RETURN QUERY 
  WITH vagas_agrupadas AS (
    SELECT v.vaga_id,
      (array_agg(v.vaga_data)) [1] AS vaga_data,
      (array_agg(v.vaga_horainicio)) [1] AS vaga_horainicio,
      (array_agg(v.vaga_horafim)) [1] AS vaga_horafim,
      (array_agg(v.vaga_valor)) [1] AS vaga_valor,
      (array_agg(v.vaga_status)) [1] AS vaga_status,
      (array_agg(v.vaga_observacoes)) [1] AS vaga_observacoes,
      (array_agg(v.vaga_datapagamento)) [1] AS vaga_datapagamento,
      (array_agg(v.total_candidaturas)) [1] AS total_candidaturas,
      (array_agg(v.vaga_createdate)) [1] AS vaga_createdate,
      (array_agg(v.vaga_periodo)) [1] AS vaga_periodo,
      (array_agg(v.vaga_periodo_nome)) [1] AS vaga_periodo_nome,
      (array_agg(v.vaga_tipo)) [1] AS vaga_tipo,
      (array_agg(v.vaga_tipo_nome)) [1] AS vaga_tipo_nome,
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
          WHEN v.candidatura_id IS NOT NULL THEN jsonb_build_object(
            'candidatura_id',
            v.candidatura_id,
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
        WHERE v.candidatura_id IS NOT NULL
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
        OR v.vaga_periodo = ANY(period_ids)
      )
      AND (
        type_ids IS NULL
        OR v.vaga_tipo = ANY(type_ids)
      )
      AND (
        group_ids IS NULL
        OR v.grupo_id = ANY(group_ids)
      )
      AND (
        start_date IS NULL
        OR v.vaga_data >= start_date
      )
      AND (
        end_date IS NULL
        OR v.vaga_data <= end_date
      )
      AND (
        min_value IS NULL
        OR v.vaga_valor >= min_value
      )
      AND (
        max_value IS NULL
        OR v.vaga_valor <= max_value
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
        OR v.vaga_status = ANY(job_status_filter)
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
        OR v.vaga_observacoes ILIKE '%' || search_text || '%'
        OR v.setor_nome ILIKE '%' || search_text || '%'
      )
    GROUP BY v.vaga_id
    ORDER BY 
      CASE
        WHEN validated_order_by = 'vaga_data'
        AND validated_order_direction = 'DESC' THEN (array_agg(v.vaga_data)) [1]
      END DESC,
      CASE
        WHEN validated_order_by = 'vaga_data'
        AND validated_order_direction = 'ASC' THEN (array_agg(v.vaga_data)) [1]
      END ASC,
      CASE
        WHEN validated_order_by = 'vaga_valor'
        AND validated_order_direction = 'DESC' THEN (array_agg(v.vaga_valor)) [1]
      END DESC,
      CASE
        WHEN validated_order_by = 'vaga_valor'
        AND validated_order_direction = 'ASC' THEN (array_agg(v.vaga_valor)) [1]
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
        WHEN validated_order_by = 'vaga_periodo_nome'
        AND validated_order_direction = 'DESC' THEN (array_agg(v.vaga_periodo_nome)) [1]
      END DESC,
      CASE
        WHEN validated_order_by = 'vaga_periodo_nome'
        AND validated_order_direction = 'ASC' THEN (array_agg(v.vaga_periodo_nome)) [1]
      END ASC,
      CASE
        WHEN validated_order_by = 'vaga_status'
        AND validated_order_direction = 'DESC' THEN (array_agg(v.vaga_status)) [1]
      END DESC,
      CASE
        WHEN validated_order_by = 'vaga_status'
        AND validated_order_direction = 'ASC' THEN (array_agg(v.vaga_status)) [1]
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
          'vaga_id',
          v.vaga_id,
          'vaga_data',
          v.vaga_data,
          'vaga_horainicio',
          v.vaga_horainicio,
          'vaga_horafim',
          v.vaga_horafim,
          'vaga_valor',
          v.vaga_valor,
          'vaga_status',
          v.vaga_status,
          'vaga_observacoes',
          v.vaga_observacoes,
          'vaga_datapagamento',
          v.vaga_datapagamento,
          'total_candidaturas',
          v.total_candidaturas,
          'vaga_createdate',
          v.vaga_createdate,
          'vaga_periodo',
          v.vaga_periodo,
          'vaga_periodo_nome',
          v.vaga_periodo_nome,
          'vaga_tipo',
          v.vaga_tipo,
          'vaga_tipo_nome',
          v.vaga_tipo_nome,
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
            WHEN validated_order_by = 'vaga_data'
            AND validated_order_direction = 'DESC' THEN v.vaga_data
          END DESC,
          CASE
            WHEN validated_order_by = 'vaga_data'
            AND validated_order_direction = 'ASC' THEN v.vaga_data
          END ASC,
          CASE
            WHEN validated_order_by = 'vaga_valor'
            AND validated_order_direction = 'DESC' THEN v.vaga_valor
          END DESC,
          CASE
            WHEN validated_order_by = 'vaga_valor'
            AND validated_order_direction = 'ASC' THEN v.vaga_valor
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
            WHEN validated_order_by = 'vaga_periodo_nome'
            AND validated_order_direction = 'DESC' THEN v.vaga_periodo_nome
          END DESC,
          CASE
            WHEN validated_order_by = 'vaga_periodo_nome'
            AND validated_order_direction = 'ASC' THEN v.vaga_periodo_nome
          END ASC,
          CASE
            WHEN validated_order_by = 'vaga_status'
            AND validated_order_direction = 'DESC' THEN v.vaga_status
          END DESC,
          CASE
            WHEN validated_order_by = 'vaga_status'
            AND validated_order_direction = 'ASC' THEN v.vaga_status
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

-- Função get_applications_paginated - Apenas alteração dos nomes das colunas
CREATE OR REPLACE FUNCTION get_applications_paginated(
    page_number integer DEFAULT 1,
    page_size integer DEFAULT 10,
    hospital_ids uuid [] DEFAULT NULL,
    specialty_ids uuid [] DEFAULT NULL,
    sector_ids uuid [] DEFAULT NULL,
    start_date date DEFAULT NULL,
    end_date date DEFAULT NULL,
    min_value numeric DEFAULT NULL,
    max_value numeric DEFAULT NULL,
    period_ids uuid [] DEFAULT NULL,
    type_ids uuid [] DEFAULT NULL,
    group_ids uuid [] DEFAULT NULL,
    search_text text DEFAULT NULL,
    doctor_ids uuid [] DEFAULT NULL,
    application_status_filter text [] DEFAULT NULL,
    -- Valores: ['PENDENTE', 'APROVADO', 'REPROVADO']
    job_status_filter text [] DEFAULT NULL,
    -- Valores: ['aberta', 'fechada', 'cancelada', 'anunciada']
    grade_ids uuid [] DEFAULT NULL,
    order_by text DEFAULT 'candidatura_createdate',
    -- Valores atualizados: 'candidatura_createdate', 'vaga_createdate', 'vaga_data', 'vaga_valor', 'medico_primeiro_nome', 'hospital_nome', 'setor_nome', 'especialidade_nome', 'vaga_periodo_nome', 'vaga_status', 'candidatura_status'
    order_direction text DEFAULT 'DESC' -- Valores: 'ASC', 'DESC'
  ) RETURNS TABLE(data jsonb, pagination jsonb) LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public AS $$
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
      'vaga_createdate', 
      'vaga_data',
      'vaga_valor',
      'medico_primeiro_nome',
      'hospital_nome',
      'setor_nome',
      'especialidade_nome',
      'vaga_periodo_nome',
      'vaga_status',
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
  WHERE v.candidatura_id IS NOT NULL
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
      OR v.vaga_periodo = ANY(period_ids)
    )
    AND (
      type_ids IS NULL
      OR v.vaga_tipo = ANY(type_ids)
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
      OR v.vaga_valor >= min_value
    )
    AND (
      max_value IS NULL
      OR v.vaga_valor <= max_value
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
      OR v.vaga_status = ANY(job_status_filter)
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
      OR v.vaga_observacoes ILIKE '%' || search_text || '%'
      OR v.setor_nome ILIKE '%' || search_text || '%'
    );
  
  RETURN QUERY
  SELECT COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'candidatura_id',
          v.candidatura_id,
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
            'vaga_id',
            v.vaga_id,
            'vaga_data',
            v.vaga_data,
            'vaga_horainicio',
            v.vaga_horainicio,
            'vaga_horafim',
            v.vaga_horafim,
            'vaga_valor',
            v.vaga_valor,
            'vaga_status',
            v.vaga_status,
            'vaga_observacoes',
            v.vaga_observacoes,
            'vaga_datapagamento',
            v.vaga_datapagamento,
            'total_candidaturas',
            v.total_candidaturas,
            'vaga_createdate',
            v.vaga_createdate,
            'vaga_periodo',
            v.vaga_periodo,
            'vaga_periodo_nome',
            v.vaga_periodo_nome,
            'vaga_tipo',
            v.vaga_tipo,
            'vaga_tipo_nome',
            v.vaga_tipo_nome
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
      WHERE v.candidatura_id IS NOT NULL
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
          OR v.vaga_periodo = ANY(period_ids)
        )
        AND (
          type_ids IS NULL
          OR v.vaga_tipo = ANY(type_ids)
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
          OR v.vaga_valor >= min_value
        )
        AND (
          max_value IS NULL
          OR v.vaga_valor <= max_value
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
          OR v.vaga_status = ANY(job_status_filter)
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
          OR v.vaga_observacoes ILIKE '%' || search_text || '%'
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
          WHEN validated_order_by = 'vaga_createdate'
          AND validated_order_direction = 'DESC' THEN v.vaga_createdate
        END DESC,
        CASE
          WHEN validated_order_by = 'vaga_createdate'
          AND validated_order_direction = 'ASC' THEN v.vaga_createdate
        END ASC,
        CASE
          WHEN validated_order_by = 'vaga_data'
          AND validated_order_direction = 'DESC' THEN v.vaga_data
        END DESC,
        CASE
          WHEN validated_order_by = 'vaga_data'
          AND validated_order_direction = 'ASC' THEN v.vaga_data
        END ASC,
        CASE
          WHEN validated_order_by = 'vaga_valor'
          AND validated_order_direction = 'DESC' THEN v.vaga_valor
        END DESC,
        CASE
          WHEN validated_order_by = 'vaga_valor'
          AND validated_order_direction = 'ASC' THEN v.vaga_valor
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
          WHEN validated_order_by = 'vaga_periodo_nome'
          AND validated_order_direction = 'DESC' THEN v.vaga_periodo_nome
        END DESC,
        CASE
          WHEN validated_order_by = 'vaga_periodo_nome'
          AND validated_order_direction = 'ASC' THEN v.vaga_periodo_nome
        END ASC,
        CASE
          WHEN validated_order_by = 'vaga_status'
          AND validated_order_direction = 'DESC' THEN v.vaga_status
        END DESC,
        CASE
          WHEN validated_order_by = 'vaga_status'
          AND validated_order_direction = 'ASC' THEN v.vaga_status
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

-- Função verificar_conflito_vaga_designada 
CREATE OR REPLACE FUNCTION verificar_conflito_vaga_designada(
     p_medico_id UUID,
     p_data date,
     p_hora_inicio time,
     p_hora_fim time
)
RETURNS void
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
          JOIN vagas v ON c.vaga_id = v.id
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
          JOIN vagas v ON c.vaga_id = v.id
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

END;
$$;

-- Função verificar_conflito_antes_candidatura - Apenas alteração dos nomes das colunas
CREATE OR REPLACE FUNCTION verificar_conflito_antes_candidatura()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
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
    WHERE v.id = NEW.vaga_id;
    
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
            JOIN vagas v ON c.vaga_id = v.id
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
            JOIN vagas v ON c.vaga_id = v.id
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

-- Função criar_recorrencia_com_vagas - Apenas alteração dos nomes das colunas
CREATE OR REPLACE FUNCTION public.criar_recorrencia_com_vagas(p_data_inicio date, p_data_fim date, p_dias_semana integer[], p_vaga_base jsonb, p_created_by uuid, p_medico_id uuid DEFAULT NULL::uuid, p_observacoes text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
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
    (p_vaga_base->>'vaga_data')::date,  -- ALTERADO: vagas_data → vaga_data
    (p_vaga_base->>'vagas_periodo')::uuid,
    (p_vaga_base->>'vaga_horainicio')::time,  -- ALTERADO: vagas_horainicio → vaga_horainicio
    (p_vaga_base->>'vaga_horafim')::time,  -- ALTERADO: vagas_horafim → vaga_horafim
    (p_vaga_base->>'vaga_valor')::integer,  -- ALTERADO: vagas_valor → vaga_valor
    CASE 
      WHEN p_vaga_base->>'vaga_datapagamento' IS NOT NULL  -- ALTERADO: vagas_datapagamento → vaga_datapagamento
      THEN (p_vaga_base->>'vaga_datapagamento')::date 
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
    p_vaga_base->>'vaga_observacoes',  -- ALTERADO: vagas_observacoes → vaga_observacoes
    0,
    nova_recorrencia_id
  ) RETURNING vagas_id INTO nova_vaga_id;

  -- Gera as demais vagas recorrentes (CORRIGIDO: Passar p_created_by)
  PERFORM public.gerar_vagas_recorrentes(nova_recorrencia_id, nova_vaga_id, p_medico_id, p_created_by);

  RETURN nova_recorrencia_id;
END;
$function$;

-- Função criar_recorrencia_com_vagas (versão com benefícios e requisitos) - Apenas alteração dos nomes das colunas
CREATE OR REPLACE FUNCTION public.criar_recorrencia_com_vagas(p_data_inicio date, p_data_fim date, p_dias_semana integer[], p_vaga_base jsonb, p_created_by uuid, p_medico_id uuid DEFAULT NULL::uuid, p_observacoes text DEFAULT NULL::text, p_beneficios text[] DEFAULT ARRAY[]::text[], p_requisitos text[] DEFAULT ARRAY[]::text[])
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
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
    (p_vaga_base->>'vaga_data')::date,  -- ALTERADO: vagas_data → vaga_data
    (p_vaga_base->>'vagas_periodo')::uuid,
    (p_vaga_base->>'vaga_horainicio')::time,  -- ALTERADO: vagas_horainicio → vaga_horainicio
    (p_vaga_base->>'vaga_horafim')::time,  -- ALTERADO: vagas_horafim → vaga_horafim
    (p_vaga_base->>'vaga_valor')::integer,  -- ALTERADO: vagas_valor → vaga_valor
    CASE 
      WHEN p_vaga_base->>'vaga_datapagamento' IS NOT NULL  -- ALTERADO: vagas_datapagamento → vaga_datapagamento
      THEN (p_vaga_base->>'vaga_datapagamento')::date 
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
    p_vaga_base->>'vaga_observacoes',  -- ALTERADO: vagas_observacoes → vaga_observacoes
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
      p_medico_id, nova_vaga_id, 'APROVADO', now_brasil, now_brasil, p_created_by::text, (p_vaga_base->>'vaga_valor')::integer  -- ALTERADO: vagas_valor → vaga_valor
    );
    
    RAISE NOTICE 'Candidatura aprovada criada para vaga base: % (médico: %)', nova_vaga_id, p_medico_id;
  END IF;

  -- Gera as demais vagas recorrentes
  PERFORM public.gerar_vagas_recorrentes(nova_recorrencia_id, nova_vaga_id, p_medico_id, p_created_by, p_beneficios, p_requisitos);

  RAISE NOTICE 'Recorrência criada com sucesso: % (vaga base: %)', nova_recorrencia_id, nova_vaga_id;
  
  RETURN nova_recorrencia_id;
END;
$function$;

-- =====================================================
-- Função 1: editar_vagas_recorrencia (versão básica) - Apenas alteração dos nomes das colunas
-- =====================================================

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
    -- Atualizar dados da vaga (usando nomenclatura correta)
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
$function$;

-- =====================================================
-- Função 2: editar_vagas_recorrencia (com benefícios e requisitos) - Apenas alteração dos nomes das colunas
-- =====================================================

CREATE OR REPLACE FUNCTION public.editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid, p_beneficios text[] DEFAULT ARRAY[]::text[], p_requisitos text[] DEFAULT ARRAY[]::text[])
 RETURNS void
 LANGUAGE plpgsql
AS $function$
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
  
  -- LÓGICA CORRIGIDA: Se há vagas_datapagamento no update, calcular dias baseado na primeira vaga da recorrência
  IF (p_update ? 'vagas_datapagamento') THEN
    -- Buscar primeira vaga da recorrência para calcular os dias de pagamento originais
    SELECT v.vagas_data, v.vagas_datapagamento INTO nova_data_plantao, nova_data_pagamento
    FROM vagas v 
    WHERE v.recorrencia_id = p_recorrencia_id 
    ORDER BY v.vagas_data 
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
      nova_data_pagamento := vaga.vagas_data + (dias_para_pagamento || ' days')::interval;
      RAISE NOTICE 'Vaga %: Data plantão %, nova data pagamento %', vaga.vagas_id, vaga.vagas_data, nova_data_pagamento;
    ELSE
      -- Usar data do update se não conseguiu calcular dias
      nova_data_pagamento := COALESCE((p_update->>'vagas_datapagamento')::date, vaga.vagas_datapagamento);
    END IF;
    
    -- Atualizar dados da vaga (usando nomenclatura correta)
    UPDATE public.vagas SET
      vagas_hospital = COALESCE((p_update->>'vagas_hospital')::uuid, vagas_hospital),
      vagas_data = COALESCE((p_update->>'vagas_data')::date, vagas_data),
      vagas_periodo = COALESCE((p_update->>'vagas_periodo')::uuid, vagas_periodo),
      vagas_horainicio = COALESCE((p_update->>'vagas_horainicio')::time, vagas_horainicio),
      vagas_horafim = COALESCE((p_update->>'vagas_horafim')::time, vagas_horafim),
      vagas_valor = COALESCE((p_update->>'vagas_valor')::integer, vagas_valor),
      vagas_datapagamento = nova_data_pagamento, -- USAR DATA RECALCULADA INDIVIDUALMENTE
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
    
    -- Atualizar benefícios da vaga
    DELETE FROM public.vagas_beneficio WHERE vagas_id = vaga.vagas_id;
    IF p_beneficios IS NOT NULL AND array_length(p_beneficios, 1) > 0 THEN
      FOR beneficio_id IN SELECT unnest(p_beneficios) LOOP
        INSERT INTO public.vagas_beneficio (vagas_id, beneficio_id)
        VALUES (vaga.vagas_id, beneficio_id::uuid);
      END LOOP;
    END IF;

    -- Atualizar requisitos da vaga
    DELETE FROM public.vagas_requisito WHERE vagas_id = vaga.vagas_id;
    IF p_requisitos IS NOT NULL AND array_length(p_requisitos, 1) > 0 THEN
      FOR requisito_id IN SELECT unnest(p_requisitos) LOOP
        INSERT INTO public.vagas_requisito (vagas_id, requisito_id)
        VALUES (vaga.vagas_id, requisito_id::uuid);
      END LOOP;
    END IF;
    
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
    
    RAISE NOTICE 'Vaga % atualizada com pagamento em %', vaga.vagas_id, nova_data_pagamento;
  END LOOP;
  
  -- Log do resultado
  RAISE NOTICE 'Edição concluída. % vagas atualizadas para recorrência: %', vagas_atualizadas, p_recorrencia_id;
  
  -- Verificar se alguma vaga foi atualizada
  IF vagas_atualizadas = 0 THEN
    RAISE EXCEPTION 'Nenhuma vaga encontrada para a recorrência: %', p_recorrencia_id;
  END IF;
END;
$function$;

-- =====================================================
-- Função 3: editar_vagas_recorrencia (com dias de pagamento) - Apenas alteração dos nomes das colunas
-- =====================================================

CREATE OR REPLACE FUNCTION public.editar_vagas_recorrencia(p_recorrencia_id uuid, p_update jsonb, p_updateby uuid, p_beneficios text[] DEFAULT ARRAY[]::text[], p_requisitos text[] DEFAULT ARRAY[]::text[], p_dias_pagamento integer DEFAULT NULL::integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
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
  ELSIF (p_update ? 'vagas_datapagamento') THEN
    -- Tentar calcular baseado na primeira vaga da recorrência
    SELECT calcular_dias_pagamento(v.vagas_data, v.vagas_datapagamento) 
    INTO dias_para_pagamento
    FROM vagas v 
    WHERE v.recorrencia_id = p_recorrencia_id 
    ORDER BY v.vagas_data 
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
      nova_data_pagamento := vaga.vagas_data + (dias_para_pagamento || ' days')::interval;
      RAISE NOTICE 'Vaga %: Data plantão %, nova data pagamento % (+ % dias)', 
        vaga.vagas_id, vaga.vagas_data, nova_data_pagamento, dias_para_pagamento;
    ELSE
      nova_data_pagamento := COALESCE((p_update->>'vagas_datapagamento')::date, vaga.vagas_datapagamento);
    END IF;
    
    -- Atualizar dados da vaga (usando nomenclatura correta)
    UPDATE public.vagas SET
      vagas_hospital = COALESCE((p_update->>'vagas_hospital')::uuid, vagas_hospital),
      vagas_data = COALESCE((p_update->>'vagas_data')::date, vagas_data),
      vagas_periodo = COALESCE((p_update->>'vagas_periodo')::uuid, vagas_periodo),
      vagas_horainicio = COALESCE((p_update->>'vagas_horainicio')::time, vagas_horainicio),
      vagas_horafim = COALESCE((p_update->>'vagas_horafim')::time, vagas_horafim),
      vagas_valor = COALESCE((p_update->>'vagas_valor')::integer, vagas_valor),
      vagas_datapagamento = nova_data_pagamento, -- DATA RECALCULADA INDIVIDUALMENTE
      vagas_formarecebimento = COALESCE((p_update->>'vagas_formarecebimento')::uuid, vagas_formarecebimento),
      vagas_tipo = COALESCE((p_update->>'vagas_tipo')::uuid, vagas_tipo),
      vagas_observacoes = COALESCE((p_update->>'vagas_observacoes'), vagas_observacoes),
      vagas_setor = COALESCE((p_update->>'vagas_setor')::uuid, vagas_setor),
      vagas_escalista = COALESCE((p_update->>'vagas_escalista')::uuid, vagas_escalista),
      vaga_especialidade = COALESCE((p_update->>'vaga_especialidade')::uuid, vaga_especialidade),
      grupo_id = COALESCE((p_update->>'grupo_id')::uuid, grupo_id),
      vagas_status = CASE 
        WHEN (p_update ? 'medico_id') THEN 
          CASE WHEN novo_medico_id IS NOT NULL THEN 'fechada' ELSE 'aberta' END
        ELSE vagas_status 
      END,
      vagas_updateat = now_brasil,
      vagas_updateby = p_updateby
    WHERE vagas_id = vaga.vagas_id;
    
    -- Atualizar benefícios da vaga
    DELETE FROM public.vagas_beneficio WHERE vagas_id = vaga.vagas_id;
    IF p_beneficios IS NOT NULL AND array_length(p_beneficios, 1) > 0 THEN
      FOR beneficio_id IN SELECT unnest(p_beneficios) LOOP
        INSERT INTO public.vagas_beneficio (vagas_id, beneficio_id)
        VALUES (vaga.vagas_id, beneficio_id::uuid);
      END LOOP;
    END IF;

    -- Atualizar requisitos da vaga
    DELETE FROM public.vagas_requisito WHERE vagas_id = vaga.vagas_id;
    IF p_requisitos IS NOT NULL AND array_length(p_requisitos, 1) > 0 THEN
      FOR requisito_id IN SELECT unnest(p_requisitos) LOOP
        INSERT INTO public.vagas_requisito (vagas_id, requisito_id)
        VALUES (vaga.vagas_id, requisito_id::uuid);
      END LOOP;
    END IF;
    
    vagas_atualizadas := vagas_atualizadas + 1;
    
    -- Gerenciar candidaturas quando médico é especificado
    IF (p_update ? 'medico_id') THEN
      IF novo_medico_id IS NOT NULL THEN
        SELECT * INTO candidatura_existente 
        FROM public.candidaturas 
        WHERE vagas_id = vaga.vagas_id AND candidatura_status = 'APROVADO'
        LIMIT 1;
        
        IF candidatura_existente.candidaturas_id IS NOT NULL THEN
          UPDATE public.candidaturas SET
            medico_id = novo_medico_id,
            candidaturas_updateat = now_brasil,
            candidaturas_updateby = p_updateby::text
          WHERE candidaturas_id = candidatura_existente.candidaturas_id;
        ELSE
          INSERT INTO public.candidaturas (
            medico_id, vagas_id, candidatura_status, candidatos_createdate, candidaturas_updateat, candidaturas_updateby, vagas_valor
          ) VALUES (
            novo_medico_id, vaga.vagas_id, 'APROVADO', now_brasil, now_brasil, p_updateby::text, vaga.vagas_valor
          );
        END IF;
      ELSE
        DELETE FROM public.candidaturas 
        WHERE vagas_id = vaga.vagas_id AND candidatura_status = 'APROVADO';
      END IF;
    END IF;
  END LOOP;
  
  RAISE NOTICE 'Edição concluída. % vagas atualizadas para recorrência: %', vagas_atualizadas, p_recorrencia_id;
  
  IF vagas_atualizadas = 0 THEN
    RAISE EXCEPTION 'Nenhuma vaga encontrada para a recorrência: %', p_recorrencia_id;
  END IF;
END;
$function$;

-- Função deletar_vagas_recorrencia - Apenas alteração dos nomes das colunas
CREATE OR REPLACE FUNCTION public.deletar_vagas_recorrencia(p_recorrencia_id uuid, p_updateby uuid)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
  vaga RECORD;
BEGIN
  FOR vaga IN SELECT vagas_id FROM public.vagas WHERE recorrencia_id = p_recorrencia_id LOOP
    -- Deleta benefícios
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
$function$;


-- Função excluir_vagas_lote - Apenas alteração dos nomes das colunas
CREATE OR REPLACE FUNCTION excluir_vagas_lote(vagas_ids UUID[])
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY INVOKER
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


-- 13. Remove funções não utilizadas

-- Remover funções na ordem de dependências (menos dependentes primeiro)

-- Funções de documentação
DROP FUNCTION IF EXISTS reprovar_documento(uuid, text, text, uuid) cascade;
DROP FUNCTION IF EXISTS update_documento_status(uuid, text, boolean, uuid);
DROP FUNCTION IF EXISTS update_documento_url(uuid, text, text);
DROP FUNCTION IF EXISTS get_documento_historico(uuid);
DROP FUNCTION IF EXISTS get_documentos_pendentes(uuid);
DROP FUNCTION IF EXISTS get_medicos_com_documentos();
DROP FUNCTION IF EXISTS get_medicos_documentacao_pendente();
DROP FUNCTION IF EXISTS get_percentual_conclusao(uuid);
DROP FUNCTION IF EXISTS get_urls_pendentes(uuid);
DROP FUNCTION IF EXISTS inserir_validacao_documentos();

-- Funções de carteira digital
DROP FUNCTION IF EXISTS criar_carteira_digital(uuid);
DROP FUNCTION IF EXISTS inserir_carteira_digital();

-- Funções de cálculo e pagamento
DROP FUNCTION IF EXISTS calcular_distancia(decimal, decimal, decimal, decimal);

-- Funções de sincronização
DROP FUNCTION IF EXISTS sync_pagamentos_medico_id();
DROP FUNCTION IF EXISTS sync_vagas_beneficio_vaga_id();

-- Funções de atualização de views
DROP FUNCTION IF EXISTS refresh_dashboard_metrics();
DROP FUNCTION IF EXISTS refresh_vw_vagas_disponiveis();

-- Funções de validação e debug
DROP FUNCTION IF EXISTS pode_ver_candidatura_colega_debug(uuid, uuid);
DROP FUNCTION IF EXISTS verificar_consistencia_status_vagas();
DROP FUNCTION IF EXISTS contar_linhas_duplo(text);

-- Funções de correção e atualização de vagas
DROP FUNCTION IF EXISTS corrigir_inconsistencias_vagas();
DROP FUNCTION IF EXISTS atualizar_status_vagas_expiradas();