-- Migration Script: Convert from role_id to direct role column
-- This script changes the users table to store role names directly

-- ========================================
-- STEP 1: Check current state
-- ========================================
SELECT 'Current user-role mapping:' as info;
SELECT 
    u.id,
    u.name,
    u.email,
    u.role_id,
    r.name as role_name,
    r.code as role_code
FROM users u
LEFT JOIN roles r ON u.role_id = r.id
ORDER BY u.created_at;

-- ========================================
-- STEP 2: Add role column to users table
-- ========================================
DO $$ 
BEGIN
    -- Add 'role' column if it doesn't exist
    IF NOT EXISTS (SELECT column_name 
                   FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='role') THEN
        ALTER TABLE users ADD COLUMN role VARCHAR(100);
        RAISE NOTICE 'Added role column to users table';
    ELSE
        RAISE NOTICE 'Role column already exists in users table';
    END IF;
END $$;

-- ========================================
-- STEP 3: Populate role column from role_id
-- ========================================
UPDATE users u
SET role = r.name
FROM roles r
WHERE u.role_id = r.id
AND u.role IS NULL;

-- Verify the update
SELECT 'After populating role column:' as info;
SELECT 
    u.id,
    u.name,
    u.email,
    u.role,
    r.name as role_from_join
FROM users u
LEFT JOIN roles r ON u.role_id = r.id
ORDER BY u.created_at;

-- ========================================
-- STEP 4: Set default role for any NULL values
-- ========================================
UPDATE users 
SET role = 'Field Officer'
WHERE role IS NULL;

-- ========================================
-- STEP 5: Add constraint to ensure valid roles
-- ========================================
ALTER TABLE users 
ADD CONSTRAINT valid_role_check 
CHECK (role IN (
    'Field Officer',
    'Lab Analyst',
    'QC Inspector',
    'District Agriculture Officer',
    'Legal Officer',
    'Lab Coordinator',
    'HQ Monitoring',
    'District Admin',
    'Super Admin'
));

-- ========================================
-- STEP 6: Create new view using direct role
-- ========================================
CREATE OR REPLACE VIEW user_details_direct AS
SELECT 
    u.id,
    u.email,
    u.name,
    u.phone,
    u.officer_code,
    u.district,
    u.status,
    u.role,
    u.last_login,
    u.created_at,
    -- Map role to dashboard route directly
    CASE u.role
        WHEN 'Field Officer' THEN '/field-officer-dashboard'
        WHEN 'Lab Analyst' THEN '/lab-analyst-dashboard'
        WHEN 'QC Inspector' THEN '/qc-inspector-dashboard'
        WHEN 'District Agriculture Officer' THEN '/dao-dashboard'
        WHEN 'Legal Officer' THEN '/legal-officer-dashboard'
        WHEN 'Lab Coordinator' THEN '/lab-coordinator-dashboard'
        WHEN 'HQ Monitoring' THEN '/hq-monitoring-dashboard'
        WHEN 'District Admin' THEN '/district-admin-dashboard'
        WHEN 'Super Admin' THEN '/admin-dashboard'
        ELSE '/dashboard'
    END as dashboard_route,
    -- Map role to code directly
    CASE u.role
        WHEN 'Field Officer' THEN 'FO'
        WHEN 'Lab Analyst' THEN 'LA'
        WHEN 'QC Inspector' THEN 'QC'
        WHEN 'District Agriculture Officer' THEN 'DAO'
        WHEN 'Legal Officer' THEN 'LO'
        WHEN 'Lab Coordinator' THEN 'LC'
        WHEN 'HQ Monitoring' THEN 'HQ'
        WHEN 'District Admin' THEN 'DA'
        WHEN 'Super Admin' THEN 'SA'
        ELSE 'UK'
    END as role_code
FROM users u;

-- ========================================
-- STEP 7: Update RLS policies (if using Supabase Auth)
-- ========================================
-- Drop old policies that reference role_id
DROP POLICY IF EXISTS "Admins can view all users" ON users;

-- Create new policy using direct role
CREATE POLICY "Admins can view all users" ON users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users u
            WHERE u.id::text = auth.uid()::text 
            AND u.role = 'Super Admin'
        )
    );

-- ========================================
-- STEP 8: (OPTIONAL) Drop role_id column
-- ========================================
-- WARNING: Only run this after confirming everything works!
-- This will break the foreign key relationship permanently

-- First, drop the foreign key constraint
-- ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_id_fkey;

-- Then, drop the column
-- ALTER TABLE users DROP COLUMN role_id;

-- ========================================
-- STEP 9: Final verification
-- ========================================
SELECT 'Final user table structure:' as info;
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'users'
ORDER BY ordinal_position;

SELECT 'Users with direct roles:' as info;
SELECT 
    name,
    email,
    role,
    district,
    status
FROM users
ORDER BY role, name;

-- ========================================
-- Rollback Script (if needed)
-- ========================================
-- To rollback this change:
-- 1. Re-add role_id column: ALTER TABLE users ADD COLUMN role_id UUID;
-- 2. Populate role_id from role names:
--    UPDATE users u 
--    SET role_id = r.id 
--    FROM roles r 
--    WHERE u.role = r.name;
-- 3. Re-add foreign key: ALTER TABLE users ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES roles(id);
-- 4. Drop role column: ALTER TABLE users DROP COLUMN role;
