-- =====================================================
-- AGRIVIGIL Indexes and Row Level Security Policies
-- Version: 2.0
-- =====================================================

-- =====================================================
-- PRE-CHECKS: Ensure required columns exist
-- =====================================================
-- Run column fixes first if needed
DO $$
BEGIN
    -- Check if critical columns are missing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='role_permissions' AND column_name='module') OR
       NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='inspection_tasks' AND column_name='priority') OR
       NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='lab_samples' AND column_name='field_execution_id') OR
       NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='field_executions' AND column_name='verification_status') OR
       NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='roles' AND column_name='is_active') OR
       NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='products' AND column_name='is_active') OR
       NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='scan_results' AND column_name='scanned_by') THEN
        RAISE NOTICE '';
        RAISE NOTICE '⚠️  WARNING: Some columns required for indexes are missing!';
        RAISE NOTICE 'Please run one of these commands first:';
        RAISE NOTICE '  \i fix_all_column_errors.sql    (recommended)';
        RAISE NOTICE '  \i 04_migration_from_existing.sql';
        RAISE NOTICE '';
    END IF;
END $$;

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Core table indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_officer_code ON users(officer_code);
CREATE INDEX IF NOT EXISTS idx_users_role_id ON users(role_id);
CREATE INDEX IF NOT EXISTS idx_users_district ON users(district);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_roles_code ON roles(code);

-- Ensure is_active column exists before creating index
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name='roles' AND column_name='is_active') THEN
        CREATE INDEX IF NOT EXISTS idx_roles_is_active ON roles(is_active);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_role_permissions_role_id ON role_permissions(role_id);

-- Ensure module column exists before creating index
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name='role_permissions' AND column_name='module') THEN
        CREATE INDEX IF NOT EXISTS idx_role_permissions_module ON role_permissions(module);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_sessions_token ON user_sessions(token);
CREATE INDEX IF NOT EXISTS idx_user_sessions_expires_at ON user_sessions(expires_at);

-- Inspection and field execution indexes
CREATE INDEX IF NOT EXISTS idx_inspection_tasks_user_id ON inspection_tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_inspection_tasks_status ON inspection_tasks(status);
CREATE INDEX IF NOT EXISTS idx_inspection_tasks_district ON inspection_tasks(district);
CREATE INDEX IF NOT EXISTS idx_inspection_tasks_datetime ON inspection_tasks(datetime);

-- Ensure priority column exists before creating index
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name='inspection_tasks' AND column_name='priority') THEN
        CREATE INDEX IF NOT EXISTS idx_inspection_tasks_priority ON inspection_tasks(priority);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_field_executions_inspectionid ON field_executions(inspectionid);
CREATE INDEX IF NOT EXISTS idx_field_executions_fieldcode ON field_executions(fieldcode);
CREATE INDEX IF NOT EXISTS idx_field_executions_userid ON field_executions(userid);
CREATE INDEX IF NOT EXISTS idx_field_executions_sampling_date ON field_executions(sampling_date);
CREATE INDEX IF NOT EXISTS idx_field_executions_batch_no ON field_executions(batch_no);

-- Product and scan indexes
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_company ON products(company);

-- Ensure is_active column exists before creating index
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name='products' AND column_name='is_active') THEN
        CREATE INDEX IF NOT EXISTS idx_products_is_active ON products(is_active);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_scan_results_product_id ON scan_results(product_id);
CREATE INDEX IF NOT EXISTS idx_scan_results_batch_number ON scan_results(batch_number);
CREATE INDEX IF NOT EXISTS idx_scan_results_timestamp ON scan_results(timestamp DESC);

-- Ensure scanned_by column exists before creating index
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name='scan_results' AND column_name='scanned_by') THEN
        CREATE INDEX IF NOT EXISTS idx_scan_results_scanned_by ON scan_results(scanned_by);
    END IF;
END $$;

-- Seizure and legal indexes
CREATE INDEX IF NOT EXISTS idx_seizures_field_execution_id ON seizures(field_execution_id);
CREATE INDEX IF NOT EXISTS idx_seizures_seizurecode ON seizures(seizurecode);
CREATE INDEX IF NOT EXISTS idx_seizures_status ON seizures(status);
CREATE INDEX IF NOT EXISTS idx_seizures_seizure_date ON seizures(seizure_date);
CREATE INDEX IF NOT EXISTS idx_seizures_user_id ON seizures(user_id);

CREATE INDEX IF NOT EXISTS idx_fir_cases_fircode ON fir_cases(fircode);
CREATE INDEX IF NOT EXISTS idx_fir_cases_user_id ON fir_cases(user_id);
CREATE INDEX IF NOT EXISTS idx_fir_cases_seizure_id ON fir_cases(seizure_id);
CREATE INDEX IF NOT EXISTS idx_fir_cases_case_status ON fir_cases(case_status);

-- Lab sample indexes
CREATE INDEX IF NOT EXISTS idx_lab_samples_samplecode ON lab_samples(samplecode);
CREATE INDEX IF NOT EXISTS idx_lab_samples_status ON lab_samples(status);
CREATE INDEX IF NOT EXISTS idx_lab_samples_seizure_id ON lab_samples(seizure_id);

-- Ensure field_execution_id column exists before creating index
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name='lab_samples' AND column_name='field_execution_id') THEN
        CREATE INDEX IF NOT EXISTS idx_lab_samples_field_execution_id ON lab_samples(field_execution_id);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_lab_samples_collected_at ON lab_samples(collected_at);

CREATE INDEX IF NOT EXISTS idx_lab_test_results_sample_id ON lab_test_results(sample_id);
CREATE INDEX IF NOT EXISTS idx_lab_test_results_parameter ON lab_test_results(parameter);
CREATE INDEX IF NOT EXISTS idx_lab_test_results_result ON lab_test_results(result);

-- QC department indexes
CREATE INDEX IF NOT EXISTS idx_qc_inspections_status ON qc_inspections(status);
CREATE INDEX IF NOT EXISTS idx_qc_inspections_officer ON qc_inspections(assigned_officer_id);
CREATE INDEX IF NOT EXISTS idx_qc_inspections_scheduled_date ON qc_inspections(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_qc_inspections_priority ON qc_inspections(priority);

CREATE INDEX IF NOT EXISTS idx_qc_approvals_item ON qc_approvals(item_type, item_id);
CREATE INDEX IF NOT EXISTS idx_qc_approvals_approver ON qc_approvals(approver_id);
CREATE INDEX IF NOT EXISTS idx_qc_approvals_decision ON qc_approvals(decision);

CREATE INDEX IF NOT EXISTS idx_qc_non_compliance_status ON qc_non_compliance(status);
CREATE INDEX IF NOT EXISTS idx_qc_non_compliance_severity ON qc_non_compliance(severity);
CREATE INDEX IF NOT EXISTS idx_qc_non_compliance_target_date ON qc_non_compliance(target_date);

-- Audit and system indexes
CREATE INDEX IF NOT EXISTS idx_audit_logs_entity ON audit_logs(entity, entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);

-- Composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_inspection_tasks_user_status ON inspection_tasks(user_id, status);

-- Ensure verification_status column exists before creating composite index
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name='field_executions' AND column_name='verification_status') THEN
        CREATE INDEX IF NOT EXISTS idx_field_executions_inspection_status ON field_executions(inspectionid, verification_status);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_seizures_district_status ON seizures(district, status);
CREATE INDEX IF NOT EXISTS idx_lab_samples_district_status ON lab_samples(district, status);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE inspection_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE field_executions ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE scan_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE seizures ENABLE ROW LEVEL SECURITY;
ALTER TABLE fir_cases ENABLE ROW LEVEL SECURITY;
ALTER TABLE lab_samples ENABLE ROW LEVEL SECURITY;
ALTER TABLE lab_test_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE qc_inspections ENABLE ROW LEVEL SECURITY;
ALTER TABLE qc_compliance_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE qc_test_parameters ENABLE ROW LEVEL SECURITY;
ALTER TABLE qc_abc_analysis ENABLE ROW LEVEL SECURITY;
ALTER TABLE qc_approvals ENABLE ROW LEVEL SECURITY;
ALTER TABLE qc_checkpoint_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE qc_non_compliance ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_settings ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- USER AND ROLE POLICIES
-- =====================================================

-- Users can view their own profile
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid()::text = id::text);

-- Admins can view all users
CREATE POLICY "Admins can view all users" ON users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.id::text = auth.uid()::text 
            AND r.code IN ('SA', 'DA')
        )
    );

-- District officers can view users in their district
CREATE POLICY "District officers view district users" ON users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.id::text = auth.uid()::text 
            AND r.code = 'DAO'
            AND u.district = users.district
        )
    );

-- Everyone can view roles
CREATE POLICY "Public can view roles" ON roles
    FOR SELECT USING (is_active = true);

-- Only admins can modify roles
CREATE POLICY "Admins can manage roles" ON roles
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.id::text = auth.uid()::text 
            AND r.code = 'SA'
        )
    );

-- =====================================================
-- INSPECTION AND FIELD EXECUTION POLICIES
-- =====================================================

-- Users can view their assigned inspections
CREATE POLICY "Users view own inspections" ON inspection_tasks
    FOR SELECT USING (
        user_id::text = auth.uid()::text
        OR auth.uid()::text = ANY(assigned_team::text[])
    );

-- District officers can view all inspections in their district
CREATE POLICY "District officers view district inspections" ON inspection_tasks
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.id::text = auth.uid()::text 
            AND r.code IN ('DAO', 'DA')
            AND u.district = inspection_tasks.district
        )
    );

-- Field officers can create and update their inspections
CREATE POLICY "Field officers manage inspections" ON inspection_tasks
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.id::text = auth.uid()::text 
            AND r.code = 'FO'
            AND (user_id::text = auth.uid()::text OR user_id IS NULL)
        )
    );

-- Similar policies for field_executions
CREATE POLICY "Users view own field executions" ON field_executions
    FOR SELECT USING (userid::text = auth.uid()::text);

CREATE POLICY "District officers view district executions" ON field_executions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users u
            JOIN roles r ON u.role_id = r.id
            JOIN inspection_tasks it ON field_executions.inspectionid = it.id
            WHERE u.id::text = auth.uid()::text 
            AND r.code IN ('DAO', 'DA')
            AND u.district = it.district
        )
    );

-- =====================================================
-- PRODUCT AND SCAN POLICIES
-- =====================================================

-- All authenticated users can view active products
CREATE POLICY "Authenticated users view products" ON products
    FOR SELECT USING (is_active = true);

-- Only specific roles can manage products
CREATE POLICY "Product managers modify products" ON products
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.id::text = auth.uid()::text 
            AND r.code IN ('SA', 'QCM', 'QCH')
        )
    );

-- Users can view their own scan results
-- Note: Requires scanned_by column (added by fix_all_column_errors.sql)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name='scan_results' AND column_name='scanned_by') THEN
        IF NOT EXISTS (SELECT 1 FROM pg_policies 
                       WHERE tablename = 'scan_results' 
                       AND policyname = 'Users view own scans') THEN
            CREATE POLICY "Users view own scans" ON scan_results
                FOR SELECT USING (scanned_by::text = auth.uid()::text);
        END IF;
    END IF;
END $$;

-- =====================================================
-- LAB AND QC POLICIES
-- =====================================================

-- Lab personnel can view and manage lab samples
CREATE POLICY "Lab personnel manage samples" ON lab_samples
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.id::text = auth.uid()::text 
            AND r.code IN ('LA', 'LC')
        )
    );

-- QC personnel can view and manage QC inspections
CREATE POLICY "QC personnel manage inspections" ON qc_inspections
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.id::text = auth.uid()::text 
            AND r.code IN ('QC', 'QCS', 'QCM', 'QCH')
        )
    );

-- =====================================================
-- NOTIFICATION POLICIES
-- =====================================================

-- Users can only view their own notifications
CREATE POLICY "Users view own notifications" ON notifications
    FOR SELECT USING (user_id::text = auth.uid()::text);

-- Users can update their own notifications (mark as read)
CREATE POLICY "Users update own notifications" ON notifications
    FOR UPDATE USING (user_id::text = auth.uid()::text);

-- =====================================================
-- AUDIT LOG POLICIES
-- =====================================================

-- Only admins can view audit logs
CREATE POLICY "Admins view audit logs" ON audit_logs
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.id::text = auth.uid()::text 
            AND r.code IN ('SA', 'HQ')
        )
    );

-- System automatically creates audit logs
CREATE POLICY "System creates audit logs" ON audit_logs
    FOR INSERT WITH CHECK (true);

-- =====================================================
-- SYSTEM SETTINGS POLICIES
-- =====================================================

-- Public settings are viewable by all
CREATE POLICY "Public view public settings" ON system_settings
    FOR SELECT USING (is_public = true);

-- Only super admins can manage settings
CREATE POLICY "Super admins manage settings" ON system_settings
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.id::text = auth.uid()::text 
            AND r.code = 'SA'
        )
    );

-- =====================================================
-- END OF INDEXES AND POLICIES
-- =====================================================
