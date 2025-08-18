-- Fix for Missing scanned_by Column Error
-- This adds the scanned_by column to scan_results table if it doesn't exist

-- Add scanned_by column to scan_results
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='scan_results' AND column_name='scanned_by') THEN
        ALTER TABLE scan_results ADD COLUMN scanned_by UUID REFERENCES users(id);
        RAISE NOTICE 'Added scanned_by column to scan_results table';
    ELSE
        RAISE NOTICE 'scanned_by column already exists in scan_results table';
    END IF;
END $$;

-- Also add device_info column if missing
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='scan_results' AND column_name='device_info') THEN
        ALTER TABLE scan_results ADD COLUMN device_info JSONB;
        RAISE NOTICE 'Added device_info column to scan_results table';
    ELSE
        RAISE NOTICE 'device_info column already exists in scan_results table';
    END IF;
END $$;

-- Also add updated_at column if missing
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='scan_results' AND column_name='updated_at') THEN
        ALTER TABLE scan_results ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
        RAISE NOTICE 'Added updated_at column to scan_results table';
    ELSE
        RAISE NOTICE 'updated_at column already exists in scan_results table';
    END IF;
END $$;

RAISE NOTICE 'scan_results table columns fix completed!';
