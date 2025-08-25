
-- Criar uma extensão para gerar UUIDs se ainda não existir
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Criar a tabela escalista_novo
CREATE TABLE IF NOT EXISTS public.escalista_novo (
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
CREATE INDEX IF NOT EXISTS idx_escalista_novo_nome ON public.escalista_novo(escalista_nome);
CREATE INDEX IF NOT EXISTS idx_escalista_novo_email ON public.escalista_novo(escalista_email);

-- Comentário para documentar a tabela
COMMENT ON TABLE public.escalista_novo IS 'Tabela para armazenar escalistas sem a restrição de chave estrangeira com user_profile';

-- Configurar permissões de RLS (Row Level Security) semelhantes à tabela original
ALTER TABLE public.escalista_novo ENABLE ROW LEVEL SECURITY;

-- Criar política para permitir inserções de usuários autenticados
CREATE POLICY insert_escalista_novo ON public.escalista_novo
FOR INSERT TO authenticated WITH CHECK (true);

-- Criar política para permitir leitura a usuários autenticados
CREATE POLICY read_escalista_novo ON public.escalista_novo
FOR SELECT TO authenticated USING (true);

-- Criar política para permitir atualização a usuários autenticados
CREATE POLICY update_escalista_novo ON public.escalista_novo
FOR UPDATE TO authenticated USING (true);

-- Criar política para permitir exclusão a usuários autenticados
CREATE POLICY delete_escalista_novo ON public.escalista_novo
FOR DELETE TO authenticated USING (true);
;
