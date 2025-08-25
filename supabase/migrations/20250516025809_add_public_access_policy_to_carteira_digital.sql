CREATE POLICY "Permitir acesso público para visualização" 
ON storage.objects FOR SELECT 
TO public 
USING (bucket_id = 'carteira-digital');;
