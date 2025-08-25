-- Habilitar RLS na tabela medicos_favoritos
ALTER TABLE medicos_favoritos ENABLE ROW LEVEL SECURITY;

-- Criar política que permite acesso completo apenas às linhas do próprio escalista
CREATE POLICY "escalistas_can_manage_own_favorites" ON medicos_favoritos
    FOR ALL
    USING (
        escalista_id IN (
            SELECT escalista_id 
            FROM escalista 
            WHERE escalista_auth_id = auth.uid()
        )
    )
    WITH CHECK (
        escalista_id IN (
            SELECT escalista_id 
            FROM escalista 
            WHERE escalista_auth_id = auth.uid()
        )
    );

-- Comentário explicativo
COMMENT ON POLICY "escalistas_can_manage_own_favorites" ON medicos_favoritos IS 
'Permite que escalistas tenham acesso completo (SELECT, INSERT, UPDATE, DELETE) apenas aos seus próprios favoritos, identificados pelo escalista_id correspondente ao auth.uid() na tabela escalista';;
