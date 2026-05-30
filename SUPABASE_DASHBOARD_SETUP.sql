-- ============================================================
--  HealthIQ — Tables for Secure Viewer + Student Dashboard
--  Run this once in Supabase Dashboard → SQL Editor
-- ============================================================

-- 1. course_views: every open/close/blur of the secure PDF viewer
create table if not exists public.course_views (
    id            bigserial primary key,
    user_id       uuid references auth.users(id) on delete cascade,
    course_id     uuid references public.courses(id) on delete cascade,
    action        text check (action in ('open','close','blur')) default 'open',
    duration_seconds int default 0,
    user_agent    text,
    ip            text,
    created_at    timestamptz default now()
);
create index if not exists idx_course_views_user on public.course_views(user_id);
create index if not exists idx_course_views_course on public.course_views(course_id);
create index if not exists idx_course_views_created on public.course_views(created_at desc);

-- 2. study_sessions: accumulates a learner's time per course
create table if not exists public.study_sessions (
    id               bigserial primary key,
    user_id          uuid references auth.users(id) on delete cascade,
    course_id        uuid references public.courses(id) on delete cascade,
    duration_seconds int default 0,
    session_date     date default current_date,
    created_at       timestamptz default now()
);
create index if not exists idx_study_sessions_user on public.study_sessions(user_id);
create index if not exists idx_study_sessions_date on public.study_sessions(session_date desc);

-- 3. (Optional) bookmarks for future feature
create table if not exists public.bookmarks (
    id          bigserial primary key,
    user_id     uuid references auth.users(id) on delete cascade,
    course_id   uuid references public.courses(id) on delete cascade,
    page        int,
    note        text,
    created_at  timestamptz default now()
);

-- ============================================================
--  ⚠ NOTE on RLS: with RLS DISABLED (current setup) inserts
--  will succeed via the anon key. When you turn RLS on, add:
--
--  alter table course_views enable row level security;
--  create policy "own views"  on course_views
--     for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
--  alter table study_sessions enable row level security;
--  create policy "own sessions" on study_sessions
--     for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
--  alter table bookmarks enable row level security;
--  create policy "own bookmarks" on bookmarks
--     for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
-- ============================================================
