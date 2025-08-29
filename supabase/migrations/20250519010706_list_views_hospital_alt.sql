SELECT table_name, view_definition FROM information_schema.views WHERE table_schema = 'public' AND view_definition ILIKE '%hospital%';;
