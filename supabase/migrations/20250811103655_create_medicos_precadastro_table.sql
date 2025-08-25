-- Criar tabela para médicos pré-cadastrados
CREATE TABLE medicos_precadastro (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  medico_primeironome VARCHAR(255) NOT NULL,
  medico_sobrenome VARCHAR(255) NOT NULL,
  medico_crm VARCHAR(50) NOT NULL,
  medico_cpf VARCHAR(14),
  medico_email VARCHAR(255),
  medico_telefone VARCHAR(20),
  medico_especialidade UUID REFERENCES especialidades(especialidade_id),
  created_by UUID REFERENCES escalista(escalista_id) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Índices únicos para evitar duplicatas
CREATE UNIQUE INDEX idx_medicos_precadastro_crm ON medicos_precadastro(medico_crm);
CREATE UNIQUE INDEX idx_medicos_precadastro_cpf ON medicos_precadastro(medico_cpf) WHERE medico_cpf IS NOT NULL;

-- Índices para performance
CREATE INDEX idx_medicos_precadastro_nome ON medicos_precadastro(medico_primeironome, medico_sobrenome);
CREATE INDEX idx_medicos_precadastro_created_by ON medicos_precadastro(created_by);

-- Habilitar RLS
ALTER TABLE medicos_precadastro ENABLE ROW LEVEL SECURITY;

-- Política RLS - usuários só veem pré-cadastros do próprio grupo
CREATE POLICY medicos_precadastro_policy ON medicos_precadastro
FOR ALL USING (
  created_by IN (
    SELECT e.escalista_id 
    FROM escalista e 
    WHERE e.grupo_id = (
      SELECT grupo_id 
      FROM escalista 
      WHERE escalista_auth_id = auth.uid()
    )
  )
);;
