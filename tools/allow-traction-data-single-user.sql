-- Allow the static EDGEx app to read/write its single shared traction_data namespace.
-- Run this in Supabase SQL Editor.

alter table traction_data enable row level security;

drop policy if exists traction_data_single_user on traction_data;
create policy traction_data_single_user on traction_data
  for all
  to anon, authenticated
  using (user_id = 'jack_traction_hub_v1')
  with check (user_id = 'jack_traction_hub_v1');
