-- AGRIVIGIL Supabase Database Schema
-- Run this SQL in your Supabase SQL Editor to set up the database

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create roles table
CREATE TABLE IF NOT EXISTS roles (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    officer_code VARCHAR(50) UNIQUE,
    password VARCHAR(255) NOT NULL,
    role_id UUID REFERENCES roles(id),
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create role_permissions table
CREATE TABLE IF NOT EXISTS role_permissions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    role_id UUID REFERENCES roles(id),
    menu_id TEXT[],
    auth_type TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create inspection_tasks table
CREATE TABLE IF NOT EXISTS inspection_tasks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    inspectioncode VARCHAR(50) UNIQUE NOT NULL,
    user_id UUID REFERENCES users(id),
    datetime TIMESTAMPTZ NOT NULL,
    state VARCHAR(100) NOT NULL,
    district VARCHAR(100) NOT NULL,
    taluka VARCHAR(100) NOT NULL,
    location VARCHAR(255) NOT NULL,
    addressland TEXT NOT NULL,
    target_type VARCHAR(50) NOT NULL,
    typeofpremises TEXT[],
    visitpurpose TEXT[],
    equipment TEXT[],
    totaltarget VARCHAR(50) NOT NULL,
    achievedtarget VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'scheduled',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create field_executions table
CREATE TABLE IF NOT EXISTS field_executions (
    id SERIAL PRIMARY KEY,
    inspectionid UUID REFERENCES inspection_tasks(id),
    fieldcode VARCHAR(50) UNIQUE NOT NULL,
    companyname VARCHAR(255) NOT NULL,
    productname VARCHAR(255) NOT NULL,
    dealer_name VARCHAR(255) NOT NULL,
    registration_no VARCHAR(100),
    sampling_date DATE,
    fertilizer_type VARCHAR(100) NOT NULL,
    batch_no VARCHAR(100),
    manufacture_import_date DATE,
    stock_receipt_date DATE,
    sample_code VARCHAR(100),
    stock_position VARCHAR(100),
    physical_condition VARCHAR(100),
    specification_fco TEXT,
    composition_analysis TEXT,
    variation VARCHAR(100),
    moisture DECIMAL(5,2),
    total_n DECIMAL(5,2),
    nh4n DECIMAL(5,2),
    nh4no3n DECIMAL(5,2),
    urea_n DECIMAL(5,2),
    total_p2o5 DECIMAL(5,2),
    nac_soluble_p2o5 DECIMAL(5,2),
    citric_soluble_p2o5 DECIMAL(5,2),
    water_soluble_p2o5 DECIMAL(5,2),
    water_soluble_k2o DECIMAL(5,2),
    particle_size VARCHAR(100),
    document TEXT NOT NULL,
    productphoto TEXT NOT NULL,
    userid UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create scan_results table
CREATE TABLE IF NOT EXISTS scan_results (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    company VARCHAR(255) NOT NULL,
    product VARCHAR(255) NOT NULL,
    batch_number VARCHAR(100) NOT NULL,
    authenticity_score FLOAT NOT NULL,
    issues TEXT[],
    recommendation VARCHAR(100) NOT NULL,
    geo_location VARCHAR(255) NOT NULL,
    timestamp VARCHAR(50) NOT NULL,
    product_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create seizures table
CREATE TABLE IF NOT EXISTS seizures (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    seizurecode VARCHAR(50) UNIQUE NOT NULL,
    field_execution_id INTEGER REFERENCES field_executions(id),
    location VARCHAR(255) NOT NULL,
    district VARCHAR(100) NOT NULL,
    taluka VARCHAR(100),
    premises_type TEXT[],
    fertilizer_type VARCHAR(100),
    batch_no VARCHAR(100),
    quantity DECIMAL(10,2),
    estimated_value VARCHAR(100),
    witness_name VARCHAR(255),
    evidence_photos TEXT[],
    video_evidence TEXT,
    status VARCHAR(50) DEFAULT 'pending',
    remarks TEXT,
    seizure_date DATE,
    memo_no VARCHAR(100),
    officer_name VARCHAR(255),
    user_id UUID REFERENCES users(id),
    scan_result_id UUID REFERENCES scan_results(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create lab_samples table
CREATE TABLE IF NOT EXISTS lab_samples (
    id SERIAL PRIMARY KEY,
    samplecode VARCHAR(50) UNIQUE NOT NULL,
    department VARCHAR(100) NOT NULL,
    sample_desc TEXT NOT NULL,
    district VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL,
    collected_at TIMESTAMPTZ,
    dispatched_at TIMESTAMPTZ,
    received_at TIMESTAMPTZ,
    under_testing BOOLEAN DEFAULT FALSE,
    result_status VARCHAR(50),
    report_sent_at TIMESTAMPTZ,
    officer_name VARCHAR(255),
    remarks TEXT,
    user_id UUID REFERENCES users(id),
    seizure_id UUID REFERENCES seizures(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create fir_cases table
CREATE TABLE IF NOT EXISTS fir_cases (
    id SERIAL PRIMARY KEY,
    fircode VARCHAR(50) UNIQUE NOT NULL,
    police_station VARCHAR(255) NOT NULL,
    accused_party VARCHAR(255) NOT NULL,
    suspect_name VARCHAR(255) NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    street1 VARCHAR(255),
    street2 VARCHAR(255),
    village VARCHAR(100),
    district VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    license_no VARCHAR(100),
    contact_no VARCHAR(20),
    brand_name VARCHAR(100),
    fertilizer_type VARCHAR(100),
    batch_no VARCHAR(100),
    manufacture_date DATE,
    expiry_date DATE,
    violation_type TEXT[],
    evidence TEXT,
    remarks TEXT,
    user_id UUID REFERENCES users(id),
    lab_sample_id INTEGER REFERENCES lab_samples(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    category VARCHAR(50) NOT NULL,
    company VARCHAR(100) NOT NULL,
    name VARCHAR(255) NOT NULL,
    active_ingredient TEXT,
    composition TEXT,
    packaging TEXT[],
    batch_format VARCHAR(100),
    common_counterfeit_markers TEXT[],
    mrp JSONB,
    hologram_features TEXT[],
    bag_color VARCHAR(50),
    subsidized_rate FLOAT,
    varieties TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(category, company, name)
);

-- Create audit_logs table
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    action VARCHAR(100) NOT NULL,
    entity VARCHAR(100) NOT NULL,
    entity_id VARCHAR(100) NOT NULL,
    old_data JSONB,
    new_data JSONB,
    user_id UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance (with existence checks)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_email') THEN
        CREATE INDEX idx_users_email ON users(email);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_users_role_id') THEN
        CREATE INDEX idx_users_role_id ON users(role_id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_inspection_tasks_user_id') THEN
        CREATE INDEX idx_inspection_tasks_user_id ON inspection_tasks(user_id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_inspection_tasks_status') THEN
        CREATE INDEX idx_inspection_tasks_status ON inspection_tasks(status);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_field_executions_inspectionid') THEN
        CREATE INDEX idx_field_executions_inspectionid ON field_executions(inspectionid);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_seizures_field_execution_id') THEN
        CREATE INDEX idx_seizures_field_execution_id ON seizures(field_execution_id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_lab_samples_seizure_id') THEN
        CREATE INDEX idx_lab_samples_seizure_id ON lab_samples(seizure_id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_fir_cases_lab_sample_id') THEN
        CREATE INDEX idx_fir_cases_lab_sample_id ON fir_cases(lab_sample_id);
    END IF;
END $$;

-- Enable Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE inspection_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE field_executions ENABLE ROW LEVEL SECURITY;
ALTER TABLE seizures ENABLE ROW LEVEL SECURITY;
ALTER TABLE lab_samples ENABLE ROW LEVEL SECURITY;
ALTER TABLE fir_cases ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Create basic RLS policies (adjust based on your needs)
-- Allow authenticated users to read their own data
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid()::text = id::text);

CREATE POLICY "Users can view all roles" ON roles
    FOR SELECT USING (true);

CREATE POLICY "Users can view role permissions" ON role_permissions
    FOR SELECT USING (true);

-- Insert default roles
INSERT INTO roles (name, description) VALUES
    ('Field Officer', 'Field inspection and execution officer'),
    ('District Agricultural Officer', 'District level agricultural officer'),
    ('Legal Officer', 'Legal and enforcement officer'),
    ('Lab Coordinator', 'Laboratory sample coordinator'),
    ('HQ Monitoring Cell', 'Headquarters monitoring team'),
    ('District Admin', 'District administration'),
    ('Super Admin', 'System administrator with full access'),
    ('QC Department Head', 'Head of Quality Control Department'),
    ('QC Manager', 'Quality Control Manager'),
    ('QC Supervisor', 'Quality Control Supervisor'),
    ('QC Inspector', 'Quality Control Inspector'),
    ('Lab Analyst', 'Laboratory Analyst')
ON CONFLICT (name) DO NOTHING;

-- Insert Super User (password: 123 - Note: In production, use proper hashing)
INSERT INTO users (email, name, officer_code, password, role_id)
SELECT 
    'super@gmail.com',
    'Super Administrator',
    'SUPER001',
    '123',
    id
FROM roles 
WHERE name = 'Super Admin'
ON CONFLICT (email) DO NOTHING;

-- Grant Super Admin full permissions
INSERT INTO role_permissions (role_id, menu_id, auth_type)
SELECT 
    id,
    ARRAY['dashboard', 'administration', 'inspection-planning', 'field-execution', 'seizure-logging', 'lab-interface', 'legal-module', 'report-audit', 'agri-forms-module', 'qc-module'],
    ARRAY['F', 'F', 'F', 'F', 'F', 'F', 'F', 'F', 'F', 'F']
FROM roles 
WHERE name = 'Super Admin'
ON CONFLICT DO NOTHING;

-- Grant QC Module permissions to QC roles
INSERT INTO role_permissions (role_id, menu_id, auth_type)
SELECT 
    id,
    ARRAY['dashboard', 'qc-module', 'inspection-planning', 'field-execution', 'lab-interface', 'report-audit'],
    ARRAY['R', 'F', 'F', 'R', 'F', 'R']
FROM roles 
WHERE name = 'QC Department Head'
ON CONFLICT DO NOTHING;

INSERT INTO role_permissions (role_id, menu_id, auth_type)
SELECT 
    id,
    ARRAY['dashboard', 'qc-module', 'inspection-planning', 'field-execution', 'lab-interface', 'report-audit'],
    ARRAY['R', 'F', 'F', 'R', 'R', 'R']
FROM roles 
WHERE name = 'QC Manager'
ON CONFLICT DO NOTHING;

INSERT INTO role_permissions (role_id, menu_id, auth_type)
SELECT 
    id,
    ARRAY['dashboard', 'qc-module', 'inspection-planning', 'field-execution', 'lab-interface'],
    ARRAY['R', 'F', 'R', 'R', 'R']
FROM roles 
WHERE name = 'QC Supervisor'
ON CONFLICT DO NOTHING;

INSERT INTO role_permissions (role_id, menu_id, auth_type)
SELECT 
    id,
    ARRAY['dashboard', 'qc-module', 'inspection-planning', 'field-execution'],
    ARRAY['R', 'R', 'R', 'R']
FROM roles 
WHERE name = 'QC Inspector'
ON CONFLICT DO NOTHING;

-- =======================
-- QC Department Tables
-- =======================

-- QC Inspections
CREATE TABLE IF NOT EXISTS qc_inspections (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    inspection_code VARCHAR(50) UNIQUE NOT NULL,
    process_type VARCHAR(50) NOT NULL, -- 'routine', 'complaint-based', 'special'
    scheduled_date TIMESTAMPTZ NOT NULL,
    assigned_officer_id UUID REFERENCES users(id),
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    checkpoints JSONB DEFAULT '[]'::jsonb,
    remarks TEXT,
    priority VARCHAR(20) DEFAULT 'medium',
    department VARCHAR(50) DEFAULT 'QC',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- QC Compliance Rules
CREATE TABLE IF NOT EXISTS qc_compliance_rules (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    regulation_type VARCHAR(50) NOT NULL, -- 'FCO', 'BIS', 'State'
    regulation_code VARCHAR(100) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    applicable_products TEXT[],
    parameters JSONB NOT NULL,
    is_mandatory BOOLEAN DEFAULT true,
    effective_from DATE NOT NULL,
    effective_to DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- QC Test Parameters
CREATE TABLE IF NOT EXISTS qc_test_parameters (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    parameter_name VARCHAR(100) NOT NULL,
    test_method VARCHAR(100) NOT NULL,
    unit VARCHAR(50) NOT NULL,
    product_category VARCHAR(50) NOT NULL,
    min_value DECIMAL(10,2),
    max_value DECIMAL(10,2),
    tolerance_percentage DECIMAL(5,2),
    is_critical BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ABC Analysis Results
CREATE TABLE IF NOT EXISTS qc_abc_analysis (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    analysis_type VARCHAR(50) NOT NULL, -- 'product', 'manufacturer', 'defect'
    analysis_date DATE NOT NULL,
    analyzed_by UUID REFERENCES users(id),
    time_range VARCHAR(20) NOT NULL, -- '1month', '3months', '6months', '1year'
    categories JSONB NOT NULL,
    recommendations TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- QC Approval Workflow
CREATE TABLE IF NOT EXISTS qc_approvals (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    item_type VARCHAR(50) NOT NULL, -- 'inspection', 'lab_report', 'deviation'
    item_id VARCHAR(100) NOT NULL,
    approval_level VARCHAR(10) NOT NULL, -- 'L1', 'L2', 'L3', 'L4'
    approver_id UUID REFERENCES users(id),
    decision VARCHAR(20), -- 'approved', 'rejected', 'conditional'
    comments TEXT,
    conditions TEXT[],
    approval_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- QC Checkpoints Master
CREATE TABLE IF NOT EXISTS qc_checkpoint_master (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    checkpoint_name VARCHAR(200) NOT NULL,
    category VARCHAR(50) NOT NULL, -- 'documentation', 'physical', 'chemical', 'compliance'
    description TEXT,
    is_mandatory BOOLEAN DEFAULT true,
    applicable_products TEXT[],
    required_evidence VARCHAR(50), -- 'photo', 'document', 'both', 'none'
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- QC Non-Compliance Records
CREATE TABLE IF NOT EXISTS qc_non_compliance (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    inspection_id UUID REFERENCES qc_inspections(id),
    checkpoint_id UUID REFERENCES qc_checkpoint_master(id),
    severity VARCHAR(20) NOT NULL, -- 'critical', 'major', 'minor'
    description TEXT NOT NULL,
    corrective_action TEXT,
    preventive_action TEXT,
    target_date DATE,
    status VARCHAR(50) DEFAULT 'open', -- 'open', 'in_progress', 'closed'
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for QC tables (with existence checks)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_qc_inspections_status') THEN
        CREATE INDEX idx_qc_inspections_status ON qc_inspections(status);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_qc_inspections_officer') THEN
        CREATE INDEX idx_qc_inspections_officer ON qc_inspections(assigned_officer_id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_qc_approvals_item') THEN
        CREATE INDEX idx_qc_approvals_item ON qc_approvals(item_type, item_id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_qc_non_compliance_status') THEN
        CREATE INDEX idx_qc_non_compliance_status ON qc_non_compliance(status);
    END IF;
END $$;

-- Enable RLS for QC tables
ALTER TABLE qc_inspections ENABLE ROW LEVEL SECURITY;
ALTER TABLE qc_compliance_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE qc_test_parameters ENABLE ROW LEVEL SECURITY;
ALTER TABLE qc_abc_analysis ENABLE ROW LEVEL SECURITY;
ALTER TABLE qc_approvals ENABLE ROW LEVEL SECURITY;
ALTER TABLE qc_checkpoint_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE qc_non_compliance ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for QC tables
CREATE POLICY "QC staff can view inspections" ON qc_inspections
    FOR SELECT USING (true);

CREATE POLICY "QC inspectors can create inspections" ON qc_inspections
    FOR INSERT WITH CHECK (auth.uid()::text IN (
        SELECT u.id::text FROM users u 
        JOIN roles r ON u.role_id = r.id 
        WHERE r.name IN ('QC Inspector', 'QC Supervisor', 'QC Manager', 'QC Department Head', 'Super Admin')
    ));

CREATE POLICY "All can view compliance rules" ON qc_compliance_rules
    FOR SELECT USING (true);

CREATE POLICY "QC managers can manage compliance" ON qc_compliance_rules
    FOR ALL USING (auth.uid()::text IN (
        SELECT u.id::text FROM users u 
        JOIN roles r ON u.role_id = r.id 
        WHERE r.name IN ('QC Manager', 'QC Department Head', 'Super Admin')
    ));

-- Migration: Add metadata column to users table if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT column_name 
                   FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='metadata') THEN
        ALTER TABLE users ADD COLUMN metadata JSONB;
    END IF;
END $$;

-- Migration: Add unique constraint to officer_code if it doesn't exist
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

-- Initialize default roles
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
ON CONFLICT (name) DO NOTHING;
