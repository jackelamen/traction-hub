-- Samsung seed chunk 00: initialize the clean v2 row.
delete from traction_data
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';

insert into traction_data (user_id, key, value, updated_at)
values ('jack_traction_hub_v1', 'edgex_daily_signals_v2', '{}'::jsonb, now());
