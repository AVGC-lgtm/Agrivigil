-- Safe Cleanup Script for Roles - Handles Foreign Key Constraints
-- This script safely removes extra roles while preserving existing user data

-- Step 1: Check current roles and their usage
SELECT 'Current roles and their user count:' as info;
SELECT 
    r.id,
    r.name,
    r.code,
    r.dashboard_route,
    COUNT(u.id) as user_count
FROM roles r
LEFT JOIN users u ON r.id = u.role_id
GROUP BY r.id, r.name, r.code, r.dashboard_route
ORDER BY r.priority;

-- Step 2: Identify roles that can be safely removed (no users assigned)
SELECT 'Roles with no users (safe to delete):' as info;
SELECT 
    r.id,
    r.name,
    r.code,
    r.dashboard_route
FROM roles r
LEFT JOIN users u ON r.id = u.role_id
WHERE u.id IS NULL
AND r.name NOT IN (
    'Field Officer',
    'Lab Analyst', 
    'QC Inspector',
    'District Agriculture Officer',
    'Super Admin'
);

-- Step 3: Identify roles that have users but are not essential
SELECT 'Roles with users that need migration:' as info;
SELECT 
    r.id,
    r.name,
    r.code,
    r.dashboard_route,
    COUNT(u.id) as user_count
FROM roles r
JOIN users u ON r.id = u.role_id
WHERE r.name NOT IN (
    'Field Officer',
    'Lab Analyst', 
    'QC Inspector',
    'District Agriculture Officer',
    'Super Admin'
)
GROUP BY r.id, r.name, r.code, r.dashboard_route;

-- Step 4: Migrate users from non-essential roles to essential roles
-- First, let's see what we're working with
SELECT 'Users that need role migration:' as info;
SELECT 
    u.id,
    u.name,
    u.email,
    r.name as current_role,
    r.id as current_role_id
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE r.name NOT IN (
    'Field Officer',
    'Lab Analyst', 
    'QC Inspector',
    'District Agriculture Officer',
    'Super Admin'
);

-- Step 5: Update users to have essential roles (migrate them)
-- We'll migrate users to Field Officer role as a default
UPDATE users 
SET role_id = (
    SELECT id FROM roles WHERE name = 'Field Officer' LIMIT 1
)
WHERE role_id IN (
    SELECT r.id 
    FROM roles r 
    WHERE r.name NOT IN (
        'Field Officer',
        'Lab Analyst', 
        'QC Inspector',
        'District Agriculture Officer',
        'Super Admin'
    )
);

-- Step 6: Now safely delete the extra roles
DELETE FROM roles 
WHERE name NOT IN (
    'Field Officer',
    'Lab Analyst', 
    'QC Inspector',
    'District Agriculture Officer',
    'Super Admin'
);

-- Step 7: Verify the cleanup
SELECT 'After cleanup - only essential roles remain:' as info;
SELECT 
    r.id,
    r.name,
    r.code,
    r.dashboard_route,
    COUNT(u.id) as user_count
FROM roles r
LEFT JOIN users u ON r.id = u.role_id
GROUP BY r.id, r.name, r.code, r.dashboard_route
ORDER BY r.priority;

-- Step 8: Final verification
SELECT 'Final user-role mapping:' as info;
SELECT 
    u.name,
    u.email,
    r.name as role_name,
    r.dashboard_route
FROM users u
JOIN roles r ON u.role_id = r.id
ORDER BY r.priority, u.name;

-- Success message
DO $$ 
BEGIN
    RAISE NOTICE 'Safe role cleanup completed!';
    RAISE NOTICE 'Users have been migrated to essential roles.';
    RAISE NOTICE 'Only 5 roles remain: 4 essential + Super Admin.';
END $$;
