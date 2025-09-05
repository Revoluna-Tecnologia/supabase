-- =============================================
-- SISTEMA DE PAGINAÇÃO PARA TABELA VAGAS
-- =============================================

-- Função principal para buscar vagas com paginação e filtros
CREATE OR REPLACE FUNCTION get_vagas_paginated(
    page_number integer DEFAULT 1,
    page_size integer DEFAULT 10,
    filtro_status text DEFAULT NULL,
    filtro_hospital_id uuid DEFAULT NULL,
    filtro_especialidade_id uuid DEFAULT NULL,
    filtro_setor_id uuid DEFAULT NULL,
    filtro_data_inicio date DEFAULT NULL,
    filtro_data_fim date DEFAULT NULL,
    filtro_valor_min numeric DEFAULT NULL,
    filtro_valor_max numeric DEFAULT NULL,
    filtro_periodo_id uuid DEFAULT NULL,
    filtro_tipo_id uuid DEFAULT NULL,
    filtro_grupo_id uuid DEFAULT NULL,
    filtro_busca_texto text DEFAULT NULL
)
RETURNS TABLE(
    data jsonb,
    pagination jsonb
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    validated_page integer;
    validated_size integer;
    total_count bigint;
    offset_value integer;
BEGIN
    -- Validar parâmetros
    validated_page := CASE WHEN page_number < 1 THEN 1 ELSE page_number END;
    validated_size := CASE 
        WHEN page_size < 1 THEN 10
        WHEN page_size > 100 THEN 100
        ELSE page_size
    END;
    
    offset_value := (validated_page - 1) * validated_size;
    
    -- Contar total de vagas únicas (aplicando filtros)
    WITH vagas_filtradas AS (
        SELECT DISTINCT v.vagas_id
        FROM vw_vagas_candidaturas v
        WHERE 1=1
            -- Filtro por status
            AND (filtro_status IS NULL OR v.vagas_status = filtro_status)
            -- Filtro por hospital
            AND (filtro_hospital_id IS NULL OR v.hospital_id = filtro_hospital_id)
            -- Filtro por especialidade
            AND (filtro_especialidade_id IS NULL OR v.especialidade_id = filtro_especialidade_id)
            -- Filtro por setor
            AND (filtro_setor_id IS NULL OR v.setor_id = filtro_setor_id)
            -- Filtro por período
            AND (filtro_periodo_id IS NULL OR v.vagas_periodo = filtro_periodo_id)
            -- Filtro por tipo
            AND (filtro_tipo_id IS NULL OR v.vagas_tipo = filtro_tipo_id)
            -- Filtro por grupo
            AND (filtro_grupo_id IS NULL OR v.grupo_id = filtro_grupo_id)
            -- Filtro por data (entre data_inicio e data_fim)
            AND (filtro_data_inicio IS NULL OR v.vagas_data >= filtro_data_inicio)
            AND (filtro_data_fim IS NULL OR v.vagas_data <= filtro_data_fim)
            -- Filtro por valor (entre valor_min e valor_max)
            AND (filtro_valor_min IS NULL OR v.vagas_valor >= filtro_valor_min)
            AND (filtro_valor_max IS NULL OR v.vagas_valor <= filtro_valor_max)
            -- Filtro por texto (busca em hospital, especialidade, observações)
            AND (
                filtro_busca_texto IS NULL OR 
                v.hospital_nome ILIKE '%' || filtro_busca_texto || '%' OR
                v.especialidade_nome ILIKE '%' || filtro_busca_texto || '%' OR
                v.vagas_observacoes ILIKE '%' || filtro_busca_texto || '%' OR
                v.setor_nome ILIKE '%' || filtro_busca_texto || '%'
            )
    )
    SELECT COUNT(*) INTO total_count FROM vagas_filtradas;
    
    -- Retornar vagas agrupadas com suas candidaturas
    RETURN QUERY
    WITH vagas_agrupadas AS (
        SELECT 
            v.vagas_id,
            -- Dados da vaga (pegar qualquer um já que são iguais por vagas_id)
            (array_agg(v.vagas_data))[1] as vagas_data,
            (array_agg(v.vagas_horainicio))[1] as vagas_horainicio,
            (array_agg(v.vagas_horafim))[1] as vagas_horafim,
            (array_agg(v.vagas_valor))[1] as vagas_valor,
            (array_agg(v.vagas_status))[1] as vagas_status,
            (array_agg(v.vagas_observacoes))[1] as vagas_observacoes,
            (array_agg(v.total_candidaturas))[1] as total_candidaturas,
            (array_agg(v.vagas_createdate))[1] as vagas_createdate,
            (array_agg(v.vagas_periodo))[1] as vagas_periodo,
            (array_agg(v.vagas_periodo_nome))[1] as vagas_periodo_nome,
            (array_agg(v.vagas_tipo))[1] as vagas_tipo,
            (array_agg(v.vagas_tipo_nome))[1] as vagas_tipo_nome,
            (array_agg(v.hospital_id))[1] as hospital_id,
            (array_agg(v.hospital_nome))[1] as hospital_nome,
            (array_agg(v.hospital_estado))[1] as hospital_estado,
            (array_agg(v.hospital_lat))[1] as hospital_lat,
            (array_agg(v.hospital_log))[1] as hospital_log,
            (array_agg(v.hospital_end))[1] as hospital_end,
            (array_agg(v.hospital_avatar))[1] as hospital_avatar,
            (array_agg(v.especialidade_id))[1] as especialidade_id,
            (array_agg(v.especialidade_nome))[1] as especialidade_nome,
            (array_agg(v.setor_id))[1] as setor_id,
            (array_agg(v.setor_nome))[1] as setor_nome,
            (array_agg(v.escalista_id))[1] as escalista_id,
            (array_agg(v.escalista_nome))[1] as escalista_nome,
            (array_agg(v.escalista_email))[1] as escalista_email,
            (array_agg(v.escalista_telefone))[1] as escalista_telefone,
            (array_agg(v.grupo_id))[1] as grupo_id,
            (array_agg(v.grupo_nome))[1] as grupo_nome,
            (array_agg(v.grade_id))[1] as grade_id,
            (array_agg(v.grade_nome))[1] as grade_nome,
            (array_agg(v.grade_cor))[1] as grade_cor,
            -- Array com TODAS as candidaturas desta vaga
            array_agg(
                CASE 
                    WHEN v.candidaturas_id IS NOT NULL THEN
                        jsonb_build_object(
                            'candidaturas_id', v.candidaturas_id,
                            'candidatura_status', v.candidatura_status,
                            'candidatos_createdate', v.candidatos_createdate,
                            'vaga_salva', v.vaga_salva,
                            'medico_favorito', v.medico_favorito,
                            'medico_id', v.medico_id,
                            'medico_primeironome', v.medico_primeironome,
                            'medico_sobrenome', v.medico_sobrenome,
                            'medico_crm', v.medico_crm,
                            'medico_estado', v.medico_estado,
                            'medico_email', v.medico_email,
                            'medico_telefone', v.medico_telefone
                        )
                    ELSE NULL
                END
                ORDER BY v.candidatos_createdate DESC
            ) FILTER (WHERE v.candidaturas_id IS NOT NULL) as candidaturas_list
        FROM vw_vagas_candidaturas v
        WHERE 1=1
            -- Aplicar os mesmos filtros da contagem
            AND (filtro_status IS NULL OR v.vagas_status = filtro_status)
            AND (filtro_hospital_id IS NULL OR v.hospital_id = filtro_hospital_id)
            AND (filtro_especialidade_id IS NULL OR v.especialidade_id = filtro_especialidade_id)
            AND (filtro_setor_id IS NULL OR v.setor_id = filtro_setor_id)
            AND (filtro_periodo_id IS NULL OR v.vagas_periodo = filtro_periodo_id)
            AND (filtro_tipo_id IS NULL OR v.vagas_tipo = filtro_tipo_id)
            AND (filtro_grupo_id IS NULL OR v.grupo_id = filtro_grupo_id)
            AND (filtro_data_inicio IS NULL OR v.vagas_data >= filtro_data_inicio)
            AND (filtro_data_fim IS NULL OR v.vagas_data <= filtro_data_fim)
            AND (filtro_valor_min IS NULL OR v.vagas_valor >= filtro_valor_min)
            AND (filtro_valor_max IS NULL OR v.vagas_valor <= filtro_valor_max)
            AND (
                filtro_busca_texto IS NULL OR 
                v.hospital_nome ILIKE '%' || filtro_busca_texto || '%' OR
                v.especialidade_nome ILIKE '%' || filtro_busca_texto || '%' OR
                v.vagas_observacoes ILIKE '%' || filtro_busca_texto || '%' OR
                v.setor_nome ILIKE '%' || filtro_busca_texto || '%'
            )
        GROUP BY v.vagas_id
        ORDER BY (array_agg(v.vagas_createdate))[1] DESC
        LIMIT validated_size
        OFFSET offset_value
    )
    SELECT 
        COALESCE(
            jsonb_agg(
                jsonb_build_object(
                    'vagas_id', v.vagas_id,
                    'vagas_data', v.vagas_data,
                    'vagas_horainicio', v.vagas_horainicio,
                    'vagas_horafim', v.vagas_horafim,
                    'vagas_valor', v.vagas_valor,
                    'vagas_status', v.vagas_status,
                    'vagas_observacoes', v.vagas_observacoes,
                    'total_candidaturas', v.total_candidaturas,
                    'vagas_createdate', v.vagas_createdate,
                    'vagas_periodo', v.vagas_periodo,
                    'vagas_periodo_nome', v.vagas_periodo_nome,
                    'vagas_tipo', v.vagas_tipo,
                    'vagas_tipo_nome', v.vagas_tipo_nome,
                    'hospital', jsonb_build_object(
                        'hospital_id', v.hospital_id,
                        'hospital_nome', v.hospital_nome,
                        'hospital_estado', v.hospital_estado,
                        'hospital_lat', v.hospital_lat,
                        'hospital_log', v.hospital_log,
                        'hospital_end', v.hospital_end,
                        'hospital_avatar', v.hospital_avatar
                    ),
                    'especialidade', jsonb_build_object(
                        'especialidade_id', v.especialidade_id,
                        'especialidade_nome', v.especialidade_nome
                    ),
                    'setor', jsonb_build_object(
                        'setor_id', v.setor_id,
                        'setor_nome', v.setor_nome
                    ),
                    'escalista', jsonb_build_object(
                        'escalista_id', v.escalista_id,
                        'escalista_nome', v.escalista_nome,
                        'escalista_email', v.escalista_email,
                        'escalista_telefone', v.escalista_telefone
                    ),
                    'grupo', jsonb_build_object(
                        'grupo_id', v.grupo_id,
                        'grupo_nome', v.grupo_nome
                    ),
                    'candidaturas', COALESCE(array_to_json(v.candidaturas_list)::jsonb, '[]'::jsonb),
                    'grade', jsonb_build_object(
                        'grade_id', v.grade_id,
                        'grade_nome', v.grade_nome,
                        'grade_cor', v.grade_cor
                    )
                )
                ORDER BY v.vagas_createdate DESC
            ),
            '[]'::jsonb
        ) as data,
        jsonb_build_object(
            'current_page', validated_page,
            'page_size', validated_size,
            'total_count', total_count,
            'total_pages', CASE 
                WHEN total_count = 0 THEN 0
                ELSE CEIL(total_count::numeric / validated_size::numeric)::integer
            END,
            'has_previous', validated_page > 1,
            'has_next', validated_page < CEIL(total_count::numeric / validated_size::numeric)::integer,
            'previous_page', CASE WHEN validated_page > 1 THEN validated_page - 1 ELSE null END,
            'next_page', CASE 
                WHEN validated_page < CEIL(total_count::numeric / validated_size::numeric)::integer 
                THEN validated_page + 1 
                ELSE null 
            END
        ) as pagination
    FROM vagas_agrupadas v;
END;
$$;

-- Índices para otimização da view vw_vagas_candidaturas
CREATE INDEX IF NOT EXISTS idx_vagas_pagination ON vagas(vagas_createdate DESC, vagas_id);
CREATE INDEX IF NOT EXISTS idx_vagas_status_data ON vagas(vagas_status, vagas_data);
CREATE INDEX IF NOT EXISTS idx_vagas_especialidade_status ON vagas(vaga_especialidade, vagas_status);
CREATE INDEX IF NOT EXISTS idx_vagas_hospital_data ON vagas(vagas_hospital, vagas_data);
CREATE INDEX IF NOT EXISTS idx_candidaturas_vaga_medico ON candidaturas(vagas_id, medico_id);
CREATE INDEX IF NOT EXISTS idx_candidaturas_vaga_precadastro ON candidaturas(vagas_id, medico_precadastro_id);

-- Permissões
GRANT EXECUTE ON FUNCTION get_vagas_paginated(integer, integer, text, uuid, uuid, uuid, date, date, numeric, numeric, uuid, uuid, uuid, text) TO authenticated;

-- Comentário
COMMENT ON FUNCTION get_vagas_paginated IS 'Busca vagas agrupadas por vagas_id com filtros opcionais (status, hospital, especialidade, setor, data, valor, período, tipo, grupo, texto). Todas as candidaturas são compactadas em array por vaga, resultando em menos páginas totais';
