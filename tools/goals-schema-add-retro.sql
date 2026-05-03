-- ============================================================
-- THE EDGEx Goals Schema Patch: Sprint Retrospectives
-- Run this if completed-cycle retrospectives disappear after reload.
-- ============================================================

alter table sprints add column if not exists retro jsonb;

select 'goals sprint retro storage enabled' as status;
