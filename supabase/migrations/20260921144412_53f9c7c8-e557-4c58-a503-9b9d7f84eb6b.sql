
create type public.app_role as enum ('admin','admin_staff','user','user_staff');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  full_name text,
  manager_id uuid references public.profiles(id) on delete set null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
grant select, insert, update on public.profiles to authenticated;
grant all on public.profiles to service_role;
alter table public.profiles enable row level security;

create table public.user_roles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  role public.app_role not null,
  created_at timestamptz not null default now(),
  unique (user_id, role)
);
grant select on public.user_roles to authenticated;
grant all on public.user_roles to service_role;
alter table public.user_roles enable row level security;

create or replace function public.has_role(_user_id uuid, _role public.app_role)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.user_roles where user_id = _user_id and role = _role);
$$;

create or replace function public.is_manager_of(_manager uuid, _staff uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.profiles where id = _staff and manager_id = _manager);
$$;

create policy "profiles_select_own" on public.profiles for select to authenticated
  using (id = auth.uid() or manager_id = auth.uid() or public.has_role(auth.uid(),'admin') or public.has_role(auth.uid(),'admin_staff'));
create policy "profiles_update_own" on public.profiles for update to authenticated
  using (id = auth.uid() or manager_id = auth.uid() or public.has_role(auth.uid(),'admin'))
  with check (id = auth.uid() or manager_id = auth.uid() or public.has_role(auth.uid(),'admin'));

create policy "user_roles_select" on public.user_roles for select to authenticated
  using (user_id = auth.uid() or public.is_manager_of(auth.uid(), user_id) or public.has_role(auth.uid(),'admin') or public.has_role(auth.uid(),'admin_staff'));

create trigger trg_profiles_touch before update on public.profiles
  for each row execute function public.touch_updated_at();

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, email, full_name, manager_id)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    nullif(new.raw_user_meta_data->>'manager_id','')::uuid
  )
  on conflict (id) do nothing;

  insert into public.user_roles (user_id, role)
  values (new.id, coalesce((new.raw_user_meta_data->>'role')::public.app_role, 'user'))
  on conflict do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
