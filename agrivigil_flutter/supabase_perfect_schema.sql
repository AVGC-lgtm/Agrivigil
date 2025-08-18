-- AGRIVIGIL Perfect Database Schema for Supabase
-- Based on your registration screen fields

-- Enable UUID extension if not exists
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop existing tables if needed (BE CAREFUL IN PRODUCTION!)
-- DROP TABLE IF EXISTS users CASCADE;
-- DROP TABLE IF EXISTS roles CASCADE;

-- Create roles table
CREATE TABLE IF NOT EXISTS roles (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL, -- Short code like 'FO', 'DAO', etc.
    description TEXT,
    dashboard_route VARCHAR(100) NOT NULL, -- Route to redirect after login
    priority INTEGER DEFAULT 0, -- For sorting
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create users table with all registration fields
CREATE TABLE IF NOT EXISTS users (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL, -- In production, use Supabase Auth
    phone VARCHAR(20) NOT NULL,
    officer_code VARCHAR(50) UNIQUE NOT NULL,
    role_id UUID REFERENCES roles(id) ON DELETE RESTRICT,
    district VARCHAR(100) NOT NULL,
    state VARCHAR(100) DEFAULT 'Maharashtra', -- Added state column
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    metadata JSONB DEFAULT '{}', -- For additional flexible data
    last_login TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default roles with dashboard routes
INSERT INTO roles (name, code, description, dashboard_route, priority) VALUES
    ('Field Officer', 'FO', 'Field inspection and execution officer', '/field-officer-dashboard', 1),
    ('Lab Analyst', 'LA', 'Laboratory analysis and testing', '/lab-analyst-dashboard', 2),
    ('QC Inspector', 'QC', 'Quality Control inspection', '/qc-inspector-dashboard', 3),
    ('District Agriculture Officer', 'DAO', 'District level agriculture officer', '/dao-dashboard', 4),
    ('Legal Officer', 'LO', 'Legal and compliance officer', '/legal-officer-dashboard', 5),
    ('Lab Coordinator', 'LC', 'Laboratory coordination and management', '/lab-coordinator-dashboard', 6),
    ('HQ Monitoring', 'HQ', 'Headquarters monitoring team', '/hq-monitoring-dashboard', 7),
    ('District Admin', 'DA', 'District administration', '/district-admin-dashboard', 8),
    ('Super Admin', 'SA', 'System administrator with full access', '/admin-dashboard', 99)
ON CONFLICT (name) DO UPDATE SET 
    code = EXCLUDED.code,
    description = EXCLUDED.description,
    dashboard_route = EXCLUDED.dashboard_route,
    priority = EXCLUDED.priority;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role_id ON users(role_id);
CREATE INDEX IF NOT EXISTS idx_users_officer_code ON users(officer_code);
CREATE INDEX IF NOT EXISTS idx_users_district ON users(district);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_roles_updated_at BEFORE UPDATE ON roles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create view for user details with role
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
    r.description as role_description
FROM users u
LEFT JOIN roles r ON u.role_id = r.id;

-- Row Level Security (RLS) policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own data
CREATE POLICY "Users can view own data" ON users
    FOR SELECT USING (auth.uid()::text = id::text);

-- Allow admins to view all users
CREATE POLICY "Admins can view all users" ON users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.id::text = auth.uid()::text 
            AND r.code = 'SA'
        )
    );

-- Everyone can view roles
CREATE POLICY "Public can view roles" ON roles
    FOR SELECT USING (true);

-- Sample data for testing (REMOVE IN PRODUCTION)
-- INSERT INTO users (email, name, password, phone, officer_code, role_id, district) 
-- SELECT 
--     'test.fo@agrivigil.com',
--     'Test Field Officer',
--     'password123', -- Use proper hashing!
--     '9876543210',
--     'FO-MH-001',
--     id,
--     'Mumbai'
-- FROM roles WHERE code = 'FO';
