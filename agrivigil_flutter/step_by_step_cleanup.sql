-- Step-by-Step Role Cleanup (Run each section separately)

-- ========================================
-- STEP 1: Check what we have
-- ========================================
SELECT 'Current roles and user count:' as info;
SELECT 
    r.name,
    r.code,
    r.dashboard_route,
    COUNT(u.id) as user_count
FROM roles r
LEFT JOIN users u ON r.id = u.role_id
GROUP BY r.id, r.name, r.code, r.dashboard_route
ORDER BY r.priority;

-- ========================================
-- STEP 2: See which users have non-essential roles
-- ========================================
SELECT 'Users with non-essential roles:' as info;
SELECT 
    u.name,
    u.email,
    r.name as current_role
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE r.name NOT IN (
    'Field Officer',
    'Lab Analyst', 
    'QC Inspector',
    'District Agriculture Officer',
    'Super Admin'
);

-- ========================================
-- STEP 3: Migrate users to Field Officer role
-- ========================================
-- First, get the Field Officer role ID
SELECT 'Field Officer role ID:' as info;
SELECT id, name FROM roles WHERE name = 'Field Officer';

-- Then update users (replace 'FIELD_OFFICER_ID_HERE' with actual ID from above)
-- UPDATE users 
-- SET role_id = 'FIELD_OFFICER_ID_HERE'
-- WHERE role_id IN (
--     SELECT r.id 
--     FROM roles r 
--     WHERE r.name NOT IN (
--         'Field Officer',
--         'Lab Analyst', 
--         'QC Inspector',
--         'District Agriculture Officer',
--         'Super Admin'
--     )
-- );

-- ========================================
-- STEP 4: Verify migration worked
-- ========================================
SELECT 'After migration - user roles:' as info;
SELECT 
    u.name,
    u.email,
    r.name as role_name
FROM users u
JOIN roles r ON u.role_id = r.id
ORDER BY r.priority, u.name;

-- ========================================
-- STEP 5: Now safely delete extra roles
-- ========================================
-- DELETE FROM roles 
-- WHERE name NOT IN (
--     'Field Officer',
--     'Lab Analyst', 
--     'QC Inspector',
--     'District Agriculture Officer',
--     'Super Admin'
-- );

-- ========================================
-- STEP 6: Final verification
-- ========================================
SELECT 'Final roles:' as info;
SELECT name, code, dashboard_route FROM roles ORDER BY priority;

SELECT 'Final user-role mapping:' as info;
SELECT 
    u.name,
    u.email,
    r.name as role_name,
    r.dashboard_route
FROM users u
JOIN roles r ON u.role_id = r.id
ORDER BY r.priority, u.name;
