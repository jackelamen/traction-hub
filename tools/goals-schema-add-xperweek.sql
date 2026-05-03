-- ============================================================
-- THE EDGEx Goals Schema Patch: X-per-week Tactics
-- Run this if Goals focus-cycle tactics fail when using "X times/week".
-- ============================================================

alter type tactic_freq add value if not exists 'xperweek';

select 'goals xperweek tactic frequency enabled' as status;
