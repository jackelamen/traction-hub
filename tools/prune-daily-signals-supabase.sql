-- Prune Samsung Health daily signal data in place.
-- Run this in the Supabase SQL editor.
--
-- It keeps only:
--   - date entries from the last 30 Korea-time days
--   - fields the EDGEx app currently reads
--
-- It removes older dated entries and unused imported fields such as sample counts,
-- calories, distance, floors, sleep score/efficiency/type, and activity timing.

update traction_data
set
  value = (
    select coalesce(jsonb_object_agg(date_key, pruned_value), '{}'::jsonb)
    from (
      select
        date_key,
        case
          when date_key ~ '^\d{4}-\d{2}-\d{2}$' then
            jsonb_strip_nulls(jsonb_build_object(
              'source', day_value -> 'source',
              'updatedAt', day_value -> 'updatedAt',
              'steps', day_value -> 'steps',
              'sleepHours', day_value -> 'sleepHours',
              'exerciseMins', day_value -> 'exerciseMins',
              'weight', day_value -> 'weight',
              'hrvRmssd', day_value -> 'hrvRmssd',
              'respiratoryRate', day_value -> 'respiratoryRate',
              'spo2', day_value -> 'spo2',
              'spo2Min', day_value -> 'spo2Min',
              'stressScore', day_value -> 'stressScore',
              'skinTemperatureC', day_value -> 'skinTemperatureC',
              'waterOz', day_value -> 'waterOz',
              'waterL', day_value -> 'waterL',
              'stepBase', day_value -> 'stepBase',
              'netSteps', day_value -> 'netSteps',
              'walks', day_value -> 'walks',
              'horizonCount', day_value -> 'horizonCount'
            ))
          else day_value
        end as pruned_value
      from jsonb_each(value) as signals(date_key, day_value)
      where
        date_key !~ '^\d{4}-\d{2}-\d{2}$'
        or date_key >= to_char(((now() at time zone 'Asia/Seoul')::date - 29), 'YYYY-MM-DD')
    ) pruned
  ),
  updated_at = now()
where
  user_id = 'jack_traction_hub_v1'
  and key = 'edgex_daily_signals_v1';

-- Optional check after running:
select
  (select count(*) from jsonb_object_keys(value)) as kept_days,
  pg_size_pretty(pg_column_size(value)::bigint) as json_size
from traction_data
where
  user_id = 'jack_traction_hub_v1'
  and key = 'edgex_daily_signals_v1';
