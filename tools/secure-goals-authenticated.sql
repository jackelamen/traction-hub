-- ============================================================
-- THE EDGEx Goals Owner-Only Access Patch
-- Run this in Supabase SQL Editor for an already-created project.
--
-- Safe to run even if the Goals schema has not been created yet.
-- Missing tables are skipped with a NOTICE.
-- ============================================================

do $$
declare
  tbl text;
  policy_name text;
  protected_tables text[] := array[
    'visions',
    'goals',
    'goal_metrics',
    'metric_logs',
    'sprints',
    'sprint_phases',
    'sprint_tactics'
  ];
begin
  foreach tbl in array protected_tables loop
    if to_regclass('public.' || tbl) is null then
      raise notice 'Skipping %. Table does not exist yet.', tbl;
    else
      policy_name := tbl || '_authenticated_access';

      execute format('alter table public.%I add column if not exists user_id uuid', tbl);
      execute format(
        'update public.%I set user_id = %L::uuid where user_id is null',
        tbl,
        'fa3f910d-64f8-43cf-94c1-61d645ed9414'
      );
      execute format('alter table public.%I alter column user_id set not null', tbl);
      execute format('alter table public.%I alter column user_id set default auth.uid()', tbl);
      execute format('grant select, insert, update, delete on public.%I to authenticated', tbl);
      execute format('alter table public.%I enable row level security', tbl);
      execute format('drop policy if exists %I on public.%I', policy_name, tbl);
      execute format(
        'create policy %I on public.%I for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id)',
        policy_name,
        tbl
      );

      raise notice 'Protected % for authenticated access.', tbl;
    end if;
  end loop;
end $$;
