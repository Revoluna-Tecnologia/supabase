-- Change WhatsAppNumber table policy to allow public read access

drop policy if exists "Enable read access for authenticated users" on public.whatsapp_number;
drop policy if exists "Enable read access for public" on public.whatsapp_number;
create policy "Enable read access for public" on public.whatsapp_number
    for select
    to public
    using (true);