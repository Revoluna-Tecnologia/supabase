create or replace view vw_relatorio_folhapagamento as
select
  v.vagas_id,
  v.vagas_data,
  v.vagas_datapagamento,
  v.vagas_valor,
  h.hospital_id,
  h.hospital_nome,
  e.especialidade_id,
  e.especialidade_nome,
  s.setor_id,
  s.setor_nome,
  m.id as medico_id,
  m.medico_primeironome,
  m.medico_sobrenome,
  m.medico_crm,
  c.candidatura_status
from vagas v
join hospital h on v.vagas_hospital = h.hospital_id
join especialidades e on v.vaga_especialidade = e.especialidade_id
join setores s on v.vagas_setor = s.setor_id
join candidaturas c on c.vagas_id = v.vagas_id
join medicos m on c.medicos_id = m.id
where c.candidatura_status = 'APROVADO';;
