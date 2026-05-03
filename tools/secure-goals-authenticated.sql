-- ============================================================
-- THE EDGEx Goals Authenticated-Only Access Patch
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

      execute format('grant select, insert, update, delete on public.%I to authenticated', tbl);
      execute format('alter table public.%I enable row level security', tbl);
      execute format('drop policy if exists %I on public.%I', policy_name, tbl);
      execute format(
        'create policy %I on public.%I for all to authenticated using (true) with check (true)',
        policy_name,
        tbl
      );

      raise notice 'Protected % for authenticated access.', tbl;
    end if;
  end loop;
end $$;
