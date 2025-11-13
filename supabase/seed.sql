-- Seed data for Supabase project
-- Este arquivo contém os dados essenciais para o funcionamento do sistema

SET session_replication_role = replica;

--
-- Data for Name: especialidades; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."especialidades" ("id", "created_at", "nome", "index") VALUES
	('d64227b6-4ceb-47ac-9b1c-f51d1735f4ba', '2025-11-12 16:46:55.567197+00', 'Generalista', 0),
	('a1b2c3d4-e5f6-4789-a012-b3c4d5e6f789', '2025-11-12 16:46:55.567197+00', 'Cardiologia', 1),
	('f1e2d3c4-b5a6-4789-9012-345678901234', '2025-11-12 16:46:55.567197+00', 'Ortopedia', 2),
	('12345678-9abc-4def-0123-456789abcdef', '2025-11-12 16:46:55.567197+00', 'Pediatria', 3)
ON CONFLICT (id) DO NOTHING;

--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: houston; Owner: postgres
--

INSERT INTO "houston"."role_permissions" ("role", "permission") VALUES
	('administrador', 'vagas.select'),
	('administrador', 'vagas.insert'),
	('administrador', 'vagas.update'),
	('administrador', 'vagas.delete'),
	('administrador', 'membros.select'),
	('administrador', 'membros.insert'),
	('administrador', 'membros.update'),
	('administrador', 'membros.delete'),
	('administrador', 'medicos.select'),
	('administrador', 'medicos.insert'),
	('administrador', 'medicos.update'),
	('administrador', 'medicos_precadastro.select'),
	('administrador', 'medicos_precadastro.insert'),
	('administrador', 'medicos_precadastro.update'),
	('administrador', 'medicos_precadastro.delete'),
	('administrador', 'grupos.select'),
	('administrador', 'grupos.insert'),
	('administrador', 'grupos.update'),
	('administrador', 'grupos.delete'),
	('administrador', 'roles.select'),
	('administrador', 'roles.insert'),
	('administrador', 'roles.update'),
	('administrador', 'roles.delete'),
	('administrador', 'candidaturas.update'),
	('administrador', 'candidaturas.delete'),
	('administrador', 'candidaturas.insert'),
	('administrador', 'candidaturas.select'),
	('administrador', 'hospitais.update'),
	('administrador', 'hospitais.delete'),
	('administrador', 'hospitais.insert'),
	('administrador', 'hospitais.select'),
	('escalista', 'vagas.select'),
	('escalista', 'vagas.insert'),
	('escalista', 'vagas.update'),
	('escalista', 'medicos.select'),
	('escalista', 'candidaturas.select'),
	('escalista', 'candidaturas.update')
ON CONFLICT (role, permission) DO NOTHING;

--
-- Data for Name: grupos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."grupos" ("id", "nome", "created_at") VALUES
	('ada3a79a-6437-4e27-9e22-40c08c36c59b', 'Grupo Padrão', NOW())
ON CONFLICT (id) DO NOTHING;

--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."users" (
    "id", "instance_id", "email", "encrypted_password", "email_confirmed_at", 
    "email_change_confirm_status", "created_at", "updated_at", "raw_app_meta_data", 
    "raw_user_meta_data", "is_super_admin", "role", "aud", "confirmation_token", 
    "recovery_token", "email_change_token_new", "email_change"
) VALUES (
    'ada3a79a-6437-4e27-9e22-40c08c36c59b',
    '00000000-0000-0000-0000-000000000000',
    'escalista.migrado@placeholder.com',
    '$2a$10$hashed_password_placeholder',
    NOW(),
    0,
    NOW(),
    NOW(),
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    '{"full_name": "Escalista Migrado", "phone": "(00) 00000-0000", "platform_origin": "houston"}'::jsonb,
    false,
    'authenticated',
    'authenticated',
    '',
    '',
    '',
    ''
)
ON CONFLICT (id) DO NOTHING;

--
-- Data for Name: escalistas; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."escalistas" (
    "id", "nome", "telefone", "email", "grupo_id", "created_at"
) VALUES (
    'ada3a79a-6437-4e27-9e22-40c08c36c59b',
    'Escalista Migrado - Dados Órfãos',
    '(00) 00000-0000',
    'escalista.migrado@placeholder.com',
    'ada3a79a-6437-4e27-9e22-40c08c36c59b',
    NOW()
)
ON CONFLICT (id) DO NOTHING;

--
-- Data for Name: user_profile; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."user_profile" ("id", "created_at", "role", "displayname") VALUES
	('ada3a79a-6437-4e27-9e22-40c08c36c59b', NOW(), 'escalista', 'Escalista Migrado')
ON CONFLICT (id) DO NOTHING;

SET session_replication_role = DEFAULT;