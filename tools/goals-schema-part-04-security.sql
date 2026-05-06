-- ============================================================
-- THE EDGEx Goals Schema - Part 04: Security
-- Run after parts 01, 02, and 03.
-- Enables authenticated owner-only access for the Goals schema.
-- Existing rows are assigned to Jack's Supabase auth UUID before RLS is tightened.
-- ============================================================

grant select, insert, update, delete on visions to authenticated;
grant select, insert, update, delete on goals to authenticated;
grant select, insert, update, delete on goal_metrics to authenticated;
grant select, insert, update, delete on metric_logs to authenticated;
grant select, insert, update, delete on sprints to authenticated;
grant select, insert, update, delete on sprint_phases to authenticated;
grant select, insert, update, delete on sprint_tactics to authenticated;

alter table visions add column if not exists user_id uuid;
alter table goals add column if not exists user_id uuid;
alter table goal_metrics add column if not exists user_id uuid;
alter table metric_logs add column if not exists user_id uuid;
alter table sprints add column if not exists user_id uuid;
alter table sprint_phases add column if not exists user_id uuid;
alter table sprint_tactics add column if not exists user_id uuid;

update visions set user_id = 'fa3f910d-64f8-43cf-94c1-61d645ed9414'::uuid where user_id is null;
update goals set user_id = 'fa3f910d-64f8-43cf-94c1-61d645ed9414'::uuid where user_id is null;
update goal_metrics gm set user_id = g.user_id from goals g where gm.goal_id = g.id and gm.user_id is null;
update metric_logs ml set user_id = g.user_id from goals g where ml.goal_id = g.id and ml.user_id is null;
update sprints s set user_id = g.user_id from goals g where s.goal_id = g.id and s.user_id is null;
update sprint_phases ph set user_id = s.user_id from sprints s where ph.sprint_id = s.id and ph.user_id is null;
update sprint_tactics t set user_id = s.user_id from sprints s where t.sprint_id = s.id and t.user_id is null;

update goal_metrics set user_id = 'fa3f910d-64f8-43cf-94c1-61d645ed9414'::uuid where user_id is null;
update metric_logs set user_id = 'fa3f910d-64f8-43cf-94c1-61d645ed9414'::uuid where user_id is null;
update sprints set user_id = 'fa3f910d-64f8-43cf-94c1-61d645ed9414'::uuid where user_id is null;
update sprint_phases set user_id = 'fa3f910d-64f8-43cf-94c1-61d645ed9414'::uuid where user_id is null;
update sprint_tactics set user_id = 'fa3f910d-64f8-43cf-94c1-61d645ed9414'::uuid where user_id is null;

alter table visions alter column user_id set not null;
alter table goals alter column user_id set not null;
alter table goal_metrics alter column user_id set not null;
alter table metric_logs alter column user_id set not null;
alter table sprints alter column user_id set not null;
alter table sprint_phases alter column user_id set not null;
alter table sprint_tactics alter column user_id set not null;

alter table visions alter column user_id set default auth.uid();
alter table goals alter column user_id set default auth.uid();
alter table goal_metrics alter column user_id set default auth.uid();
alter table metric_logs alter column user_id set default auth.uid();
alter table sprints alter column user_id set default auth.uid();
alter table sprint_phases alter column user_id set default auth.uid();
alter table sprint_tactics alter column user_id set default auth.uid();

alter table visions drop constraint if exists visions_area_key;
alter table goals drop constraint if exists goals_local_id_key;
alter table goal_metrics drop constraint if exists goal_metrics_local_id_key;
alter table metric_logs drop constraint if exists metric_logs_metric_id_log_date_key;
alter table sprints drop constraint if exists sprints_local_id_key;
alter table sprint_phases drop constraint if exists sprint_phases_sprint_id_phase_index_key;
alter table sprint_tactics drop constraint if exists sprint_tactics_local_id_key;

create unique index if not exists visions_user_area_key on visions (user_id, area);
create unique index if not exists goals_user_local_id_key on goals (user_id, local_id);
create unique index if not exists goal_metrics_user_local_id_key on goal_metrics (user_id, local_id);
create unique index if not exists metric_logs_user_metric_date_key on metric_logs (user_id, metric_id, log_date);
create unique index if not exists sprints_user_local_id_key on sprints (user_id, local_id);
create unique index if not exists sprint_phases_user_sprint_phase_key on sprint_phases (user_id, sprint_id, phase_index);
create unique index if not exists sprint_tactics_user_local_id_key on sprint_tactics (user_id, local_id);

alter table visions enable row level security;
alter table goals enable row level security;
alter table goal_metrics enable row level security;
alter table metric_logs enable row level security;
alter table sprints enable row level security;
alter table sprint_phases enable row level security;
alter table sprint_tactics enable row level security;

drop policy if exists visions_authenticated_access on visions;
create policy visions_authenticated_access on visions
  for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists goals_authenticated_access on goals;
create policy goals_authenticated_access on goals
  for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists goal_metrics_authenticated_access on goal_metrics;
create policy goal_metrics_authenticated_access on goal_metrics
  for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists metric_logs_authenticated_access on metric_logs;
create policy metric_logs_authenticated_access on metric_logs
  for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists sprints_authenticated_access on sprints;
create policy sprints_authenticated_access on sprints
  for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists sprint_phases_authenticated_access on sprint_phases;
create policy sprint_phases_authenticated_access on sprint_phases
  for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists sprint_tactics_authenticated_access on sprint_tactics;
create policy sprint_tactics_authenticated_access on sprint_tactics
  for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

select 'goals schema part 04 complete' as status;
