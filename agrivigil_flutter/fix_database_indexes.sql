-- Quick Fix for Database Index Errors
-- Run this SQL in your Supabase SQL Editor to fix index-related errors

-- Drop existing indexes if they exist (to clean up)
DROP INDEX IF EXISTS idx_users_email;
DROP INDEX IF EXISTS idx_users_role_id;
DROP INDEX IF EXISTS idx_inspection_tasks_user_id;
DROP INDEX IF EXISTS idx_inspection_tasks_status;
DROP INDEX IF EXISTS idx_field_executions_inspectionid;
DROP INDEX IF EXISTS idx_seizures_field_execution_id;
DROP INDEX IF EXISTS idx_lab_samples_seizure_id;
DROP INDEX IF EXISTS idx_fir_cases_lab_sample_id;
DROP INDEX IF EXISTS idx_qc_inspections_status;
DROP INDEX IF EXISTS idx_qc_inspections_officer;
DROP INDEX IF EXISTS idx_qc_approvals_item;
DROP INDEX IF EXISTS idx_qc_non_compliance_status;

-- Recreate indexes with proper existence checks
DO $$ 
BEGIN
    -- Users table indexes
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_email') THEN
        CREATE INDEX idx_users_email ON users(email);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_role_id') THEN
        CREATE INDEX idx_users_role_id ON users(role_id);
    END IF;
    
    -- Inspection tasks indexes
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_inspection_tasks_user_id') THEN
        CREATE INDEX idx_inspection_tasks_user_id ON inspection_tasks(user_id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_inspection_tasks_status') THEN
        CREATE INDEX idx_inspection_tasks_status ON inspection_tasks(status);
    END IF;
    
    -- Field executions index
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_field_executions_inspectionid') THEN
        CREATE INDEX idx_field_executions_inspectionid ON field_executions(inspectionid);
    END IF;
    
    -- Seizures index
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_seizures_field_execution_id') THEN
        CREATE INDEX idx_seizures_field_execution_id ON seizures(field_execution_id);
    END IF;
    
    -- Lab samples index
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_lab_samples_seizure_id') THEN
        CREATE INDEX idx_lab_samples_seizure_id ON lab_samples(seizure_id);
    END IF;
    
    -- FIR cases index
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_fir_cases_lab_sample_id') THEN
        CREATE INDEX idx_fir_cases_lab_sample_id ON fir_cases(lab_sample_id);
    END IF;
    
    -- QC module indexes (if tables exist)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'qc_inspections') THEN
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_qc_inspections_status') THEN
            CREATE INDEX idx_qc_inspections_status ON qc_inspections(status);
        END IF;
        
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_qc_inspections_officer') THEN
            CREATE INDEX idx_qc_inspections_officer ON qc_inspections(assigned_officer_id);
        END IF;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'qc_approvals') THEN
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_qc_approvals_item') THEN
            CREATE INDEX idx_qc_approvals_item ON qc_approvals(item_type, item_id);
        END IF;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'qc_non_compliance') THEN
        IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_qc_non_compliance_status') THEN
            CREATE INDEX idx_qc_non_compliance_status ON qc_non_compliance(status);
        END IF;
    END IF;
END $$;

-- Also ensure the metadata column exists on users table
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT column_name 
                   FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='metadata') THEN
        ALTER TABLE users ADD COLUMN metadata JSONB;
    END IF;
END $$;

-- Ensure officer_code has unique constraint
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT constraint_name 
                   FROM information_schema.table_constraints 
                   WHERE table_name = 'users' 
                   AND constraint_type = 'UNIQUE' 
                   AND constraint_name = 'users_officer_code_key') THEN
        ALTER TABLE users ADD CONSTRAINT users_officer_code_key UNIQUE (officer_code);
    END IF;
END $$;

-- Success message
DO $$ 
BEGIN
    RAISE NOTICE 'Database indexes have been successfully fixed!';
END $$;
