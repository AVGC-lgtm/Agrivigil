-- Test Queries for Direct Role Implementation
-- This file contains runnable queries to test the direct role approach

-- ========================================
-- STEP 1: Check if role column exists
-- ========================================
SELECT 'Checking for role column:' as info;
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'users' 
AND column_name = 'role';

-- ========================================
-- STEP 2: View current users with both approaches
-- ========================================
SELECT 'Users with role_id and direct role:' as info;
SELECT 
    u.id,
    u.name,
    u.email,
    u.role_id,
    u.role as direct_role,
    r.name as role_from_join
FROM users u
LEFT JOIN roles r ON u.role_id = r.id
LIMIT 5;

-- ========================================
-- STEP 3: Test direct role queries
-- ========================================

-- Count users by role (no join needed)
SELECT 'User count by role (direct):' as info;
SELECT 
    role, 
    COUNT(*) as user_count
FROM users
WHERE role IS NOT NULL
GROUP BY role
ORDER BY user_count DESC;

-- Find all Field Officers
SELECT 'Field Officers (direct query):' as info;
SELECT 
    name,
    email,
    district,
    officer_code
FROM users
WHERE role = 'Field Officer'
LIMIT 5;

-- Check for admin users
SELECT 'Admin users (direct query):' as info;
SELECT 
    name,
    email,
    role
FROM users
WHERE role = 'Super Admin';

-- ========================================
-- STEP 4: Performance comparison
-- ========================================

-- Query with JOIN (old approach)
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    u.name,
    r.name as role_name,
    r.dashboard_route
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE r.name = 'Field Officer';

-- Query without JOIN (new approach)
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    name,
    role,
    CASE role
        WHEN 'Field Officer' THEN '/field-officer-dashboard'
        WHEN 'Lab Analyst' THEN '/lab-analyst-dashboard'
        WHEN 'Super Admin' THEN '/admin-dashboard'
        ELSE '/dashboard'
    END as dashboard_route
FROM users
WHERE role = 'Field Officer';

-- ========================================
-- STEP 5: Verify constraint is working
-- ========================================
SELECT 'Testing role constraint:' as info;

-- This should fail with an error (uncomment to test)
-- INSERT INTO users (email, name, password, phone, officer_code, role, district)
-- VALUES ('test@example.com', 'Test User', 'password', '1234567890', 'TEST001', 'Invalid Role', 'Test District');

-- ========================================
-- STEP 6: Useful queries for your application
-- ========================================

-- Get user with dashboard route
SELECT 'User with dashboard route:' as info;
SELECT 
    name,
    email,
    role,
    CASE role
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
    END as dashboard_route
FROM users
WHERE email = (SELECT email FROM users LIMIT 1); -- Gets first user as example

-- Get role statistics
SELECT 'Role statistics:' as info;
SELECT 
    role,
    COUNT(*) as total_users,
    COUNT(CASE WHEN status = 'active' THEN 1 END) as active_users,
    COUNT(CASE WHEN status = 'inactive' THEN 1 END) as inactive_users
FROM users
WHERE role IS NOT NULL
GROUP BY role
ORDER BY total_users DESC;
