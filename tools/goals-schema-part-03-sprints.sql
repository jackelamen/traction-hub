-- ============================================================
-- THE EDGEx Goals Schema - Part 03: Sprints
-- Run after parts 01 and 02.
-- Creates focus cycles, phases, and tactics.
-- ============================================================

do $$ begin
  create type tactic_freq as enum ('daily', 'weekly', 'custom', 'xperweek', 'onetime');
exception when duplicate_object then null; end $$;

alter type tactic_freq add value if not exists 'xperweek';

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

create index if not exists sprints_goal_idx on sprints (goal_id);
create index if not exists sprints_start_date_idx on sprints (start_date);
create index if not exists sprints_end_date_idx on sprints (end_date);
create index if not exists sprint_phases_sprint_idx on sprint_phases (sprint_id);
create index if not exists sprint_tactics_phase_idx on sprint_tactics (phase_id);
create index if not exists sprint_tactics_sprint_idx on sprint_tactics (sprint_id);

drop trigger if exists sprints_updated_at on sprints;
create trigger sprints_updated_at
  before update on sprints
  for each row execute function set_updated_at();

select 'goals schema part 03 complete' as status;
