-- =====================================================
-- AGRIVIGIL Master Database Schema
-- Version: 2.0
-- Last Updated: 2024
-- =====================================================
-- This is the complete database schema for AGRIVIGIL
-- Including all modules: Core, Field Operations, QC, Legal, Lab
-- =====================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- CORE TABLES
-- =====================================================

-- Roles table with enhanced features
CREATE TABLE IF NOT EXISTS roles (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    dashboard_route VARCHAR(100) NOT NULL,
    priority INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    permissions JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Users table with complete registration fields
CREATE TABLE IF NOT EXISTS users (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL, -- In production, use Supabase Auth
    phone VARCHAR(20) NOT NULL,
    officer_code VARCHAR(50) UNIQUE NOT NULL,
    role_id UUID REFERENCES roles(id) ON DELETE RESTRICT,
    district VARCHAR(100) NOT NULL,
    state VARCHAR(100) DEFAULT 'Maharashtra',
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    metadata JSONB DEFAULT '{}',
    last_login TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Role permissions table
CREATE TABLE IF NOT EXISTS role_permissions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    role_id UUID REFERENCES roles(id) ON DELETE CASCADE,
    module VARCHAR(50) NOT NULL,
    menu_id TEXT[],
    auth_type TEXT[], -- 'R' (Read), 'W' (Write), 'D' (Delete), 'F' (Full)
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(role_id, module)
);

-- User sessions table
CREATE TABLE IF NOT EXISTS user_sessions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    token TEXT UNIQUE NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- INSPECTION & FIELD EXECUTION TABLES
-- =====================================================

-- Inspection tasks table
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
    totaltarget INTEGER NOT NULL,
    achievedtarget INTEGER DEFAULT 0,
    status VARCHAR(50) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),
    assigned_team UUID[],
    priority VARCHAR(20) DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Field executions table
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
    -- Chemical composition fields
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
    -- Evidence fields
    document TEXT NOT NULL,
    productphoto TEXT NOT NULL,
    additional_photos TEXT[],
    gps_location JSONB,
    userid UUID REFERENCES users(id),
    verification_status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- PRODUCT & SCAN TABLES
-- =====================================================

-- Products master table
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
    subsidized_rate DECIMAL(10,2),
    varieties TEXT[],
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(category, company, name)
);

-- Scan results table
CREATE TABLE IF NOT EXISTS scan_results (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    company VARCHAR(255) NOT NULL,
    product VARCHAR(255) NOT NULL,
    batch_number VARCHAR(100) NOT NULL,
    authenticity_score FLOAT NOT NULL CHECK (authenticity_score >= 0 AND authenticity_score <= 100),
    issues TEXT[],
    recommendation VARCHAR(100) NOT NULL,
    geo_location JSONB NOT NULL,
    timestamp TIMESTAMPTZ NOT NULL,
    product_id UUID REFERENCES products(id),
    scanned_by UUID REFERENCES users(id),
    device_info JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- SEIZURE & LEGAL TABLES
-- =====================================================

-- Seizures table
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
    estimated_value DECIMAL(12,2),
    witness_name VARCHAR(255),
    witness_contact VARCHAR(20),
    evidence_photos TEXT[],
    video_evidence TEXT,
    status VARCHAR(50) DEFAULT 'pending',
    remarks TEXT,
    seizure_date DATE,
    memo_no VARCHAR(100),
    officer_name VARCHAR(255),
    user_id UUID REFERENCES users(id),
    scan_result_id UUID REFERENCES scan_results(id),
    approval_status VARCHAR(50) DEFAULT 'pending',
    approved_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- FIR cases table
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
    case_status VARCHAR(50) DEFAULT 'filed',
    court_name VARCHAR(255),
    next_hearing_date DATE,
    user_id UUID REFERENCES users(id),
    lab_sample_id INTEGER,
    seizure_id UUID REFERENCES seizures(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- LAB & SAMPLE MANAGEMENT TABLES
-- =====================================================

-- Lab samples table
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
    priority VARCHAR(20) DEFAULT 'normal',
    test_parameters JSONB,
    user_id UUID REFERENCES users(id),
    seizure_id UUID REFERENCES seizures(id),
    field_execution_id INTEGER REFERENCES field_executions(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Lab test results table
CREATE TABLE IF NOT EXISTS lab_test_results (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    sample_id INTEGER REFERENCES lab_samples(id),
    test_name VARCHAR(100) NOT NULL,
    test_method VARCHAR(100),
    parameter VARCHAR(100) NOT NULL,
    unit VARCHAR(50),
    specification_min DECIMAL(10,4),
    specification_max DECIMAL(10,4),
    actual_value DECIMAL(10,4),
    result VARCHAR(20) CHECK (result IN ('pass', 'fail', 'pending')),
    tested_by UUID REFERENCES users(id),
    tested_at TIMESTAMPTZ,
    verified_by UUID REFERENCES users(id),
    verified_at TIMESTAMPTZ,
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- QC DEPARTMENT TABLES
-- =====================================================

-- QC Inspections
CREATE TABLE IF NOT EXISTS qc_inspections (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    inspection_code VARCHAR(50) UNIQUE NOT NULL,
    process_type VARCHAR(50) NOT NULL CHECK (process_type IN ('routine', 'complaint-based', 'special', 'follow-up')),
    scheduled_date TIMESTAMPTZ NOT NULL,
    assigned_officer_id UUID REFERENCES users(id),
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    checkpoints JSONB DEFAULT '[]'::jsonb,
    remarks TEXT,
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'critical')),
    department VARCHAR(50) DEFAULT 'QC',
    linked_complaint_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- QC Compliance Rules
CREATE TABLE IF NOT EXISTS qc_compliance_rules (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    regulation_type VARCHAR(50) NOT NULL CHECK (regulation_type IN ('FCO', 'BIS', 'State', 'International')),
    regulation_code VARCHAR(100) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    applicable_products TEXT[],
    parameters JSONB NOT NULL,
    is_mandatory BOOLEAN DEFAULT true,
    effective_from DATE NOT NULL,
    effective_to DATE,
    penalty_amount DECIMAL(10,2),
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
    min_value DECIMAL(10,4),
    max_value DECIMAL(10,4),
    tolerance_percentage DECIMAL(5,2),
    is_critical BOOLEAN DEFAULT false,
    test_frequency VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ABC Analysis Results
CREATE TABLE IF NOT EXISTS qc_abc_analysis (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    analysis_type VARCHAR(50) NOT NULL CHECK (analysis_type IN ('product', 'manufacturer', 'defect', 'location')),
    analysis_date DATE NOT NULL,
    analyzed_by UUID REFERENCES users(id),
    time_range VARCHAR(20) NOT NULL CHECK (time_range IN ('1month', '3months', '6months', '1year', 'custom')),
    categories JSONB NOT NULL,
    recommendations TEXT,
    action_items JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- QC Approval Workflow
CREATE TABLE IF NOT EXISTS qc_approvals (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    item_type VARCHAR(50) NOT NULL CHECK (item_type IN ('inspection', 'lab_report', 'deviation', 'compliance')),
    item_id VARCHAR(100) NOT NULL,
    approval_level VARCHAR(10) NOT NULL CHECK (approval_level IN ('L1', 'L2', 'L3', 'L4')),
    approver_id UUID REFERENCES users(id),
    decision VARCHAR(20) CHECK (decision IN ('approved', 'rejected', 'conditional', 'pending')),
    comments TEXT,
    conditions TEXT[],
    approval_date TIMESTAMPTZ,
    due_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(item_type, item_id, approval_level)
);

-- QC Checkpoints Master
CREATE TABLE IF NOT EXISTS qc_checkpoint_master (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    checkpoint_name VARCHAR(200) NOT NULL,
    category VARCHAR(50) NOT NULL CHECK (category IN ('documentation', 'physical', 'chemical', 'compliance', 'packaging')),
    description TEXT,
    is_mandatory BOOLEAN DEFAULT true,
    applicable_products TEXT[],
    required_evidence VARCHAR(50) CHECK (required_evidence IN ('photo', 'document', 'both', 'none')),
    weightage INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- QC Non-Compliance Records
CREATE TABLE IF NOT EXISTS qc_non_compliance (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    inspection_id UUID REFERENCES qc_inspections(id),
    checkpoint_id UUID REFERENCES qc_checkpoint_master(id),
    severity VARCHAR(20) NOT NULL CHECK (severity IN ('critical', 'major', 'minor', 'observation')),
    description TEXT NOT NULL,
    corrective_action TEXT,
    preventive_action TEXT,
    target_date DATE,
    completion_date DATE,
    status VARCHAR(50) DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'closed', 'overdue')),
    created_by UUID REFERENCES users(id),
    assigned_to UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- AUDIT & SYSTEM TABLES
-- =====================================================

-- Audit logs table
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    action VARCHAR(100) NOT NULL,
    entity VARCHAR(100) NOT NULL,
    entity_id VARCHAR(100) NOT NULL,
    old_data JSONB,
    new_data JSONB,
    user_id UUID REFERENCES users(id),
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    priority VARCHAR(20) DEFAULT 'normal',
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMPTZ,
    action_url VARCHAR(255),
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- System settings table
CREATE TABLE IF NOT EXISTS system_settings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    key VARCHAR(100) UNIQUE NOT NULL,
    value JSONB NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- VIEWS
-- =====================================================

-- User details view
-- First ensure state column exists
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='users' AND column_name='state') THEN
        ALTER TABLE users ADD COLUMN state VARCHAR(100) DEFAULT 'Maharashtra';
    END IF;
END $$;

-- Drop existing view to avoid column name conflicts
DROP VIEW IF EXISTS user_details CASCADE;

CREATE VIEW user_details AS
SELECT 
    u.id,
    u.email,
    u.name,
    u.phone,
    u.officer_code,
    u.district,
    u.state,
    u.status,
    u.last_login,
    u.created_at,
    r.name as role_name,
    r.code as role_code,
    r.dashboard_route,
    r.description as role_description,
    r.priority as role_priority
FROM users u
LEFT JOIN roles r ON u.role_id = r.id;

-- Active inspections view
-- Ensure priority column exists first
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='inspection_tasks' AND column_name='priority') THEN
        ALTER TABLE inspection_tasks ADD COLUMN priority VARCHAR(20) DEFAULT 'normal';
        ALTER TABLE inspection_tasks ADD CONSTRAINT inspection_tasks_priority_check 
            CHECK (priority IN ('low', 'normal', 'high', 'urgent'));
    END IF;
END $$;

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

-- Lab sample status view
-- Ensure field_execution_id column exists first
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='lab_samples' AND column_name='field_execution_id') THEN
        ALTER TABLE lab_samples ADD COLUMN field_execution_id INTEGER REFERENCES field_executions(id);
    END IF;
END $$;

DROP VIEW IF EXISTS lab_sample_status CASCADE;
CREATE VIEW lab_sample_status AS
SELECT 
    ls.id,
    ls.samplecode,
    ls.department,
    ls.district,
    ls.status,
    ls.collected_at,
    ls.result_status,
    u.name as officer_name,
    fe.fieldcode,
    fe.companyname,
    fe.productname
FROM lab_samples ls
LEFT JOIN users u ON ls.user_id = u.id
LEFT JOIN field_executions fe ON ls.field_execution_id = fe.id;

-- =====================================================
-- FUNCTIONS & TRIGGERS
-- =====================================================

-- Update timestamp function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create update triggers for all tables with updated_at
DO $$
DECLARE
    t text;
BEGIN
    FOR t IN 
        SELECT table_name 
        FROM information_schema.columns 
        WHERE column_name = 'updated_at' 
        AND table_schema = 'public'
    LOOP
        EXECUTE format('
            CREATE TRIGGER update_%I_updated_at 
            BEFORE UPDATE ON %I 
            FOR EACH ROW 
            EXECUTE FUNCTION update_updated_at_column()',
            t, t);
    END LOOP;
END$$;

-- Audit log function
CREATE OR REPLACE FUNCTION create_audit_log()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_logs (
        action,
        entity,
        entity_id,
        old_data,
        new_data,
        user_id
    ) VALUES (
        TG_OP,
        TG_TABLE_NAME,
        CASE 
            WHEN TG_OP = 'DELETE' THEN OLD.id::text
            ELSE NEW.id::text
        END,
        CASE 
            WHEN TG_OP IN ('UPDATE', 'DELETE') THEN to_jsonb(OLD)
            ELSE NULL
        END,
        CASE 
            WHEN TG_OP IN ('INSERT', 'UPDATE') THEN to_jsonb(NEW)
            ELSE NULL
        END,
        current_setting('app.current_user_id', true)::uuid
    );
    RETURN NEW;
END;
$$ language 'plpgsql';

-- =====================================================
-- END OF SCHEMA
-- =====================================================
