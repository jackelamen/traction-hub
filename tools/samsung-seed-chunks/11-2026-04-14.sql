-- Samsung seed chunk 11: 2026-04-14.
update traction_data
set value = value || jsonb_build_object('2026-04-14', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 85.9,
  'respiratoryRate', 12.7,
  'skinTemperatureC', 34.2,
  'spo2', 94.3,
  'spo2Min', 89,
  'steps', 9743,
  'exerciseMins', 38
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
