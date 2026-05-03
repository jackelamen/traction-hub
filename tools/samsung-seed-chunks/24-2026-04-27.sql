-- Samsung seed chunk 24: 2026-04-27.
update traction_data
set value = value || jsonb_build_object('2026-04-27', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.405Z',
  'hrvRmssd', 67.4,
  'respiratoryRate', 13,
  'skinTemperatureC', 33.4,
  'spo2', 94,
  'spo2Min', 92,
  'steps', 10815,
  'sleepHours', 5.72,
  'exerciseMins', 24
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
