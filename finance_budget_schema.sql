-- ============================================================
--  THE EDGEx Finance — Budgeting Schema
--  Run this in Supabase SQL Editor after finance_transactions exists.
--  These tables are per authenticated user and back the Budget tab.
-- ============================================================

create table if not exists finance_budgets (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null,
  month_key   text not null check (month_key ~ '^[0-9]{4}-[0-9]{2}$'),
  income      numeric not null default 0,
  categories  jsonb not null default '{}',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (user_id, month_key)
);

create table if not exists finance_recurring_charges (
  id          text primary key,
  user_id     uuid not null,
  name        text not null,
  amount      numeric not null default 0,
  category    text not null,
  active      boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create table if not exists finance_savings_goals (
  id          text primary key,
  user_id     uuid not null,
  name        text not null,
  target      numeric not null default 0,
  current     numeric not null default 0,
  due_date    date,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists finance_budgets_user_idx on finance_budgets (user_id);
create index if not exists finance_budgets_month_idx on finance_budgets (month_key);
create index if not exists finance_recurring_user_idx on finance_recurring_charges (user_id);
create index if not exists finance_savings_user_idx on finance_savings_goals (user_id);

create or replace function set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists finance_budgets_updated_at on finance_budgets;
create trigger finance_budgets_updated_at
  before update on finance_budgets
  for each row execute function set_updated_at();

drop trigger if exists finance_recurring_updated_at on finance_recurring_charges;
create trigger finance_recurring_updated_at
  before update on finance_recurring_charges
  for each row execute function set_updated_at();

drop trigger if exists finance_savings_updated_at on finance_savings_goals;
create trigger finance_savings_updated_at
  before update on finance_savings_goals
  for each row execute function set_updated_at();

alter table finance_budgets enable row level security;
alter table finance_recurring_charges enable row level security;
alter table finance_savings_goals enable row level security;

drop policy if exists finance_budgets_own_rows on finance_budgets;
create policy finance_budgets_own_rows on finance_budgets
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists finance_recurring_own_rows on finance_recurring_charges;
create policy finance_recurring_own_rows on finance_recurring_charges
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists finance_savings_own_rows on finance_savings_goals;
create policy finance_savings_own_rows on finance_savings_goals
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
