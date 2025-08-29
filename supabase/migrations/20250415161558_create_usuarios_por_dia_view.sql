
CREATE OR REPLACE VIEW public.vw_usuarios_por_dia AS
SELECT 
  DATE(created_at) as data,
  COUNT(*) as total
FROM auth.users
GROUP BY DATE(created_at)
ORDER BY data;
;
