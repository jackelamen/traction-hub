-- Samsung seed chunk 04: 2026-04-07.
update traction_data
set value = value || jsonb_build_object('2026-04-07', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 55.2,
  'respiratoryRate', 13.1,
  'skinTemperatureC', 34.7,
  'spo2', 92.9,
  'spo2Min', 90,
  'steps', 8455,
  'exerciseMins', 53
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
