-- Migration: julia_escalista_externo_support
-- Epic 01 - Tarefa 4: Adicionar coluna escalista_externo_id e atualizar view
-- Permite que vagas referenciem escalistas externos

-- Nova coluna (nullable, sem impacto em vagas existentes)
ALTER TABLE vagas
  ADD COLUMN IF NOT EXISTS escalista_externo_id UUID REFERENCES escalistas_externos(id);

-- Tornar escalista_id nullable (vagas externas nao tem escalista auth)
ALTER TABLE vagas
  ALTER COLUMN escalista_id DROP NOT NULL;

-- Criar indice para a nova coluna
CREATE INDEX IF NOT EXISTS idx_vagas_escalista_externo_id
  ON vagas(escalista_externo_id);

-- Recriar a view vw_vagas_abertas com suporte a escalistas externos
DROP VIEW IF EXISTS vw_vagas_abertas;

CREATE VIEW vw_vagas_abertas AS
SELECT
    row_number() OVER (ORDER BY v.id) AS idx,
    v.id AS vaga_id,
    v.data AS vaga_data,
    v.created_at AS vaga_createdate,
    v.status AS vaga_status,
    v.valor AS vaga_valor,
    v.hora_inicio AS vaga_horainicio,
    v.hora_fim AS vaga_horafim,
    v.data_pagamento AS vaga_datapagamento,
    v.periodo_id,
    p.nome AS periodo_nome,
    v.tipos_vaga_id,
    t.nome AS tipos_vaga_nome,
    v.forma_recebimento_id AS formarecebimento_id,
    f.forma_recebimento AS formarecebimento_nome,
    v.observacoes AS vaga_observacoes,
    h.id AS hospital_id,
    h.nome AS hospital_nome,
    h.estado AS hospital_estado,
    h.latitude AS hospital_lat,
    h.longitude AS hospital_log,
    h.endereco_formatado AS hospital_end,
    h.avatar AS hospital_avatar,
    e.id AS especialidade_id,
    e.nome AS especialidade_nome,
    s.id AS setor_id,
    s.nome AS setor_nome,
    esc.id AS escalista_id,
    -- MUDANCA: COALESCE para buscar nome do escalista externo se nao houver interno
    COALESCE(esc.nome, eext.nome) AS escalista_nome,
    esc.email AS escalista_email,
    -- MUDANCA: COALESCE para buscar telefone do escalista externo se nao houver interno
    COALESCE(esc.telefone, eext.telefone) AS escalista_telefone,
    g.id AS grupo_id,
    g.nome AS grupo_nome
FROM vagas v
    JOIN hospitais h ON v.hospital_id = h.id
    JOIN especialidades e ON v.especialidade_id = e.id
    JOIN setores s ON v.setor_id = s.id
    LEFT JOIN escalistas esc ON v.escalista_id = esc.id
    -- MUDANCA: novo JOIN para escalistas externos
    LEFT JOIN escalistas_externos eext ON v.escalista_externo_id = eext.id
    LEFT JOIN grupos g ON v.grupo_id = g.id
    LEFT JOIN periodos p ON v.periodo_id = p.id
    LEFT JOIN tipos_vaga t ON v.tipos_vaga_id = t.id
    LEFT JOIN formas_recebimento f ON v.forma_recebimento_id = f.id
WHERE v.status::text = 'aberta'::text;

-- Comentario na coluna para documentacao
COMMENT ON COLUMN vagas.escalista_externo_id IS
  'Referencia para escalista externo (contatos WhatsApp). Usado quando escalista_id e NULL (vagas vindas do Julia).';
