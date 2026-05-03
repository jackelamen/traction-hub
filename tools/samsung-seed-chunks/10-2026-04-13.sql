-- Samsung seed chunk 10: 2026-04-13.
update traction_data
set value = value || jsonb_build_object('2026-04-13', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 67.7,
  'respiratoryRate', 12.7,
  'skinTemperatureC', 33.6,
  'spo2', 94.2,
  'spo2Min', 87,
  'steps', 8083,
  'exerciseMins', 10
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
