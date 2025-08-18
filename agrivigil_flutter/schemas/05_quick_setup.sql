-- =====================================================
-- AGRIVIGIL Quick Setup Script
-- Version: 2.0
-- =====================================================
-- Run this for a fresh installation with test data
-- =====================================================

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Run all schema files in sequence
\echo 'Creating database schema...'
\i 01_master_schema.sql

\echo 'Creating indexes and policies...'
\i 02_indexes_and_policies.sql

\echo 'Loading seed data...'
\i 03_seed_data.sql

-- Quick verification
\echo ''
\echo '======================================'
\echo 'Database setup completed!'
\echo '======================================'
\echo ''

-- Show summary
SELECT 'Tables created' as item, COUNT(*) as count 
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
UNION ALL
SELECT 'Roles created', COUNT(*) FROM roles
UNION ALL
SELECT 'Test users created', COUNT(*) FROM users
UNION ALL
SELECT 'Products loaded', COUNT(*) FROM products
UNION ALL
SELECT 'QC checkpoints', COUNT(*) FROM qc_checkpoint_master;

\echo ''
\echo 'Test user credentials:'
\echo '====================='
SELECT 
    r.name as role,
    u.email,
    'Test@123' as password
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE u.email LIKE '%@agrivigil.com'
ORDER BY r.priority;

\echo ''
\echo 'Setup complete! You can now login with any test user.'
\echo ''
