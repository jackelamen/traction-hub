-- Samsung seed chunk 26: 2026-04-29.
update traction_data
set value = value || jsonb_build_object('2026-04-29', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 61.3,
  'respiratoryRate', 12.8,
  'skinTemperatureC', 34.5,
  'spo2', 94.8,
  'spo2Min', 92,
  'steps', 13481,
  'exerciseMins', 57
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
