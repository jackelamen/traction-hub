-- Samsung seed chunk 03: 2026-04-06.
update traction_data
set value = value || jsonb_build_object('2026-04-06', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 46.2,
  'respiratoryRate', 13.4,
  'skinTemperatureC', 33.4,
  'spo2', 95.5,
  'spo2Min', 93,
  'steps', 4881,
  'exerciseMins', 12
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
