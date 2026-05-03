-- Samsung seed chunk 18: 2026-04-21.
update traction_data
set value = value || jsonb_build_object('2026-04-21', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 68.8,
  'respiratoryRate', 12.6,
  'skinTemperatureC', 34.4,
  'spo2', 94.4,
  'spo2Min', 89,
  'steps', 10236,
  'exerciseMins', 59
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
