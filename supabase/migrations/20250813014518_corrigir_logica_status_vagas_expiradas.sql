
-- Função corrigida para atualizar status de vagas expiradas
-- Vagas SEM candidaturas -> cancelada
-- Vagas COM candidaturas -> fechada
CREATE OR REPLACE FUNCTION atualizar_status_vagas_expiradas()
RETURNS TABLE (
    vagas_atualizadas_canceladas INTEGER,
    vagas_atualizadas_fechadas INTEGER,
    candidaturas_reprovadas INTEGER
) 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    vagas_canceladas INTEGER := 0;
    vagas_fechadas INTEGER := 0;
    candidaturas_reprovadas_count INTEGER := 0;
BEGIN
    -- 1. Atualizar vagas expiradas SEM candidaturas para 'cancelada'
    UPDATE vagas 
    SET 
        vagas_status = 'cancelada',
        vagas_updateat = NOW(),
        vagas_updateby = 'ada3a79a-6437-4e27-9e22-40c08c36c59b'
    WHERE 
        vagas_data < CURRENT_DATE 
        AND vagas_status = 'aberta'
        AND vagas_totalcandidaturas = 0
        AND NOT EXISTS (
            SELECT 1 FROM candidaturas c 
            WHERE c.vagas_id = vagas.vagas_id
        );
    
    GET DIAGNOSTICS vagas_canceladas = ROW_COUNT;
    
    -- 2. Atualizar vagas expiradas COM candidaturas para 'fechada'
    UPDATE vagas 
    SET 
        vagas_status = 'fechada',
        vagas_updateat = NOW(),
        vagas_updateby = 'ada3a79a-6437-4e27-9e22-40c08c36c59b'
    WHERE 
        vagas_data < CURRENT_DATE 
        AND vagas_status = 'aberta'
        AND (
            vagas_totalcandidaturas > 0 
            OR EXISTS (
                SELECT 1 FROM candidaturas c 
                WHERE c.vagas_id = vagas.vagas_id
            )
        );
    
    GET DIAGNOSTICS vagas_fechadas = ROW_COUNT;
    
    -- 3. Reprovar candidaturas pendentes de vagas expiradas
    UPDATE candidaturas 
    SET 
        candidatura_status = 'REPROVADO',
        candidaturas_updateat = NOW(),
        candidaturas_updateby = 'Sistema - Vaga expirada'
    WHERE 
        candidatura_status = 'PENDENTE'
        AND vagas_id IN (
            SELECT vagas_id 
            FROM vagas 
            WHERE vagas_data < CURRENT_DATE 
            AND vagas_status IN ('fechada', 'cancelada')
        );
    
    GET DIAGNOSTICS candidaturas_reprovadas_count = ROW_COUNT;
    
    -- Retornar resultados
    RETURN QUERY SELECT 
        vagas_canceladas,
        vagas_fechadas,
        candidaturas_reprovadas_count;
END;
$$;

-- Adicionar comentário explicativo
COMMENT ON FUNCTION atualizar_status_vagas_expiradas() IS 
'Atualiza status de vagas expiradas seguindo a regra:
- Vagas SEM candidaturas -> cancelada
- Vagas COM candidaturas -> fechada
- Reprova candidaturas pendentes de vagas expiradas';
;
