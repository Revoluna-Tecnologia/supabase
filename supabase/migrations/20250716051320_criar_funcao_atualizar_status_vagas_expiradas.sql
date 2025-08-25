
-- Função para atualizar status de vagas com data passada
CREATE OR REPLACE FUNCTION atualizar_status_vagas_expiradas()
RETURNS TABLE(
    vagas_atualizadas_canceladas integer,
    vagas_atualizadas_fechadas integer,
    candidaturas_reprovadas integer
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    canceladas_count integer := 0;
    fechadas_count integer := 0;
    reprovadas_count integer := 0;
BEGIN
    -- 1. Cancelar vagas 'aberta' com data passada
    UPDATE vagas 
    SET 
        vagas_status = 'cancelada',
        vagas_updateat = NOW(),
        vagas_updateby = 'Sistema: Expiração Automática'
    WHERE vagas_status = 'aberta' 
    AND vagas_data < CURRENT_DATE;
    
    GET DIAGNOSTICS canceladas_count = ROW_COUNT;
    
    -- 2. Fechar vagas 'anunciada' com data passada  
    UPDATE vagas 
    SET 
        vagas_status = 'fechada',
        vagas_updateat = NOW(),
        vagas_updateby = 'Sistema: Expiração Automática'
    WHERE vagas_status = 'anunciada' 
    AND vagas_data < CURRENT_DATE;
    
    GET DIAGNOSTICS fechadas_count = ROW_COUNT;
    
    -- 3. Reprovar candidaturas pendentes de vagas canceladas
    UPDATE candidaturas 
    SET 
        candidatura_status = 'REPROVADO',
        candidaturas_updateat = NOW(),
        candidaturas_updateby = 'Sistema: Vaga Expirada'
    WHERE candidatura_status = 'PENDENTE'
    AND vagas_id IN (
        SELECT vagas_id 
        FROM vagas 
        WHERE vagas_status = 'cancelada' 
        AND vagas_data < CURRENT_DATE
    );
    
    GET DIAGNOSTICS reprovadas_count = ROW_COUNT;
    
    -- Log da execução
    INSERT INTO sistema_logs (
        log_tipo,
        log_descricao,
        log_data,
        log_detalhes
    ) VALUES (
        'MANUTENCAO_AUTOMATICA',
        'Atualização automática de status de vagas expiradas',
        NOW(),
        jsonb_build_object(
            'vagas_canceladas', canceladas_count,
            'vagas_fechadas', fechadas_count,
            'candidaturas_reprovadas', reprovadas_count,
            'data_execucao', CURRENT_DATE
        )
    );
    
    -- Retornar estatísticas
    RETURN QUERY SELECT canceladas_count, fechadas_count, reprovadas_count;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log de erro
        INSERT INTO sistema_logs (
            log_tipo,
            log_descricao,
            log_data,
            log_detalhes
        ) VALUES (
            'ERRO_MANUTENCAO',
            'Erro na atualização automática de vagas expiradas',
            NOW(),
            jsonb_build_object(
                'erro_message', SQLERRM,
                'erro_state', SQLSTATE
            )
        );
        
        -- Re-raise o erro
        RAISE;
END;
$$;

-- Criar tabela de logs se não existir
CREATE TABLE IF NOT EXISTS sistema_logs (
    log_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    log_tipo text NOT NULL,
    log_descricao text NOT NULL,
    log_data timestamp with time zone NOT NULL DEFAULT NOW(),
    log_detalhes jsonb
);

-- Comentário da função
COMMENT ON FUNCTION atualizar_status_vagas_expiradas() 
IS 'Função para execução diária: cancela vagas abertas e fecha vagas anunciadas com data passada';
;
