-- Fix for Missing field_execution_id Column Error
-- This adds the field_execution_id column to lab_samples table if it doesn't exist

-- Add field_execution_id column to lab_samples
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='lab_samples' AND column_name='field_execution_id') THEN
        ALTER TABLE lab_samples ADD COLUMN field_execution_id INTEGER REFERENCES field_executions(id);
        RAISE NOTICE 'Added field_execution_id column to lab_samples table';
    ELSE
        RAISE NOTICE 'field_execution_id column already exists';
    END IF;
END $$;

-- Also ensure other lab_samples columns exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='lab_samples' AND column_name='priority') THEN
        ALTER TABLE lab_samples ADD COLUMN priority VARCHAR(20) DEFAULT 'normal';
        RAISE NOTICE 'Added priority column to lab_samples table';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='lab_samples' AND column_name='test_parameters') THEN
        ALTER TABLE lab_samples ADD COLUMN test_parameters JSONB;
        RAISE NOTICE 'Added test_parameters column to lab_samples table';
    END IF;
END $$;

-- Drop and recreate the view that uses field_execution_id
DROP VIEW IF EXISTS lab_sample_status CASCADE;

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

RAISE NOTICE 'View recreated successfully!';
