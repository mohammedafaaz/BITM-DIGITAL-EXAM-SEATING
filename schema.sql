-- BITM Digital Seating Arrangement System — Supabase schema
-- Run this once in your Supabase project's SQL Editor before deploying.

create table if not exists kv_store (
  key text primary key,
  value text not null,
  updated_at timestamptz not null default now()
);

-- Keep updated_at fresh on every write (useful for debugging, not required by the app)
create or replace function kv_store_touch()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists kv_store_touch_trigger on kv_store;
create trigger kv_store_touch_trigger
  before update on kv_store
  for each row execute function kv_store_touch();

-- Row Level Security
-- The app stores a salted admin password hash in this table and verifies it
-- in the browser. Because the anon policy below is public, anyone with the
-- anon key could still bypass the page and write directly. This password is
-- therefore a browser-level deterrent, not real server-side access control.
-- Real protection requires Supabase Auth plus RLS policies for admin users.
alter table kv_store enable row level security;

drop policy if exists "public full access" on kv_store;
create policy "public full access" on kv_store
  for all
  using (true)
  with check (true);
