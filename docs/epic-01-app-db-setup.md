# EPICO 01: Preparacao do Banco do App

**Responsavel:** Dev App
**Estimativa:** 1h
**Risco:** P1 (medio-alto) — se os SQLs falharem, bloqueia toda a sprint

## Contexto

O banco do app precisa de novas tabelas e registros de fallback antes do worker da Julia comecar a sincronizar. Tambem precisa de um ajuste na view principal e uma nova coluna na tabela vagas.

## Escopo

- **Incluido**: Criar tabelas, registros fallback, alterar view, alterar tabela vagas
- **Excluido**: Codigo Python, FlutterFlow, qualquer logica de sync

---

## Tarefa 1: Criar registros de fallback

### Objetivo
Criar grupo "Vagas Externas (Julia)" e setor "Nao informado" que servem como defaults para vagas externas.

### SQL

```sql
-- Grupo fallback
INSERT INTO grupos (id, nome, responsavel, telefone, email, created_at, updated_at)
VALUES (
  'a0000000-0000-0000-0000-000000000001',
  'Vagas Externas (Julia)',
  'Julia - Revoluna',
  NULL, NULL, NOW(), NOW()
)
ON CONFLICT (id) DO NOTHING;

-- Setor fallback
INSERT INTO setores (id, nome, created_at, updated_at)
VALUES (
  'a0000000-0000-0000-0000-000000000002',
  'Nao informado',
  NOW(), NOW()
)
ON CONFLICT (id) DO NOTHING;
```

### Definition of Done
- [ ] Grupo "Vagas Externas (Julia)" existe na tabela grupos
- [ ] Setor "Nao informado" existe na tabela setores

---

## Tarefa 2: Criar tabela escalistas_externos

### Objetivo
Tabela separada de escalistas para contatos extraidos dos grupos WhatsApp. Necessaria porque `escalistas.id` tem FK com `auth.users` e escalistas externos nao tem login.

### SQL

```sql
CREATE TABLE IF NOT EXISTS escalistas_externos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nome VARCHAR NOT NULL DEFAULT 'Contato da vaga',
  telefone VARCHAR,
  grupo_id UUID REFERENCES grupos(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_escalistas_externos_telefone
  ON escalistas_externos(telefone);

-- Fallback generico
INSERT INTO escalistas_externos (id, nome, telefone, grupo_id)
VALUES (
  'b0000000-0000-0000-0000-000000000001',
  'Contato da vaga',
  '',
  'a0000000-0000-0000-0000-000000000001'
)
ON CONFLICT (id) DO NOTHING;
```

### Definition of Done
- [ ] Tabela `escalistas_externos` existe
- [ ] Indice no campo telefone existe
- [ ] Registro fallback com id `b0000000-...0001` existe

---

## Tarefa 3: Criar tabelas de controle de sync

### Objetivo
Tabelas usadas pelo worker para rastrear o que ja foi sincronizado e mapear IDs entre os dois bancos.

### SQL

```sql
CREATE TABLE IF NOT EXISTS vagas_sync_julia (
  julia_vaga_id UUID PRIMARY KEY,
  app_vaga_id UUID NOT NULL REFERENCES vagas(id) ON DELETE CASCADE,
  app_hospital_id UUID REFERENCES hospitais(id),
  app_escalista_ext_id UUID REFERENCES escalistas_externos(id),
  source_hash TEXT,
  synced_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(app_vaga_id)
);

CREATE INDEX IF NOT EXISTS idx_sync_julia_updated ON vagas_sync_julia(updated_at);

CREATE TABLE IF NOT EXISTS sync_especialidades_map (
  julia_id UUID PRIMARY KEY,
  app_id UUID NOT NULL,
  nome TEXT NOT NULL,
  mapped_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS sync_periodos_map (
  julia_id UUID PRIMARY KEY,
  app_id UUID NOT NULL,
  nome TEXT NOT NULL,
  mapped_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS sync_setores_map (
  julia_id UUID PRIMARY KEY,
  app_id UUID NOT NULL,
  nome TEXT NOT NULL,
  mapped_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Definition of Done
- [ ] Tabela `vagas_sync_julia` existe com FK correta
- [ ] Tabelas `sync_*_map` existem
- [ ] Indices criados

---

## Tarefa 4: Adicionar coluna escalista_externo_id e atualizar view

### Objetivo
Permitir que vagas referenciem escalistas externos. Atualizar a view para buscar nessa tabela.

### SQL

```sql
-- Nova coluna (nullable, sem impacto em vagas existentes)
ALTER TABLE vagas ADD COLUMN IF NOT EXISTS escalista_externo_id UUID REFERENCES escalistas_externos(id);

-- Tornar escalista_id nullable (vagas externas nao tem escalista auth)
ALTER TABLE vagas ALTER COLUMN escalista_id DROP NOT NULL;
```

Depois, recriar a view (SQL completo em `planning/sync-vagas-app/briefing-dev-app.md`, Tarefa 2).

Mudancas na view (apenas 3 linhas):
1. Novo JOIN: `LEFT JOIN escalistas_externos eext ON v.escalista_externo_id = eext.id`
2. `COALESCE(esc.nome, eext.nome) AS escalista_nome`
3. `COALESCE(esc.telefone, eext.telefone) AS escalista_telefone`

### Testes Obrigatorios

- [ ] View retorna vagas existentes normalmente (regressao)
- [ ] Inserir vaga com `escalista_id = NULL` e `escalista_externo_id` preenchido funciona
- [ ] View retorna nome/telefone do escalista externo para vagas novas

### Definition of Done
- [ ] Coluna `escalista_externo_id` existe em vagas
- [ ] `escalista_id` aceita NULL
- [ ] View recriada sem erros
- [ ] Vagas existentes continuam aparecendo normalmente no app

---

## Tarefa 5: Fornecer credenciais

### Objetivo
Enviar service_role key + URL do Supabase do app para configurar o worker.

### Definition of Done
- [ ] URL do projeto Supabase enviada
- [ ] Service Role Key enviada (de forma segura, nao por chat)
