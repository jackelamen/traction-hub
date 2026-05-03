-- Samsung seed chunk 17: 2026-04-20.
update traction_data
set value = value || jsonb_build_object('2026-04-20', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 60.6,
  'respiratoryRate', 13.1,
  'skinTemperatureC', 35.5,
  'spo2', 92.9,
  'spo2Min', 70,
  'steps', 12449,
  'exerciseMins', 55
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
