-- Criar tabela grades para o sistema de plantões
-- Execute este SQL no Supabase Dashboard > SQL Editor
-- Projeto: hxgbaruenomkfeeafmff

-- 1. CRIAR TABELA GRADES COM FOREIGN KEYS
CREATE TABLE IF NOT EXISTS grades (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  grupo_id UUID NOT NULL,
  nome VARCHAR(255) NOT NULL,
  especialidade_id UUID REFERENCES especialidades(especialidade_id) ON DELETE RESTRICT,
  setor_id UUID REFERENCES setores(setor_id) ON DELETE RESTRICT,
  hospital_id UUID REFERENCES hospital(hospital_id) ON DELETE RESTRICT,
  cor VARCHAR(7) NOT NULL,
  horario_inicial INTEGER DEFAULT 7,
  configuracao JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  created_by UUID REFERENCES auth.users(id),
  updated_by UUID REFERENCES auth.users(id)
);

-- 2. ADICIONAR COMENTÁRIO À COLUNA CONFIGURACAO
COMMENT ON COLUMN grades.configuracao IS 
'Estrutura JSON: {
  "slots": [{"id": "...", "startHour": 7, "endHour": 19, "vagasCount": 2, "lineIndex": 0}],
  "lineNames": {"0": "Nome da Semana 1"},
  "selectedDays": {"0": [true, true, true, true, true, false, false]},
  "slotsByDay": {"0": {"0": [{"id": "...", "startHour": 7, "endHour": 19, "vagasCount": 2}]}},
  "subLinesByDay": {"0": {"0": [...]}},
  "weekStartHours": {"0": 7}
}';

-- 3. CRIAR ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_grades_grupo_id ON grades(grupo_id);
CREATE INDEX IF NOT EXISTS idx_grades_especialidade_id ON grades(especialidade_id);
CREATE INDEX IF NOT EXISTS idx_grades_setor_id ON grades(setor_id);
CREATE INDEX IF NOT EXISTS idx_grades_hospital_id ON grades(hospital_id);
CREATE INDEX IF NOT EXISTS idx_grades_created_by ON grades(created_by);
CREATE INDEX IF NOT EXISTS idx_grades_configuracao ON grades USING GIN (configuracao);

-- 4. HABILITAR ROW LEVEL SECURITY
ALTER TABLE grades ENABLE ROW LEVEL SECURITY;

-- 5. CRIAR POLÍTICAS RLS PARA ASTRONAUTAS

-- Política SELECT
CREATE POLICY "astronauts_can_select_grades" ON grades
  FOR SELECT 
  USING (
    EXISTS (
      SELECT 1 FROM user_profile 
      WHERE user_profile.id = auth.uid() 
      AND user_profile.role = 'astronauta'
    )
  );

-- Política INSERT
CREATE POLICY "astronauts_can_insert_grades" ON grades
  FOR INSERT 
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_profile 
      WHERE user_profile.id = auth.uid() 
      AND user_profile.role = 'astronauta'
    )
    AND auth.uid() = created_by
  );

-- Política UPDATE
CREATE POLICY "astronauts_can_update_grades" ON grades
  FOR UPDATE 
  USING (
    EXISTS (
      SELECT 1 FROM user_profile 
      WHERE user_profile.id = auth.uid() 
      AND user_profile.role = 'astronauta'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_profile 
      WHERE user_profile.id = auth.uid() 
      AND user_profile.role = 'astronauta'
    )
  );

-- Política DELETE
CREATE POLICY "astronauts_can_delete_grades" ON grades
  FOR DELETE 
  USING (
    EXISTS (
      SELECT 1 FROM user_profile 
      WHERE user_profile.id = auth.uid() 
      AND user_profile.role = 'astronauta'
    )
  );

-- 6. CRIAR FUNÇÃO PARA ATUALIZAR updated_at E updated_by AUTOMATICAMENTE
CREATE OR REPLACE FUNCTION handle_grades_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc'::text, NOW());
  NEW.updated_by = auth.uid();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. CRIAR TRIGGER PARA EXECUTAR A FUNÇÃO
CREATE TRIGGER trigger_grades_updated_at
  BEFORE UPDATE ON grades
  FOR EACH ROW
  EXECUTE FUNCTION handle_grades_updated_at();

-- 8. VERIFICAR SE TUDO FOI CRIADO CORRETAMENTE
SELECT 
  'Tabela grades criada!' as status,
  COUNT(*) as total_colunas
FROM information_schema.columns 
WHERE table_name = 'grades' 
  AND table_schema = 'public';

-- 9. VERIFICAR FOREIGN KEYS
SELECT 
  tc.constraint_name,
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
  AND tc.table_name = 'grades';;
