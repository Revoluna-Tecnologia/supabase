-- Migration: Padronização dos enums de permissões para usar insert, select, update, delete
-- Adiciona também permissões para hospitais, relatorios e candidaturas

--Roles
ALTER TYPE houston.app_permission RENAME VALUE 'roles.edit' TO 'roles.update';
ALTER TYPE houston.app_permission RENAME VALUE 'roles.remove' TO 'roles.delete';
ALTER TYPE houston.app_permission RENAME VALUE 'roles.add' TO 'roles.insert';
ALTER TYPE houston.app_permission RENAME VALUE 'roles.view' TO 'roles.select';

-- vagas
ALTER TYPE houston.app_permission RENAME VALUE 'vagas.edit' TO 'vagas.update';
ALTER TYPE houston.app_permission RENAME VALUE 'vagas.remove' TO 'vagas.delete';
ALTER TYPE houston.app_permission RENAME VALUE 'vagas.create' TO 'vagas.insert';
ALTER TYPE houston.app_permission RENAME VALUE 'vagas.view' TO 'vagas.select';

-- membros
ALTER TYPE houston.app_permission RENAME VALUE 'membros.edit' TO 'membros.update';
ALTER TYPE houston.app_permission RENAME VALUE 'membros.remove' TO 'membros.delete';
ALTER TYPE houston.app_permission RENAME VALUE 'membros.add' TO 'membros.insert';
ALTER TYPE houston.app_permission RENAME VALUE 'membros.view' TO 'membros.select';

-- Medicos (cadastro "ativo")
ALTER TYPE houston.app_permission RENAME VALUE 'medicos.edit' TO 'medicos.update';
ALTER TYPE houston.app_permission RENAME VALUE 'medicos.remove' TO 'medicos.delete';
ALTER TYPE houston.app_permission RENAME VALUE 'medicos.add' TO 'medicos.insert';
ALTER TYPE houston.app_permission RENAME VALUE 'medicos.view' TO 'medicos.select';

-- Medicos pré-cadastrados
ALTER TYPE houston.app_permission RENAME VALUE 'medicos_precadastro.edit' TO 'medicos_precadastro.update';
ALTER TYPE houston.app_permission RENAME VALUE 'medicos_precadastro.remove' TO 'medicos_precadastro.delete';
ALTER TYPE houston.app_permission RENAME VALUE 'medicos_precadastro.add' TO 'medicos_precadastro.insert';
ALTER TYPE houston.app_permission RENAME VALUE 'medicos_precadastro.view' TO 'medicos_precadastro.select';

-- grupos
ALTER TYPE houston.app_permission RENAME VALUE 'grupos.edit' TO 'grupos.update';
ALTER TYPE houston.app_permission RENAME VALUE 'grupos.remove' TO 'grupos.delete';
ALTER TYPE houston.app_permission RENAME VALUE 'grupos.add' TO 'grupos.insert';
ALTER TYPE houston.app_permission RENAME VALUE 'grupos.view' TO 'grupos.select';

-- candidaturas
ALTER TYPE houston.app_permission ADD VALUE 'candidaturas.update';
ALTER TYPE houston.app_permission ADD VALUE 'candidaturas.delete';
ALTER TYPE houston.app_permission ADD VALUE 'candidaturas.insert';
ALTER TYPE houston.app_permission ADD VALUE 'candidaturas.select'; 

-- hospitais
ALTER TYPE houston.app_permission ADD VALUE 'hospitais.update';
ALTER TYPE houston.app_permission ADD VALUE 'hospitais.delete';
ALTER TYPE houston.app_permission ADD VALUE 'hospitais.insert';
ALTER TYPE houston.app_permission ADD VALUE 'hospitais.select';

-- relatorios
ALTER TYPE houston.app_permission ADD VALUE 'relatorios.update';
ALTER TYPE houston.app_permission ADD VALUE 'relatorios.delete';
ALTER TYPE houston.app_permission ADD VALUE 'relatorios.insert';
ALTER TYPE houston.app_permission ADD VALUE 'relatorios.select';