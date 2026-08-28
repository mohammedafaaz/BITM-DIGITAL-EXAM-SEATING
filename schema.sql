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
-- This app has no real user accounts — the admin dashboard is gated only by
-- a client-side password check in the page itself, exactly like the original
-- Claude-artifact version. Because of that, the same public anon key that
-- lets the app read/write data would also let anyone with the key bypass the
-- admin screen and write directly. That is a limitation of the app's design,
-- not something this schema can close — treat the admin password as a soft
-- deterrent for a low-stakes internal tool, not real access control. If you
-- need real protection, the fix is a server-side auth layer, which is a
-- bigger change than this deployment covers.
alter table kv_store enable row level security;

drop policy if exists "public full access" on kv_store;
create policy "public full access" on kv_store
  for all
  using (true)
  with check (true);
