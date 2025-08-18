-- =====================================================
-- Comprehensive Fix for All Column Errors
-- Run this to fix all missing column issues at once
-- =====================================================

\echo 'Starting comprehensive column fixes...'

-- Fix 1: Add state column to users table
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='state') THEN
        ALTER TABLE users ADD COLUMN state VARCHAR(100) DEFAULT 'Maharashtra';
        RAISE NOTICE '✓ Added state column to users table';
    ELSE
        RAISE NOTICE '- State column already exists';
    END IF;
END $$;

-- Fix 2: Add priority column to inspection_tasks
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='inspection_tasks' AND column_name='priority') THEN
        ALTER TABLE inspection_tasks ADD COLUMN priority VARCHAR(20) DEFAULT 'normal';
        ALTER TABLE inspection_tasks ADD CONSTRAINT inspection_tasks_priority_check 
            CHECK (priority IN ('low', 'normal', 'high', 'urgent'));
        RAISE NOTICE '✓ Added priority column to inspection_tasks table';
    ELSE
        RAISE NOTICE '- Priority column already exists';
    END IF;
END $$;

-- Fix 3: Add assigned_team column to inspection_tasks
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='inspection_tasks' AND column_name='assigned_team') THEN
        ALTER TABLE inspection_tasks ADD COLUMN assigned_team UUID[];
        RAISE NOTICE '✓ Added assigned_team column to inspection_tasks table';
    ELSE
        RAISE NOTICE '- Assigned_team column already exists';
    END IF;
END $$;

-- Fix 4: Add metadata column to inspection_tasks
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='inspection_tasks' AND column_name='metadata') THEN
        ALTER TABLE inspection_tasks ADD COLUMN metadata JSONB DEFAULT '{}';
        RAISE NOTICE '✓ Added metadata column to inspection_tasks table';
    ELSE
        RAISE NOTICE '- Metadata column already exists';
    END IF;
END $$;

-- Fix 5: Add phone column to users
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='phone') THEN
        ALTER TABLE users ADD COLUMN phone VARCHAR(20);
        RAISE NOTICE '✓ Added phone column to users table';
    ELSE
        RAISE NOTICE '- Phone column already exists';
    END IF;
END $$;

-- Fix 6: Add district column to users
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='district') THEN
        ALTER TABLE users ADD COLUMN district VARCHAR(100);
        RAISE NOTICE '✓ Added district column to users table';
    ELSE
        RAISE NOTICE '- District column already exists';
    END IF;
END $$;

-- Fix 7: Add last_login column to users
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='last_login') THEN
        ALTER TABLE users ADD COLUMN last_login TIMESTAMPTZ;
        RAISE NOTICE '✓ Added last_login column to users table';
    ELSE
        RAISE NOTICE '- Last_login column already exists';
    END IF;
END $$;

-- Fix 8: Add permissions column to roles
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='roles' AND column_name='permissions') THEN
        ALTER TABLE roles ADD COLUMN permissions JSONB DEFAULT '{}';
        RAISE NOTICE '✓ Added permissions column to roles table';
    ELSE
        RAISE NOTICE '- Permissions column already exists';
    END IF;
END $$;

-- Fix 9: Convert totaltarget and achievedtarget to INTEGER if needed
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name='inspection_tasks' AND column_name='totaltarget' 
               AND data_type = 'character varying') THEN
        
        -- Add temporary columns
        ALTER TABLE inspection_tasks ADD COLUMN totaltarget_new INTEGER;
        ALTER TABLE inspection_tasks ADD COLUMN achievedtarget_new INTEGER;
        
        -- Convert data
        UPDATE inspection_tasks 
        SET totaltarget_new = CASE 
                WHEN totaltarget ~ '^\d+$' THEN totaltarget::INTEGER 
                ELSE 0 
            END,
            achievedtarget_new = CASE 
                WHEN achievedtarget ~ '^\d+$' THEN achievedtarget::INTEGER 
                ELSE 0 
            END;
        
        -- Drop old columns and rename new ones
        ALTER TABLE inspection_tasks DROP COLUMN totaltarget;
        ALTER TABLE inspection_tasks DROP COLUMN achievedtarget;
        ALTER TABLE inspection_tasks RENAME COLUMN totaltarget_new TO totaltarget;
        ALTER TABLE inspection_tasks RENAME COLUMN achievedtarget_new TO achievedtarget;
        
        RAISE NOTICE '✓ Converted target columns to INTEGER';
    ELSE
        RAISE NOTICE '- Target columns are already INTEGER';
    END IF;
END $$;

-- Fix 10: Add field_execution_id column to lab_samples
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='lab_samples' AND column_name='field_execution_id') THEN
        ALTER TABLE lab_samples ADD COLUMN field_execution_id INTEGER REFERENCES field_executions(id);
        RAISE NOTICE '✓ Added field_execution_id column to lab_samples table';
    ELSE
        RAISE NOTICE '- field_execution_id column already exists';
    END IF;
END $$;

-- Fix 11: Add priority column to lab_samples
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='lab_samples' AND column_name='priority') THEN
        ALTER TABLE lab_samples ADD COLUMN priority VARCHAR(20) DEFAULT 'normal';
        RAISE NOTICE '✓ Added priority column to lab_samples table';
    ELSE
        RAISE NOTICE '- Priority column in lab_samples already exists';
    END IF;
END $$;

-- Fix 12: Add test_parameters column to lab_samples
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='lab_samples' AND column_name='test_parameters') THEN
        ALTER TABLE lab_samples ADD COLUMN test_parameters JSONB;
        RAISE NOTICE '✓ Added test_parameters column to lab_samples table';
    ELSE
        RAISE NOTICE '- test_parameters column already exists';
    END IF;
END $$;

-- Fix 13: Add module column to role_permissions
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='role_permissions' AND column_name='module') THEN
        ALTER TABLE role_permissions ADD COLUMN module VARCHAR(50);
        
        -- Set default value for existing rows
        UPDATE role_permissions SET module = 'all' WHERE module IS NULL;
        
        -- Make it NOT NULL after setting values
        ALTER TABLE role_permissions ALTER COLUMN module SET NOT NULL;
        
        RAISE NOTICE '✓ Added module column to role_permissions table';
    ELSE
        RAISE NOTICE '- Module column already exists';
    END IF;
END $$;

-- Fix 14: Add verification_status column to field_executions
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='field_executions' AND column_name='verification_status') THEN
        ALTER TABLE field_executions ADD COLUMN verification_status VARCHAR(50) DEFAULT 'pending';
        RAISE NOTICE '✓ Added verification_status column to field_executions table';
    ELSE
        RAISE NOTICE '- verification_status column already exists';
    END IF;
END $$;

-- Fix 15: Add is_active column to roles
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='roles' AND column_name='is_active') THEN
        ALTER TABLE roles ADD COLUMN is_active BOOLEAN DEFAULT true;
        RAISE NOTICE '✓ Added is_active column to roles table';
    ELSE
        RAISE NOTICE '- is_active column already exists in roles table';
    END IF;
END $$;

-- Fix 16: Add is_active column to products
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='products' AND column_name='is_active') THEN
        ALTER TABLE products ADD COLUMN is_active BOOLEAN DEFAULT true;
        RAISE NOTICE '✓ Added is_active column to products table';
    ELSE
        RAISE NOTICE '- is_active column already exists in products table';
    END IF;
END $$;

-- Fix 17: Add scanned_by column to scan_results
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='scan_results' AND column_name='scanned_by') THEN
        ALTER TABLE scan_results ADD COLUMN scanned_by UUID REFERENCES users(id);
        RAISE NOTICE '✓ Added scanned_by column to scan_results table';
    ELSE
        RAISE NOTICE '- scanned_by column already exists';
    END IF;
END $$;

-- Fix 18: Add device_info column to scan_results
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='scan_results' AND column_name='device_info') THEN
        ALTER TABLE scan_results ADD COLUMN device_info JSONB;
        RAISE NOTICE '✓ Added device_info column to scan_results table';
    ELSE
        RAISE NOTICE '- device_info column already exists';
    END IF;
END $$;

-- Fix 19: Add updated_at column to scan_results
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='scan_results' AND column_name='updated_at') THEN
        ALTER TABLE scan_results ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
        RAISE NOTICE '✓ Added updated_at column to scan_results table';
    ELSE
        RAISE NOTICE '- updated_at column already exists';
    END IF;
END $$;

\echo ''
\echo 'Recreating views with updated columns...'

-- Recreate all views to ensure they use the correct columns
DROP VIEW IF EXISTS user_details CASCADE;
DROP VIEW IF EXISTS active_inspections CASCADE;
DROP VIEW IF EXISTS lab_sample_status CASCADE;

-- User details view
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

-- Active inspections view
CREATE VIEW active_inspections AS
SELECT 
    it.id,
    it.inspectioncode,
    it.datetime,
    it.district,
    it.location,
    it.status,
    it.priority,
    u.name as assigned_officer,
    u.officer_code,
    COUNT(fe.id) as execution_count
FROM inspection_tasks it
LEFT JOIN users u ON it.user_id = u.id
LEFT JOIN field_executions fe ON fe.inspectionid = it.id
WHERE it.status IN ('scheduled', 'in_progress')
GROUP BY it.id, u.name, u.officer_code;

-- Lab sample status view
CREATE VIEW lab_sample_status AS
SELECT 
    ls.id,
    ls.samplecode,
    ls.department,
    ls.district,
    ls.status,
    ls.collected_at,
    ls.result_status,
    u.name as officer_name,
    fe.fieldcode,
    fe.companyname,
    fe.productname
FROM lab_samples ls
LEFT JOIN users u ON ls.user_id = u.id
LEFT JOIN field_executions fe ON ls.field_execution_id = fe.id;

\echo ''
\echo '=============================================';
\echo 'All column fixes completed successfully!';
\echo '=============================================';
\echo '';
\echo 'You can now run the main schema files.';
\echo '';
