
-- Corrigir FK: candidaturas -> medicos_precadastro	
ALTER TABLE public.candidaturas DROP CONSTRAINT fk_medico_precadastro_candidaturas;
ALTER TABLE public.candidaturas ADD CONSTRAINT fk_medico_precadastro_candidaturas FOREIGN KEY (medico_precadastro_id) REFERENCES public.medicos_precadastro(id) ON DELETE CASCADE ON UPDATE CASCADE;
-- Corrigir FK: candidaturas -> vagas	
ALTER TABLE public.candidaturas DROP CONSTRAINT candidaturas_vaga_id_fkey;
ALTER TABLE public.candidaturas ADD CONSTRAINT candidaturas_vaga_id_fkey FOREIGN KEY (vaga_id) REFERENCES public.vagas(id) ON DELETE CASCADE ON UPDATE CASCADE;
-- Corrigir FK: checkin_checkout -> vagas	
ALTER TABLE public.checkin_checkout DROP CONSTRAINT checkin_checkout_vagas_id_fkey;
ALTER TABLE public.checkin_checkout ADD CONSTRAINT checkin_checkout_vagas_id_fkey FOREIGN KEY (vaga_id) REFERENCES public.vagas(id) ON DELETE CASCADE ON UPDATE CASCADE;
-- Corrigir FK: checkin_checkout -> medicos	
ALTER TABLE public.checkin_checkout DROP CONSTRAINT checkin_checkout_medico_id_fkey;
ALTER TABLE public.checkin_checkout ADD CONSTRAINT checkin_checkout_medico_id_fkey FOREIGN KEY (medico_id) REFERENCES public.medicos(id) ON DELETE CASCADE ON UPDATE CASCADE;
-- Corrigir FK: equipes_medicos -> medicos_precadastro	
ALTER TABLE public.equipes_medicos DROP CONSTRAINT fk_medico_precadastro;
ALTER TABLE public.equipes_medicos ADD CONSTRAINT fk_medico_precadastro FOREIGN KEY (medico_precadastro_id) REFERENCES public.medicos_precadastro(id) ON DELETE CASCADE ON UPDATE CASCADE;
-- Corrigir FK: grades -> hospitais	
ALTER TABLE public.grades DROP CONSTRAINT grades_hospital_id_fkey;	
ALTER TABLE public.grades ADD CONSTRAINT grades_hospital_id_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospitais(id) ON DELETE CASCADE ON UPDATE CASCADE;
-- Corrigir FK: grades -> setores	
ALTER TABLE public.grades DROP CONSTRAINT grades_setor_id_fkey;	
ALTER TABLE public.grades ADD CONSTRAINT grades_setor_id_fkey FOREIGN KEY (setor_id) REFERENCES public.setores(id) ON DELETE CASCADE ON UPDATE CASCADE;
-- Corrigir FK: grades -> especialidades	
ALTER TABLE public.grades DROP CONSTRAINT grades_especialidade_id_fkey;	
ALTER TABLE public.grades ADD CONSTRAINT grades_especialidade_id_fkey FOREIGN KEY (especialidade_id) REFERENCES public.especialidades(id) ON DELETE CASCADE ON UPDATE CASCADE;
-- Corrigir FK: vagas -> tipos_vaga	
ALTER TABLE public.vagas DROP CONSTRAINT vagas_vagas_tipo_fkey;	
ALTER TABLE public.vagas ADD CONSTRAINT vagas_vagas_tipo_fkey FOREIGN KEY (tipos_vaga_id) REFERENCES public.tipos_vaga(id) ON DELETE CASCADE ON UPDATE CASCADE;
-- Corrigir FK: vagas -> periodos	
ALTER TABLE public.vagas DROP CONSTRAINT vagas_vagas_periodo_fkey;	
ALTER TABLE public.vagas ADD CONSTRAINT vagas_vagas_periodo_fkey FOREIGN KEY (periodo_id) REFERENCES public.periodos(id) ON DELETE CASCADE ON UPDATE CASCADE;
-- Corrigir FK: vagas -> vagas_recorrencias	
ALTER TABLE public.vagas DROP CONSTRAINT vagas_recorrencia_id_fkey;	
ALTER TABLE public.vagas ADD CONSTRAINT vagas_recorrencia_id_fkey FOREIGN KEY (recorrencia_id) REFERENCES public.vagas_recorrencias(id) ON DELETE CASCADE ON UPDATE CASCADE;
-- Corrigir FK: vagas -> hospitais	
ALTER TABLE public.vagas DROP CONSTRAINT vagas_vagas_hospital_fkey;	
ALTER TABLE public.vagas ADD CONSTRAINT vagas_vagas_hospital_fkey FOREIGN KEY (hospital_id) REFERENCES public.hospitais(id) ON DELETE CASCADE ON UPDATE CASCADE;
-- Corrigir FK: vagas -> setores	
ALTER TABLE public.vagas DROP CONSTRAINT vagas_vagas_setor_fkey;
ALTER TABLE public.vagas ADD CONSTRAINT vagas_vagas_setor_fkey FOREIGN KEY (setor_id) REFERENCES public.setores(id) ON DELETE CASCADE ON UPDATE CASCADE;
-- Corrigir FK: vagas -> grades	
ALTER TABLE public.vagas DROP CONSTRAINT fk_vagas_grade;
ALTER TABLE public.vagas ADD CONSTRAINT fk_vagas_grade FOREIGN KEY (grade_id) REFERENCES public.grades(id) ON DELETE CASCADE ON UPDATE CASCADE;
-- Corrigir FK: vagas -> especialidades	
ALTER TABLE public.vagas DROP CONSTRAINT vagas_vaga_especialidade_fkey;	
ALTER TABLE public.vagas ADD CONSTRAINT vagas_vaga_especialidade_fkey FOREIGN KEY (especialidade_id) REFERENCES public.especialidades(id) ON DELETE CASCADE ON UPDATE CASCADE;
-- Corrigir FK: vagas -> formas_recebimento	
ALTER TABLE public.vagas DROP CONSTRAINT vagas_formarecebimento_fkey;	
ALTER TABLE public.vagas ADD CONSTRAINT vagas_formarecebimento_fkey FOREIGN KEY (forma_recebimento_id) REFERENCES public.formas_recebimento(id) ON DELETE CASCADE ON UPDATE CASCADE;
