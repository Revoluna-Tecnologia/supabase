
-- Esta migration contém:
-- 1. Adicionar permissões para coordenador e medicos.delete para admin/moderador
-- 2. Dropar função obsoleta houston.authorize(permission) - mantém apenas versão com 4 parâmetros
-- 3. DROP completo de todas as políticas existentes em storage.objects
-- 4. Políticas RLS para storage.objects usando houston.authorize (versão com 4 parâmetros)
-- 5. Mapeamento usando permissões hospitais.* e medicos.*
-- 6. Configuração de acesso público para leitura (buckets já são públicos)
--
-- BUCKETS:
--   - avatarhospitais: Usa permissões hospitais.* (insert, delete)
--   - carteira-digital: Usa permissões medicos.* (insert, delete)
--   - profilepictures: Apenas médicos (próprias fotos, usado pela app mobile)
-- =============================================================================

-- =============================================================================
-- 1. ADICIONAR PERMISSÕES FALTANTES
-- =============================================================================
-- Adiciona permissões de médicos para coordenador
-- Adiciona permissão medicos.delete para administrador e moderador

INSERT INTO houston.role_permissions (role, permission) VALUES
  -- Permissões de coordenador
  ('coordenador', 'medicos.select'),
  ('coordenador', 'medicos.insert'),
  ('coordenador', 'medicos.update'),
  ('coordenador', 'medicos_precadastro.select'),
  ('coordenador', 'medicos_precadastro.insert'),
  ('coordenador', 'medicos_precadastro.update'),
  -- Permissão de delete para administrador e moderador
  ('administrador', 'medicos.delete'),
  ('moderador', 'medicos.delete')
ON CONFLICT (role, permission) DO NOTHING;

-- =============================================================================
-- 2. DROPAR FUNÇÃO OBSOLETA houston.authorize COM 1 PARÂMETRO
-- =============================================================================
-- Remove a função antiga que causa conflito com a nova versão de 4 parâmetros

DROP FUNCTION IF EXISTS houston.authorize(houston.app_permission);

-- =============================================================================
-- 3. REMOVER TODAS AS POLÍTICAS DE STORAGE.OBJECTS (TRUNCATE)
-- =============================================================================
-- Remove todas as políticas existentes na tabela storage.objects para começar limpo

DO $$
DECLARE
  policy_record RECORD;
BEGIN
  -- Loop através de todas as políticas em storage.objects e remove uma por uma
  FOR policy_record IN
    SELECT policyname
    FROM pg_policies
    WHERE schemaname = 'storage'
      AND tablename = 'objects'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', policy_record.policyname);
  END LOOP;

  RAISE NOTICE 'Todas as políticas de storage.objects foram removidas';
END$$;

-- =============================================================================
-- 4. POLÍTICAS PARA BUCKET: avatarhospitais
-- =============================================================================
-- Avatares de hospitais são gerenciados por quem tem permissão de hospitais
-- Lógica: Quem pode gerenciar hospitais, pode gerenciar avatares de hospitais
-- Permissões usadas: hospitais.insert, hospitais.delete
-- Nota: Não há UPDATE porque arquivos são sempre substituídos (delete + insert)

-- SELECT: Público (bucket é público, qualquer um pode ler)
CREATE POLICY "avatarhospitais_select_public"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'avatarhospitais');

-- INSERT: Usuários que podem inserir hospitais
CREATE POLICY "avatarhospitais_insert"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatarhospitais'
  AND houston.authorize('hospitais.insert')
);

-- DELETE: Usuários que podem deletar hospitais
CREATE POLICY "avatarhospitais_delete"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatarhospitais'
  AND houston.authorize('hospitais.delete')
);

-- =============================================================================
-- 5. POLÍTICAS PARA BUCKET: carteira-digital
-- =============================================================================
-- Carteiras digitais são gerenciadas por quem tem permissão de médicos
-- Lógica: Médicos podem gerenciar suas próprias carteiras, ou quem tem permissão de médicos
-- Permissões usadas: medicos.insert (upload), medicos.delete (remoção)
-- Nota: Não há UPDATE porque arquivos são sempre substituídos (delete + insert)
--
-- IMPORTANTE: A estrutura de arquivos deve seguir o padrão:
--   carteira-digital/{medico_id}/{tipo}/{arquivo}

-- SELECT: Público (bucket é público, qualquer um pode ler)
CREATE POLICY "carteira_digital_select_public"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'carteira-digital');

-- INSERT: Médicos podem fazer upload de sua própria carteira OU usuários com permissão
CREATE POLICY "carteira_digital_insert"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'carteira-digital'
  AND (
    -- Médico pode fazer upload da própria carteira (primeira pasta = UUID do médico)
    (storage.foldername(name))[1] = auth.uid()::text
    OR
    -- Ou tem permissão medicos.insert (administradores, moderadores, gestores, escalistas, coordenadores)
    houston.authorize('medicos.insert')
  )
);

-- DELETE: Médicos podem deletar sua própria carteira OU usuários com permissão medicos.delete
CREATE POLICY "carteira_digital_delete"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'carteira-digital'
  AND (
    -- Médico pode deletar documentos da própria pasta
    (storage.foldername(name))[1] = auth.uid()::text
    OR
    -- Ou tem permissão medicos.delete (apenas administradores e moderadores)
    houston.authorize('medicos.delete')
  )
);

-- =============================================================================
-- 6. POLÍTICAS PARA BUCKET: profilepictures
-- =============================================================================
-- Fotos de perfil de médicos são gerenciadas pelos próprios médicos
-- Lógica: Médicos podem fazer upload/deletar apenas suas próprias fotos
-- Upload feito pela plataforma mobile
-- Estrutura: profilepictures/{medico_id}/foto.jpg

-- INSERT: Apenas médicos podem fazer upload de suas próprias fotos
CREATE POLICY "profilepictures_insert"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'profilepictures'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- DELETE: Apenas médicos podem deletar suas próprias fotos
CREATE POLICY "profilepictures_delete"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'profilepictures'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- =============================================================================
-- 7. GRANTS E PERMISSÕES
-- =============================================================================
-- Garantir que usuários autenticados podem acessar storage.objects

GRANT ALL ON storage.objects TO authenticated;
GRANT ALL ON storage.buckets TO authenticated;

-- =============================================================================
-- FIM DA MIGRATION
-- =============================================================================
--
-- RESUMO DAS POLÍTICAS CRIADAS:
--
-- AVATARHOSPITAIS (Avatares de Hospitais):
--   - SELECT: Público (qualquer um pode visualizar)
--   - INSERT: Requer permissão hospitais.insert
--   - DELETE: Requer permissão hospitais.delete
--   - UPDATE: Não implementado (arquivos são substituídos via delete + insert)
--
--   Roles com acesso (baseado na tabela de permissões):
--     - Administrador: Insert, delete, select
--     - Moderador: Insert, select
--     - Gestor: Insert, select
--     - Escalista: Insert, select
--     - Coordenador: Apenas visualização (select público)
--
-- CARTEIRA-DIGITAL (Carteiras Digitais dos Médicos):
--   - SELECT: Público (qualquer um pode visualizar)
--   - INSERT: Médico pode fazer upload da própria OU permissão medicos.insert
--   - DELETE: Médico pode deletar a própria OU permissão medicos.delete
--   - UPDATE: Não implementado (arquivos são substituídos via delete + insert)
--
--   Roles com acesso para upload (medicos.insert):
--     - Administrador: Insert em todas carteiras
--     - Moderador: Insert em todas carteiras
--     - Gestor: Insert em todas carteiras
--     - Escalista: Insert em todas carteiras
--     - Coordenador: Insert em todas carteiras
--
--   Roles com acesso para delete (medicos.delete):
--     - Administrador: Delete em todas carteiras
--     - Moderador: Delete em todas carteiras
--
--   Acesso próprio:
--     - Médicos: Podem fazer upload e deletar apenas suas próprias carteiras
--
-- ESTRUTURA DE ARQUIVOS ESPERADA:
--   - avatarhospitais: Qualquer estrutura de nomes (ex: {hospital_id}.png)
--   - carteira-digital: {medico_id}/{tipo}/{arquivo}
--                       (pasta com UUID do médico, depois tipo do documento)
--
-- PERMISSÕES ADICIONADAS NESTA MIGRATION:
--
--   Para coordenador:
--     - medicos.select
--     - medicos.insert
--     - medicos.update
--     - medicos_precadastro.select
--     - medicos_precadastro.insert
--     - medicos_precadastro.update
--
--   Para administrador e moderador:
--     - medicos.delete (permite deletar documentos de carteira-digital de qualquer médico)
--
-- NOTAS IMPORTANTES:
--   1. Os buckets estão configurados como PUBLIC no config.toml para leitura
--   2. O DELETE em carteira-digital usa medicos.delete, restrito a administradores
--      e moderadores para maior controle sobre remoção de documentos
--   3. Não há políticas de UPDATE porque a aplicação sempre faz delete + insert
--      para substituir arquivos (upsert: false no código)
--   4. Coordenadores podem fazer upload de documentos mas NÃO podem deletar
--      documentos de outros médicos (apenas administradores e moderadores)
-- =============================================================================
