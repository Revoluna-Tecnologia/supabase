# Edge Function: julia-sync

Spec completo da Edge Function que a Julia chama para sincronizar vagas.

## Visao geral

- **Nome**: `julia-sync`
- **URL**: `https://<app-ref>.supabase.co/functions/v1/julia-sync`
- **Metodo**: POST
- **Auth**: Header `Authorization: Bearer <JULIA_SYNC_API_KEY>`
- **Body**: `{ "operation": "...", "data": { ... } }`
- **Response**: JSON, sempre com status 200 para sucesso

## Autenticacao

A Edge Function valida o header `Authorization` contra o secret `JULIA_SYNC_API_KEY`.
Se invalido, retorna 401.

## Operacoes

### 1. `get_lookups`

Retorna lookups do app + mapeamentos existentes com a Julia.

**Request:**
```json
{ "operation": "get_lookups", "data": {} }
```

**Response:**
```json
{
  "especialidades": [{ "id": "uuid", "nome": "Cardiologia" }, ...],
  "periodos": [{ "id": "uuid", "nome": "Diurno" }, ...],
  "setores": [{ "id": "uuid", "nome": "UTI" }, ...],
  "maps": {
    "especialidades": [{ "julia_id": "uuid", "app_id": "uuid" }, ...],
    "periodos": [{ "julia_id": "uuid", "app_id": "uuid" }, ...],
    "setores": [{ "julia_id": "uuid", "app_id": "uuid" }, ...]
  }
}
```

**SQL interno:**
```sql
SELECT id, nome FROM especialidades;
SELECT id, nome FROM periodos;
SELECT id, nome FROM setores;
SELECT julia_id, app_id FROM sync_especialidades_map;
SELECT julia_id, app_id FROM sync_periodos_map;
SELECT julia_id, app_id FROM sync_setores_map;
```

---

### 2. `register_lookup_map`

Registra mapeamento de lookup (Julia ID -> App ID).

**Request:**
```json
{
  "operation": "register_lookup_map",
  "data": {
    "tabela": "especialidades",
    "julia_id": "uuid",
    "app_id": "uuid",
    "nome": "Cardiologia"
  }
}
```

**Response:** `{ "ok": true }`

**SQL interno:**
```sql
-- tabela = "especialidades" -> sync_especialidades_map
-- tabela = "periodos" -> sync_periodos_map
-- tabela = "setores" -> sync_setores_map
INSERT INTO sync_{tabela}_map (julia_id, app_id, nome)
VALUES ($1, $2, $3)
ON CONFLICT (julia_id) DO UPDATE SET app_id = $2, nome = $3;
```

**Validacao:** `tabela` deve ser um de: `especialidades`, `periodos`, `setores`.

---

### 3. `get_hospitais`

Retorna hospitais para matching local na Julia.

**Request:**
```json
{ "operation": "get_hospitais", "data": {} }
```

**Response:**
```json
{
  "hospitais": [
    { "id": "uuid", "nome": "Hospital São Luiz", "latitude": -23.55, "longitude": -46.63 },
    ...
  ]
}
```

**SQL interno:**
```sql
SELECT id, nome, latitude, longitude FROM hospitais;
```

---

### 4. `create_hospital`

Cria hospital novo no app.

**Request:**
```json
{
  "operation": "create_hospital",
  "data": {
    "nome": "Hospital São Luiz",
    "logradouro": "Rua ...",
    "numero": "123",
    "cidade": "São Paulo",
    "bairro": "Itaim Bibi",
    "estado": "SP",
    "pais": "Brasil",
    "cep": "04543-000",
    "latitude": -23.55,
    "longitude": -46.63,
    "endereco_formatado": "Rua ..., 123 - Itaim Bibi, São Paulo - SP",
    "avatar": "https://..."
  }
}
```

**Response:** `{ "id": "uuid-do-hospital-criado" }`

**SQL interno:**
```sql
INSERT INTO hospitais (nome, logradouro, numero, cidade, bairro, estado, pais, cep, latitude, longitude, endereco_formatado, avatar)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
RETURNING id;
```

---

### 5. `find_escalista`

Busca escalista externo por telefone.

**Request:**
```json
{
  "operation": "find_escalista",
  "data": { "telefone": "5511999999999" }
}
```

**Response (encontrado):** `{ "id": "uuid" }`
**Response (nao encontrado):** `{ "id": null }`

**SQL interno:**
```sql
SELECT id FROM escalistas_externos WHERE telefone = $1 LIMIT 1;
```

---

### 6. `create_escalista`

Cria escalista externo.

**Request:**
```json
{
  "operation": "create_escalista",
  "data": {
    "nome": "Dr. Carlos",
    "telefone": "5511999999999",
    "grupo_id": "a0000000-0000-0000-0000-000000000001"
  }
}
```

**Response:** `{ "id": "uuid-do-escalista-criado" }`

**SQL interno:**
```sql
INSERT INTO escalistas_externos (nome, telefone, grupo_id)
VALUES ($1, $2, $3)
RETURNING id;
```

---

### 7. `upsert_vaga`

Insere uma vaga nova.

**Request:**
```json
{
  "operation": "upsert_vaga",
  "data": {
    "hospital_id": "uuid",
    "especialidade_id": "uuid",
    "periodo_id": "uuid",
    "setor_id": "uuid",
    "escalista_externo_id": "uuid",
    "data": "2026-03-15",
    "hora_inicio": "07:00:00",
    "hora_fim": "19:00:00",
    "status": "aberta",
    "observacoes": "Plantão 12h",
    "valor": 0,
    "data_pagamento": "2099-12-31",
    "tipos_vaga_id": "418cf451-ec43-415c-87bc-5685dc290842",
    "escalista_id": null,
    "grupo_id": "a0000000-0000-0000-0000-000000000001",
    "updated_by": "c0000000-0000-0000-0000-000000000001",
    "index": 0,
    "forma_recebimento_id": null,
    "grade_id": null,
    "recorrencia_id": null
  }
}
```

**Response:** `{ "id": "uuid-da-vaga-criada" }`

**SQL interno:**
```sql
INSERT INTO vagas (hospital_id, especialidade_id, periodo_id, setor_id, escalista_externo_id,
  data, hora_inicio, hora_fim, status, observacoes, valor, data_pagamento, tipos_vaga_id,
  escalista_id, grupo_id, updated_by, index, forma_recebimento_id, grade_id, recorrencia_id)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20)
RETURNING id;
```

---

### 8. `update_vaga`

Atualiza vaga existente.

**Request:**
```json
{
  "operation": "update_vaga",
  "data": {
    "id": "uuid-da-vaga",
    "hospital_id": "uuid",
    "especialidade_id": "uuid",
    "...": "mesmos campos do upsert_vaga"
  }
}
```

**Response:** `{ "ok": true }`

**SQL interno:**
```sql
UPDATE vagas SET hospital_id=$2, especialidade_id=$3, ... WHERE id = $1;
```

---

### 9. `close_vaga`

Fecha uma vaga (muda status para 'fechada').

**Request:**
```json
{
  "operation": "close_vaga",
  "data": { "id": "uuid-da-vaga" }
}
```

**Response:** `{ "ok": true }`

**SQL interno:**
```sql
UPDATE vagas SET status = 'fechada' WHERE id = $1;
```

---

### 10. `get_sync_state`

Retorna estado atual do sync.

**Request:**
```json
{ "operation": "get_sync_state", "data": {} }
```

**Response:**
```json
{
  "syncs": [
    { "julia_vaga_id": "uuid", "app_vaga_id": "uuid", "source_hash": "md5..." },
    ...
  ]
}
```

**SQL interno:**
```sql
SELECT julia_vaga_id, app_vaga_id, source_hash FROM vagas_sync_julia;
```

---

### 11. `register_sync`

Registra/atualiza mapeamento de sync.

**Request:**
```json
{
  "operation": "register_sync",
  "data": {
    "julia_vaga_id": "uuid",
    "app_vaga_id": "uuid",
    "app_hospital_id": "uuid",
    "app_escalista_ext_id": "uuid",
    "source_hash": "md5..."
  }
}
```

**Response:** `{ "ok": true }`

**SQL interno:**
```sql
INSERT INTO vagas_sync_julia (julia_vaga_id, app_vaga_id, app_hospital_id, app_escalista_ext_id, source_hash, updated_at)
VALUES ($1, $2, $3, $4, $5, NOW())
ON CONFLICT (julia_vaga_id)
DO UPDATE SET app_vaga_id=$2, app_hospital_id=$3, app_escalista_ext_id=$4, source_hash=$5, updated_at=NOW();
```

---

## Codigo de referencia (TypeScript/Deno)

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SYNC_API_KEY = Deno.env.get("JULIA_SYNC_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

const VALID_MAP_TABLES = ["especialidades", "periodos", "setores"] as const;

serve(async (req) => {
  // Auth
  const authHeader = req.headers.get("Authorization");
  if (authHeader !== `Bearer ${SYNC_API_KEY}`) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401 });
  }

  const { operation, data } = await req.json();

  try {
    switch (operation) {
      case "get_lookups": {
        const [esp, per, set, mapEsp, mapPer, mapSet] = await Promise.all([
          supabase.from("especialidades").select("id, nome"),
          supabase.from("periodos").select("id, nome"),
          supabase.from("setores").select("id, nome"),
          supabase.from("sync_especialidades_map").select("julia_id, app_id"),
          supabase.from("sync_periodos_map").select("julia_id, app_id"),
          supabase.from("sync_setores_map").select("julia_id, app_id"),
        ]);
        return json({
          especialidades: esp.data ?? [],
          periodos: per.data ?? [],
          setores: set.data ?? [],
          maps: {
            especialidades: mapEsp.data ?? [],
            periodos: mapPer.data ?? [],
            setores: mapSet.data ?? [],
          },
        });
      }

      case "register_lookup_map": {
        const { tabela, julia_id, app_id, nome } = data;
        if (!VALID_MAP_TABLES.includes(tabela)) {
          return json({ error: "tabela invalida" }, 400);
        }
        await supabase
          .from(`sync_${tabela}_map`)
          .upsert({ julia_id, app_id, nome }, { onConflict: "julia_id" });
        return json({ ok: true });
      }

      case "get_hospitais": {
        const { data: hospitais } = await supabase
          .from("hospitais")
          .select("id, nome, latitude, longitude");
        return json({ hospitais: hospitais ?? [] });
      }

      case "create_hospital": {
        const { data: created, error } = await supabase
          .from("hospitais")
          .insert(data)
          .select("id")
          .single();
        if (error) return json({ error: error.message }, 500);
        return json({ id: created.id });
      }

      case "find_escalista": {
        const { data: found } = await supabase
          .from("escalistas_externos")
          .select("id")
          .eq("telefone", data.telefone)
          .limit(1)
          .maybeSingle();
        return json({ id: found?.id ?? null });
      }

      case "create_escalista": {
        const { data: created, error } = await supabase
          .from("escalistas_externos")
          .insert({ nome: data.nome, telefone: data.telefone, grupo_id: data.grupo_id })
          .select("id")
          .single();
        if (error) return json({ error: error.message }, 500);
        return json({ id: created.id });
      }

      case "upsert_vaga": {
        const { data: created, error } = await supabase
          .from("vagas")
          .insert(data)
          .select("id")
          .single();
        if (error) return json({ error: error.message }, 500);
        return json({ id: created.id });
      }

      case "update_vaga": {
        const { id, ...fields } = data;
        const { error } = await supabase
          .from("vagas")
          .update(fields)
          .eq("id", id);
        if (error) return json({ error: error.message }, 500);
        return json({ ok: true });
      }

      case "close_vaga": {
        const { error } = await supabase
          .from("vagas")
          .update({ status: "fechada" })
          .eq("id", data.id);
        if (error) return json({ error: error.message }, 500);
        return json({ ok: true });
      }

      case "get_sync_state": {
        const { data: syncs } = await supabase
          .from("vagas_sync_julia")
          .select("julia_vaga_id, app_vaga_id, source_hash");
        return json({ syncs: syncs ?? [] });
      }

      case "register_sync": {
        const { error } = await supabase
          .from("vagas_sync_julia")
          .upsert(
            { ...data, updated_at: new Date().toISOString() },
            { onConflict: "julia_vaga_id" }
          );
        if (error) return json({ error: error.message }, 500);
        return json({ ok: true });
      }

      default:
        return json({ error: `Operacao desconhecida: ${operation}` }, 400);
    }
  } catch (err) {
    return json({ error: String(err) }, 500);
  }
});

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
```

## Deploy

```bash
# 1. Criar a funcao (se ainda nao existe)
supabase functions new julia-sync

# 2. Copiar o codigo acima para supabase/functions/julia-sync/index.ts

# 3. Configurar o secret
supabase secrets set JULIA_SYNC_API_KEY="$(openssl rand -hex 32)"

# 4. Deploy
supabase functions deploy julia-sync --no-verify-jwt

# O flag --no-verify-jwt e necessario porque a auth e via API key,
# nao via JWT do Supabase Auth.
```

## Teste manual

```bash
# Testar get_lookups
curl -X POST https://<ref>.supabase.co/functions/v1/julia-sync \
  -H "Authorization: Bearer <API_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"operation": "get_lookups", "data": {}}'
```
