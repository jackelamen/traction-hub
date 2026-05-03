-- ============================================================
-- THE EDGEx Goals Schema - Part 02: Metrics
-- Run after part 01.
-- Creates goal metrics and metric logs.
-- ============================================================

do $$ begin
  create type metric_type as enum ('Number', 'Percentage', 'Duration', 'Frequency', 'Currency');
exception when duplicate_object then null; end $$;

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

create index if not exists goal_metrics_goal_idx on goal_metrics (goal_id);
create index if not exists metric_logs_metric_idx on metric_logs (metric_id);
create index if not exists metric_logs_goal_idx on metric_logs (goal_id);
create index if not exists metric_logs_date_idx on metric_logs (log_date);

select 'goals schema part 02 complete' as status;
