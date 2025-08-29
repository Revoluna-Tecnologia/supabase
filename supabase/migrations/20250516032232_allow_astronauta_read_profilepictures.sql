CREATE POLICY "Permitir leitura para astronauta em todas as pastas" ON storage.objects FOR SELECT TO authenticated USING (
  bucket_id = 'profilepictures' AND (
    (SELECT user_profile.role FROM user_profile WHERE user_profile.id = auth.uid()) = 'astronauta'
  )
);;
