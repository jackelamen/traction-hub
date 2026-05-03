-- Samsung seed chunk 06: 2026-04-09.
update traction_data
set value = value || jsonb_build_object('2026-04-09', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 50.5,
  'respiratoryRate', 12.5,
  'skinTemperatureC', 34.2,
  'spo2', 94.9,
  'spo2Min', 92,
  'steps', 4980
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
