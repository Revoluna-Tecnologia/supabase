-- Criar função que bypassa RLS para contar candidaturas
CREATE OR REPLACE FUNCTION count_candidaturas_total(vaga_id_param UUID)
RETURNS INTEGER
LANGUAGE SQL
SECURITY DEFINER  -- Executa com privilégios do proprietário da função
STABLE
AS $$
  SELECT COUNT(*)::INTEGER 
  FROM candidaturas 
  WHERE vagas_id = vaga_id_param;
$$;

-- Comentário explicativo
COMMENT ON FUNCTION count_candidaturas_total(UUID) IS 'Conta o total de candidaturas de uma vaga, ignorando políticas RLS para dar visibilidade completa aos usuários';

-- Dar permissão para usuários autenticados usarem a função
GRANT EXECUTE ON FUNCTION count_candidaturas_total(UUID) TO authenticated;;
