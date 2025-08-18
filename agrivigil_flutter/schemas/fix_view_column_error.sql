-- Fix for View Column Name Error
-- This error occurs when trying to replace a view with different column names/order

-- Drop existing views that might have conflicts
DROP VIEW IF EXISTS user_details CASCADE;
DROP VIEW IF EXISTS active_inspections CASCADE;
DROP VIEW IF EXISTS lab_sample_status CASCADE;

-- Ensure state column exists
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='state') THEN
        ALTER TABLE users ADD COLUMN state VARCHAR(100) DEFAULT 'Maharashtra';
        RAISE NOTICE 'Added state column to users table';
    END IF;
END $$;

-- Recreate user_details view
CREATE VIEW user_details AS
SELECT 
    u.id,
    u.email,
    u.name,
    u.phone,
    u.officer_code,
    u.district,
    u.state,
    u.status,
    u.last_login,
    u.created_at,
    r.name as role_name,
    r.code as role_code,
    r.dashboard_route,
    r.description as role_description,
    r.priority as role_priority
FROM users u
LEFT JOIN roles r ON u.role_id = r.id;

RAISE NOTICE 'Views recreated successfully!';
