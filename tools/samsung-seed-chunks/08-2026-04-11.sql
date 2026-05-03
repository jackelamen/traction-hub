-- Samsung seed chunk 08: 2026-04-11.
update traction_data
set value = value || jsonb_build_object('2026-04-11', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:40.114Z',
  'steps', 9811
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
