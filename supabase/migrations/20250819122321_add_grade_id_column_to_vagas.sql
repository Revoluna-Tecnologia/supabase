-- Adicionar coluna grade_id na tabela vagas
ALTER TABLE vagas 
ADD COLUMN grade_id uuid NULL;

-- Adicionar comentário explicativo
COMMENT ON COLUMN vagas.grade_id IS 'ID da grade que gerou esta vaga';

-- Criar foreign key constraint
ALTER TABLE vagas
ADD CONSTRAINT fk_vagas_grade
FOREIGN KEY (grade_id) 
REFERENCES grades(id)
ON DELETE SET NULL;

-- Criar índice para otimizar queries de filtro
CREATE INDEX idx_vagas_grade_id ON vagas(grade_id);;
