-- Cleanup script to remove extra roles and keep only the 4 essential dashboard roles
-- Run this after the main migration to clean up any extra roles

-- First, let's see what roles currently exist
SELECT 'Current roles:' as info;
SELECT id, name, code, dashboard_route, priority FROM roles ORDER BY priority;

-- Remove extra roles that are not needed for the 4 main dashboards
DELETE FROM roles WHERE name NOT IN (
    'Field Officer',
    'Lab Analyst', 
    'QC Inspector',
    'District Agriculture Officer'
);

-- Verify the cleanup
SELECT 'After cleanup - only 4 essential roles remain:' as info;
SELECT id, name, code, dashboard_route, priority FROM roles ORDER BY priority;

-- Success message
DO $$ 
BEGIN
    RAISE NOTICE 'Role cleanup completed! Only 4 essential roles remain.';
    RAISE NOTICE 'Registration will now show only the necessary roles.';
END $$;
