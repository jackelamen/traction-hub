-- ============================================================
-- THE EDGEx Finance PIN Support
-- Run in Supabase SQL Editor before deploying finance-pin.
-- ============================================================

create table if not exists finance_pin_challenges (
  user_id uuid primary key,
  email text not null,
  pin_hash text not null,
  expires_at timestamptz not null,
  attempts int not null default 0,
  created_at timestamptz not null default now()
);

alter table finance_pin_challenges enable row level security;

-- Only the Edge Function should access this table through the service role key.
drop policy if exists finance_pin_no_client_access on finance_pin_challenges;
create policy finance_pin_no_client_access on finance_pin_challenges
  for all
  using (false)
  with check (false);
