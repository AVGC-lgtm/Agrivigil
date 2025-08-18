-- Verification Script for Direct Role Migration
-- Run this after migrate_to_direct_role.sql to verify everything is working

-- ========================================
-- 1. Check role column was added
-- ========================================
SELECT 'Checking role column exists:' as step;
SELECT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'users' 
    AND column_name = 'role'
) as role_column_exists;

-- ========================================
-- 2. Check all users have roles populated
-- ========================================
SELECT 'Users without direct role:' as step;
SELECT COUNT(*) as users_without_role
FROM users
WHERE role IS NULL;

-- ========================================
-- 3. Compare role_id mapping with direct role
-- ========================================
SELECT 'Verifying role consistency:' as step;
SELECT 
    COUNT(*) as mismatched_roles
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE u.role != r.name;

-- ========================================
-- 4. Check constraint is active
-- ========================================
SELECT 'Checking role constraint:' as step;
SELECT 
    constraint_name,
    check_clause
FROM information_schema.check_constraints
WHERE constraint_name = 'valid_role_check';

-- ========================================
-- 5. Show role distribution
-- ========================================
SELECT 'Role distribution:' as step;
SELECT 
    role,
    COUNT(*) as user_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM users
WHERE role IS NOT NULL
GROUP BY role
ORDER BY user_count DESC;

-- ========================================
-- 6. Test the new view
-- ========================================
SELECT 'Testing user_details_direct view:' as step;
SELECT 
    name,
    email,
    role,
    dashboard_route,
    role_code
FROM user_details_direct
LIMIT 3;

-- ========================================
-- 7. Summary
-- ========================================
SELECT 'Migration Summary:' as step;
SELECT 
    (SELECT COUNT(*) FROM users) as total_users,
    (SELECT COUNT(*) FROM users WHERE role IS NOT NULL) as users_with_role,
    (SELECT COUNT(DISTINCT role) FROM users WHERE role IS NOT NULL) as unique_roles,
    (SELECT COUNT(*) FROM users WHERE role_id IS NOT NULL) as users_with_role_id;
