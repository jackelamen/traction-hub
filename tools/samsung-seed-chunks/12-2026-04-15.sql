-- Samsung seed chunk 12: 2026-04-15.
update traction_data
set value = value || jsonb_build_object('2026-04-15', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 54.8,
  'respiratoryRate', 13.4,
  'skinTemperatureC', 33.5,
  'spo2', 93.5,
  'spo2Min', 90,
  'steps', 11345,
  'exerciseMins', 28
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
