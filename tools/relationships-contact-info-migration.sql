-- Adds contact information fields to the Relationships people table.
-- Safe to run more than once.

alter table if exists public.rel_people
  add column if not exists phone text,
  add column if not exists email text,
  add column if not exists birthday date,
  add column if not exists preferred_contact text,
  add column if not exists social text;
