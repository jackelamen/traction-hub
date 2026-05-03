-- ============================================================
-- THE EDGEx Goals Schema - Part 01: Core
-- Run first.
-- Creates shared helpers, enum types, visions, and goals.
-- ============================================================

create extension if not exists pgcrypto;

create or replace function set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

do $$ begin
  create type life_area as enum ('health', 'work', 'family', 'personal');
exception when duplicate_object then null; end $$;

do $$ begin
  create type goal_status as enum ('active', 'completed', 'paused', 'archived');
exception when duplicate_object then null; end $$;

create table if not exists visions (
  id uuid primary key default gen_random_uuid(),
  area life_area not null unique,
  content text not null default '',
  updated_at timestamptz not null default now()
);

insert into visions (area, content)
values ('health', ''), ('work', ''), ('family', ''), ('personal', '')
on conflict (area) do nothing;

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

create index if not exists goals_area_idx on goals (area);
create index if not exists goals_status_idx on goals (status);

drop trigger if exists visions_updated_at on visions;
create trigger visions_updated_at
  before update on visions
  for each row execute function set_updated_at();

drop trigger if exists goals_updated_at on goals;
create trigger goals_updated_at
  before update on goals
  for each row execute function set_updated_at();

select 'goals schema part 01 complete' as status;
