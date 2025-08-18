-- Fix for Missing Priority Column Error
-- This adds the priority column to inspection_tasks table if it doesn't exist

-- Add priority column to inspection_tasks
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='inspection_tasks' AND column_name='priority') THEN
        ALTER TABLE inspection_tasks ADD COLUMN priority VARCHAR(20) DEFAULT 'normal';
        ALTER TABLE inspection_tasks ADD CONSTRAINT inspection_tasks_priority_check 
            CHECK (priority IN ('low', 'normal', 'high', 'urgent'));
        RAISE NOTICE 'Added priority column to inspection_tasks table';
    ELSE
        RAISE NOTICE 'Priority column already exists';
    END IF;
END $$;

-- Add assigned_team column if missing
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='inspection_tasks' AND column_name='assigned_team') THEN
        ALTER TABLE inspection_tasks ADD COLUMN assigned_team UUID[];
        RAISE NOTICE 'Added assigned_team column to inspection_tasks table';
    END IF;
END $$;

-- Add metadata column if missing
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='inspection_tasks' AND column_name='metadata') THEN
        ALTER TABLE inspection_tasks ADD COLUMN metadata JSONB DEFAULT '{}';
        RAISE NOTICE 'Added metadata column to inspection_tasks table';
    END IF;
END $$;

-- Drop and recreate the view that uses priority
DROP VIEW IF EXISTS active_inspections CASCADE;

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

RAISE NOTICE 'View recreated successfully!';
