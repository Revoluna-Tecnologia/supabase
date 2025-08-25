CREATE TABLE public.vagas_recorrencia (
  recorrencia_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  created_by uuid REFERENCES user_profile(id),
  data_inicio date NOT NULL,
  data_fim date NOT NULL,
  dias_semana integer[] NOT NULL, -- 0=domingo, 1=segunda, ...
  observacoes text
);

-- Adiciona coluna de referência na tabela de vagas
ALTER TABLE public.vagas ADD COLUMN IF NOT EXISTS recorrencia_id uuid REFERENCES public.vagas_recorrencia(recorrencia_id);

-- Index para facilitar buscas
CREATE INDEX IF NOT EXISTS idx_vagas_recorrencia_id ON public.vagas(recorrencia_id);;
