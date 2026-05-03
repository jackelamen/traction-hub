-- Samsung seed chunk 13: 2026-04-16.
update traction_data
set value = value || jsonb_build_object('2026-04-16', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 44.4,
  'respiratoryRate', 12.4,
  'skinTemperatureC', 34.6,
  'spo2', 94.9,
  'spo2Min', 94,
  'steps', 6456,
  'exerciseMins', 24
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
