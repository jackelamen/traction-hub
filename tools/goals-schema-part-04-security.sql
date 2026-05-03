-- ============================================================
-- THE EDGEx Goals Schema - Part 04: Security
-- Run after parts 01, 02, and 03.
-- Enables authenticated-only access for the current single-user Goals schema.
-- ============================================================

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
create policy visions_authenticated_access on visions
  for all to authenticated using (true) with check (true);

drop policy if exists goals_authenticated_access on goals;
create policy goals_authenticated_access on goals
  for all to authenticated using (true) with check (true);

drop policy if exists goal_metrics_authenticated_access on goal_metrics;
create policy goal_metrics_authenticated_access on goal_metrics
  for all to authenticated using (true) with check (true);

drop policy if exists metric_logs_authenticated_access on metric_logs;
create policy metric_logs_authenticated_access on metric_logs
  for all to authenticated using (true) with check (true);

drop policy if exists sprints_authenticated_access on sprints;
create policy sprints_authenticated_access on sprints
  for all to authenticated using (true) with check (true);

drop policy if exists sprint_phases_authenticated_access on sprint_phases;
create policy sprint_phases_authenticated_access on sprint_phases
  for all to authenticated using (true) with check (true);

drop policy if exists sprint_tactics_authenticated_access on sprint_tactics;
create policy sprint_tactics_authenticated_access on sprint_tactics
  for all to authenticated using (true) with check (true);

select 'goals schema part 04 complete' as status;
