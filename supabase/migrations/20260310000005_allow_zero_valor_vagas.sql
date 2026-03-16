-- Migration: allow_zero_valor_vagas
-- Permite que o valor seja 0 (vagas externas do Julia podem não ter valor definido)

-- VAGAS: Remove constraint antiga (valor > 0)
ALTER TABLE vagas DROP CONSTRAINT IF EXISTS vagas_vagas_valor_check;

-- VAGAS: Adiciona nova constraint (valor >= 0)
ALTER TABLE vagas ADD CONSTRAINT vagas_vagas_valor_check CHECK (valor >= 0);

-- CANDIDATURAS: Remove constraint antiga (vaga_valor > 0)
ALTER TABLE candidaturas DROP CONSTRAINT IF EXISTS candidaturas_vaga_valor_check;

-- CANDIDATURAS: Adiciona nova constraint (vaga_valor >= 0)
ALTER TABLE candidaturas ADD CONSTRAINT candidaturas_vaga_valor_check CHECK (vaga_valor >= 0);
