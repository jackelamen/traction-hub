-- Samsung seed chunk 28: 2026-05-01.
update traction_data
set value = value || jsonb_build_object('2026-05-01', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 48,
  'respiratoryRate', 13.3,
  'skinTemperatureC', 33.9,
  'spo2', 94.7,
  'spo2Min', 91,
  'steps', 8100
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
