-- Migration Script for Existing AGROVIGIL Database
-- This script safely adds missing columns to existing tables
-- Based on your current database structure

-- Step 1: Check current table structure
DO $$ 
BEGIN
    RAISE NOTICE 'Current roles table structure:';
END $$;

-- Display current roles table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'roles' 
ORDER BY ordinal_position;

-- Step 2: Add missing columns to roles table (only if they don't exist)
DO $$ 
BEGIN
    -- Add 'code' column if it doesn't exist
    IF NOT EXISTS (SELECT column_name 
                   FROM information_schema.columns 
                   WHERE table_name='roles' AND column_name='code') THEN
        ALTER TABLE roles ADD COLUMN code VARCHAR(20);
        RAISE NOTICE 'Added code column to roles table';
    ELSE
        RAISE NOTICE 'code column already exists in roles table';
    END IF;
    
    -- Add 'dashboard_route' column if it doesn't exist
    IF NOT EXISTS (SELECT column_name 
                   FROM information_schema.columns 
                   WHERE table_name='roles' AND column_name='dashboard_route') THEN
        ALTER TABLE roles ADD COLUMN dashboard_route VARCHAR(100);
        RAISE NOTICE 'Added dashboard_route column to roles table';
    ELSE
        RAISE NOTICE 'dashboard_route column already exists in roles table';
    END IF;
    
    -- Add 'priority' column if it doesn't exist
    IF NOT EXISTS (SELECT column_name 
                   FROM information_schema.columns 
                   WHERE table_name='roles' AND column_name='priority') THEN
        ALTER TABLE roles ADD COLUMN priority INTEGER DEFAULT 0;
        RAISE NOTICE 'Added priority column to roles table';
    ELSE
        RAISE NOTICE 'priority column already exists in roles table';
    END IF;
    
    -- Add 'is_active' column if it doesn't exist
    IF NOT EXISTS (SELECT column_name 
                   FROM information_schema.columns 
                   WHERE table_name='roles' AND column_name='is_active') THEN
        ALTER TABLE roles ADD COLUMN is_active BOOLEAN DEFAULT true;
        RAISE NOTICE 'Added is_active column to roles table';
    ELSE
        RAISE NOTICE 'is_active column already exists in roles table';
    END IF;
END $$;

-- Step 3: Update existing roles with proper values
UPDATE roles SET 
    code = CASE 
        WHEN name = 'Super Admin' THEN 'SA'
        WHEN name = 'Field Officer' THEN 'FO'
        WHEN name = 'Lab Analyst' THEN 'LA'
        WHEN name = 'QC Inspector' THEN 'QC'
        WHEN name = 'District Agriculture Officer' THEN 'DAO'
        WHEN name = 'Legal Officer' THEN 'LO'
        WHEN name = 'Lab Coordinator' THEN 'LC'
        WHEN name = 'HQ Monitoring' THEN 'HQ'
        WHEN name = 'District Admin' THEN 'DA'
        WHEN name = 'QC Manager' THEN 'QCM'
        WHEN name = 'QC Supervisor' THEN 'QCS'
        WHEN name = 'QC Department Head' THEN 'QCH'
        ELSE UPPER(LEFT(name, 3))
    END,
    dashboard_route = CASE 
        WHEN name = 'Super Admin' THEN '/admin-dashboard'
        WHEN name = 'Field Officer' THEN '/field-officer-dashboard'
        WHEN name = 'Lab Analyst' THEN '/lab-analyst-dashboard'
        WHEN name = 'QC Inspector' THEN '/qc-inspector-dashboard'
        WHEN name = 'District Agriculture Officer' THEN '/dao-dashboard'
        WHEN name = 'Legal Officer' THEN '/legal-officer-dashboard'
        WHEN name = 'Lab Coordinator' THEN '/lab-coordinator-dashboard'
        WHEN name = 'HQ Monitoring' THEN '/hq-monitoring-dashboard'
        WHEN name = 'District Admin' THEN '/district-admin-dashboard'
        ELSE '/dashboard'
    END,
    priority = CASE 
        WHEN name = 'Super Admin' THEN 99
        WHEN name = 'Field Officer' THEN 1
        WHEN name = 'Lab Analyst' THEN 2
        WHEN name = 'QC Inspector' THEN 3
        WHEN name = 'District Agriculture Officer' THEN 4
        WHEN name = 'Legal Officer' THEN 5
        WHEN name = 'Lab Coordinator' THEN 6
        WHEN name = 'HQ Monitoring' THEN 7
        WHEN name = 'District Admin' THEN 8
        ELSE 10
    END
WHERE code IS NULL OR dashboard_route IS NULL;

-- Step 4: Add unique constraint to code column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT constraint_name 
                   FROM information_schema.table_constraints 
                   WHERE table_name = 'roles' 
                   AND constraint_type = 'UNIQUE' 
                   AND constraint_name = 'roles_code_key') THEN
        ALTER TABLE roles ADD CONSTRAINT roles_code_key UNIQUE (code);
        RAISE NOTICE 'Added unique constraint to code column';
    ELSE
        RAISE NOTICE 'Unique constraint on code column already exists';
    END IF;
END $$;

-- Step 5: Add missing columns to users table (only if they don't exist)
DO $$ 
BEGIN
    -- Add 'phone' column if it doesn't exist
    IF NOT EXISTS (SELECT column_name 
                   FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='phone') THEN
        ALTER TABLE users ADD COLUMN phone VARCHAR(20);
        RAISE NOTICE 'Added phone column to users table';
    ELSE
        RAISE NOTICE 'phone column already exists in users table';
    END IF;
    
    -- Add 'district' column if it doesn't exist
    IF NOT EXISTS (SELECT column_name 
                   FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='district') THEN
        ALTER TABLE users ADD COLUMN district VARCHAR(100);
        RAISE NOTICE 'Added district column to users table';
    ELSE
        RAISE NOTICE 'district column already exists in users table';
    END IF;
    
    -- Add 'status' column if it doesn't exist
    IF NOT EXISTS (SELECT column_name 
                   FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='status') THEN
        ALTER TABLE users ADD COLUMN status VARCHAR(20) DEFAULT 'active';
        RAISE NOTICE 'Added status column to users table';
    ELSE
        RAISE NOTICE 'status column already exists in users table';
    END IF;
    
    -- Add 'last_login' column if it doesn't exist
    IF NOT EXISTS (SELECT column_name 
                   FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='last_login') THEN
        ALTER TABLE users ADD COLUMN last_login TIMESTAMPTZ;
        RAISE NOTICE 'Added last_login column to users table';
    ELSE
        RAISE NOTICE 'last_login column already exists in users table';
    END IF;
END $$;

-- Step 6: Insert any missing roles that are needed for registration
INSERT INTO roles (name, code, description, dashboard_route, priority) VALUES
    ('Field Officer', 'FO', 'Field inspection and execution officer', '/field-officer-dashboard', 1),
    ('Lab Analyst', 'LA', 'Laboratory analysis and testing', '/lab-analyst-dashboard', 2),
    ('QC Inspector', 'QC', 'Quality Control inspection', '/qc-inspector-dashboard', 3),
    ('District Agriculture Officer', 'DAO', 'District level agriculture officer', '/dao-dashboard', 4),
    ('Legal Officer', 'LO', 'Legal and compliance officer', '/legal-officer-dashboard', 5),
    ('Lab Coordinator', 'LC', 'Laboratory coordination and management', '/lab-coordinator-dashboard', 6),
    ('HQ Monitoring', 'HQ', 'Headquarters monitoring team', '/hq-monitoring-dashboard', 7),
    ('District Admin', 'DA', 'District administration', '/district-admin-dashboard', 8)
ON CONFLICT (name) DO UPDATE SET 
    code = EXCLUDED.code,
    description = EXCLUDED.description,
    dashboard_route = EXCLUDED.dashboard_route,
    priority = EXCLUDED.priority;

-- Step 7: Create or replace the user_details view
CREATE OR REPLACE VIEW user_details AS
SELECT 
    u.id,
    u.email,
    u.name,
    u.phone,
    u.officer_code,
    u.district,
    u.status,
    u.last_login,
    u.created_at,
    r.name as role_name,
    r.code as role_code,
    r.dashboard_route,
    r.description as role_description
FROM users u
LEFT JOIN roles r ON u.role_id = r.id;

-- Step 8: Display the final roles structure
DO $$ 
BEGIN
    RAISE NOTICE 'Migration completed! Final roles table structure:';
END $$;

SELECT id, name, code, dashboard_route, priority, is_active FROM roles ORDER BY priority;

-- Step 9: Test the view
SELECT 'View test:' as info;
SELECT * FROM user_details LIMIT 3;

-- Success message
DO $$ 
BEGIN
    RAISE NOTICE 'Database migration completed successfully!';
    RAISE NOTICE 'Your registration system should now work properly.';
END $$;
