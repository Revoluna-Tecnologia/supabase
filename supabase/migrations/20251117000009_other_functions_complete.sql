-- =====================================================================================
-- Migration: 20251117000009_other_functions_complete.sql
-- Description: Other utility functions - count_candidaturas_total
-- =====================================================================================

-- Drop and recreate count_candidaturas_total function with corrected column name
DROP FUNCTION IF EXISTS public.count_candidaturas_total(uuid);

CREATE OR REPLACE FUNCTION public.count_candidaturas_total(vaga_id_param uuid)
 RETURNS integer
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
  SELECT COUNT(*)::INTEGER
  FROM candidaturas
  WHERE vaga_id = vaga_id_param;
$function$;

-- =====================================================================================
-- Candidaturas Policies
-- =====================================================================================

-- funciona
-- SELECT candidaturas
DROP POLICY IF EXISTS "candidaturas_select_policy" ON "public"."candidaturas";

CREATE POLICY "candidaturas_select_policy" 
ON "public"."candidaturas" 
FOR SELECT TO "authenticated" 
USING (
    CASE 
        -- Se o usuário existe em user_profile (usuários do app)
        WHEN EXISTS (
            SELECT 1 FROM "public"."user_profile" 
            WHERE "user_profile"."id" = "auth"."uid"()
        ) THEN (
            -- Condição 1: Se tem grupo, vaga deve pertencer ao mesmo grupo
            -- Se não tem grupo (NULL), pula esta condição
            ("public"."get_current_user_grupo_id"() IS NOT NULL AND EXISTS ( 
                SELECT 1
                FROM "public"."vagas" "v"
                WHERE (("v"."id" = "candidaturas"."vaga_id") AND ("v"."grupo_id" = "public"."get_current_user_grupo_id"()))
            )) 
            OR 
            -- Condição 2: Médico free vendo suas próprias candidaturas
            ((EXISTS ( 
                SELECT 1
                FROM ("public"."user_profile" "up"
                    JOIN "public"."medicos" "m" ON (("m"."id" = "up"."id")))
                WHERE (("up"."id" = "auth"."uid"()) AND ("up"."role" = 'free'::"text"))
            )) AND ("medico_id" = "auth"."uid"())) 
            OR 
            -- Condição 3: Médico precadastro vendo suas próprias candidaturas
            ((EXISTS ( 
                SELECT 1
                FROM ("public"."user_profile" "up"
                    JOIN "public"."medicos_precadastro" "mp" ON (("mp"."id" = "up"."id")))
                WHERE (("up"."id" = "auth"."uid"()) AND ("up"."role" = 'free'::"text"))
            )) AND ("medico_precadastro_id" = "auth"."uid"())) 
            OR 
            -- Condição 4: Médico free pode ver candidaturas de colegas
            ((EXISTS ( 
                SELECT 1
                FROM ("public"."user_profile" "up"
                    JOIN "public"."medicos" "m" ON (("m"."id" = "up"."id")))
                WHERE (("up"."id" = "auth"."uid"()) AND ("up"."role" = 'free'::"text"))
            )) AND "public"."pode_ver_candidatura_colega"("id")) 
            OR 
            -- Condição 5: Médico precadastro pode ver candidaturas de colegas
            ((EXISTS ( 
                SELECT 1
                FROM ("public"."user_profile" "up"
                    JOIN "public"."medicos_precadastro" "mp" ON (("mp"."id" = "up"."id")))
                WHERE (("up"."id" = "auth"."uid"()) AND ("up"."role" = 'free'::"text"))
            )) AND "public"."pode_ver_candidatura_colega"("id"))
            OR
            -- Condição 6: Se não tem grupo, mas é médico free, pode ver todas as candidaturas
            ("public"."get_current_user_grupo_id"() IS NULL AND EXISTS ( 
                SELECT 1
                FROM ("public"."user_profile" "up"
                    JOIN "public"."medicos" "m" ON (("m"."id" = "up"."id")))
                WHERE (("up"."id" = "auth"."uid"()) AND ("up"."role" = 'free'::"text"))
            ))
            OR
            -- Condição 7: Se não tem grupo, mas é médico precadastro, pode ver todas as candidaturas
            ("public"."get_current_user_grupo_id"() IS NULL AND EXISTS ( 
                SELECT 1
                FROM ("public"."user_profile" "up"
                    JOIN "public"."medicos_precadastro" "mp" ON (("mp"."id" = "up"."id")))
                WHERE (("up"."id" = "auth"."uid"()) AND ("up"."role" = 'free'::"text"))
            ))
        )
        -- Se não existe em user_profile (usuários via Houston)
        ELSE 
            "houston"."authorize_simple"('candidaturas.select'::"houston"."app_permission")
    END
);

-- NEW 
-- UPDATE candidaturas_update_policy
DROP POLICY IF EXISTS "candidaturas_update_policy" ON "public"."candidaturas";

CREATE POLICY "candidaturas_update_policy" 
ON "public"."candidaturas" 
FOR UPDATE TO "authenticated" 
USING (
    CASE 
        -- Se o usuário existe em user_profile (usuários do app)
        WHEN EXISTS (
            SELECT 1 FROM "public"."user_profile" 
            WHERE "user_profile"."id" = "auth"."uid"()
        ) THEN ( 
            -- Condição 1: Se tem grupo, vaga deve pertencer ao mesmo grupo
            (("public"."get_current_user_grupo_id"() IS NOT NULL) AND (EXISTS ( 
                SELECT 1
                FROM "public"."vagas" "v"
                WHERE (("v"."id" = "candidaturas"."vaga_id") AND ("v"."grupo_id" = "public"."get_current_user_grupo_id"()))
            ))) 
            OR 
            -- Condição 2: Médico free atualizando suas próprias candidaturas
            ((EXISTS ( 
                SELECT 1
                FROM ("public"."user_profile" "up"
                    JOIN "public"."medicos" "m" ON (("m"."id" = "up"."id")))
                WHERE (("up"."id" = "auth"."uid"()) AND ("up"."role" = 'free'::"text"))
            )) AND ("medico_id" = "auth"."uid"()))
        )
        -- Se não existe em user_profile (usuários via Houston)
        ELSE 
            "houston"."authorize_simple"('candidaturas.update'::"houston"."app_permission")
    END
) 
WITH CHECK (
    CASE 
        -- Se o usuário existe em user_profile (usuários do app)
        WHEN EXISTS (
            SELECT 1 FROM "public"."user_profile" 
            WHERE "user_profile"."id" = "auth"."uid"()
        ) THEN (
            -- Condição 1: Se tem grupo, vaga deve pertencer ao mesmo grupo
            (("public"."get_current_user_grupo_id"() IS NOT NULL) AND (EXISTS ( 
                SELECT 1
                FROM "public"."vagas" "v"
                WHERE (("v"."id" = "candidaturas"."vaga_id") AND ("v"."grupo_id" = "public"."get_current_user_grupo_id"()))
            ))) 
            OR 
            -- Condição 2: Médico free atualizando suas próprias candidaturas
            ((EXISTS ( 
                SELECT 1
                FROM ("public"."user_profile" "up"
                    JOIN "public"."medicos" "m" ON (("m"."id" = "up"."id")))
                WHERE (("up"."id" = "auth"."uid"()) AND ("up"."role" = 'free'::"text"))
            )) AND ("medico_id" = "auth"."uid"()))
        )
        -- Se não existe em user_profile (usuários via Houston)
        ELSE 
            "houston"."authorize_simple"('candidaturas.update'::"houston"."app_permission")
    END
);

--NEW
-- INSERT candidaturas_insert_policy
DROP POLICY IF EXISTS "candidaturas_insert_policy" ON "public"."candidaturas";

CREATE POLICY "candidaturas_insert_policy" 
ON "public"."candidaturas" 
FOR INSERT TO "authenticated" 
WITH CHECK (
    CASE 
        -- Se o usuário existe em user_profile (usuários do app)
        WHEN EXISTS (
            SELECT 1 FROM "public"."user_profile" 
            WHERE "user_profile"."id" = "auth"."uid"()
        ) THEN (
            -- Condição 1: Se tem grupo, vaga deve pertencer ao mesmo grupo
            ("public"."get_current_user_grupo_id"() IS NOT NULL AND EXISTS ( 
                SELECT 1
                FROM "public"."vagas" "v"
                WHERE (("v"."id" = "candidaturas"."vaga_id") AND ("v"."grupo_id" = "public"."get_current_user_grupo_id"()))
            )) 
            OR 
            -- Condição 2: Médico free inserindo suas próprias candidaturas
            ((EXISTS ( 
                SELECT 1
                FROM ("public"."user_profile" "up"
                    JOIN "public"."medicos" "m" ON (("m"."id" = "up"."id")))
                WHERE (("up"."id" = "auth"."uid"()) AND ("up"."role" = 'free'::"text"))
            )) AND ("medico_id" = "auth"."uid"()))
        )
        -- Se não existe em user_profile (usuários via Houston)
        ELSE 
            "houston"."authorize_simple"('candidaturas.insert'::"houston"."app_permission")
    END
);

-- NEW 
-- DELETE candidaturas_delete_policy
DROP POLICY IF EXISTS "candidaturas_delete_policy" ON "public"."candidaturas";

CREATE POLICY "candidaturas_delete_policy" 
ON "public"."candidaturas" 
FOR DELETE TO "authenticated" 
USING (
    CASE 
        -- Se o usuário existe em user_profile (usuários do app)
        WHEN EXISTS (
            SELECT 1 FROM "public"."user_profile" 
            WHERE "user_profile"."id" = "auth"."uid"()
        ) THEN ( 
            -- Condição 1: Se tem grupo, vaga deve pertencer ao mesmo grupo
            (("public"."get_current_user_grupo_id"() IS NOT NULL) AND (EXISTS ( 
                SELECT 1
                FROM "public"."vagas" "v"
                WHERE (("v"."id" = "candidaturas"."vaga_id") AND ("v"."grupo_id" = "public"."get_current_user_grupo_id"()))
            ))) 
            OR 
            -- Condição 2: Médico free deletando suas próprias candidaturas
            ((EXISTS ( 
                SELECT 1
                FROM ("public"."user_profile" "up"
                    JOIN "public"."medicos" "m" ON (("m"."id" = "up"."id")))
                WHERE (("up"."id" = "auth"."uid"()) AND ("up"."role" = 'free'::"text"))
            )) AND ("medico_id" = "auth"."uid"()))
        )
        -- Se não existe em user_profile (usuários via Houston)
        ELSE 
            "houston"."authorize_simple"('candidaturas.delete'::"houston"."app_permission")
    END
);