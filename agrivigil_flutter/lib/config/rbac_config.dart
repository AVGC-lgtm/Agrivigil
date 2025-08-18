// Enhanced RBAC Configuration for QC Department

class RBACConfig {
  // Extended Roles for QC Department
  static const Map<String, RoleDefinition> roles = {
    'SUPER_ADMIN': RoleDefinition(
      id: 'super_admin',
      name: 'Super Administrator',
      description: 'Full system access',
      level: 100,
      department: 'ALL',
    ),
    'QC_HEAD': RoleDefinition(
      id: 'qc_head',
      name: 'QC Department Head',
      description: 'Head of Quality Control Department',
      level: 90,
      department: 'QC',
    ),
    'QC_MANAGER': RoleDefinition(
      id: 'qc_manager',
      name: 'QC Manager',
      description: 'Quality Control Manager',
      level: 80,
      department: 'QC',
    ),
    'QC_SUPERVISOR': RoleDefinition(
      id: 'qc_supervisor',
      name: 'QC Supervisor',
      description: 'Quality Control Supervisor',
      level: 70,
      department: 'QC',
    ),
    'QC_INSPECTOR': RoleDefinition(
      id: 'qc_inspector',
      name: 'QC Inspector',
      description: 'Quality Control Inspector',
      level: 60,
      department: 'QC',
    ),
    'LAB_ANALYST': RoleDefinition(
      id: 'lab_analyst',
      name: 'Lab Analyst',
      description: 'Laboratory Analyst',
      level: 50,
      department: 'LAB',
    ),
    'FIELD_OFFICER': RoleDefinition(
      id: 'field_officer',
      name: 'Field Officer',
      description: 'Field inspection officer',
      level: 40,
      department: 'FIELD',
    ),
    'DAO': RoleDefinition(
      id: 'dao',
      name: 'District Agricultural Officer',
      description: 'District level officer',
      level: 70,
      department: 'ADMIN',
    ),
    'LEGAL_OFFICER': RoleDefinition(
      id: 'legal_officer',
      name: 'Legal Officer',
      description: 'Legal enforcement officer',
      level: 60,
      department: 'LEGAL',
    ),
  };

  // Extended Permissions
  static const Map<String, List<Permission>> modulePermissions = {
    'dashboard': [
      Permission('view_dashboard', 'View Dashboard', ['ALL']),
      Permission('view_analytics', 'View Analytics', ['QC_HEAD', 'QC_MANAGER', 'DAO']),
      Permission('export_reports', 'Export Reports', ['QC_HEAD', 'QC_MANAGER']),
    ],
    'qc_module': [
      Permission('view_qc_dashboard', 'View QC Dashboard', ['QC']),
      Permission('create_qc_inspection', 'Create QC Inspection', ['QC_INSPECTOR', 'QC_SUPERVISOR']),
      Permission('approve_qc_inspection', 'Approve QC Inspection', ['QC_SUPERVISOR', 'QC_MANAGER']),
      Permission('reject_qc_inspection', 'Reject QC Inspection', ['QC_SUPERVISOR', 'QC_MANAGER']),
      Permission('final_approval', 'Final QC Approval', ['QC_MANAGER', 'QC_HEAD']),
      Permission('view_compliance', 'View Compliance', ['QC']),
      Permission('manage_compliance', 'Manage Compliance', ['QC_MANAGER', 'QC_HEAD']),
      Permission('abc_analysis', 'Perform ABC Analysis', ['QC_SUPERVISOR', 'QC_MANAGER', 'QC_HEAD']),
    ],
    'inspection_planning': [
      Permission('view_inspections', 'View Inspections', ['ALL']),
      Permission('create_inspection', 'Create Inspection', ['QC_INSPECTOR', 'FIELD_OFFICER']),
      Permission('edit_inspection', 'Edit Inspection', ['QC_SUPERVISOR']),
      Permission('delete_inspection', 'Delete Inspection', ['QC_MANAGER']),
      Permission('assign_inspector', 'Assign Inspector', ['QC_SUPERVISOR', 'QC_MANAGER']),
    ],
    'lab_interface': [
      Permission('view_samples', 'View Lab Samples', ['LAB', 'QC']),
      Permission('create_sample', 'Create Lab Sample', ['LAB_ANALYST', 'QC_INSPECTOR']),
      Permission('enter_test_results', 'Enter Test Results', ['LAB_ANALYST']),
      Permission('approve_test_results', 'Approve Test Results', ['QC_SUPERVISOR']),
      Permission('generate_lab_report', 'Generate Lab Report', ['LAB_ANALYST', 'QC_SUPERVISOR']),
    ],
    'administration': [
      Permission('view_users', 'View Users', ['ADMIN', 'QC_HEAD']),
      Permission('manage_users', 'Manage Users', ['ADMIN']),
      Permission('manage_roles', 'Manage Roles', ['SUPER_ADMIN']),
      Permission('view_audit_logs', 'View Audit Logs', ['QC_MANAGER', 'QC_HEAD', 'ADMIN']),
    ],
  };

  // Approval Hierarchy
  static const Map<String, List<String>> approvalHierarchy = {
    'qc_inspection': ['QC_INSPECTOR', 'QC_SUPERVISOR', 'QC_MANAGER', 'QC_HEAD'],
    'lab_report': ['LAB_ANALYST', 'QC_SUPERVISOR', 'QC_MANAGER'],
    'compliance_deviation': ['QC_SUPERVISOR', 'QC_MANAGER', 'QC_HEAD'],
    'fir_case': ['FIELD_OFFICER', 'QC_SUPERVISOR', 'LEGAL_OFFICER', 'DAO'],
  };

  // Data Access Rules
  static const Map<String, DataAccessRule> dataAccessRules = {
    'QC_INSPECTOR': DataAccessRule(
      ownDataOnly: false,
      districtLevel: true,
      stateLevel: false,
      nationalLevel: false,
    ),
    'QC_SUPERVISOR': DataAccessRule(
      ownDataOnly: false,
      districtLevel: true,
      stateLevel: false,
      nationalLevel: false,
    ),
    'QC_MANAGER': DataAccessRule(
      ownDataOnly: false,
      districtLevel: false,
      stateLevel: true,
      nationalLevel: false,
    ),
    'QC_HEAD': DataAccessRule(
      ownDataOnly: false,
      districtLevel: false,
      stateLevel: false,
      nationalLevel: true,
    ),
  };
}

class RoleDefinition {
  final String id;
  final String name;
  final String description;
  final int level; // Higher level = more authority
  final String department;

  const RoleDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.department,
  });
}

class Permission {
  final String id;
  final String name;
  final List<String> allowedDepartments;

  const Permission(this.id, this.name, this.allowedDepartments);
}

class DataAccessRule {
  final bool ownDataOnly;
  final bool districtLevel;
  final bool stateLevel;
  final bool nationalLevel;

  const DataAccessRule({
    required this.ownDataOnly,
    required this.districtLevel,
    required this.stateLevel,
    required this.nationalLevel,
  });
}

// Action-Based Access Control (ABAC) attributes
class ABACAttributes {
  static bool canPerformAction({
    required String userId,
    required String action,
    required Map<String, dynamic> resource,
    required Map<String, dynamic> context,
  }) {
    // Implement attribute-based rules
    final userRole = context['userRole'];
    final userDepartment = context['userDepartment'];
    final userLevel = context['userLevel'];
    final resourceType = resource['type'];
    final resourceStatus = resource['status'];
    final resourceOwner = resource['ownerId'];

    // Example rules
    switch (action) {
      case 'approve_qc_inspection':
        // Can only approve if user level is higher than creator
        // and inspection is in 'awaiting_approval' status
        return userLevel > resource['creatorLevel'] && 
               resourceStatus == 'awaiting_approval' &&
               userDepartment == 'QC';
               
      case 'edit_lab_result':
        // Can only edit own lab results within 24 hours
        final isOwner = userId == resourceOwner;
        final isWithin24Hours = DateTime.now().difference(
          DateTime.parse(resource['createdAt'])
        ).inHours < 24;
        return isOwner && isWithin24Hours;
        
      case 'view_confidential_report':
        // Only QC Head and managers can view confidential reports
        return ['QC_HEAD', 'QC_MANAGER'].contains(userRole);
        
      default:
        return false;
    }
  }
}

// Workflow States and Transitions
class WorkflowConfig {
  static const Map<String, List<WorkflowTransition>> workflows = {
    'qc_inspection': [
      WorkflowTransition(
        from: 'draft',
        to: 'submitted',
        requiredRole: 'QC_INSPECTOR',
        action: 'submit_inspection',
      ),
      WorkflowTransition(
        from: 'submitted',
        to: 'under_review',
        requiredRole: 'QC_SUPERVISOR',
        action: 'start_review',
      ),
      WorkflowTransition(
        from: 'under_review',
        to: 'approved',
        requiredRole: 'QC_SUPERVISOR',
        action: 'approve',
      ),
      WorkflowTransition(
        from: 'under_review',
        to: 'rejected',
        requiredRole: 'QC_SUPERVISOR',
        action: 'reject',
      ),
      WorkflowTransition(
        from: 'approved',
        to: 'final_approved',
        requiredRole: 'QC_MANAGER',
        action: 'final_approve',
      ),
    ],
  };
}

class WorkflowTransition {
  final String from;
  final String to;
  final String requiredRole;
  final String action;

  const WorkflowTransition({
    required this.from,
    required this.to,
    required this.requiredRole,
    required this.action,
  });
}
