-- Quick fix for missing state column error
-- Run this before running the main schema files

-- Add state column to users table if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT column_name 
                   FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='state') THEN
        ALTER TABLE users ADD COLUMN state VARCHAR(100) DEFAULT 'Maharashtra';
        RAISE NOTICE 'Added state column to users table';
    ELSE
        RAISE NOTICE 'State column already exists';
    END IF;
END $$;

-- Now you can proceed with running the schema files
