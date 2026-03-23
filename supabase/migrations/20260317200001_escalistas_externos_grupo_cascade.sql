-- =============================================================================
-- Migration: Alterar FK grupo_id em escalistas_externos para CASCADE
-- =============================================================================

ALTER TABLE escalistas_externos
    DROP CONSTRAINT escalistas_externos_grupo_id_fkey,
    ADD CONSTRAINT escalistas_externos_grupo_id_fkey
        FOREIGN KEY (grupo_id) REFERENCES grupos(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE;
