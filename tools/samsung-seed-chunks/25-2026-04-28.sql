-- Samsung seed chunk 25: 2026-04-28.
update traction_data
set value = value || jsonb_build_object('2026-04-28', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 70.9,
  'respiratoryRate', 13.1,
  'skinTemperatureC', 34,
  'spo2', 94.8,
  'spo2Min', 90,
  'steps', 10005,
  'exerciseMins', 39
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
