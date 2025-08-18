-- Quick Fix for Registration Role Error
-- Run this SQL in your Supabase SQL Editor to fix the registration UUID error

-- Step 1: Create roles table if it doesn't exist
CREATE TABLE IF NOT EXISTS roles (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Step 2: Insert default roles (or update if they exist)
INSERT INTO roles (name, description) VALUES
    ('Super Admin', 'System administrator with full access'),
    ('Field Officer', 'Field inspection and execution officer'),
    ('District Agriculture Officer', 'District level agriculture officer'),
    ('Legal Officer', 'Legal and compliance officer'),
    ('Lab Coordinator', 'Laboratory coordination and management'),
    ('HQ Monitoring', 'Headquarters monitoring team'),
    ('District Admin', 'District administration'),
    ('QC Inspector', 'Quality Control inspector'),
    ('Lab Analyst', 'Laboratory analyst'),
    ('QC Manager', 'Quality Control manager'),
    ('QC Supervisor', 'Quality Control supervisor'),
    ('QC Department Head', 'Head of Quality Control department')
ON CONFLICT (name) DO UPDATE SET
    description = EXCLUDED.description,
    updated_at = NOW();

-- Step 3: Show the created roles with their IDs
SELECT id, name, description FROM roles ORDER BY name;

-- Step 4: Ensure metadata column exists on users table
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT column_name 
                   FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='metadata') THEN
        ALTER TABLE users ADD COLUMN metadata JSONB;
    END IF;
END $$;

-- Step 5: Ensure officer_code has unique constraint
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
    RAISE NOTICE 'Roles have been created successfully! You can now register users.';
END $$;
