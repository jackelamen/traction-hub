-- Samsung seed chunk 23: 2026-04-26.
update traction_data
set value = value || jsonb_build_object('2026-04-26', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 54.9,
  'respiratoryRate', 13.1,
  'skinTemperatureC', 33.8,
  'spo2', 95.1,
  'spo2Min', 91,
  'steps', 13804,
  'exerciseMins', 44
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
