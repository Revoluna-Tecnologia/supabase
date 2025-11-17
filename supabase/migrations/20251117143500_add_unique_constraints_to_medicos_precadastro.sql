-- Migration: Add unique constraints to medicos_precadastro table
-- Description: Adds unique partial indexes to crm, cpf, email, and telefone columns
-- These indexes allow multiple 'Não informado' values while ensuring uniqueness for all other values

-- Create unique partial index for crm (excluding 'Não informado')
CREATE UNIQUE INDEX medicos_precadastro_crm_key
ON public.medicos_precadastro (crm)
WHERE crm IS NOT NULL AND crm != 'Não informado';

-- Create unique partial index for cpf (excluding 'Não informado')
CREATE UNIQUE INDEX medicos_precadastro_cpf_key
ON public.medicos_precadastro (cpf)
WHERE cpf IS NOT NULL AND cpf != 'Não informado';

-- Create unique partial index for email (excluding 'Não informado')
CREATE UNIQUE INDEX medicos_precadastro_email_key
ON public.medicos_precadastro (email)
WHERE email IS NOT NULL AND email != 'Não informado';

-- Create unique partial index for telefone (excluding 'Não informado')
CREATE UNIQUE INDEX medicos_precadastro_telefone_key
ON public.medicos_precadastro (telefone)
WHERE telefone IS NOT NULL AND telefone != 'Não informado';
