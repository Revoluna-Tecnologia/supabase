-- 1. Remover as views dependentes primeiro, e depois a view vagas_completo
DROP VIEW IF EXISTS vw_vagas_por_mes;
DROP VIEW IF EXISTS vw_distribuicao_especialidades;
DROP VIEW IF EXISTS vagas_completo;

-- 2. Atualizar os valores na tabela vagas para UUIDs baseados nas correspondências na tabela formas_recebimento
-- Primeiro, vamos criar uma coluna temporária para evitar conflitos
ALTER TABLE public.vagas ADD COLUMN vagas_formarecebimento_temp UUID;

-- Atualizar a coluna temporária com os UUIDs correspondentes
UPDATE public.vagas v
SET vagas_formarecebimento_temp = fr.id
FROM public.formas_recebimento fr
WHERE fr.forma_recebimento = v.vagas_formarecebimento;

-- 3. Remover a coluna original e renomear a temporária
ALTER TABLE public.vagas DROP COLUMN vagas_formarecebimento;
ALTER TABLE public.vagas RENAME COLUMN vagas_formarecebimento_temp TO vagas_formarecebimento;

-- 4. Ajustar o tipo da coluna e adicionar a chave estrangeira
ALTER TABLE public.vagas ALTER COLUMN vagas_formarecebimento TYPE UUID USING vagas_formarecebimento::uuid;
ALTER TABLE public.vagas ADD CONSTRAINT vagas_formarecebimento_fkey FOREIGN KEY (vagas_formarecebimento) REFERENCES public.formas_recebimento(id);

-- 5. Recriar a view vagas_completo com a coluna traduzida
CREATE VIEW vagas_completo AS
SELECT 
    v.vagas_id,
    v.vagas_createdate,
    v.vagas_data,
    v.vagas_horainicio,
    v.vagas_horafim,
    v.vagas_valor,
    v.vagas_datapagamento,
    fr.forma_recebimento AS vagas_formarecebimento, -- Usar o texto traduzido em vez do UUID
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
    e.escalista_id,
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
LEFT JOIN escalista e ON v.vagas_escalista = e.escalista_id
LEFT JOIN especialidades esp ON v.vaga_especialidade = esp.especialidade_id
LEFT JOIN grupo g ON v.grupo_id = g.grupo_id
LEFT JOIN formas_recebimento fr ON v.vagas_formarecebimento = fr.id; -- Nova JOIN para trazer o texto

-- 6. Recriar as views dependentes
CREATE VIEW vw_vagas_por_mes AS
SELECT 
    date_trunc('month'::text, (vagas_completo.vagas_data)::timestamp without time zone) AS mes,
    count(vagas_completo.vagas_id) AS total_vagas
FROM vagas_completo
GROUP BY (date_trunc('month'::text, (vagas_completo.vagas_data)::timestamp without time zone))
ORDER BY (date_trunc('month'::text, (vagas_completo.vagas_data)::timestamp without time zone));

CREATE VIEW vw_distribuicao_especialidades AS
SELECT 
    vagas_completo.especialidade_nome AS especialidade,
    count(*) AS total
FROM vagas_completo
GROUP BY vagas_completo.especialidade_nome
ORDER BY (count(*)) DESC;;
