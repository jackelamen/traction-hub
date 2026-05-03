-- Samsung seed chunk 09: 2026-04-12.
update traction_data
set value = value || jsonb_build_object('2026-04-12', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 73.2,
  'respiratoryRate', 12.6,
  'skinTemperatureC', 32.7,
  'spo2', 94.6,
  'spo2Min', 92,
  'steps', 6044
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
