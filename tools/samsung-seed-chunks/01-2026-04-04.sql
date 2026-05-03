-- Samsung seed chunk 01: 2026-04-04.
update traction_data
set value = value || jsonb_build_object('2026-04-04', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 65.6,
  'respiratoryRate', 13.5,
  'skinTemperatureC', 34.4,
  'spo2', 94.9,
  'spo2Min', 92,
  'steps', 8965,
  'sleepHours', 7.72,
  'exerciseMins', 25
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
