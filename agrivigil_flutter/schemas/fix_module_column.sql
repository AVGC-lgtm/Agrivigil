-- Fix for Missing module Column in role_permissions Table
-- This adds the module column if it doesn't exist

-- Add module column to role_permissions
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='role_permissions' AND column_name='module') THEN
        ALTER TABLE role_permissions ADD COLUMN module VARCHAR(50);
        
        -- Set default value for existing rows
        UPDATE role_permissions SET module = 'all' WHERE module IS NULL;
        
        -- Make it NOT NULL after setting values
        ALTER TABLE role_permissions ALTER COLUMN module SET NOT NULL;
        
        RAISE NOTICE 'Added module column to role_permissions table';
    ELSE
        RAISE NOTICE 'Module column already exists';
    END IF;
END $$;

-- Drop existing unique constraint if it exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'role_permissions_role_id_module_key') THEN
        ALTER TABLE role_permissions DROP CONSTRAINT role_permissions_role_id_module_key;
    END IF;
END $$;

-- Add unique constraint for role_id and module
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint 
                   WHERE conname = 'role_permissions_role_id_module_key' 
                   AND conrelid = 'role_permissions'::regclass) THEN
        ALTER TABLE role_permissions ADD CONSTRAINT role_permissions_role_id_module_key 
            UNIQUE(role_id, module);
        RAISE NOTICE 'Added unique constraint on (role_id, module)';
    END IF;
END $$;

RAISE NOTICE 'Module column fix completed!';
