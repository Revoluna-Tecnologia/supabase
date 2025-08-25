-- Remover constraint antiga
ALTER TABLE equipes_medicos DROP CONSTRAINT unique_equipe_medico;

-- Criar índices únicos parciais para substituir a constraint
CREATE UNIQUE INDEX unique_equipe_medico_real 
ON equipes_medicos (equipes_id, medico_id) 
WHERE medico_precadastro_id IS NULL;

CREATE UNIQUE INDEX unique_equipe_medico_precadastro 
ON equipes_medicos (equipes_id, medico_precadastro_id) 
WHERE medico_precadastro_id IS NOT NULL;;
