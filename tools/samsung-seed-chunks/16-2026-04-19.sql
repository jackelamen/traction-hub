-- Samsung seed chunk 16: 2026-04-19.
update traction_data
set value = value || jsonb_build_object('2026-04-19', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 59.9,
  'respiratoryRate', 13.3,
  'skinTemperatureC', 33.6,
  'spo2', 93.8,
  'spo2Min', 80,
  'steps', 9178
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
