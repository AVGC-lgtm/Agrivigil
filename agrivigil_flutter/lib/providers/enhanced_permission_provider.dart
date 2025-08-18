import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../config/rbac_config.dart';
import 'auth_provider.dart';

class EnhancedPermissionProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
  AuthProvider? _authProvider;
  RoleDefinition? _userRole;
  Map<String, List<String>> _modulePermissions = {};
  Map<String, dynamic> _userContext = {};
  bool _isLoading = false;
  String? _error;

  RoleDefinition? get userRole => _userRole;
  Map<String, List<String>> get modulePermissions => _modulePermissions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    _loadEnhancedPermissions();
  }

  Future<void> _loadEnhancedPermissions() async {
    if (_authProvider == null || _authProvider!.user == null) {
      _clearPermissions();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _authProvider!.user!;
      
      // Load user role details
      final roleResponse = await _supabase
          .from('roles')
          .select()
          .eq('id', user.roleId)
          .single();

      // Map to role definition
      final roleName = roleResponse['name'] as String;
      _userRole = _getRoleDefinitionByName(roleName);
      
      if (_userRole == null) {
        throw Exception('Unknown role: $roleName');
      }

      // Build user context for ABAC
      _userContext = {
        'userId': user.id,
        'userRole': _userRole!.id,
        'userDepartment': _userRole!.department,
        'userLevel': _userRole!.level,
        'userDistrict': user.officerCode?.substring(0, 3), // Extract district from officer code
        'userState': user.officerCode?.substring(3, 5), // Extract state from officer code
      };

      // Load module permissions based on role
      _loadModulePermissions();
      
    } catch (e) {
      _error = 'Failed to load enhanced permissions: ${e.toString()}';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadModulePermissions() {
    _modulePermissions = {};
    
    RBACConfig.modulePermissions.forEach((module, permissions) {
      final allowedPermissions = <String>[];
      
      for (final permission in permissions) {
        if (_canAccessPermission(permission)) {
          allowedPermissions.add(permission.id);
        }
      }
      
      if (allowedPermissions.isNotEmpty) {
        _modulePermissions[module] = allowedPermissions;
      }
    });
  }

  bool _canAccessPermission(Permission permission) {
    if (_authProvider?.isSuperUser ?? false) {
      return true;
    }
    
    if (_userRole == null) return false;
    
    // Check if user's department is allowed
    if (permission.allowedDepartments.contains('ALL')) {
      return true;
    }
    
    if (permission.allowedDepartments.contains(_userRole!.department)) {
      return true;
    }
    
    // Check specific role permissions
    return permission.allowedDepartments.contains(_userRole!.id);
  }

  // Check if user has specific permission
  bool hasPermission(String module, String permissionId) {
    if (_authProvider?.isSuperUser ?? false) {
      return true;
    }
    
    final modulePerms = _modulePermissions[module];
    return modulePerms?.contains(permissionId) ?? false;
  }

  // Check if user can access module
  bool canAccessModule(String module) {
    if (_authProvider?.isSuperUser ?? false) {
      return true;
    }
    
    return _modulePermissions.containsKey(module);
  }

  // Check if user can perform action on resource (ABAC)
  bool canPerformAction({
    required String action,
    required Map<String, dynamic> resource,
  }) {
    if (_authProvider?.isSuperUser ?? false) {
      return true;
    }
    
    return ABACAttributes.canPerformAction(
      userId: _userContext['userId'],
      action: action,
      resource: resource,
      context: _userContext,
    );
  }

  // Check if user can approve at specific level
  bool canApprove(String processType, String currentStatus) {
    if (_authProvider?.isSuperUser ?? false) {
      return true;
    }
    
    final hierarchy = RBACConfig.approvalHierarchy[processType];
    if (hierarchy == null) return false;
    
    final userRoleIndex = hierarchy.indexOf(_userRole!.id);
    if (userRoleIndex == -1) return false;
    
    // Can approve if user is at higher level than current status
    // Implementation depends on your workflow
    return true;
  }

  // Get data access scope
  DataAccessRule? getDataAccessRule() {
    if (_authProvider?.isSuperUser ?? false) {
      return const DataAccessRule(
        ownDataOnly: false,
        districtLevel: false,
        stateLevel: false,
        nationalLevel: true,
      );
    }
    
    return RBACConfig.dataAccessRules[_userRole?.id];
  }

  // Check workflow transition permission
  bool canTransition({
    required String workflow,
    required String fromStatus,
    required String toStatus,
  }) {
    if (_authProvider?.isSuperUser ?? false) {
      return true;
    }
    
    final transitions = WorkflowConfig.workflows[workflow];
    if (transitions == null) return false;
    
    final transition = transitions.firstWhere(
      (t) => t.from == fromStatus && t.to == toStatus,
      orElse: () => WorkflowTransition(
        from: '', 
        to: '', 
        requiredRole: '', 
        action: '',
      ),
    );
    
    return transition.requiredRole == _userRole?.id;
  }

  // Get user's subordinates (for hierarchical data access)
  Future<List<String>> getSubordinateUserIds() async {
    if (_userRole == null) return [];
    
    try {
      // Get roles with lower level than current user
      final subordinateRoles = RBACConfig.roles.values
          .where((role) => role.level < _userRole!.level)
          .map((role) => role.id)
          .toList();
      
      // Get users with those roles
      final response = await _supabase
          .from('users')
          .select('id')
          .inFilter('roleId', subordinateRoles);
      
      return (response as List).map((user) => user['id'] as String).toList();
    } catch (e) {
      print('Error getting subordinates: $e');
      return [];
    }
  }

  RoleDefinition? _getRoleDefinitionByName(String name) {
    // Map database role names to RBAC config
    final roleMap = {
      'Super Admin': RBACConfig.roles['SUPER_ADMIN'],
      'QC Department Head': RBACConfig.roles['QC_HEAD'],
      'QC Manager': RBACConfig.roles['QC_MANAGER'],
      'QC Supervisor': RBACConfig.roles['QC_SUPERVISOR'],
      'QC Inspector': RBACConfig.roles['QC_INSPECTOR'],
      'Lab Analyst': RBACConfig.roles['LAB_ANALYST'],
      'Field Officer': RBACConfig.roles['FIELD_OFFICER'],
      'District Agricultural Officer': RBACConfig.roles['DAO'],
      'Legal Officer': RBACConfig.roles['LEGAL_OFFICER'],
    };
    
    return roleMap[name];
  }

  void _clearPermissions() {
    _userRole = null;
    _modulePermissions = {};
    _userContext = {};
    notifyListeners();
  }

  // Activity-based permission check
  bool canPerformActivity(String activity) {
    final activityPermissionMap = {
      'create_inspection': hasPermission('inspection_planning', 'create_inspection'),
      'approve_sample': hasPermission('lab_interface', 'approve_test_results'),
      'generate_report': hasPermission('qc_module', 'export_reports'),
      'manage_compliance': hasPermission('qc_module', 'manage_compliance'),
      'perform_abc_analysis': hasPermission('qc_module', 'abc_analysis'),
    };
    
    return activityPermissionMap[activity] ?? false;
  }

  // Get available actions for a resource
  List<String> getAvailableActions(Map<String, dynamic> resource) {
    final actions = <String>[];
    
    if (canPerformAction(action: 'view', resource: resource)) {
      actions.add('view');
    }
    
    if (canPerformAction(action: 'edit', resource: resource)) {
      actions.add('edit');
    }
    
    if (canPerformAction(action: 'delete', resource: resource)) {
      actions.add('delete');
    }
    
    if (canPerformAction(action: 'approve', resource: resource)) {
      actions.add('approve');
    }
    
    if (canPerformAction(action: 'reject', resource: resource)) {
      actions.add('reject');
    }
    
    return actions;
  }

  Future<void> refreshPermissions() async {
    await _loadEnhancedPermissions();
  }
}
