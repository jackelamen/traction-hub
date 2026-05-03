-- Samsung seed chunk 20: 2026-04-23.
update traction_data
set value = value || jsonb_build_object('2026-04-23', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 41.6,
  'respiratoryRate', 13,
  'skinTemperatureC', 34.6,
  'spo2', 95.3,
  'spo2Min', 92,
  'steps', 8141,
  'sleepHours', 7.48,
  'exerciseMins', 49
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
