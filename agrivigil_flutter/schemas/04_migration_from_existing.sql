-- =====================================================
-- AGRIVIGIL Migration Script from Existing Database
-- Version: 2.0
-- =====================================================
-- This script safely migrates existing database to new schema
-- Run this AFTER backing up your database!
-- =====================================================

-- Create a migration log table
CREATE TABLE IF NOT EXISTS migration_log (
    id SERIAL PRIMARY KEY,
    migration_name VARCHAR(255) NOT NULL,
    executed_at TIMESTAMPTZ DEFAULT NOW(),
    status VARCHAR(50) NOT NULL,
    details TEXT
);

-- Function to log migration steps
CREATE OR REPLACE FUNCTION log_migration(p_name TEXT, p_status TEXT, p_details TEXT DEFAULT NULL)
RETURNS VOID AS $$
BEGIN
    INSERT INTO migration_log (migration_name, status, details)
    VALUES (p_name, p_status, p_details);
END;
$$ LANGUAGE plpgsql;

-- Start migration transaction
BEGIN;

-- =====================================================
-- STEP 1: Add missing columns to existing tables
-- =====================================================

DO $$ 
BEGIN
    -- Add columns to roles table
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='roles' AND column_name='code') THEN
        ALTER TABLE roles ADD COLUMN code VARCHAR(20);
        PERFORM log_migration('Add roles.code column', 'SUCCESS');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='roles' AND column_name='dashboard_route') THEN
        ALTER TABLE roles ADD COLUMN dashboard_route VARCHAR(100);
        PERFORM log_migration('Add roles.dashboard_route column', 'SUCCESS');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='roles' AND column_name='priority') THEN
        ALTER TABLE roles ADD COLUMN priority INTEGER DEFAULT 0;
        PERFORM log_migration('Add roles.priority column', 'SUCCESS');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='roles' AND column_name='is_active') THEN
        ALTER TABLE roles ADD COLUMN is_active BOOLEAN DEFAULT true;
        PERFORM log_migration('Add roles.is_active column', 'SUCCESS');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='roles' AND column_name='permissions') THEN
        ALTER TABLE roles ADD COLUMN permissions JSONB DEFAULT '{}';
        PERFORM log_migration('Add roles.permissions column', 'SUCCESS');
    END IF;

    -- Add module column to role_permissions table
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='role_permissions' AND column_name='module') THEN
        ALTER TABLE role_permissions ADD COLUMN module VARCHAR(50);
        UPDATE role_permissions SET module = 'all' WHERE module IS NULL;
        ALTER TABLE role_permissions ALTER COLUMN module SET NOT NULL;
        PERFORM log_migration('Add role_permissions.module column', 'SUCCESS');
    END IF;

    -- Add columns to users table
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='phone') THEN
        ALTER TABLE users ADD COLUMN phone VARCHAR(20);
        PERFORM log_migration('Add users.phone column', 'SUCCESS');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='district') THEN
        ALTER TABLE users ADD COLUMN district VARCHAR(100);
        PERFORM log_migration('Add users.district column', 'SUCCESS');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='state') THEN
        ALTER TABLE users ADD COLUMN state VARCHAR(100) DEFAULT 'Maharashtra';
        PERFORM log_migration('Add users.state column', 'SUCCESS');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='status') THEN
        ALTER TABLE users ADD COLUMN status VARCHAR(20) DEFAULT 'active';
        PERFORM log_migration('Add users.status column', 'SUCCESS');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='last_login') THEN
        ALTER TABLE users ADD COLUMN last_login TIMESTAMPTZ;
        PERFORM log_migration('Add users.last_login column', 'SUCCESS');
    END IF;

    -- Add columns to existing tables
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='inspection_tasks' AND column_name='assigned_team') THEN
        ALTER TABLE inspection_tasks ADD COLUMN assigned_team UUID[];
        PERFORM log_migration('Add inspection_tasks.assigned_team column', 'SUCCESS');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='inspection_tasks' AND column_name='priority') THEN
        ALTER TABLE inspection_tasks ADD COLUMN priority VARCHAR(20) DEFAULT 'normal';
        PERFORM log_migration('Add inspection_tasks.priority column', 'SUCCESS');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='inspection_tasks' AND column_name='metadata') THEN
        ALTER TABLE inspection_tasks ADD COLUMN metadata JSONB DEFAULT '{}';
        PERFORM log_migration('Add inspection_tasks.metadata column', 'SUCCESS');
    END IF;
    
    -- Add columns to lab_samples table
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='lab_samples' AND column_name='field_execution_id') THEN
        ALTER TABLE lab_samples ADD COLUMN field_execution_id INTEGER REFERENCES field_executions(id);
        PERFORM log_migration('Add lab_samples.field_execution_id column', 'SUCCESS');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='lab_samples' AND column_name='priority') THEN
        ALTER TABLE lab_samples ADD COLUMN priority VARCHAR(20) DEFAULT 'normal';
        PERFORM log_migration('Add lab_samples.priority column', 'SUCCESS');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='lab_samples' AND column_name='test_parameters') THEN
        ALTER TABLE lab_samples ADD COLUMN test_parameters JSONB;
        PERFORM log_migration('Add lab_samples.test_parameters column', 'SUCCESS');
    END IF;
    
    -- Add verification_status to field_executions table
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='field_executions' AND column_name='verification_status') THEN
        ALTER TABLE field_executions ADD COLUMN verification_status VARCHAR(50) DEFAULT 'pending';
        PERFORM log_migration('Add field_executions.verification_status column', 'SUCCESS');
    END IF;
    
    -- Add columns to scan_results table
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='scan_results' AND column_name='scanned_by') THEN
        ALTER TABLE scan_results ADD COLUMN scanned_by UUID REFERENCES users(id);
        PERFORM log_migration('Add scan_results.scanned_by column', 'SUCCESS');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='scan_results' AND column_name='device_info') THEN
        ALTER TABLE scan_results ADD COLUMN device_info JSONB;
        PERFORM log_migration('Add scan_results.device_info column', 'SUCCESS');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='scan_results' AND column_name='updated_at') THEN
        ALTER TABLE scan_results ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
        PERFORM log_migration('Add scan_results.updated_at column', 'SUCCESS');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        PERFORM log_migration('Add missing columns', 'FAILED', SQLERRM);
        RAISE;
END $$;

-- =====================================================
-- STEP 2: Update existing role data
-- =====================================================

DO $$
BEGIN
    UPDATE roles SET 
        code = CASE 
            WHEN name = 'Field Officer' THEN 'FO'
            WHEN name = 'Lab Analyst' THEN 'LA'
            WHEN name = 'QC Inspector' THEN 'QC'
            WHEN name = 'District Agriculture Officer' THEN 'DAO'
            WHEN name = 'District Agricultural Officer' THEN 'DAO'
            WHEN name = 'Legal Officer' THEN 'LO'
            WHEN name = 'Lab Coordinator' THEN 'LC'
            WHEN name = 'HQ Monitoring' THEN 'HQ'
            WHEN name = 'HQ Monitoring Cell' THEN 'HQ'
            WHEN name = 'District Admin' THEN 'DA'
            WHEN name = 'QC Manager' THEN 'QCM'
            WHEN name = 'QC Supervisor' THEN 'QCS'
            WHEN name = 'QC Department Head' THEN 'QCH'
            WHEN name = 'Super Admin' THEN 'SA'
            ELSE UPPER(LEFT(REPLACE(name, ' ', ''), 3))
        END,
        dashboard_route = CASE 
            WHEN name = 'Field Officer' THEN '/field-officer-dashboard'
            WHEN name = 'Lab Analyst' THEN '/lab-analyst-dashboard'
            WHEN name = 'QC Inspector' THEN '/qc-inspector-dashboard'
            WHEN name IN ('District Agriculture Officer', 'District Agricultural Officer') THEN '/dao-dashboard'
            WHEN name = 'Legal Officer' THEN '/legal-officer-dashboard'
            WHEN name = 'Lab Coordinator' THEN '/lab-coordinator-dashboard'
            WHEN name IN ('HQ Monitoring', 'HQ Monitoring Cell') THEN '/hq-monitoring-dashboard'
            WHEN name = 'District Admin' THEN '/district-admin-dashboard'
            WHEN name = 'QC Manager' THEN '/qc-manager-dashboard'
            WHEN name = 'QC Supervisor' THEN '/qc-supervisor-dashboard'
            WHEN name = 'QC Department Head' THEN '/qc-head-dashboard'
            WHEN name = 'Super Admin' THEN '/admin-dashboard'
            ELSE '/dashboard'
        END,
        priority = CASE 
            WHEN name = 'Field Officer' THEN 1
            WHEN name = 'Lab Analyst' THEN 2
            WHEN name = 'QC Inspector' THEN 3
            WHEN name IN ('District Agriculture Officer', 'District Agricultural Officer') THEN 4
            WHEN name = 'Legal Officer' THEN 5
            WHEN name = 'Lab Coordinator' THEN 6
            WHEN name IN ('HQ Monitoring', 'HQ Monitoring Cell') THEN 7
            WHEN name = 'District Admin' THEN 8
            WHEN name = 'QC Supervisor' THEN 10
            WHEN name = 'QC Manager' THEN 11
            WHEN name = 'QC Department Head' THEN 12
            WHEN name = 'Super Admin' THEN 99
            ELSE 50
        END
    WHERE code IS NULL OR dashboard_route IS NULL;
    
    PERFORM log_migration('Update role data', 'SUCCESS', 'Updated ' || ROW_COUNT || ' roles');
EXCEPTION
    WHEN OTHERS THEN
        PERFORM log_migration('Update role data', 'FAILED', SQLERRM);
        RAISE;
END $$;

-- =====================================================
-- STEP 3: Add constraints
-- =====================================================

DO $$ 
BEGIN
    -- Add unique constraints
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                   WHERE table_name = 'roles' AND constraint_name = 'roles_code_key') THEN
        ALTER TABLE roles ADD CONSTRAINT roles_code_key UNIQUE (code);
        PERFORM log_migration('Add roles.code unique constraint', 'SUCCESS');
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                   WHERE table_name = 'users' AND constraint_name = 'users_status_check') THEN
        ALTER TABLE users ADD CONSTRAINT users_status_check 
            CHECK (status IN ('active', 'inactive', 'suspended'));
        PERFORM log_migration('Add users.status check constraint', 'SUCCESS');
    END IF;

    -- Add check constraints for new fields
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                   WHERE table_name = 'inspection_tasks' AND constraint_name = 'inspection_tasks_priority_check') THEN
        ALTER TABLE inspection_tasks ADD CONSTRAINT inspection_tasks_priority_check 
            CHECK (priority IN ('low', 'normal', 'high', 'urgent'));
        PERFORM log_migration('Add inspection_tasks.priority check constraint', 'SUCCESS');
    END IF;
    
    -- Add unique constraint for role_permissions
    IF NOT EXISTS (SELECT 1 FROM pg_constraint 
                   WHERE conname = 'role_permissions_role_id_module_key' 
                   AND conrelid = 'role_permissions'::regclass) THEN
        ALTER TABLE role_permissions ADD CONSTRAINT role_permissions_role_id_module_key 
            UNIQUE(role_id, module);
        PERFORM log_migration('Add role_permissions unique constraint', 'SUCCESS');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        PERFORM log_migration('Add constraints', 'FAILED', SQLERRM);
        RAISE;
END $$;

-- =====================================================
-- STEP 4: Create new tables if they don't exist
-- =====================================================

-- User sessions table
CREATE TABLE IF NOT EXISTS user_sessions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    token TEXT UNIQUE NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    priority VARCHAR(20) DEFAULT 'normal',
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMPTZ,
    action_url VARCHAR(255),
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- System settings table
CREATE TABLE IF NOT EXISTS system_settings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    key VARCHAR(100) UNIQUE NOT NULL,
    value JSONB NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Lab test results table
CREATE TABLE IF NOT EXISTS lab_test_results (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    sample_id INTEGER REFERENCES lab_samples(id),
    test_name VARCHAR(100) NOT NULL,
    test_method VARCHAR(100),
    parameter VARCHAR(100) NOT NULL,
    unit VARCHAR(50),
    specification_min DECIMAL(10,4),
    specification_max DECIMAL(10,4),
    actual_value DECIMAL(10,4),
    result VARCHAR(20) CHECK (result IN ('pass', 'fail', 'pending')),
    tested_by UUID REFERENCES users(id),
    tested_at TIMESTAMPTZ,
    verified_by UUID REFERENCES users(id),
    verified_at TIMESTAMPTZ,
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

PERFORM log_migration('Create new tables', 'SUCCESS');

-- =====================================================
-- STEP 5: Migrate data transformations
-- =====================================================

-- Update field_executions to use integers for totaltarget and achievedtarget
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
        
        PERFORM log_migration('Convert inspection_tasks target columns to integer', 'SUCCESS');
    END IF;
END $$;

-- =====================================================
-- STEP 6: Create missing indexes
-- =====================================================

-- Create indexes that don't exist
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_officer_code ON users(officer_code);
CREATE INDEX IF NOT EXISTS idx_users_role_id ON users(role_id);
CREATE INDEX IF NOT EXISTS idx_users_district ON users(district);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);

CREATE INDEX IF NOT EXISTS idx_inspection_tasks_user_id ON inspection_tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_inspection_tasks_status ON inspection_tasks(status);
CREATE INDEX IF NOT EXISTS idx_inspection_tasks_district ON inspection_tasks(district);

CREATE INDEX IF NOT EXISTS idx_field_executions_inspectionid ON field_executions(inspectionid);
CREATE INDEX IF NOT EXISTS idx_seizures_field_execution_id ON seizures(field_execution_id);
CREATE INDEX IF NOT EXISTS idx_lab_samples_seizure_id ON lab_samples(seizure_id);
CREATE INDEX IF NOT EXISTS idx_fir_cases_lab_sample_id ON fir_cases(lab_sample_id);

PERFORM log_migration('Create indexes', 'SUCCESS');

-- =====================================================
-- STEP 7: Update views
-- =====================================================

-- Drop existing views to avoid column conflicts
DROP VIEW IF EXISTS user_details CASCADE;
DROP VIEW IF EXISTS active_inspections CASCADE;
DROP VIEW IF EXISTS lab_sample_status CASCADE;

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

PERFORM log_migration('Update views', 'SUCCESS');

-- =====================================================
-- STEP 8: Data quality fixes
-- =====================================================

-- Ensure all users have required fields
UPDATE users 
SET phone = 'UPDATE_REQUIRED' 
WHERE phone IS NULL OR phone = '';

UPDATE users 
SET district = 'UPDATE_REQUIRED' 
WHERE district IS NULL OR district = '';

UPDATE users 
SET officer_code = 'TEMP-' || LEFT(MD5(email), 8) 
WHERE officer_code IS NULL OR officer_code = '';

PERFORM log_migration('Data quality fixes', 'SUCCESS');

-- =====================================================
-- FINAL STEP: Commit or Rollback
-- =====================================================

-- Check if any migrations failed
DO $$
DECLARE
    v_failed_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_failed_count 
    FROM migration_log 
    WHERE status = 'FAILED';
    
    IF v_failed_count > 0 THEN
        RAISE EXCEPTION 'Migration failed with % errors. Rolling back.', v_failed_count;
    END IF;
END $$;

-- If we get here, all migrations succeeded
COMMIT;

-- =====================================================
-- MIGRATION SUMMARY
-- =====================================================

DO $$
DECLARE
    v_total_migrations INTEGER;
    v_successful_migrations INTEGER;
BEGIN
    SELECT COUNT(*), 
           COUNT(*) FILTER (WHERE status = 'SUCCESS')
    INTO v_total_migrations, v_successful_migrations
    FROM migration_log;
    
    RAISE NOTICE '';
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'Migration completed successfully!';
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'Total migration steps: %', v_total_migrations;
    RAISE NOTICE 'Successful: %', v_successful_migrations;
    RAISE NOTICE '';
    RAISE NOTICE 'Next steps:';
    RAISE NOTICE '1. Review users with phone/district = UPDATE_REQUIRED';
    RAISE NOTICE '2. Update officer codes starting with TEMP-';
    RAISE NOTICE '3. Run 03_seed_data.sql for test data (optional)';
    RAISE NOTICE '4. Test all role-based logins';
    RAISE NOTICE '=============================================';
END $$;

-- =====================================================
-- END OF MIGRATION
-- =====================================================
