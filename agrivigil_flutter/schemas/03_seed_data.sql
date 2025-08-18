-- =====================================================
-- AGRIVIGIL Seed Data
-- Version: 2.0
-- =====================================================
-- Initial data for roles, permissions, and test users
-- =====================================================

-- =====================================================
-- ROLES
-- =====================================================

INSERT INTO roles (name, code, description, dashboard_route, priority, permissions) VALUES
    ('Field Officer', 'FO', 'Field inspection and execution officer', '/field-officer-dashboard', 1, 
        '{"modules": ["inspection", "field_execution", "scan", "seizure"]}'::jsonb),
    
    ('Lab Analyst', 'LA', 'Laboratory analysis and testing', '/lab-analyst-dashboard', 2,
        '{"modules": ["lab_samples", "test_results", "reports"]}'::jsonb),
    
    ('QC Inspector', 'QC', 'Quality Control inspection', '/qc-inspector-dashboard', 3,
        '{"modules": ["qc_inspection", "compliance", "checkpoints"]}'::jsonb),
    
    ('District Agriculture Officer', 'DAO', 'District level agriculture officer', '/dao-dashboard', 4,
        '{"modules": ["district_overview", "team_management", "reports", "approvals"]}'::jsonb),
    
    ('Legal Officer', 'LO', 'Legal and compliance officer', '/legal-officer-dashboard', 5,
        '{"modules": ["legal_cases", "fir_management", "court_tracking"]}'::jsonb),
    
    ('Lab Coordinator', 'LC', 'Laboratory coordination and management', '/lab-coordinator-dashboard', 6,
        '{"modules": ["lab_management", "sample_tracking", "resource_allocation"]}'::jsonb),
    
    ('HQ Monitoring', 'HQ', 'Headquarters monitoring team', '/hq-monitoring-dashboard', 7,
        '{"modules": ["system_monitoring", "analytics", "audit_logs", "reports"]}'::jsonb),
    
    ('District Admin', 'DA', 'District administration', '/district-admin-dashboard', 8,
        '{"modules": ["district_admin", "user_management", "resource_management"]}'::jsonb),
    
    ('QC Supervisor', 'QCS', 'Quality Control Supervisor', '/qc-supervisor-dashboard', 10,
        '{"modules": ["qc_supervision", "team_management", "approvals"]}'::jsonb),
    
    ('QC Manager', 'QCM', 'Quality Control Manager', '/qc-manager-dashboard', 11,
        '{"modules": ["qc_management", "compliance_management", "analytics"]}'::jsonb),
    
    ('QC Department Head', 'QCH', 'Head of Quality Control Department', '/qc-head-dashboard', 12,
        '{"modules": ["qc_strategy", "department_management", "high_level_approvals"]}'::jsonb),
    
    ('Super Admin', 'SA', 'System administrator with full access', '/admin-dashboard', 99,
        '{"modules": ["*"], "full_access": true}'::jsonb)
ON CONFLICT (name) DO UPDATE SET 
    code = EXCLUDED.code,
    description = EXCLUDED.description,
    dashboard_route = EXCLUDED.dashboard_route,
    priority = EXCLUDED.priority,
    permissions = EXCLUDED.permissions;

-- =====================================================
-- ROLE PERMISSIONS
-- =====================================================

-- Super Admin - Full access
INSERT INTO role_permissions (role_id, module, menu_id, auth_type)
SELECT 
    id, 
    'all',
    ARRAY['dashboard', 'administration', 'inspection-planning', 'field-execution', 
          'seizure-logging', 'lab-interface', 'legal-module', 'report-audit', 
          'agri-forms-module', 'qc-module', 'system-settings'],
    ARRAY['F', 'F', 'F', 'F', 'F', 'F', 'F', 'F', 'F', 'F', 'F']
FROM roles WHERE code = 'SA'
ON CONFLICT (role_id, module) DO UPDATE SET
    menu_id = EXCLUDED.menu_id,
    auth_type = EXCLUDED.auth_type;

-- Field Officer permissions
INSERT INTO role_permissions (role_id, module, menu_id, auth_type)
SELECT 
    id,
    'field_operations',
    ARRAY['dashboard', 'inspection-planning', 'field-execution', 'seizure-logging', 'scan-module'],
    ARRAY['R', 'R', 'F', 'F', 'F']
FROM roles WHERE code = 'FO'
ON CONFLICT (role_id, module) DO UPDATE SET
    menu_id = EXCLUDED.menu_id,
    auth_type = EXCLUDED.auth_type;

-- Lab Analyst permissions
INSERT INTO role_permissions (role_id, module, menu_id, auth_type)
SELECT 
    id,
    'laboratory',
    ARRAY['dashboard', 'lab-interface', 'sample-management', 'test-results', 'report-generation'],
    ARRAY['R', 'F', 'F', 'F', 'R']
FROM roles WHERE code = 'LA'
ON CONFLICT (role_id, module) DO UPDATE SET
    menu_id = EXCLUDED.menu_id,
    auth_type = EXCLUDED.auth_type;

-- QC Inspector permissions
INSERT INTO role_permissions (role_id, module, menu_id, auth_type)
SELECT 
    id,
    'quality_control',
    ARRAY['dashboard', 'qc-module', 'inspection-planning', 'compliance-check', 'abc-analysis'],
    ARRAY['R', 'F', 'R', 'F', 'R']
FROM roles WHERE code = 'QC'
ON CONFLICT (role_id, module) DO UPDATE SET
    menu_id = EXCLUDED.menu_id,
    auth_type = EXCLUDED.auth_type;

-- District Agriculture Officer permissions
INSERT INTO role_permissions (role_id, module, menu_id, auth_type)
SELECT 
    id,
    'district_management',
    ARRAY['dashboard', 'district-overview', 'team-management', 'inspection-planning', 
          'report-audit', 'approvals'],
    ARRAY['R', 'F', 'F', 'F', 'R', 'F']
FROM roles WHERE code = 'DAO'
ON CONFLICT (role_id, module) DO UPDATE SET
    menu_id = EXCLUDED.menu_id,
    auth_type = EXCLUDED.auth_type;

-- Legal Officer permissions
INSERT INTO role_permissions (role_id, module, menu_id, auth_type)
SELECT 
    id,
    'legal',
    ARRAY['dashboard', 'legal-module', 'fir-management', 'case-tracking', 'court-proceedings'],
    ARRAY['R', 'F', 'F', 'F', 'F']
FROM roles WHERE code = 'LO'
ON CONFLICT (role_id, module) DO UPDATE SET
    menu_id = EXCLUDED.menu_id,
    auth_type = EXCLUDED.auth_type;

-- =====================================================
-- TEST USERS (REMOVE IN PRODUCTION)
-- =====================================================

-- Create test users for each role
-- Password for all test users: Test@123

-- Super Admin
INSERT INTO users (email, name, password, phone, officer_code, role_id, district, state, metadata)
SELECT 
    'super.admin@agrivigil.com',
    'Super Administrator',
    crypt('Test@123', gen_salt('bf')), -- Use proper hashing
    '9999999999',
    'SA-001',
    id,
    'Mumbai',
    'Maharashtra',
    '{"designation": "System Administrator", "department": "IT"}'::jsonb
FROM roles WHERE code = 'SA'
ON CONFLICT (email) DO NOTHING;

-- Field Officer
INSERT INTO users (email, name, password, phone, officer_code, role_id, district, state, metadata)
SELECT 
    'field.officer@agrivigil.com',
    'Rajesh Kumar',
    crypt('Test@123', gen_salt('bf')),
    '9876543210',
    'FO-MUM-001',
    id,
    'Mumbai',
    'Maharashtra',
    '{"designation": "Senior Field Officer", "department": "Field Operations"}'::jsonb
FROM roles WHERE code = 'FO'
ON CONFLICT (email) DO NOTHING;

-- Lab Analyst
INSERT INTO users (email, name, password, phone, officer_code, role_id, district, state, metadata)
SELECT 
    'lab.analyst@agrivigil.com',
    'Dr. Priya Sharma',
    crypt('Test@123', gen_salt('bf')),
    '9876543211',
    'LA-MUM-001',
    id,
    'Mumbai',
    'Maharashtra',
    '{"designation": "Senior Lab Analyst", "department": "Laboratory"}'::jsonb
FROM roles WHERE code = 'LA'
ON CONFLICT (email) DO NOTHING;

-- QC Inspector
INSERT INTO users (email, name, password, phone, officer_code, role_id, district, state, metadata)
SELECT 
    'qc.inspector@agrivigil.com',
    'Amit Patel',
    crypt('Test@123', gen_salt('bf')),
    '9876543212',
    'QC-MUM-001',
    id,
    'Mumbai',
    'Maharashtra',
    '{"designation": "Quality Control Inspector", "department": "Quality Control"}'::jsonb
FROM roles WHERE code = 'QC'
ON CONFLICT (email) DO NOTHING;

-- District Agriculture Officer
INSERT INTO users (email, name, password, phone, officer_code, role_id, district, state, metadata)
SELECT 
    'dao.mumbai@agrivigil.com',
    'Suresh Deshmukh',
    crypt('Test@123', gen_salt('bf')),
    '9876543213',
    'DAO-MUM-001',
    id,
    'Mumbai',
    'Maharashtra',
    '{"designation": "District Agriculture Officer", "department": "Agriculture"}'::jsonb
FROM roles WHERE code = 'DAO'
ON CONFLICT (email) DO NOTHING;

-- =====================================================
-- MASTER DATA
-- =====================================================

-- QC Checkpoint Master Data
INSERT INTO qc_checkpoint_master (checkpoint_name, category, description, is_mandatory, required_evidence) VALUES
    ('License Verification', 'documentation', 'Verify valid fertilizer/pesticide license', true, 'document'),
    ('Stock Register Check', 'documentation', 'Check stock register maintenance', true, 'both'),
    ('Invoice Verification', 'documentation', 'Verify purchase invoices', true, 'document'),
    ('Physical Stock Count', 'physical', 'Count and verify physical stock', true, 'both'),
    ('Storage Conditions', 'physical', 'Check storage conditions and hygiene', true, 'photo'),
    ('Product Labeling', 'physical', 'Verify product labels and MRP', true, 'photo'),
    ('Sample Collection', 'chemical', 'Collect samples for lab testing', false, 'both'),
    ('Batch Number Verification', 'compliance', 'Verify batch numbers match records', true, 'photo'),
    ('Expiry Date Check', 'compliance', 'Check for expired products', true, 'both'),
    ('Packaging Integrity', 'packaging', 'Check packaging seal and condition', true, 'photo')
ON CONFLICT DO NOTHING;

-- QC Test Parameters
INSERT INTO qc_test_parameters (parameter_name, test_method, unit, product_category, min_value, max_value, tolerance_percentage, is_critical) VALUES
    ('Total Nitrogen', 'Kjeldahl Method', '%', 'Urea', 45.0, 47.0, 2.0, true),
    ('Moisture Content', 'Oven Drying', '%', 'Urea', 0.0, 1.0, 0.5, true),
    ('Biuret Content', 'Spectrophotometry', '%', 'Urea', 0.0, 1.5, 0.2, true),
    ('Total P2O5', 'Gravimetric', '%', 'DAP', 45.0, 47.0, 2.0, true),
    ('Water Soluble P2O5', 'Extraction Method', '%', 'DAP', 40.0, 42.0, 2.0, true),
    ('Total Nitrogen', 'Kjeldahl Method', '%', 'DAP', 17.0, 19.0, 1.0, true),
    ('Water Soluble K2O', 'Flame Photometry', '%', 'MOP', 59.0, 61.0, 1.0, true),
    ('Moisture Content', 'Oven Drying', '%', 'MOP', 0.0, 1.5, 0.5, false),
    ('Particle Size', 'Sieve Analysis', 'mm', 'All', 1.0, 4.0, 10.0, false)
ON CONFLICT DO NOTHING;

-- Product Master Data
INSERT INTO products (category, company, name, composition, packaging, is_active) VALUES
    ('Fertilizer', 'IFFCO', 'Urea', 'N: 46%', ARRAY['50kg'], true),
    ('Fertilizer', 'IFFCO', 'DAP', 'N: 18%, P2O5: 46%', ARRAY['50kg'], true),
    ('Fertilizer', 'IFFCO', 'NPK 10:26:26', 'N: 10%, P2O5: 26%, K2O: 26%', ARRAY['50kg'], true),
    ('Fertilizer', 'Coromandel', 'Urea', 'N: 46%', ARRAY['45kg', '50kg'], true),
    ('Fertilizer', 'Coromandel', 'DAP', 'N: 18%, P2O5: 46%', ARRAY['50kg'], true),
    ('Fertilizer', 'RCF', 'Urea', 'N: 46%', ARRAY['45kg'], true),
    ('Fertilizer', 'RCF', 'Suphala 15:15:15', 'N: 15%, P2O5: 15%, K2O: 15%', ARRAY['50kg'], true),
    ('Pesticide', 'Bayer', 'Confidor', 'Imidacloprid 17.8% SL', ARRAY['100ml', '250ml', '500ml'], true),
    ('Pesticide', 'Syngenta', 'Actara', 'Thiamethoxam 25% WG', ARRAY['100g', '250g'], true),
    ('Pesticide', 'UPL', 'Ulala', 'Flonicamid 50% WG', ARRAY['100g', '250g'], true)
ON CONFLICT (category, company, name) DO UPDATE SET
    composition = EXCLUDED.composition,
    packaging = EXCLUDED.packaging,
    is_active = EXCLUDED.is_active;

-- System Settings
INSERT INTO system_settings (key, value, description, is_public) VALUES
    ('app_version', '"2.0.0"'::jsonb, 'Current application version', true),
    ('maintenance_mode', 'false'::jsonb, 'System maintenance mode flag', true),
    ('max_file_upload_size', '10485760'::jsonb, 'Maximum file upload size in bytes (10MB)', true),
    ('session_timeout', '3600'::jsonb, 'Session timeout in seconds (1 hour)', true),
    ('password_policy', '{"min_length": 8, "require_uppercase": true, "require_lowercase": true, "require_number": true, "require_special": true}'::jsonb, 'Password policy configuration', false),
    ('email_config', '{"smtp_host": "smtp.gmail.com", "smtp_port": 587, "use_tls": true}'::jsonb, 'Email configuration', false)
ON CONFLICT (key) DO UPDATE SET
    value = EXCLUDED.value,
    description = EXCLUDED.description;

-- =====================================================
-- SAMPLE INSPECTION DATA (FOR TESTING)
-- =====================================================

-- Sample inspection task
INSERT INTO inspection_tasks (inspectioncode, user_id, datetime, state, district, taluka, location, addressland, target_type, typeofpremises, visitpurpose, equipment, totaltarget, achievedtarget, status)
SELECT 
    'INS-MUM-2024-001',
    u.id,
    NOW() + INTERVAL '2 days',
    'Maharashtra',
    'Mumbai',
    'Andheri',
    'Andheri East Market',
    'Shop No. 1-10, Andheri East Market, Mumbai',
    'Retail',
    ARRAY['Fertilizer Shop', 'Pesticide Shop'],
    ARRAY['Routine Inspection', 'License Verification'],
    ARRAY['Sampling Kit', 'Camera', 'Inspection Forms'],
    10,
    0,
    'scheduled'
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE r.code = 'FO' 
LIMIT 1
ON CONFLICT (inspectioncode) DO NOTHING;

-- =====================================================
-- DISPLAY SUMMARY
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Seed data loaded successfully!';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Test Users Created:';
    RAISE NOTICE '- Super Admin: super.admin@agrivigil.com';
    RAISE NOTICE '- Field Officer: field.officer@agrivigil.com';
    RAISE NOTICE '- Lab Analyst: lab.analyst@agrivigil.com';
    RAISE NOTICE '- QC Inspector: qc.inspector@agrivigil.com';
    RAISE NOTICE '- DAO: dao.mumbai@agrivigil.com';
    RAISE NOTICE '';
    RAISE NOTICE 'Password for all test users: Test@123';
    RAISE NOTICE '';
    RAISE NOTICE 'Total Roles: ' || (SELECT COUNT(*) FROM roles);
    RAISE NOTICE 'Total Products: ' || (SELECT COUNT(*) FROM products);
    RAISE NOTICE 'Total QC Checkpoints: ' || (SELECT COUNT(*) FROM qc_checkpoint_master);
    RAISE NOTICE '========================================';
END $$;

-- =====================================================
-- END OF SEED DATA
-- =====================================================
