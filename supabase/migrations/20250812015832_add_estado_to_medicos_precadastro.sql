-- Adicionar campo estado do CRM na tabela medicos_precadastro (consistente com tabela medicos)
ALTER TABLE medicos_precadastro 
ADD COLUMN medico_estado TEXT;;
