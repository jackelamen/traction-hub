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

-- Samsung Health seed intentionally omitted here.
-- After setup succeeds, use tools/insert-daily-signals-v2-compact.sql or the app script to add clean v2 data.

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
  create type tactic_freq as enum ('daily', 'weekly', 'custom', 'onetime');
exception when duplicate_object then null; end $$;

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
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

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

select 'setup complete' as status;
