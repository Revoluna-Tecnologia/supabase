

-- Limpar todas as permissões existentes
delete from houston.role_permissions;

-- Reinsere as permissões corretas
INSERT INTO "houston"."role_permissions" ("role", "permission") VALUES ('administrador', 'vagas.select'), ('administrador', 'vagas.insert'), ('administrador', 'vagas.update'), ('administrador', 'vagas.delete'), ('administrador', 'membros.select'), ('administrador', 'membros.insert'), ('administrador', 'membros.update'), ('administrador', 'membros.delete'), ('administrador', 'medicos.select'), ('administrador', 'medicos.insert'), ('administrador', 'medicos.update'), ('administrador', 'medicos_precadastro.select'), ('administrador', 'medicos_precadastro.insert'), ('administrador', 'medicos_precadastro.update'), ('administrador', 'medicos_precadastro.delete'), ('administrador', 'grupos.select'), ('administrador', 'grupos.insert'), ('administrador', 'grupos.update'), ('administrador', 'grupos.delete'), ('administrador', 'roles.select'), ('administrador', 'roles.insert'), ('administrador', 'roles.update'), ('administrador', 'roles.delete'), ('administrador', 'candidaturas.update'), ('administrador', 'candidaturas.delete'), ('administrador', 'candidaturas.insert'), ('administrador', 'candidaturas.select'), ('administrador', 'hospitais.update'), ('administrador', 'hospitais.delete'), ('administrador', 'hospitais.insert'), ('administrador', 'hospitais.select'), ('administrador', 'relatorios.update'), ('administrador', 'relatorios.delete'), ('administrador', 'relatorios.insert'), ('administrador', 'relatorios.select'), ('moderador', 'vagas.select'), ('moderador', 'vagas.insert'), ('moderador', 'vagas.update'), ('moderador', 'vagas.delete'), ('moderador', 'membros.select'), ('moderador', 'membros.insert'), ('moderador', 'membros.update'), ('moderador', 'membros.delete'), ('moderador', 'medicos.select'), ('moderador', 'medicos.insert'), ('moderador', 'medicos.update'), ('moderador', 'medicos_precadastro.select'), ('moderador', 'medicos_precadastro.insert'), ('moderador', 'medicos_precadastro.update'), ('moderador', 'medicos_precadastro.delete'), ('moderador', 'grupos.select'), ('moderador', 'grupos.update'), ('moderador', 'candidaturas.update'), ('moderador', 'candidaturas.delete'), ('moderador', 'candidaturas.insert'), ('moderador', 'candidaturas.select'), ('moderador', 'hospitais.update'), ('moderador', 'hospitais.insert'), ('moderador', 'hospitais.select'), ('moderador', 'relatorios.update'), ('moderador', 'relatorios.delete'), ('moderador', 'relatorios.insert'), ('moderador', 'relatorios.select'), ('gestor', 'vagas.select'), ('gestor', 'vagas.insert'), ('gestor', 'vagas.update'), ('gestor', 'vagas.delete'), ('gestor', 'membros.select'), ('gestor', 'membros.insert'), ('gestor', 'membros.update'), ('gestor', 'membros.delete'), ('gestor', 'medicos.select'), ('gestor', 'medicos.insert'), ('gestor', 'medicos.update'), ('gestor', 'medicos_precadastro.select'), ('gestor', 'medicos_precadastro.insert'), ('gestor', 'medicos_precadastro.update'), ('gestor', 'grupos.select'), ('gestor', 'grupos.update'), ('gestor', 'roles.select'), ('gestor', 'roles.update'), ('gestor', 'candidaturas.update'), ('gestor', 'candidaturas.delete'), ('gestor', 'candidaturas.insert'), ('gestor', 'candidaturas.select'), ('gestor', 'hospitais.update'), ('gestor', 'hospitais.insert'), ('gestor', 'hospitais.select'), ('gestor', 'relatorios.update'), ('gestor', 'relatorios.delete'), ('gestor', 'relatorios.insert'), ('gestor', 'relatorios.select'), ('coordenador', 'vagas.select'), ('coordenador', 'vagas.insert'), ('coordenador', 'vagas.update'), ('coordenador', 'vagas.delete'), ('coordenador', 'membros.select'), ('coordenador', 'membros.insert'), ('coordenador', 'membros.update'), ('coordenador', 'membros.delete'),
('escalista', 'vagas.select'),
('escalista', 'vagas.insert'),
('escalista', 'vagas.update'),
('escalista', 'vagas.delete'),
('escalista', 'membros.select'),
('escalista', 'medicos.select'),
('escalista', 'medicos.insert'),
('escalista', 'medicos.update'),
('escalista', 'medicos_precadastro.select'),
('escalista', 'medicos_precadastro.insert'),
('escalista', 'medicos_precadastro.update'),
('escalista', 'grupos.select'),
('escalista', 'grupos.update'),
('escalista', 'roles.select'),
('escalista', 'hospitais.update'),
('escalista', 'hospitais.insert'),
('escalista', 'hospitais.select'),
('escalista', 'candidaturas.update'),
('escalista', 'candidaturas.delete'),
('escalista', 'candidaturas.insert'),
('escalista', 'candidaturas.select');


DELETE FROM public.user_profile WHERE role IN ('escalista', 'astronauta');