-- Remover a foreign key constraint que impede inserir médicos pré-cadastrados
-- Isso permitirá que médicos da tabela medicos_precadastro sejam referenciados
ALTER TABLE equipes_medicos 
DROP CONSTRAINT fk_medico;;
