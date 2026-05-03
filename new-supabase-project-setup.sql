-- ============================================================
-- THE EDGEx New Supabase Project Setup
-- Project: https://mdkyijbgvxedelcqcouu.supabase.co
-- Run this in the new project's Supabase SQL Editor.
-- ============================================================

create extension if not exists pgcrypto;

-- Shared key/value app sync table.
create table if not exists traction_data (
  id uuid primary key default gen_random_uuid(),
  user_id text not null,
  key text not null,
  value jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  unique (user_id, key)
);

create index if not exists traction_data_user_key_idx on traction_data (user_id, key);

create or replace function upsert_traction_data(rows jsonb)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into traction_data (user_id, key, value, updated_at)
  select
    item->>'user_id',
    item->>'key',
    coalesce(item->'value', '{}'::jsonb),
    coalesce((item->>'updated_at')::timestamptz, now())
  from jsonb_array_elements(rows) as item
  on conflict (user_id, key) do update set
    value = excluded.value,
    updated_at = excluded.updated_at;
end;
$$;

grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on traction_data to anon, authenticated;
grant execute on function upsert_traction_data(jsonb) to anon, authenticated;

alter table traction_data enable row level security;
drop policy if exists traction_data_single_user on traction_data;
create policy traction_data_single_user on traction_data
  for all
  to anon, authenticated
  using (user_id = 'jack_traction_hub_v1')
  with check (user_id = 'jack_traction_hub_v1');

-- Clean Samsung Health v2 data. This intentionally does not create the oversized v1 key.
delete from traction_data
where user_id = 'jack_traction_hub_v1' and key = 'edgex_daily_signals_v2';

insert into traction_data (user_id, key, value, updated_at)
select
  'jack_traction_hub_v1',
  'edgex_daily_signals_v2',
  coalesce(jsonb_object_agg(date_key, day_value), '{}'::jsonb),
  now()
from (
      select '2026-04-04'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
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
      )) as day_value
      union all select '2026-04-05'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
        'source', 'Samsung Health',
        'updatedAt', '2026-05-03T03:31:36.406Z',
        'hrvRmssd', 59.1,
        'respiratoryRate', 12.7,
        'skinTemperatureC', 34.8,
        'spo2', 94.1,
        'spo2Min', 82,
        'steps', 2998
      )) as day_value
      union all select '2026-04-06'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
        'source', 'Samsung Health',
        'updatedAt', '2026-05-03T03:31:36.406Z',
        'hrvRmssd', 46.2,
        'respiratoryRate', 13.4,
        'skinTemperatureC', 33.4,
        'spo2', 95.5,
        'spo2Min', 93,
        'steps', 4881,
        'exerciseMins', 12
      )) as day_value
      union all select '2026-04-07'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
        'source', 'Samsung Health',
        'updatedAt', '2026-05-03T03:31:36.406Z',
        'hrvRmssd', 55.2,
        'respiratoryRate', 13.1,
        'skinTemperatureC', 34.7,
        'spo2', 92.9,
        'spo2Min', 90,
        'steps', 8455,
        'exerciseMins', 53
      )) as day_value
      union all select '2026-04-08'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
        'source', 'Samsung Health',
        'updatedAt', '2026-05-03T03:31:36.406Z',
        'hrvRmssd', 61.4,
        'respiratoryRate', 13.1,
        'skinTemperatureC', 34,
        'spo2', 94.1,
        'spo2Min', 85,
        'steps', 11017,
        'exerciseMins', 42
      )) as day_value
      union all select '2026-04-09'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
        'source', 'Samsung Health',
        'updatedAt', '2026-05-03T03:31:36.406Z',
        'hrvRmssd', 50.5,
        'respiratoryRate', 12.5,
        'skinTemperatureC', 34.2,
        'spo2', 94.9,
        'spo2Min', 92,
        'steps', 4980
      )) as day_value
      union all select '2026-04-10'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
        'source', 'Samsung Health',
        'updatedAt', '2026-05-03T03:31:36.406Z',
        'hrvRmssd', 42,
        'respiratoryRate', 12.8,
        'skinTemperatureC', 34.2,
        'spo2', 95.3,
        'spo2Min', 93,
        'steps', 10820,
        'exerciseMins', 64
      )) as day_value
      union all select '2026-04-11'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
        'source', 'Samsung Health',
        'updatedAt', '2026-05-03T03:31:40.114Z',
        'steps', 9811
      )) as day_value
      union all select '2026-04-12'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
        'source', 'Samsung Health',
        'updatedAt', '2026-05-03T03:31:36.406Z',
        'hrvRmssd', 73.2,
        'respiratoryRate', 12.6,
        'skinTemperatureC', 32.7,
        'spo2', 94.6,
        'spo2Min', 92,
        'steps', 6044
      )) as day_value
      union all select '2026-04-13'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
        'source', 'Samsung Health',
        'updatedAt', '2026-05-03T03:31:36.406Z',
        'hrvRmssd', 67.7,
        'respiratoryRate', 12.7,
        'skinTemperatureC', 33.6,
        'spo2', 94.2,
        'spo2Min', 87,
        'steps', 8083,
        'exerciseMins', 10
      )) as day_value
      union all select '2026-04-14'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
        'source', 'Samsung Health',
        'updatedAt', '2026-05-03T03:31:36.406Z',
        'hrvRmssd', 85.9,
        'respiratoryRate', 12.7,
        'skinTemperatureC', 34.2,
        'spo2', 94.3,
        'spo2Min', 89,
        'steps', 9743,
        'exerciseMins', 38
      )) as day_value
      union all select '2026-04-15'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
        'source', 'Samsung Health',
        'updatedAt', '2026-05-03T03:31:36.406Z',
        'hrvRmssd', 54.8,
        'respiratoryRate', 13.4,
        'skinTemperatureC', 33.5,
        'spo2', 93.5,
        'spo2Min', 90,
        'steps', 11345,
        'exerciseMins', 28
      )) as day_value
      union all select '2026-04-16'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
        'source', 'Samsung Health',
        'updatedAt', '2026-05-03T03:31:36.406Z',
        'hrvRmssd', 44.4,
        'respiratoryRate', 12.4,
        'skinTemperatureC', 34.6,
        'spo2', 94.9,
        'spo2Min', 94,
        'steps', 6456,
        'exerciseMins', 24
      )) as day_value
      union all select '2026-04-17'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
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
      )) as day_value
      union all select '2026-04-18'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
        'source', 'Samsung Health',
        'updatedAt', '2026-05-03T03:31:36.406Z',
        'hrvRmssd', 100.6,
        'respiratoryRate', 13.1,
        'skinTemperatureC', 34.8,
        'spo2', 93.3,
        'spo2Min', 89,
        'steps', 9532,
        'exerciseMins', 51
      )) as day_value
      union all select '2026-04-19'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
        'source', 'Samsung Health',
        'updatedAt', '2026-05-03T03:31:36.406Z',
        'hrvRmssd', 59.9,
        'respiratoryRate', 13.3,
        'skinTemperatureC', 33.6,
        'spo2', 93.8,
        'spo2Min', 80,
        'steps', 9178
      )) as day_value
      union all select '2026-04-20'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
        'source', 'Samsung Health',
        'updatedAt', '2026-05-03T03:31:36.406Z',
        'hrvRmssd', 60.6,
        'respiratoryRate', 13.1,
        'skinTemperatureC', 35.5,
        'spo2', 92.9,
        'spo2Min', 70,
        'steps', 12449,
        'exerciseMins', 55
      )) as day_value
      union all select '2026-04-21'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
        'source', 'Samsung Health',
        'updatedAt', '2026-05-03T03:31:36.406Z',
        'hrvRmssd', 68.8,
        'respiratoryRate', 12.6,
        'skinTemperatureC', 34.4,
        'spo2', 94.4,
        'spo2Min', 89,
        'steps', 10236,
        'exerciseMins', 59
      )) as day_value
      union all select '2026-04-22'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
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
      )) as day_value
      union all select '2026-04-23'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
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
      )) as day_value
      union all select '2026-04-24'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
        'source', 'Samsung Health',
        'updatedAt', '2026-05-03T03:31:36.406Z',
        'hrvRmssd', 47.5,
        'respiratoryRate', 13.5,
        'skinTemperatureC', 34,
        'spo2', 95.2,
        'spo2Min', 92,
        'steps', 12511,
        'exerciseMins', 16
      )) as day_value
      union all select '2026-04-25'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
        'source', 'Samsung Health',
        'updatedAt', '2026-05-03T03:31:36.406Z',
        'hrvRmssd', 49.1,
        'respiratoryRate', 13.7,
        'skinTemperatureC', 35.3,
        'spo2', 94.9,
        'spo2Min', 94,
        'steps', 4151
      )) as day_value
      union all select '2026-04-26'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
        'source', 'Samsung Health',
        'updatedAt', '2026-05-03T03:31:36.406Z',
        'hrvRmssd', 54.9,
        'respiratoryRate', 13.1,
        'skinTemperatureC', 33.8,
        'spo2', 95.1,
        'spo2Min', 91,
        'steps', 13804,
        'exerciseMins', 44
      )) as day_value
      union all select '2026-04-27'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
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
      )) as day_value
      union all select '2026-04-28'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
        'source', 'Samsung Health',
        'updatedAt', '2026-05-03T03:31:36.406Z',
        'hrvRmssd', 70.9,
        'respiratoryRate', 13.1,
        'skinTemperatureC', 34,
        'spo2', 94.8,
        'spo2Min', 90,
        'steps', 10005,
        'exerciseMins', 39
      )) as day_value
      union all select '2026-04-29'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
        'source', 'Samsung Health',
        'updatedAt', '2026-05-03T03:31:36.406Z',
        'hrvRmssd', 61.3,
        'respiratoryRate', 12.8,
        'skinTemperatureC', 34.5,
        'spo2', 94.8,
        'spo2Min', 92,
        'steps', 13481,
        'exerciseMins', 57
      )) as day_value
      union all select '2026-04-30'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
        'source', 'Samsung Health',
        'updatedAt', '2026-05-03T03:31:36.406Z',
        'hrvRmssd', 62.9,
        'respiratoryRate', 12.2,
        'skinTemperatureC', 34.7,
        'spo2', 94.7,
        'spo2Min', 90,
        'steps', 7091
      )) as day_value
      union all select '2026-05-01'::text as date_key,
      jsonb_strip_nulls(jsonb_build_object(
        'source', 'Samsung Health',
        'updatedAt', '2026-05-03T03:31:36.406Z',
        'hrvRmssd', 48,
        'respiratoryRate', 13.3,
        'skinTemperatureC', 33.9,
        'spo2', 94.7,
        'spo2Min', 91,
        'steps', 8100
      )) as day_value
) days;

-- Finance tables.
create table if not exists finance_transactions (
  id text primary key,
  user_id uuid not null,
  type text not null check (type in ('income', 'expense')),
  merchant text not null,
  amount numeric not null default 0,
  currency text not null default 'KRW',
  amount_krw numeric not null default 0,
  category text not null default 'Other',
  date date not null,
  note text,
  source text not null default 'manual',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists finance_transactions_user_idx on finance_transactions (user_id);
create index if not exists finance_transactions_date_idx on finance_transactions (date desc);

create table if not exists finance_budgets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  month_key text not null check (month_key ~ '^[0-9]{4}-[0-9]{2}$'),
  income numeric not null default 0,
  categories jsonb not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, month_key)
);

create table if not exists finance_recurring_charges (
  id text primary key,
  user_id uuid not null,
  name text not null,
  amount numeric not null default 0,
  category text not null,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists finance_savings_goals (
  id text primary key,
  user_id uuid not null,
  name text not null,
  target numeric not null default 0,
  current numeric not null default 0,
  due_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists finance_budgets_user_idx on finance_budgets (user_id);
create index if not exists finance_budgets_month_idx on finance_budgets (month_key);
create index if not exists finance_recurring_user_idx on finance_recurring_charges (user_id);
create index if not exists finance_savings_user_idx on finance_savings_goals (user_id);

create or replace function set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists finance_transactions_updated_at on finance_transactions;
create trigger finance_transactions_updated_at before update on finance_transactions for each row execute function set_updated_at();
drop trigger if exists finance_budgets_updated_at on finance_budgets;
create trigger finance_budgets_updated_at before update on finance_budgets for each row execute function set_updated_at();
drop trigger if exists finance_recurring_updated_at on finance_recurring_charges;
create trigger finance_recurring_updated_at before update on finance_recurring_charges for each row execute function set_updated_at();
drop trigger if exists finance_savings_updated_at on finance_savings_goals;
create trigger finance_savings_updated_at before update on finance_savings_goals for each row execute function set_updated_at();

alter table finance_transactions enable row level security;
alter table finance_budgets enable row level security;
alter table finance_recurring_charges enable row level security;
alter table finance_savings_goals enable row level security;

drop policy if exists finance_transactions_own_rows on finance_transactions;
create policy finance_transactions_own_rows on finance_transactions for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists finance_budgets_own_rows on finance_budgets;
create policy finance_budgets_own_rows on finance_budgets for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists finance_recurring_own_rows on finance_recurring_charges;
create policy finance_recurring_own_rows on finance_recurring_charges for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists finance_savings_own_rows on finance_savings_goals;
create policy finance_savings_own_rows on finance_savings_goals for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Goals schema.
do $$ begin
  create type life_area as enum ('health', 'work', 'family', 'personal');
exception when duplicate_object then null; end $$;
do $$ begin
  create type goal_status as enum ('active', 'completed', 'paused', 'archived');
exception when duplicate_object then null; end $$;
do $$ begin
  create type metric_type as enum ('Number', 'Percentage', 'Duration', 'Frequency', 'Currency');
exception when duplicate_object then null; end $$;
do $$ begin
  create type tactic_freq as enum ('daily', 'weekly', 'custom', 'xperweek', 'onetime');
exception when duplicate_object then null; end $$;
alter type tactic_freq add value if not exists 'xperweek';

create table if not exists visions (
  id uuid primary key default gen_random_uuid(),
  area life_area not null unique,
  content text not null default '',
  updated_at timestamptz not null default now()
);

insert into visions (area, content) values ('health', ''), ('work', ''), ('family', ''), ('personal', '') on conflict (area) do nothing;

create table if not exists goals (
  id uuid primary key default gen_random_uuid(),
  local_id text unique,
  title text not null,
  area life_area not null,
  why text,
  status goal_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists goal_metrics (
  id uuid primary key default gen_random_uuid(),
  local_id text unique,
  goal_id uuid not null references goals (id) on delete cascade,
  name text not null,
  type metric_type not null default 'Number',
  target text,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists metric_logs (
  id uuid primary key default gen_random_uuid(),
  metric_id uuid not null references goal_metrics (id) on delete cascade,
  goal_id uuid not null references goals (id) on delete cascade,
  log_date date not null,
  value numeric not null,
  note text,
  created_at timestamptz not null default now(),
  unique (metric_id, log_date)
);

create table if not exists sprints (
  id uuid primary key default gen_random_uuid(),
  local_id text unique,
  goal_id uuid not null references goals (id) on delete cascade,
  name text not null,
  outcome text,
  start_date date,
  end_date date,
  week_checks jsonb not null default '{}',
  reflections jsonb not null default '{}',
  retro jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table sprints add column if not exists retro jsonb;

create table if not exists sprint_phases (
  id uuid primary key default gen_random_uuid(),
  sprint_id uuid not null references sprints (id) on delete cascade,
  phase_index int not null check (phase_index between 0 and 2),
  name text not null,
  description text,
  unique (sprint_id, phase_index)
);

create table if not exists sprint_tactics (
  id uuid primary key default gen_random_uuid(),
  local_id text unique,
  phase_id uuid not null references sprint_phases (id) on delete cascade,
  sprint_id uuid not null references sprints (id) on delete cascade,
  text text not null,
  freq tactic_freq not null default 'weekly',
  days int[] default '{}',
  times_per_week int,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

create index if not exists goals_area_idx on goals (area);
create index if not exists goals_status_idx on goals (status);
create index if not exists goal_metrics_goal_idx on goal_metrics (goal_id);
create index if not exists metric_logs_metric_idx on metric_logs (metric_id);
create index if not exists metric_logs_goal_idx on metric_logs (goal_id);
create index if not exists metric_logs_date_idx on metric_logs (log_date);
create index if not exists sprints_goal_idx on sprints (goal_id);
create index if not exists sprints_start_date_idx on sprints (start_date);
create index if not exists sprints_end_date_idx on sprints (end_date);
create index if not exists sprint_phases_sprint_idx on sprint_phases (sprint_id);
create index if not exists sprint_tactics_phase_idx on sprint_tactics (phase_id);
create index if not exists sprint_tactics_sprint_idx on sprint_tactics (sprint_id);

drop trigger if exists goals_updated_at on goals;
create trigger goals_updated_at before update on goals for each row execute function set_updated_at();
drop trigger if exists sprints_updated_at on sprints;
create trigger sprints_updated_at before update on sprints for each row execute function set_updated_at();
drop trigger if exists visions_updated_at on visions;
create trigger visions_updated_at before update on visions for each row execute function set_updated_at();

grant select, insert, update, delete on visions to authenticated;
grant select, insert, update, delete on goals to authenticated;
grant select, insert, update, delete on goal_metrics to authenticated;
grant select, insert, update, delete on metric_logs to authenticated;
grant select, insert, update, delete on sprints to authenticated;
grant select, insert, update, delete on sprint_phases to authenticated;
grant select, insert, update, delete on sprint_tactics to authenticated;

alter table visions enable row level security;
alter table goals enable row level security;
alter table goal_metrics enable row level security;
alter table metric_logs enable row level security;
alter table sprints enable row level security;
alter table sprint_phases enable row level security;
alter table sprint_tactics enable row level security;

drop policy if exists visions_authenticated_access on visions;
create policy visions_authenticated_access on visions for all to authenticated using (true) with check (true);
drop policy if exists goals_authenticated_access on goals;
create policy goals_authenticated_access on goals for all to authenticated using (true) with check (true);
drop policy if exists goal_metrics_authenticated_access on goal_metrics;
create policy goal_metrics_authenticated_access on goal_metrics for all to authenticated using (true) with check (true);
drop policy if exists metric_logs_authenticated_access on metric_logs;
create policy metric_logs_authenticated_access on metric_logs for all to authenticated using (true) with check (true);
drop policy if exists sprints_authenticated_access on sprints;
create policy sprints_authenticated_access on sprints for all to authenticated using (true) with check (true);
drop policy if exists sprint_phases_authenticated_access on sprint_phases;
create policy sprint_phases_authenticated_access on sprint_phases for all to authenticated using (true) with check (true);
drop policy if exists sprint_tactics_authenticated_access on sprint_tactics;
create policy sprint_tactics_authenticated_access on sprint_tactics for all to authenticated using (true) with check (true);

select 'setup complete' as status;
