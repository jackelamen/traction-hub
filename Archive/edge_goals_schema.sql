-- ============================================================
--  THE EDGE Goals — Supabase Schema
--  Run this in the Supabase SQL Editor (Project > SQL Editor)
--  All tables are single-user for now (no auth.users FK required)
--  but the user_id column is stubbed in for when you add auth.
-- ============================================================


-- ────────────────────────────────────────────────────────────
--  ENUM: life area
--  Matches the AREAS constant in goals.html
-- ────────────────────────────────────────────────────────────
create type life_area as enum ('health', 'work', 'family', 'personal');


-- ────────────────────────────────────────────────────────────
--  ENUM: goal status
-- ────────────────────────────────────────────────────────────
create type goal_status as enum ('active', 'complete', 'paused', 'archived');


-- ────────────────────────────────────────────────────────────
--  ENUM: metric type
--  Matches the dropdown options in the goal form
-- ────────────────────────────────────────────────────────────
create type metric_type as enum (
  'Number', 'Percentage', 'Duration', 'Frequency', 'Currency'
);


-- ────────────────────────────────────────────────────────────
--  ENUM: tactic frequency
--  Matches freq values used in weekChecks logic
-- ────────────────────────────────────────────────────────────
create type tactic_freq as enum ('daily', 'weekly', 'custom', 'onetime');


-- ============================================================
--  TABLE: visions
--  One row per life area — stores the vision statement text.
--  Equivalent to gs2_db.visions[areaId] in localStorage.
-- ============================================================
create table if not exists visions (
  id          uuid primary key default gen_random_uuid(),
  area        life_area not null unique,   -- one row per area
  content     text not null default '',    -- the vision statement
  updated_at  timestamptz not null default now()
);

-- Seed the four areas so they always exist
insert into visions (area, content) values
  ('health',   ''),
  ('work',     ''),
  ('family',   ''),
  ('personal', '')
on conflict (area) do nothing;


-- ============================================================
--  TABLE: goals
--  Equivalent to gs2_db.goals[] in localStorage.
-- ============================================================
create table if not exists goals (
  id          uuid primary key default gen_random_uuid(),
  -- local_id keeps the original localStorage id during migration
  -- so sprints can reference goals by their old string key.
  -- Remove this column after migration is verified.
  local_id    text unique,

  title       text not null,
  area        life_area not null,
  why         text,
  status      goal_status not null default 'active',

  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists goals_area_idx    on goals (area);
create index if not exists goals_status_idx  on goals (status);


-- ============================================================
--  TABLE: goal_metrics
--  Each goal can have 0-n measurable targets.
--  Equivalent to gs2_db.goals[i].metrics[] in localStorage.
-- ============================================================
create table if not exists goal_metrics (
  id          uuid primary key default gen_random_uuid(),
  local_id    text,                        -- original metric id (migration aid)
  goal_id     uuid not null references goals (id) on delete cascade,

  name        text not null,
  type        metric_type not null default 'Number',
  target      text,                        -- stored as text to match original (e.g. "65bpm")

  sort_order  int not null default 0,
  created_at  timestamptz not null default now()
);

create index if not exists goal_metrics_goal_idx on goal_metrics (goal_id);


-- ============================================================
--  TABLE: metric_logs
--  Progress entries logged against a specific metric.
--  Equivalent to gs2_db.goals[i].metricLogs[metricId][] in localStorage.
--  One row per (metric, date) — duplicate dates replace each other (upsert).
-- ============================================================
create table if not exists metric_logs (
  id          uuid primary key default gen_random_uuid(),
  metric_id   uuid not null references goal_metrics (id) on delete cascade,
  goal_id     uuid not null references goals (id) on delete cascade, -- denormalized for query speed

  log_date    date not null,
  value       numeric not null,
  note        text,

  created_at  timestamptz not null default now(),

  -- matches original behavior: only one entry per metric per date
  unique (metric_id, log_date)
);

create index if not exists metric_logs_metric_idx on metric_logs (metric_id);
create index if not exists metric_logs_goal_idx   on metric_logs (goal_id);
create index if not exists metric_logs_date_idx   on metric_logs (log_date);


-- ============================================================
--  TABLE: sprints  (Focus Cycles)
--  Equivalent to gs2_db.sprints[] in localStorage.
--  12-week execution blocks tied to a goal.
-- ============================================================
create table if not exists sprints (
  id          uuid primary key default gen_random_uuid(),
  local_id    text unique,                 -- original localStorage id (migration aid)
  goal_id     uuid not null references goals (id) on delete cascade,

  name        text not null,
  outcome     text,                        -- desired end-state outcome statement
  start_date  date,
  end_date    date,

  -- week_checks: { "1": { "tacticId_dayIdx": true, ... }, "2": { ... }, ... }
  -- Stored as JSONB — this is deeply nested and changes often.
  -- Normalizing it into rows would require a schema change every time
  -- a tactic is renamed; JSONB is the right call here.
  week_checks jsonb not null default '{}',

  -- reflections: { "1": { well, obstacles, adjust, next }, ... }
  -- One entry per week number. Also naturally JSONB.
  reflections jsonb not null default '{}',

  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists sprints_goal_idx       on sprints (goal_id);
create index if not exists sprints_start_date_idx on sprints (start_date);
create index if not exists sprints_end_date_idx   on sprints (end_date);


-- ============================================================
--  TABLE: sprint_phases
--  Each sprint has exactly 3 phases (Foundation / Build / Peak).
--  Equivalent to gs2_db.sprints[i].phases[] in localStorage.
-- ============================================================
create table if not exists sprint_phases (
  id          uuid primary key default gen_random_uuid(),
  sprint_id   uuid not null references sprints (id) on delete cascade,

  phase_index int not null check (phase_index between 0 and 2),
  -- 0 = Foundation (Weeks 1-4)
  -- 1 = Build      (Weeks 5-8)
  -- 2 = Peak       (Weeks 9-12)

  name        text not null,              -- e.g. "Foundation", "Build", "Peak"
  description text,

  unique (sprint_id, phase_index)         -- exactly one row per phase per sprint
);

create index if not exists sprint_phases_sprint_idx on sprint_phases (sprint_id);


-- ============================================================
--  TABLE: sprint_tactics
--  Actions within a phase. Equivalent to phases[i].tactics[] in localStorage.
--  These are the checkable items that appear on the Today view.
-- ============================================================
create table if not exists sprint_tactics (
  id          uuid primary key default gen_random_uuid(),
  local_id    text,                       -- original tactic id — needed to map week_checks JSONB keys
  phase_id    uuid not null references sprint_phases (id) on delete cascade,
  sprint_id   uuid not null references sprints (id) on delete cascade, -- denormalized for easier querying

  text        text not null,              -- the action description
  freq        tactic_freq not null default 'weekly',
  days        int[] default '{}',         -- Mon-based day indices (0=Mon...6=Sun), used when freq='custom'

  sort_order  int not null default 0,
  created_at  timestamptz not null default now()
);

create index if not exists sprint_tactics_phase_idx  on sprint_tactics (phase_id);
create index if not exists sprint_tactics_sprint_idx on sprint_tactics (sprint_id);


-- ============================================================
--  AUTO-UPDATE updated_at TRIGGER
--  Keeps updated_at current on goals and sprints automatically.
-- ============================================================
create or replace function set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger goals_updated_at
  before update on goals
  for each row execute function set_updated_at();

create trigger sprints_updated_at
  before update on sprints
  for each row execute function set_updated_at();

create trigger visions_updated_at
  before update on visions
  for each row execute function set_updated_at();


-- ============================================================
--  MIGRATION NOTES (run these steps after applying schema)
-- ============================================================
--
--  Step 1: Export your localStorage data from the browser console:
--    copy(localStorage.getItem('gs2_db'))
--    Paste into a file called gs2_db.json
--
--  Step 2: Export vision board images separately:
--    copy(localStorage.getItem('gs2_vb'))
--    Upload images to Supabase Storage (bucket: 'vision-board')
--    instead of storing base64 in the database.
--
--  Step 3: Run the migration script (edge_goals_migrate.js — to be built)
--    which reads gs2_db.json and inserts rows into the tables above,
--    using local_id columns to preserve original IDs for reference.
--
--  Step 4: Once migration is verified, drop the local_id columns:
--    alter table goals         drop column local_id;
--    alter table goal_metrics  drop column local_id;
--    alter table sprints       drop column local_id;
--    alter table sprint_tactics drop column local_id;
--
-- ============================================================
