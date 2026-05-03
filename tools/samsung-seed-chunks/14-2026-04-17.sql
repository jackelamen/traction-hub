-- Samsung seed chunk 14: 2026-04-17.
update traction_data
set value = value || jsonb_build_object('2026-04-17', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 59.6,
  'respiratoryRate', 12.9,
  'skinTemperatureC', 34,
  'spo2', 94.1,
  'spo2Min', 82,
  'steps', 10204,
  'sleepHours', 5.95,
  'exerciseMins', 13
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
