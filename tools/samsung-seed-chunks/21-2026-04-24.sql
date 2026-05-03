-- Samsung seed chunk 21: 2026-04-24.
update traction_data
set value = value || jsonb_build_object('2026-04-24', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 47.5,
  'respiratoryRate', 13.5,
  'skinTemperatureC', 34,
  'spo2', 95.2,
  'spo2Min', 92,
  'steps', 12511,
  'exerciseMins', 16
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
