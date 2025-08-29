
-- Excluir usuário eb17de1c-85b3-48d3-befa-66633f89974d
-- Primeiro excluir da tabela identities por causa da foreign key
DELETE FROM auth.identities 
WHERE user_id = 'eb17de1c-85b3-48d3-befa-66633f89974d';

-- Depois excluir da tabela users
DELETE FROM auth.users 
WHERE id = 'eb17de1c-85b3-48d3-befa-66633f89974d';
;
