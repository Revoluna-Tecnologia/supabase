-- Alterar valores padrão das colunas escalista_id e updated_by na tabela vagas

-- Atualizar valor padrão da coluna escalista_id
ALTER TABLE public.vagas 
ALTER COLUMN escalista_id 
SET DEFAULT 'cf37ce09-e25d-4c67-b319-3e50d1cc964b'::uuid;

-- Atualizar valor padrão da coluna updated_by
ALTER TABLE public.vagas 
ALTER COLUMN updated_by 
SET DEFAULT 'cf37ce09-e25d-4c67-b319-3e50d1cc964b'::uuid;