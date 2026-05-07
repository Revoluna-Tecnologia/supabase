import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.8";

const SYNC_API_KEY = Deno.env.get("JULIA_SYNC_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

const VALID_MAP_TABLES = ["especialidades", "periodos", "setores"] as const;
type MapTable = (typeof VALID_MAP_TABLES)[number];

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  // Auth via API key
  const authHeader = req.headers.get("Authorization");
  if (authHeader !== `Bearer ${SYNC_API_KEY}`) {
    console.error("❌ Unauthorized request");
    return json({ error: "Unauthorized" }, 401);
  }

  let operation: string;
  let data: Record<string, unknown>;

  try {
    const body = await req.json();
    operation = body.operation;
    data = body.data ?? {};
  } catch {
    return json({ error: "Invalid JSON body" }, 400);
  }

  console.log(`📥 Operation: ${operation}`);

  try {
    switch (operation) {
      // ============================================
      // 1. get_lookups - Retorna lookups + mapeamentos
      // ============================================
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

      // ============================================
      // 2. register_lookup_map - Registra mapeamento
      // ============================================
      case "register_lookup_map": {
        const { tabela, julia_id, app_id, nome } = data as {
          tabela: string;
          julia_id: string;
          app_id: string;
          nome: string;
        };
        if (!VALID_MAP_TABLES.includes(tabela as MapTable)) {
          return json({ error: "tabela invalida" }, 400);
        }
        const { error } = await supabase
          .from(`sync_${tabela}_map`)
          .upsert({ julia_id, app_id, nome }, { onConflict: "julia_id" });
        if (error) return json({ error: error.message }, 500);
        return json({ ok: true });
      }

      // ============================================
      // 3. get_hospitais - Retorna hospitais para matching
      // ============================================
      case "get_hospitais": {
        const { data: hospitais } = await supabase
          .from("hospitais")
          .select("id, nome, latitude, longitude");
        return json({ hospitais: hospitais ?? [] });
      }

      // ============================================
      // 4. create_hospital - Cria hospital novo
      // ============================================
      case "create_hospital": {
        const { data: created, error } = await supabase
          .from("hospitais")
          .insert(data)
          .select("id")
          .single();
        if (error) return json({ error: error.message }, 500);
        return json({ id: created.id });
      }

      // ============================================
      // 5. find_escalista - Busca por telefone
      // ============================================
      case "find_escalista": {
        const { telefone } = data as { telefone: string };
        const { data: found } = await supabase
          .from("escalistas_externos")
          .select("id")
          .eq("telefone", telefone)
          .limit(1)
          .maybeSingle();
        return json({ id: found?.id ?? null });
      }

      // ============================================
      // 5b. find_escalistas_bulk - Busca multiplos telefones
      // ============================================
      case "find_escalistas_bulk": {
        const { telefones = [] } = data as { telefones?: string[] };
        if (!Array.isArray(telefones)) {
          return json({ error: "find_escalistas_bulk: 'telefones' must be an array" }, 400);
        }
        if (telefones.length === 0) return json({ found: {} });
        if (telefones.length > 1000) {
          return json(
            { error: `find_escalistas_bulk: max 1000 telefones, got ${telefones.length}` },
            400
          );
        }

        const { data: rows, error } = await supabase
          .from("escalistas_externos")
          .select("id, telefone")
          .in("telefone", telefones);
        if (error) return json({ error: error.message }, 500);

        const found: Record<string, string> = {};
        for (const row of rows ?? []) {
          if (row.telefone) found[row.telefone] = row.id;
        }
        return json({ found });
      }

      // ============================================
      // 6. create_escalista - Cria escalista externo
      // ============================================
      case "create_escalista": {
        const { nome, telefone, grupo_id } = data as {
          nome: string;
          telefone: string;
          grupo_id: string;
        };
        const { data: created, error } = await supabase
          .from("escalistas_externos")
          .insert({ nome, telefone, grupo_id })
          .select("id")
          .single();
        if (error) return json({ error: error.message }, 500);
        return json({ id: created.id });
      }

      // ============================================
      // 7. upsert_vaga - Insere vaga nova
      // ============================================
      case "upsert_vaga": {
        const { data: created, error } = await supabase
          .from("vagas")
          .insert(data)
          .select("id")
          .single();
        if (error) return json({ error: error.message }, 500);
        return json({ id: created.id });
      }

      // ============================================
      // 8. update_vaga - Atualiza vaga existente
      // ============================================
      case "update_vaga": {
        const { id, ...fields } = data as { id: string; [key: string]: unknown };
        const { error } = await supabase
          .from("vagas")
          .update(fields)
          .eq("id", id);
        if (error) return json({ error: error.message }, 500);
        return json({ ok: true });
      }

      // ============================================
      // 9. close_vaga - Fecha vaga
      // ============================================
      case "close_vaga": {
        const { id } = data as { id: string };
        if (!id) return json({ error: "close_vaga: missing 'id'" }, 400);

        const { data: existing, error: selectError } = await supabase
          .from("vagas")
          .select("id, status")
          .eq("id", id)
          .single();
        if (selectError) return json({ error: selectError.message }, 500);

        const alreadyClosed = existing.status === "fechada";
        if (!alreadyClosed) {
          const { error: updateError } = await supabase
            .from("vagas")
            .update({ status: "fechada", updated_at: new Date().toISOString() })
            .eq("id", id);
          if (updateError) return json({ error: updateError.message }, 500);
        }

        const { error: syncError } = await supabase
          .from("vagas_sync_julia")
          .update({ closed_at: new Date().toISOString() })
          .eq("app_vaga_id", id)
          .is("closed_at", null);
        if (syncError) return json({ error: syncError.message }, 500);

        return json({ ok: true, already_closed: alreadyClosed });
      }

      // ============================================
      // 9b. close_vagas_bulk - Fecha vagas em lote
      // ============================================
      case "close_vagas_bulk": {
        const { ids = [] } = data as { ids?: string[] };
        if (!Array.isArray(ids)) {
          return json({ error: "close_vagas_bulk: 'ids' must be an array" }, 400);
        }
        if (ids.length === 0) {
          return json({ ok: true, closed: 0, already_closed: 0, failed: [] });
        }
        if (ids.length > 500) {
          return json({ error: `close_vagas_bulk: max 500 ids per call, got ${ids.length}` }, 400);
        }

        const uniqueIds = [...new Set(ids)];
        const { data: existingRows, error: selectError } = await supabase
          .from("vagas")
          .select("id, status")
          .in("id", uniqueIds);
        if (selectError) {
          return json({ ok: false, closed: 0, already_closed: 0, failed: ids }, 500);
        }

        const existingById = new Map((existingRows ?? []).map((row) => [row.id, row.status]));
        const failed = uniqueIds.filter((id) => !existingById.has(id));
        const idsToClose = uniqueIds.filter((id) => existingById.get(id) !== "fechada");
        const alreadyClosed = uniqueIds.filter((id) => existingById.get(id) === "fechada").length;

        let closedNow = 0;
        if (idsToClose.length > 0) {
          const { data: updatedRows, error: updateError } = await supabase
            .from("vagas")
            .update({ status: "fechada", updated_at: new Date().toISOString() })
            .in("id", idsToClose)
            .neq("status", "fechada")
            .select("id");
          if (updateError) {
            return json({ ok: false, closed: 0, already_closed: alreadyClosed, failed: ids }, 500);
          }
          closedNow = updatedRows?.length ?? 0;
        }

        const existingIds = uniqueIds.filter((id) => existingById.has(id));
        if (existingIds.length > 0) {
          const { error: syncError } = await supabase
            .from("vagas_sync_julia")
            .update({ closed_at: new Date().toISOString() })
            .in("app_vaga_id", existingIds)
            .is("closed_at", null);
          if (syncError) {
            return json({ ok: false, closed: closedNow, already_closed: alreadyClosed, failed: ids }, 500);
          }
        }

        return json({
          ok: failed.length === 0,
          closed: closedNow,
          already_closed: alreadyClosed,
          failed,
        });
      }

      // ============================================
      // 10. get_sync_state - Retorna estado do sync
      // ============================================
      case "get_sync_state": {
        const { include_closed = false } = data as { include_closed?: boolean };
        let query = supabase
          .from("vagas_sync_julia")
          .select("julia_vaga_id, app_vaga_id, source_hash");
        if (!include_closed) query = query.is("closed_at", null);

        const { data: syncs, error } = await query;
        if (error) return json({ error: error.message }, 500);
        return json({ syncs: syncs ?? [] });
      }

      // ============================================
      // 11. register_sync - Registra mapeamento de sync
      // ============================================
      case "register_sync": {
        const { julia_vaga_id, app_vaga_id, app_hospital_id, app_escalista_ext_id, source_hash } =
          data as {
            julia_vaga_id: string;
            app_vaga_id: string;
            app_hospital_id?: string;
            app_escalista_ext_id?: string;
            source_hash?: string;
          };
        const { error } = await supabase.from("vagas_sync_julia").upsert(
          {
            julia_vaga_id,
            app_vaga_id,
            app_hospital_id,
            app_escalista_ext_id,
            source_hash,
            updated_at: new Date().toISOString(),
          },
          { onConflict: "julia_vaga_id" }
        );
        if (error) return json({ error: error.message }, 500);
        return json({ ok: true });
      }

      // ============================================
      // Default - Operacao desconhecida
      // ============================================
      default:
        return json({ error: `Operacao desconhecida: ${operation}` }, 400);
    }
  } catch (err) {
    console.error("❌ Error:", err);
    return json({ error: String(err) }, 500);
  }
});
