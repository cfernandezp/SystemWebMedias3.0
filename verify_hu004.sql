-- Verification Script for HU-004 Password Recovery
-- Execute with Docker:
-- docker exec -it supabase_db_systemwebmedias3.0 psql -U postgres -d postgres -f /verify_hu004.sql

-- 1. Check if table exists
SELECT
    table_name,
    table_type
FROM information_schema.tables
WHERE table_name = 'password_recovery';

-- 2. Check table structure
\d+ password_recovery

-- 3. List all password recovery functions
SELECT
    routine_name,
    routine_type,
    data_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE '%password%'
ORDER BY routine_name;

-- 4. Test request_password_reset function
SELECT request_password_reset('admin@test.com', '127.0.0.1'::INET);

-- 5. Check created records
SELECT
    id,
    user_id,
    email,
    substring(token, 1, 10) || '...' as token_preview,
    expires_at,
    used_at,
    created_at
FROM password_recovery
ORDER BY created_at DESC
LIMIT 5;

-- 6. Count records
SELECT COUNT(*) as total_recovery_tokens FROM password_recovery;
