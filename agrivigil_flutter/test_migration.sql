-- Test script to verify database migration
-- Run this after migrate_existing_database.sql

-- Check if roles table has the new columns
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'roles' 
ORDER BY ordinal_position;

-- Check if users table has the new columns
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'users' 
ORDER BY ordinal_position;

-- Check the roles data
SELECT id, name, code, dashboard_route, priority FROM roles ORDER BY priority;

-- Check if the view exists
SELECT * FROM user_details LIMIT 1;

-- Test inserting a sample role if needed
-- INSERT INTO roles (name, code, description, dashboard_route, priority) 
-- VALUES ('Test Role', 'TEST', 'Test description', '/test-dashboard', 50)
-- ON CONFLICT (name) DO NOTHING;
