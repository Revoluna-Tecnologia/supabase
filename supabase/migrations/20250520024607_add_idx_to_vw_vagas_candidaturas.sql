create view public.vw_vagas_candidaturas as
select
  row_number() over (order by v.vagas_id, c.candidaturas_id) as idx,
  v.vagas_id,
  v.vagas_data,
  v.vagas_status,
  v.vagas_valor,
  v.vagas_horainicio,
  v.vagas_horafim,
  v.vagas_datapagamento,
  v.vagas_periodo,
  p.periodo AS vagas_periodo_nome,
  v.vagas_tipo,
  t.tipo AS vagas_tipo_nome,
  v.vagas_formarecebimento,
  f.forma_recebimento AS vagas_formarecebimento_nome,
  v.vagas_observacoes,
  h.hospital_id,
  h.hospital_nome,
  e.especialidade_id,
  e.especialidade_nome,
  s.setor_id,
  s.setor_nome,
  esc.escalista_id,
  esc.escalista_nome,
  g.grupo_id,
  g.grupo_nome,
  c.candidaturas_id,
  c.candidatura_status,
  c.candidatos_createdate,
  m.id AS medico_id,
  m.medico_primeironome,
  m.medico_sobrenome,
  m.medico_crm,
  m.medico_email
from vagas v
join hospital h on v.vagas_hospital = h.hospital_id
join especialidades e on v.vaga_especialidade = e.especialidade_id
join setores s on v.vagas_setor = s.setor_id
left join escalista esc on v.vagas_escalista = esc.escalista_id
left join grupo g on v.grupo_id = g.grupo_id
left join candidaturas c on c.vagas_id = v.vagas_id
left join medicos m on c.medicos_id = m.id
left join periodo p on v.vagas_periodo = p.periodo_id
left join tipovaga t on v.vagas_tipo = t.id
left join formas_recebimento f on v.vagas_formarecebimento = f.id;;
