-- Samsung seed chunk 02: 2026-04-05.
update traction_data
set value = value || jsonb_build_object('2026-04-05', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 59.1,
  'respiratoryRate', 12.7,
  'skinTemperatureC', 34.8,
  'spo2', 94.1,
  'spo2Min', 82,
  'steps', 2998
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
