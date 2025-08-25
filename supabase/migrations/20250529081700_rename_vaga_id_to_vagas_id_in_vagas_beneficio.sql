-- Renomear coluna vaga_id para vagas_id na tabela vagas_beneficio
ALTER TABLE public.vagas_beneficio 
RENAME COLUMN vaga_id TO vagas_id;;
