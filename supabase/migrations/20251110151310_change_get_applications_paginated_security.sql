-- =============================================================================
-- MIGRATION: Change Security Type for get_applications_paginated Function
-- =============================================================================
-- Created: 2025-10-23
-- Description: Altera o tipo de security da função get_applications_paginated
--              de SECURITY DEFINER para SECURITY INVOKER
-- =============================================================================

-- Método 1: Usando ALTER FUNCTION (mais direto)
ALTER FUNCTION get_applications_paginated(
    integer,
    integer,
    uuid[],
    uuid[],
    uuid[],
    date,
    date,
    numeric,
    numeric,
    uuid[],
    uuid[],
    uuid[],
    text,
    uuid[],
    text[],
    text[],
    uuid[],
    text,
    text
) SECURITY INVOKER;

-- Verificar se a alteração foi aplicada
-- (Este SELECT é apenas para documentação - não será executado na migration)
-- SELECT 
--     proname as function_name,
--     prosecdef as is_security_definer,
--     CASE 
--         WHEN prosecdef = true THEN 'SECURITY DEFINER'
--         ELSE 'SECURITY INVOKER'
--     END as security_type
-- FROM pg_proc 
-- WHERE proname = 'get_applications_paginated';

-- =============================================================================
-- COMENTÁRIOS SOBRE OS TIPOS DE SECURITY:
-- =============================================================================
-- 
-- SECURITY DEFINER:
-- - A função executa com os privilégios do OWNER da função
-- - Útil quando você quer que usuários com menos privilégios possam 
--   executar operações que normalmente não poderiam
-- - Mais seguro para funções que fazem operações administrativas
-- 
-- SECURITY INVOKER:
-- - A função executa com os privilégios do usuário que a CHAMA
-- - O usuário precisa ter as permissões necessárias para acessar 
--   as tabelas/views utilizadas pela função
-- - Mais restritivo, mas permite controle mais granular via RLS
-- 
-- =============================================================================
-- IMPACTO DA MUDANÇA:
-- =============================================================================
-- 
-- Ao mudar para SECURITY INVOKER:
-- 1. A função agora executará com os privilégios do usuário logado
-- 2. O usuário DEVE ter permissões SELECT na view vw_vagas_candidaturas
-- 3. As políticas RLS (Row Level Security) serão aplicadas
-- 4. Mais seguro para funções que devem respeitar o controle de acesso por usuário
-- 
-- =============================================================================

COMMENT ON FUNCTION get_applications_paginated IS 'Busca candidaturas individuais com filtros opcionais usando os campos corretos da view vw_vagas_candidaturas. Função alterada para SECURITY INVOKER para respeitar RLS policies e permissões do usuário.';