CREATE OR REPLACE FUNCTION aprovacao_automatica_favoritos()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se existe uma relação de favorito entre o médico e o grupo da vaga
    IF EXISTS (
        SELECT 1 
        FROM medicos_favoritos mf
        INNER JOIN vagas v ON v.vagas_id = NEW.vagas_id
        WHERE mf.medico_id = NEW.medico_id 
        AND mf.grupo_id = v.grupo_id
    ) THEN
        -- Se o médico é favorito do grupo, aprova automaticamente
        NEW.candidatura_status := 'APROVADO';
        NEW.candidatos_dataconfirmacao := CURRENT_DATE;
        NEW.candidaturas_updateat := NOW();
        NEW.candidaturas_updateby := 'SISTEMA_AUTO_APROVACAO';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;;
