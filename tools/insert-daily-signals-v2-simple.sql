-- Seed clean Samsung Health v2 data one date at a time.
-- This avoids the fragile giant JSON string and the nested union query.

delete from traction_data
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';

insert into traction_data (user_id, key, value, updated_at)
values ('jack_traction_hub_v1', 'edgex_daily_signals_v2', '{}'::jsonb, now());

update traction_data
set value = value || jsonb_build_object('2026-04-04', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 65.6,
  'respiratoryRate', 13.5,
  'skinTemperatureC', 34.4,
  'spo2', 94.9,
  'spo2Min', 92,
  'steps', 8965,
  'sleepHours', 7.72,
  'exerciseMins', 25
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';

update traction_data
set value = value || jsonb_build_object('2026-04-05', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 59.1,
  'respiratoryRate', 12.7,
  'skinTemperatureC', 34.8,
  'spo2', 94.1,
  'spo2Min', 82,
  'steps', 2998
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';

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

update traction_data
set value = value || jsonb_build_object('2026-04-07', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 55.2,
  'respiratoryRate', 13.1,
  'skinTemperatureC', 34.7,
  'spo2', 92.9,
  'spo2Min', 90,
  'steps', 8455,
  'exerciseMins', 53
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';

update traction_data
set value = value || jsonb_build_object('2026-04-08', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 61.4,
  'respiratoryRate', 13.1,
  'skinTemperatureC', 34,
  'spo2', 94.1,
  'spo2Min', 85,
  'steps', 11017,
  'exerciseMins', 42
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';

update traction_data
set value = value || jsonb_build_object('2026-04-09', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 50.5,
  'respiratoryRate', 12.5,
  'skinTemperatureC', 34.2,
  'spo2', 94.9,
  'spo2Min', 92,
  'steps', 4980
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';

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

update traction_data
set value = value || jsonb_build_object('2026-04-11', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:40.114Z',
  'steps', 9811
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';

update traction_data
set value = value || jsonb_build_object('2026-04-12', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 73.2,
  'respiratoryRate', 12.6,
  'skinTemperatureC', 32.7,
  'spo2', 94.6,
  'spo2Min', 92,
  'steps', 6044
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';

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

update traction_data
set value = value || jsonb_build_object('2026-04-16', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 44.4,
  'respiratoryRate', 12.4,
  'skinTemperatureC', 34.6,
  'spo2', 94.9,
  'spo2Min', 94,
  'steps', 6456,
  'exerciseMins', 24
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';

update traction_data
set value = value || jsonb_build_object('2026-04-17', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 59.6,
  'respiratoryRate', 12.9,
  'skinTemperatureC', 34,
  'spo2', 94.1,
  'spo2Min', 82,
  'steps', 10204,
  'sleepHours', 5.95,
  'exerciseMins', 13
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';

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

update traction_data
set value = value || jsonb_build_object('2026-04-20', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 60.6,
  'respiratoryRate', 13.1,
  'skinTemperatureC', 35.5,
  'spo2', 92.9,
  'spo2Min', 70,
  'steps', 12449,
  'exerciseMins', 55
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';

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

update traction_data
set value = value || jsonb_build_object('2026-04-22', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 62.3,
  'respiratoryRate', 13.1,
  'skinTemperatureC', 35,
  'spo2', 94.6,
  'spo2Min', 90,
  'steps', 10825,
  'sleepHours', 8.45,
  'exerciseMins', 23
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';

update traction_data
set value = value || jsonb_build_object('2026-04-23', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 41.6,
  'respiratoryRate', 13,
  'skinTemperatureC', 34.6,
  'spo2', 95.3,
  'spo2Min', 92,
  'steps', 8141,
  'sleepHours', 7.48,
  'exerciseMins', 49
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';

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

update traction_data
set value = value || jsonb_build_object('2026-04-25', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 49.1,
  'respiratoryRate', 13.7,
  'skinTemperatureC', 35.3,
  'spo2', 94.9,
  'spo2Min', 94,
  'steps', 4151
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';

update traction_data
set value = value || jsonb_build_object('2026-04-26', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 54.9,
  'respiratoryRate', 13.1,
  'skinTemperatureC', 33.8,
  'spo2', 95.1,
  'spo2Min', 91,
  'steps', 13804,
  'exerciseMins', 44
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';

update traction_data
set value = value || jsonb_build_object('2026-04-27', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.405Z',
  'hrvRmssd', 67.4,
  'respiratoryRate', 13,
  'skinTemperatureC', 33.4,
  'spo2', 94,
  'spo2Min', 92,
  'steps', 10815,
  'sleepHours', 5.72,
  'exerciseMins', 24
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';

update traction_data
set value = value || jsonb_build_object('2026-04-28', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 70.9,
  'respiratoryRate', 13.1,
  'skinTemperatureC', 34,
  'spo2', 94.8,
  'spo2Min', 90,
  'steps', 10005,
  'exerciseMins', 39
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';

update traction_data
set value = value || jsonb_build_object('2026-04-29', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 61.3,
  'respiratoryRate', 12.8,
  'skinTemperatureC', 34.5,
  'spo2', 94.8,
  'spo2Min', 92,
  'steps', 13481,
  'exerciseMins', 57
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';

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

update traction_data
set value = value || jsonb_build_object('2026-05-01', jsonb_strip_nulls(jsonb_build_object(
  'source', 'Samsung Health',
  'updatedAt', '2026-05-03T03:31:36.406Z',
  'hrvRmssd', 48,
  'respiratoryRate', 13.3,
  'skinTemperatureC', 33.9,
  'spo2', 94.7,
  'spo2Min', 91,
  'steps', 8100
))),
    updated_at = now()
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';

select
  key,
  (select count(*) from jsonb_object_keys(value)) as kept_days,
  pg_size_pretty(pg_column_size(value)::bigint) as json_size
from traction_data
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
