-- Query Comparison: role_id vs direct role
-- 
-- NOTE: This file contains EXAMPLE queries to demonstrate the differences
-- between using role_id (foreign key) vs direct role (string) approaches.
-- 
-- DO NOT run this file directly. It contains placeholder values and 
-- commented examples. Copy and modify the queries you need for your use case.

-- ========================================
-- WITH ROLE_ID (Foreign Key Approach)
-- ========================================

-- 1. Get user with role details (requires JOIN)
SELECT 
    u.id,
    u.name,
    u.email,
    r.name as role_name,
    r.code as role_code,
    r.dashboard_route
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE u.email = 'user@example.com';

-- 2. Get all users of a specific role (requires JOIN)
SELECT u.*
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE r.name = 'Field Officer';

-- 3. Count users by role (requires JOIN)
SELECT r.name, COUNT(u.id) as user_count
FROM roles r
LEFT JOIN users u ON r.id = u.role_id
GROUP BY r.id, r.name;

-- 4. Check if user is admin (requires JOIN)
-- Example: Replace 'YOUR_USER_ID' with an actual UUID
-- SELECT EXISTS (
--     SELECT 1 FROM users u
--     JOIN roles r ON u.role_id = r.id
--     WHERE u.id = 'YOUR_USER_ID'::uuid
--     AND r.name = 'Super Admin'
-- );

-- ========================================
-- WITH DIRECT ROLE (Direct String Approach)
-- ========================================

-- 1. Get user with role details (NO JOIN needed)
SELECT 
    id,
    name,
    email,
    role,
    -- Use CASE or a function to get dashboard route
    CASE role
        WHEN 'Field Officer' THEN '/field-officer-dashboard'
        WHEN 'Lab Analyst' THEN '/lab-analyst-dashboard'
        WHEN 'Super Admin' THEN '/admin-dashboard'
        -- ... other roles
    END as dashboard_route
FROM users
WHERE email = 'user@example.com';

-- 2. Get all users of a specific role (NO JOIN)
SELECT *
FROM users
WHERE role = 'Field Officer';

-- 3. Count users by role (NO JOIN)
SELECT role, COUNT(*) as user_count
FROM users
GROUP BY role;

-- 4. Check if user is admin (NO JOIN)
-- Example: Replace 'YOUR_USER_ID' with an actual UUID
-- SELECT EXISTS (
--     SELECT 1 FROM users
--     WHERE id = 'YOUR_USER_ID'::uuid
--     AND role = 'Super Admin'
-- );

-- ========================================
-- PERFORMANCE COMPARISON
-- ========================================

-- With role_id: Requires index on users.role_id and roles.id
-- Query plan includes JOIN operation

-- With direct role: Only requires index on users.role
-- Query plan is simpler, no JOIN needed

-- ========================================
-- MAINTENANCE COMPARISON
-- ========================================

-- Changing a role name with role_id:
UPDATE roles SET name = 'Senior Field Officer' WHERE name = 'Field Officer';
-- All users automatically get the new role name

-- Changing a role name with direct role:
UPDATE users SET role = 'Senior Field Officer' WHERE role = 'Field Officer';
-- Need to update all user records

-- ========================================
-- ADDING NEW ROLES
-- ========================================

-- With role_id:
INSERT INTO roles (name, code, dashboard_route) VALUES ('New Role', 'NR', '/new-dashboard');
-- Users can be assigned to this role immediately

-- With direct role:
-- 1. Update the CHECK constraint
ALTER TABLE users DROP CONSTRAINT valid_role_check;
ALTER TABLE users ADD CONSTRAINT valid_role_check 
CHECK (role IN (
    'Field Officer', 
    'Lab Analyst', 
    'QC Inspector',
    'District Agriculture Officer',
    'Legal Officer',
    'Lab Coordinator',
    'HQ Monitoring',
    'District Admin',
    'Super Admin',
    'New Role'  -- Add your new role here
));
-- 2. Update application code with new role mappings
