-- Samsung seed chunk 22: 2026-04-25.
update traction_data
set value = value || jsonb_build_object('2026-04-25', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 49.1,
  'respiratoryRate', 13.7,
  'skinTemperatureC', 35.3,
  'spo2', 94.9,
  'spo2Min', 94,
  'steps', 4151
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
