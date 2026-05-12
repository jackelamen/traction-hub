-- Weekly Review Supabase table.
-- Run this in Supabase SQL Editor if you want dedicated weekly review rows.
-- The app also falls back to traction_data when this table is not present.

create extension if not exists pgcrypto;

create table if not exists public.weekly_reviews (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid(),
  week_id date not null,
  score integer check (score between 1 and 10),
  wins text,
  challenges text,
  learning text,
  gratitude text,
  energy text,
  other text,
  module_notes text,
  theme_word text,
  priority_1 text,
  priority_2 text,
  priority_3 text,
  protect text,
  let_go text,
  ai_insight text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists weekly_reviews_user_week_key
  on public.weekly_reviews (user_id, week_id);

create or replace function public.touch_weekly_review_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists weekly_reviews_touch_updated_at on public.weekly_reviews;
create trigger weekly_reviews_touch_updated_at
before update on public.weekly_reviews
for each row execute function public.touch_weekly_review_updated_at();

grant select, insert, update, delete on public.weekly_reviews to authenticated;
revoke all on public.weekly_reviews from anon;

alter table public.weekly_reviews enable row level security;

drop policy if exists weekly_reviews_owner_rows on public.weekly_reviews;
create policy weekly_reviews_owner_rows on public.weekly_reviews
  for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
