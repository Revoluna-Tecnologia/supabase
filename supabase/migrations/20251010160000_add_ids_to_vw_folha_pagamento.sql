-- Migration: Add hospital_id, especialidade_id, and setor_id columns to vw_folha_pagamento view
-- Date: 2025-10-10

-- Drop the existing view
DROP VIEW IF EXISTS public.vw_folha_pagamento;

create view public.vw_folha_pagamento as
select
  v.id as vagas_id,
  v.data as vagas_data,
  p.nome as periodo_nome,
  v.hora_inicio as horario_inicio,
  v.hora_fim as horario_fim,
  v.valor as vagas_valor,
  v.data_pagamento as vagas_datapagamento,
  fr.forma_recebimento,
  h.id as hospital_id,
  h.nome as hospital_nome,
  e.id as especialidade_id,
  e.nome as vagas_especialidade,
  s.id as setor_id,
  s.nome as setor_nome,
  c.id as candidaturas_id,
  c.medico_id,
  c.medico_precadastro_id,
  c.status as candidatura_status,
  c.data_confirmacao as candidatos_dataconfirmacao,
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
  join candidaturas c on c.vagas_id = v.id
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