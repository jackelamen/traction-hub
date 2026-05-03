-- Samsung seed chunk 15: 2026-04-18.
update traction_data
set value = value || jsonb_build_object('2026-04-18', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 100.6,
  'respiratoryRate', 13.1,
  'skinTemperatureC', 34.8,
  'spo2', 93.3,
  'spo2Min', 89,
  'steps', 9532,
  'exerciseMins', 51
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
