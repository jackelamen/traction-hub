-- ============================================================
-- EDGEx Tenant Isolation Migration
-- ============================================================
-- Purpose:
--   Preserve the existing single-user EDGEx data, then add per-user
--   isolation for the shared platform and the /dezignetheory system.
--
-- Safety notes:
--   - Existing goals/learning/relationships/review rows are backfilled
--     to Jack's current Supabase auth UUID before RLS is tightened.
--   - Existing traction_data rows with user_id = 'jack_traction_hub_v1'
--     remain in place for the root hub.
--   - New traction_data rows may use auth.uid()::text, which is what
--     the /dezignetheory pages now send.
--
-- Run this after deploying the HTML changes in this branch.
-- ============================================================

begin;

-- Jack's existing Supabase auth UUID, already used by the finance module.
-- If this ever changes, update this value before running the migration.

-- ------------------------------------------------------------
-- traction_data: authenticated owner policy, while preserving
-- Jack's legacy text id used by the original root hub.
-- ------------------------------------------------------------

revoke all on public.traction_data from anon;
grant select, insert, update, delete on public.traction_data to authenticated;
revoke execute on function public.upsert_traction_data(jsonb) from anon;
grant execute on function public.upsert_traction_data(jsonb) to authenticated;

create or replace function public.upsert_traction_data(rows jsonb)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  caller uuid := auth.uid();
  jack uuid := 'fa3f910d-64f8-43cf-94c1-61d645ed9414'::uuid;
begin
  if caller is null then
    raise exception 'upsert_traction_data requires an authenticated user';
  end if;

  if exists (
    select 1
    from jsonb_array_elements(rows) as item
    where not (
      item->>'user_id' = caller::text
      or (caller = jack and item->>'user_id' = 'jack_traction_hub_v1')
    )
  ) then
    raise exception 'upsert_traction_data user_id does not match authenticated user';
  end if;

  insert into public.traction_data (user_id, key, value, updated_at)
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

alter table public.traction_data enable row level security;
drop policy if exists traction_data_single_user on public.traction_data;
drop policy if exists traction_data_owner_rows on public.traction_data;
create policy traction_data_owner_rows on public.traction_data
  for all to authenticated
  using (
    user_id = auth.uid()::text
    or (
      auth.uid() = 'fa3f910d-64f8-43cf-94c1-61d645ed9414'::uuid
      and user_id = 'jack_traction_hub_v1'
    )
  )
  with check (
    user_id = auth.uid()::text
    or (
      auth.uid() = 'fa3f910d-64f8-43cf-94c1-61d645ed9414'::uuid
      and user_id = 'jack_traction_hub_v1'
    )
  );

-- ------------------------------------------------------------
-- Goals schema: add user_id, backfill current rows, then isolate.
-- ------------------------------------------------------------

alter table if exists public.visions add column if not exists user_id uuid;
alter table if exists public.goals add column if not exists user_id uuid;
alter table if exists public.goal_metrics add column if not exists user_id uuid;
alter table if exists public.metric_logs add column if not exists user_id uuid;
alter table if exists public.sprints add column if not exists user_id uuid;
alter table if exists public.sprint_phases add column if not exists user_id uuid;
alter table if exists public.sprint_tactics add column if not exists user_id uuid;

update public.visions set user_id = 'fa3f910d-64f8-43cf-94c1-61d645ed9414'::uuid where user_id is null;
update public.goals set user_id = 'fa3f910d-64f8-43cf-94c1-61d645ed9414'::uuid where user_id is null;
update public.goal_metrics gm set user_id = g.user_id from public.goals g where gm.goal_id = g.id and gm.user_id is null;
update public.metric_logs ml set user_id = g.user_id from public.goals g where ml.goal_id = g.id and ml.user_id is null;
update public.sprints s set user_id = g.user_id from public.goals g where s.goal_id = g.id and s.user_id is null;
update public.sprint_phases ph set user_id = s.user_id from public.sprints s where ph.sprint_id = s.id and ph.user_id is null;
update public.sprint_tactics t set user_id = s.user_id from public.sprints s where t.sprint_id = s.id and t.user_id is null;

update public.goal_metrics set user_id = 'fa3f910d-64f8-43cf-94c1-61d645ed9414'::uuid where user_id is null;
update public.metric_logs set user_id = 'fa3f910d-64f8-43cf-94c1-61d645ed9414'::uuid where user_id is null;
update public.sprints set user_id = 'fa3f910d-64f8-43cf-94c1-61d645ed9414'::uuid where user_id is null;
update public.sprint_phases set user_id = 'fa3f910d-64f8-43cf-94c1-61d645ed9414'::uuid where user_id is null;
update public.sprint_tactics set user_id = 'fa3f910d-64f8-43cf-94c1-61d645ed9414'::uuid where user_id is null;

alter table if exists public.visions alter column user_id set not null;
alter table if exists public.goals alter column user_id set not null;
alter table if exists public.goal_metrics alter column user_id set not null;
alter table if exists public.metric_logs alter column user_id set not null;
alter table if exists public.sprints alter column user_id set not null;
alter table if exists public.sprint_phases alter column user_id set not null;
alter table if exists public.sprint_tactics alter column user_id set not null;

alter table if exists public.visions alter column user_id set default auth.uid();
alter table if exists public.goals alter column user_id set default auth.uid();
alter table if exists public.goal_metrics alter column user_id set default auth.uid();
alter table if exists public.metric_logs alter column user_id set default auth.uid();
alter table if exists public.sprints alter column user_id set default auth.uid();
alter table if exists public.sprint_phases alter column user_id set default auth.uid();
alter table if exists public.sprint_tactics alter column user_id set default auth.uid();

alter table if exists public.visions drop constraint if exists visions_area_key;
alter table if exists public.goals drop constraint if exists goals_local_id_key;
alter table if exists public.goal_metrics drop constraint if exists goal_metrics_local_id_key;
alter table if exists public.metric_logs drop constraint if exists metric_logs_metric_id_log_date_key;
alter table if exists public.sprints drop constraint if exists sprints_local_id_key;
alter table if exists public.sprint_phases drop constraint if exists sprint_phases_sprint_id_phase_index_key;
alter table if exists public.sprint_tactics drop constraint if exists sprint_tactics_local_id_key;

create unique index if not exists visions_user_area_key on public.visions (user_id, area);
create unique index if not exists goals_user_local_id_key on public.goals (user_id, local_id);
create unique index if not exists goal_metrics_user_local_id_key on public.goal_metrics (user_id, local_id);
create unique index if not exists metric_logs_user_metric_date_key on public.metric_logs (user_id, metric_id, log_date);
create unique index if not exists sprints_user_local_id_key on public.sprints (user_id, local_id);
create unique index if not exists sprint_phases_user_sprint_phase_key on public.sprint_phases (user_id, sprint_id, phase_index);
create unique index if not exists sprint_tactics_user_local_id_key on public.sprint_tactics (user_id, local_id);

grant select, insert, update, delete on public.visions to authenticated;
grant select, insert, update, delete on public.goals to authenticated;
grant select, insert, update, delete on public.goal_metrics to authenticated;
grant select, insert, update, delete on public.metric_logs to authenticated;
grant select, insert, update, delete on public.sprints to authenticated;
grant select, insert, update, delete on public.sprint_phases to authenticated;
grant select, insert, update, delete on public.sprint_tactics to authenticated;

alter table public.visions enable row level security;
alter table public.goals enable row level security;
alter table public.goal_metrics enable row level security;
alter table public.metric_logs enable row level security;
alter table public.sprints enable row level security;
alter table public.sprint_phases enable row level security;
alter table public.sprint_tactics enable row level security;

drop policy if exists visions_authenticated_access on public.visions;
drop policy if exists goals_authenticated_access on public.goals;
drop policy if exists goal_metrics_authenticated_access on public.goal_metrics;
drop policy if exists metric_logs_authenticated_access on public.metric_logs;
drop policy if exists sprints_authenticated_access on public.sprints;
drop policy if exists sprint_phases_authenticated_access on public.sprint_phases;
drop policy if exists sprint_tactics_authenticated_access on public.sprint_tactics;

drop policy if exists visions_owner_rows on public.visions;
create policy visions_owner_rows on public.visions for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists goals_owner_rows on public.goals;
create policy goals_owner_rows on public.goals for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists goal_metrics_owner_rows on public.goal_metrics;
create policy goal_metrics_owner_rows on public.goal_metrics for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists metric_logs_owner_rows on public.metric_logs;
create policy metric_logs_owner_rows on public.metric_logs for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists sprints_owner_rows on public.sprints;
create policy sprints_owner_rows on public.sprints for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists sprint_phases_owner_rows on public.sprint_phases;
create policy sprint_phases_owner_rows on public.sprint_phases for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists sprint_tactics_owner_rows on public.sprint_tactics;
create policy sprint_tactics_owner_rows on public.sprint_tactics for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ------------------------------------------------------------
-- Newer modules: add owner columns if those tables exist.
-- ------------------------------------------------------------

do $$
declare
  tbl text;
begin
  foreach tbl in array array[
    'learn_items',
    'learn_sessions',
    'learn_insights',
    'rel_people',
    'rel_interactions',
    'weekly_reviews'
  ]
  loop
    if to_regclass('public.' || tbl) is not null then
      execute format('alter table public.%I add column if not exists user_id uuid', tbl);
      execute format(
        'update public.%I set user_id = %L::uuid where user_id is null',
        tbl,
        'fa3f910d-64f8-43cf-94c1-61d645ed9414'
      );
      execute format('alter table public.%I alter column user_id set not null', tbl);
      execute format('alter table public.%I alter column user_id set default auth.uid()', tbl);
      execute format('grant select, insert, update, delete on public.%I to authenticated', tbl);
      execute format('revoke all on public.%I from anon', tbl);
      execute format('alter table public.%I enable row level security', tbl);
      execute format('drop policy if exists %I on public.%I', tbl || '_authenticated_access', tbl);
      execute format('drop policy if exists %I on public.%I', tbl || '_owner_rows', tbl);
      execute format(
        'create policy %I on public.%I for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id)',
        tbl || '_owner_rows',
        tbl
      );
    end if;
  end loop;
end $$;

do $$
begin
  if to_regclass('public.weekly_reviews') is not null then
    alter table public.weekly_reviews drop constraint if exists weekly_reviews_week_id_key;
    create unique index if not exists weekly_reviews_user_week_key on public.weekly_reviews (user_id, week_id);
  end if;
end $$;

commit;
