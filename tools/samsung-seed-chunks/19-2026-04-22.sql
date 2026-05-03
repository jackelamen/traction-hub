-- Samsung seed chunk 19: 2026-04-22.
update traction_data
set value = value || jsonb_build_object('2026-04-22', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 62.3,
  'respiratoryRate', 13.1,
  'skinTemperatureC', 35,
  'spo2', 94.6,
  'spo2Min', 90,
  'steps', 10825,
  'sleepHours', 8.45,
  'exerciseMins', 23
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
