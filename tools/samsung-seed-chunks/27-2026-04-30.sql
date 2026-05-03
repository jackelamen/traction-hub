-- Samsung seed chunk 27: 2026-04-30.
update traction_data
set value = value || jsonb_build_object('2026-04-30', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 62.9,
  'respiratoryRate', 12.2,
  'skinTemperatureC', 34.7,
  'spo2', 94.7,
  'spo2Min', 90,
  'steps', 7091
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
