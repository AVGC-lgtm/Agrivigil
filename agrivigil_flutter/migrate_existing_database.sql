-- Migration Script for Existing AGRIVIGIL Database
-- This script safely adds missing columns to existing tables

-- Step 1: Add missing columns to roles table
DO $$ 
BEGIN
    -- Add 'code' column if it doesn't exist
    IF NOT EXISTS (SELECT column_name 
                   FROM information_schema.columns 
                   WHERE table_name='roles' AND column_name='code') THEN
        ALTER TABLE roles ADD COLUMN code VARCHAR(20);
    END IF;
    
    -- Add 'dashboard_route' column if it doesn't exist
    IF NOT EXISTS (SELECT column_name 
                   FROM information_schema.columns 
                   WHERE table_name='roles' AND column_name='dashboard_route') THEN
        ALTER TABLE roles ADD COLUMN dashboard_route VARCHAR(100);
    END IF;
    
    -- Add 'priority' column if it doesn't exist
    IF NOT EXISTS (SELECT column_name 
                   FROM information_schema.columns 
                   WHERE table_name='roles' AND column_name='priority') THEN
        ALTER TABLE roles ADD COLUMN priority INTEGER DEFAULT 0;
    END IF;
    
    -- Add 'is_active' column if it doesn't exist
    IF NOT EXISTS (SELECT column_name 
                   FROM information_schema.columns 
                   WHERE table_name='roles' AND column_name='is_active') THEN
        ALTER TABLE roles ADD COLUMN is_active BOOLEAN DEFAULT true;
    END IF;
END $$;

-- Step 2: Update existing roles with code and dashboard_route
UPDATE roles SET 
    code = CASE 
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
        WHEN name = 'Super Admin' THEN 'SA'
        ELSE UPPER(LEFT(name, 3))
    END,
    dashboard_route = CASE 
        WHEN name = 'Field Officer' THEN '/field-officer-dashboard'
        WHEN name = 'Lab Analyst' THEN '/lab-analyst-dashboard'
        WHEN name = 'QC Inspector' THEN '/qc-inspector-dashboard'
        WHEN name = 'District Agriculture Officer' THEN '/dao-dashboard'
        WHEN name = 'Legal Officer' THEN '/legal-officer-dashboard'
        WHEN name = 'Lab Coordinator' THEN '/lab-coordinator-dashboard'
        WHEN name = 'HQ Monitoring' THEN '/hq-monitoring-dashboard'
        WHEN name = 'District Admin' THEN '/district-admin-dashboard'
        WHEN name = 'Super Admin' THEN '/admin-dashboard'
        ELSE '/dashboard'
    END,
    priority = CASE 
        WHEN name = 'Field Officer' THEN 1
        WHEN name = 'Lab Analyst' THEN 2
        WHEN name = 'QC Inspector' THEN 3
        WHEN name = 'District Agriculture Officer' THEN 4
        WHEN name = 'Legal Officer' THEN 5
        WHEN name = 'Lab Coordinator' THEN 6
        WHEN name = 'HQ Monitoring' THEN 7
        WHEN name = 'District Admin' THEN 8
        WHEN name = 'Super Admin' THEN 99
        ELSE 10
    END
WHERE code IS NULL OR dashboard_route IS NULL;

-- Step 3: Add unique constraint to code column
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT constraint_name 
                   FROM information_schema.table_constraints 
                   WHERE table_name = 'roles' 
                   AND constraint_type = 'UNIQUE' 
                   AND constraint_name = 'roles_code_key') THEN
        ALTER TABLE roles ADD CONSTRAINT roles_code_key UNIQUE (code);
    END IF;
END $$;

-- Step 4: Add missing columns to users table
DO $$ 
BEGIN
    -- Add 'phone' column if it doesn't exist
    IF NOT EXISTS (SELECT column_name 
                   FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='phone') THEN
        ALTER TABLE users ADD COLUMN phone VARCHAR(20);
    END IF;
    
    -- Add 'district' column if it doesn't exist
    IF NOT EXISTS (SELECT column_name 
                   FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='district') THEN
        ALTER TABLE users ADD COLUMN district VARCHAR(100);
    END IF;
    
    -- Add 'status' column if it doesn't exist
    IF NOT EXISTS (SELECT column_name 
                   FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='status') THEN
        ALTER TABLE users ADD COLUMN status VARCHAR(20) DEFAULT 'active';
        ALTER TABLE users ADD CONSTRAINT users_status_check CHECK (status IN ('active', 'inactive', 'suspended'));
    END IF;
    
    -- Add 'last_login' column if it doesn't exist
    IF NOT EXISTS (SELECT column_name 
                   FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='last_login') THEN
        ALTER TABLE users ADD COLUMN last_login TIMESTAMPTZ;
    END IF;
END $$;

-- Step 5: Insert any missing roles
INSERT INTO roles (name, code, description, dashboard_route, priority) VALUES
    ('Field Officer', 'FO', 'Field inspection and execution officer', '/field-officer-dashboard', 1),
    ('Lab Analyst', 'LA', 'Laboratory analysis and testing', '/lab-analyst-dashboard', 2),
    ('QC Inspector', 'QC', 'Quality Control inspection', '/qc-inspector-dashboard', 3),
    ('District Agriculture Officer', 'DAO', 'District level agriculture officer', '/dao-dashboard', 4),
    ('Legal Officer', 'LO', 'Legal and compliance officer', '/legal-officer-dashboard', 5),
    ('Lab Coordinator', 'LC', 'Laboratory coordination and management', '/lab-coordinator-dashboard', 6),
    ('HQ Monitoring', 'HQ', 'Headquarters monitoring team', '/hq-monitoring-dashboard', 7),
    ('District Admin', 'DA', 'District administration', '/district-admin-dashboard', 8),
    ('Super Admin', 'SA', 'System administrator with full access', '/admin-dashboard', 99)
ON CONFLICT (name) DO UPDATE SET 
    code = EXCLUDED.code,
    description = EXCLUDED.description,
    dashboard_route = EXCLUDED.dashboard_route,
    priority = EXCLUDED.priority;

-- Step 6: Create the view if it doesn't exist
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

-- Step 7: Display the updated roles
SELECT id, name, code, dashboard_route, priority FROM roles ORDER BY priority;

-- Success message
DO $$ 
BEGIN
    RAISE NOTICE 'Database migration completed successfully!';
END $$;
