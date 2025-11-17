-- Reinsere as permissões corretas
INSERT INTO "houston"."role_permissions" ("role", "permission") VALUES 
('moderador', 'roles.select'),
('coordenador', 'roles.select');