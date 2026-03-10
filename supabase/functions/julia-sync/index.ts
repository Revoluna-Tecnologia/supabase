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
        const { error } = await supabase
          .from("vagas")
          .update({ status: "fechada" })
          .eq("id", id);
        if (error) return json({ error: error.message }, 500);
        return json({ ok: true });
      }

      // ============================================
      // 10. get_sync_state - Retorna estado do sync
      // ============================================
      case "get_sync_state": {
        const { data: syncs } = await supabase
          .from("vagas_sync_julia")
          .select("julia_vaga_id, app_vaga_id, source_hash");
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
