-- =====================================================
-- Row Level Security (RLS) Policies for DSR Application
-- =====================================================
-- Run this SQL in your Supabase SQL Editor
-- This enables RLS with proper security (not overly permissive)
-- =====================================================

-- =====================================================
-- STEP 1: DROP EXISTING OVERLY PERMISSIVE POLICIES
-- =====================================================
-- Reports
DROP POLICY IF EXISTS "Allow all operations on reports" ON public.reports;
DROP POLICY IF EXISTS "Postgres role full access to reports" ON public.reports;

-- Users
DROP POLICY IF EXISTS "Allow all operations on users" ON public.users;
DROP POLICY IF EXISTS "Postgres role full access to users" ON public.users;

-- Project_defs
DROP POLICY IF EXISTS "Allow all operations on project_defs" ON public.project_defs;
DROP POLICY IF EXISTS "Postgres role full access to project_defs" ON public.project_defs;

-- Password_reset_tokens
DROP POLICY IF EXISTS "Allow all operations on password_reset_tokens" ON public.password_reset_tokens;
DROP POLICY IF EXISTS "Postgres role full access to password_reset_tokens" ON public.password_reset_tokens;

-- Login_events
DROP POLICY IF EXISTS "Allow all operations on login_events" ON public.login_events;
DROP POLICY IF EXISTS "Postgres role full access to login_events" ON public.login_events;

-- Failed_login_attempts
DROP POLICY IF EXISTS "Allow all operations on failed_login_attempts" ON public.failed_login_attempts;
DROP POLICY IF EXISTS "Postgres role full access to failed_login_attempts" ON public.failed_login_attempts;

-- =====================================================
-- STEP 2: ENABLE RLS ON ALL TABLES
-- =====================================================
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.project_defs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.password_reset_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.login_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.failed_login_attempts ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- STEP 3: CREATE SECURE POLICIES
-- =====================================================
-- Only the postgres role (Flask backend) gets access.
-- The anon/authenticated roles are blocked (no direct Supabase client access).
-- Authorization is handled at the application level via JWT tokens.

-- =====================================================
-- REPORTS TABLE - Only backend can access
-- =====================================================
CREATE POLICY "Backend access to reports"
ON public.reports
FOR ALL
TO postgres
USING (true)
WITH CHECK (true);

-- =====================================================
-- USERS TABLE - Only backend can access
-- =====================================================
CREATE POLICY "Backend access to users"
ON public.users
FOR ALL
TO postgres
USING (true)
WITH CHECK (true);

-- =====================================================
-- PROJECT_DEFS TABLE - Only backend can access
-- =====================================================
CREATE POLICY "Backend access to project_defs"
ON public.project_defs
FOR ALL
TO postgres
USING (true)
WITH CHECK (true);

-- =====================================================
-- PASSWORD_RESET_TOKENS TABLE - Only backend can access
-- =====================================================
CREATE POLICY "Backend access to password_reset_tokens"
ON public.password_reset_tokens
FOR ALL
TO postgres
USING (true)
WITH CHECK (true);

-- =====================================================
-- LOGIN_EVENTS TABLE - Only backend can access
-- =====================================================
CREATE POLICY "Backend access to login_events"
ON public.login_events
FOR ALL
TO postgres
USING (true)
WITH CHECK (true);

-- =====================================================
-- FAILED_LOGIN_ATTEMPTS TABLE - Only backend can access
-- =====================================================
CREATE POLICY "Backend access to failed_login_attempts"
ON public.failed_login_attempts
FOR ALL
TO postgres
USING (true)
WITH CHECK (true);

-- =====================================================
-- VERIFICATION QUERY
-- =====================================================
-- Run this to verify RLS is enabled:
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('reports', 'users', 'project_defs', 'password_reset_tokens', 'login_events', 'failed_login_attempts');

-- Check policies:
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE schemaname = 'public';

-- =====================================================
-- NOTES
-- =====================================================
-- 1. RLS is enabled on all tables
-- 2. Only postgres role (Flask backend) has access
-- 3. anon/authenticated roles are BLOCKED (no direct DB access)
-- 4. All authorization handled at application level (JWT tokens)
-- 5. This removes the "RLS Policy Always True" warnings for public roles
-- 6. To rollback, run rls_rollback.sql
