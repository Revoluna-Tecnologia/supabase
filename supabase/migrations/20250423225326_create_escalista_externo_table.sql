
-- Criar uma extensão para gerar UUIDs se ainda não existir
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Criar a tabela escalista_externo
CREATE TABLE IF NOT EXISTS public.escalista_externo (
  escalista_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  escalista_nome VARCHAR NOT NULL,
  escalista_telefone VARCHAR NOT NULL,
  escalista_email VARCHAR NOT NULL UNIQUE,
  grupo_id UUID REFERENCES public.grupo(grupo_id),
  escalista_createdate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  escalista_updateat TIMESTAMP NOT NULL DEFAULT (now() AT TIME ZONE 'utc'),
  escalista_updateby UUID
);

-- Criar um índice na coluna escalista_nome para melhorar o desempenho de consultas
CREATE INDEX IF NOT EXISTS idx_escalista_externo_nome ON public.escalista_externo(escalista_nome);
CREATE INDEX IF NOT EXISTS idx_escalista_externo_email ON public.escalista_externo(escalista_email);

-- Comentário para documentar a tabela
COMMENT ON TABLE public.escalista_externo IS 'Tabela para armazenar escalistas externos sem a restrição de chave estrangeira com user_profile';

-- Configurar permissões de RLS (Row Level Security) semelhantes à tabela original
ALTER TABLE public.escalista_externo ENABLE ROW LEVEL SECURITY;

-- Criar política para permitir inserções de usuários autenticados
CREATE POLICY insert_escalista_externo ON public.escalista_externo
FOR INSERT TO authenticated WITH CHECK (true);

-- Criar política para permitir leitura a usuários autenticados
CREATE POLICY read_escalista_externo ON public.escalista_externo
FOR SELECT TO authenticated USING (true);

-- Criar política para permitir atualização a usuários autenticados
CREATE POLICY update_escalista_externo ON public.escalista_externo
FOR UPDATE TO authenticated USING (true);

-- Criar política para permitir exclusão a usuários autenticados
CREATE POLICY delete_escalista_externo ON public.escalista_externo
FOR DELETE TO authenticated USING (true);
;
