
-- Função para monitorar a consistência do status das vagas
CREATE OR REPLACE FUNCTION verificar_consistencia_status_vagas()
RETURNS TABLE (
    problema TEXT,
    quantidade INTEGER,
    detalhes TEXT
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Verificar vagas fechadas sem candidaturas (problema que corrigimos)
    RETURN QUERY 
    SELECT 
        'Vagas fechadas incorretamente (sem candidaturas)'::TEXT as problema,
        COUNT(*)::INTEGER as quantidade,
        'Vagas que deveriam estar canceladas, não fechadas'::TEXT as detalhes
    FROM vagas v
    WHERE v.vagas_status = 'fechada' 
    AND v.vagas_totalcandidaturas = 0
    AND NOT EXISTS (
        SELECT 1 FROM candidaturas c 
        WHERE c.vagas_id = v.vagas_id
    );
    
    -- Verificar vagas abertas expiradas
    RETURN QUERY 
    SELECT 
        'Vagas abertas expiradas'::TEXT as problema,
        COUNT(*)::INTEGER as quantidade,
        'Vagas que deveriam ter status atualizado'::TEXT as detalhes
    FROM vagas v
    WHERE v.vagas_data < CURRENT_DATE 
    AND v.vagas_status = 'aberta';
    
    -- Verificar candidaturas pendentes em vagas fechadas/canceladas
    RETURN QUERY 
    SELECT 
        'Candidaturas pendentes em vagas encerradas'::TEXT as problema,
        COUNT(*)::INTEGER as quantidade,
        'Candidaturas que deveriam estar reprovadas'::TEXT as detalhes
    FROM candidaturas c
    JOIN vagas v ON c.vagas_id = v.vagas_id
    WHERE c.candidatura_status = 'PENDENTE'
    AND v.vagas_status IN ('fechada', 'cancelada');
    
END;
$$;

-- Função para corrigir inconsistências encontradas
CREATE OR REPLACE FUNCTION corrigir_inconsistencias_vagas()
RETURNS TABLE (
    acao TEXT,
    quantidade INTEGER
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    correcoes_fechadas INTEGER := 0;
    correcoes_candidaturas INTEGER := 0;
BEGIN
    -- Corrigir vagas fechadas incorretamente
    UPDATE vagas 
    SET 
        vagas_status = 'cancelada',
        vagas_updateat = NOW(),
        vagas_updateby = 'ada3a79a-6437-4e27-9e22-40c08c36c59b'
    WHERE vagas_status = 'fechada' 
    AND vagas_totalcandidaturas = 0
    AND NOT EXISTS (
        SELECT 1 FROM candidaturas c 
        WHERE c.vagas_id = vagas.vagas_id
    );
    
    GET DIAGNOSTICS correcoes_fechadas = ROW_COUNT;
    
    -- Corrigir candidaturas pendentes em vagas encerradas
    UPDATE candidaturas 
    SET 
        candidatura_status = 'REPROVADO',
        candidaturas_updateat = NOW(),
        candidaturas_updateby = 'Sistema - Correção automática'
    WHERE candidatura_status = 'PENDENTE'
    AND vagas_id IN (
        SELECT vagas_id 
        FROM vagas 
        WHERE vagas_status IN ('fechada', 'cancelada')
    );
    
    GET DIAGNOSTICS correcoes_candidaturas = ROW_COUNT;
    
    -- Retornar resultados
    RETURN QUERY SELECT 
        'Vagas corrigidas (fechada -> cancelada)'::TEXT,
        correcoes_fechadas;
        
    RETURN QUERY SELECT 
        'Candidaturas corrigidas (pendente -> reprovado)'::TEXT,
        correcoes_candidaturas;
END;
$$;

-- Comentários explicativos
COMMENT ON FUNCTION verificar_consistencia_status_vagas() IS 
'Verifica inconsistências no status de vagas e candidaturas para monitoramento preventivo';

COMMENT ON FUNCTION corrigir_inconsistencias_vagas() IS 
'Corrige inconsistências encontradas no status de vagas e candidaturas';
;
