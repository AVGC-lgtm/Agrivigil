-- Fix for Missing is_active Column Error
-- This adds the is_active column to roles and products tables if they don't exist

-- Add is_active column to roles table
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='roles' AND column_name='is_active') THEN
        ALTER TABLE roles ADD COLUMN is_active BOOLEAN DEFAULT true;
        RAISE NOTICE 'Added is_active column to roles table';
    ELSE
        RAISE NOTICE 'is_active column already exists in roles table';
    END IF;
END $$;

-- Add is_active column to products table
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='products' AND column_name='is_active') THEN
        ALTER TABLE products ADD COLUMN is_active BOOLEAN DEFAULT true;
        RAISE NOTICE 'Added is_active column to products table';
    ELSE
        RAISE NOTICE 'is_active column already exists in products table';
    END IF;
END $$;

RAISE NOTICE 'is_active column fix completed!';
