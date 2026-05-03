-- Samsung seed final check.
select
  key,
  (select count(*) from jsonb_object_keys(value)) as kept_days,
  pg_size_pretty(pg_column_size(value)::bigint) as json_size
from traction_data
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';
