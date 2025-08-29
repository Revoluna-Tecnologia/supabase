
-- Corrigir função para usar UUID correto no vagas_updateby
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
    sistema_uuid uuid := '00000000-0000-0000-0000-000000000001'; -- UUID para sistema
BEGIN
    -- 1. Cancelar vagas 'aberta' com data passada
    UPDATE vagas 
    SET 
        vagas_status = 'cancelada',
        vagas_updateat = NOW(),
        vagas_updateby = sistema_uuid
    WHERE vagas_status = 'aberta' 
    AND vagas_data < CURRENT_DATE;
    
    GET DIAGNOSTICS canceladas_count = ROW_COUNT;
    
    -- 2. Fechar vagas 'anunciada' com data passada  
    UPDATE vagas 
    SET 
        vagas_status = 'fechada',
        vagas_updateat = NOW(),
        vagas_updateby = sistema_uuid
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
    
    -- Log da execução (apenas se tabela sistema_logs existir)
    BEGIN
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
    EXCEPTION
        WHEN undefined_table THEN
            -- Tabela sistema_logs não existe, continuar sem log
            NULL;
    END;
    
    -- Retornar estatísticas
    RETURN QUERY SELECT canceladas_count, fechadas_count, reprovadas_count;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Tentar log de erro se tabela existir
        BEGIN
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
        EXCEPTION
            WHEN OTHERS THEN
                -- Ignorar erro de log
                NULL;
        END;
        
        -- Re-raise o erro
        RAISE;
END;
$$;
;
