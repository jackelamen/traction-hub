-- Samsung seed chunk 07: 2026-04-10.
update traction_data
set value = value || jsonb_build_object('2026-04-10', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 42,
  'respiratoryRate', 12.8,
  'skinTemperatureC', 34.2,
  'spo2', 95.3,
  'spo2Min', 93,
  'steps', 10820,
  'exerciseMins', 64
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
