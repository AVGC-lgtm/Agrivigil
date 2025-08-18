import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
// Role-based Dashboards
import '../screens/dashboards/field_officer_dashboard.dart';
import '../screens/dashboards/lab_analyst_dashboard.dart';
import '../screens/dashboards/qc_inspector_dashboard.dart';
import '../screens/dashboards/dao_dashboard.dart';
import '../screens/dashboards/legal_officer_dashboard.dart';
import '../screens/dashboards/lab_coordinator_dashboard.dart';
import '../screens/dashboards/hq_monitoring_dashboard.dart';
import '../screens/dashboards/district_admin_dashboard.dart';
import '../screens/dashboards/admin_dashboard.dart';
// Field Execution
import '../screens/modules/field_execution/field_execution_list.dart';
import '../screens/modules/field_execution/field_execution_form.dart';
import '../screens/modules/field_execution/field_execution_detail.dart';
import '../screens/modules/field_execution/product_scan_screen.dart';
// Seizure Logging
import '../screens/modules/seizure_logging/seizure_list.dart';
import '../screens/modules/seizure_logging/seizure_form.dart';
import '../screens/modules/seizure_logging/seizure_detail.dart';
// Lab Interface
import '../screens/modules/lab_interface/lab_sample_list.dart';
import '../screens/modules/lab_interface/lab_sample_form.dart';
import '../screens/modules/lab_interface/lab_sample_detail.dart';
import '../screens/modules/lab_interface/test_result_form.dart';
// Legal Module
import '../screens/modules/legal/fir_case_list.dart';
import '../screens/modules/legal/fir_case_form.dart';
import '../screens/modules/legal/fir_case_detail.dart';
// Reports & Audit
import '../screens/modules/reports_audit/report_list.dart';
import '../screens/modules/reports_audit/report_viewer.dart';
import '../screens/modules/reports_audit/audit_log_screen.dart';
// AgriForm Portal
import '../screens/modules/agri_forms/form_catalog.dart';
import '../screens/modules/agri_forms/form_submission.dart';
import '../screens/modules/agri_forms/submission_list.dart';
// Administration
import '../screens/modules/administration/user_management.dart';
import '../screens/modules/administration/role_management.dart';
import '../screens/modules/administration/permission_matrix.dart';
// Profile
import '../screens/profile/user_profile.dart';
import '../screens/profile/change_password.dart';
import '../screens/profile/settings_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  
  // Role-based Dashboard Routes
  static const String fieldOfficerDashboard = '/field-officer-dashboard';
  static const String labAnalystDashboard = '/lab-analyst-dashboard';
  static const String qcInspectorDashboard = '/qc-inspector-dashboard';
  static const String daoDashboard = '/dao-dashboard';
  static const String legalOfficerDashboard = '/legal-officer-dashboard';
  static const String labCoordinatorDashboard = '/lab-coordinator-dashboard';
  static const String hqMonitoringDashboard = '/hq-monitoring-dashboard';
  static const String districtAdminDashboard = '/district-admin-dashboard';
  static const String adminDashboard = '/admin-dashboard';
  
  // Field Execution Routes
  static const String fieldExecutionList = '/field-execution';
  static const String fieldExecutionForm = '/field-execution/form';
  static const String fieldExecutionDetail = '/field-execution/detail';
  static const String productScan = '/field-execution/scan';
  
  // Seizure Logging Routes
  static const String seizureList = '/seizure';
  static const String seizureForm = '/seizure/form';
  static const String seizureDetail = '/seizure/detail';
  
  // Lab Interface Routes
  static const String labSampleList = '/lab';
  static const String labSampleForm = '/lab/form';
  static const String labSampleDetail = '/lab/detail';
  static const String testResultForm = '/lab/test-result';
  
  // Legal Module Routes
  static const String firCaseList = '/legal';
  static const String firCaseForm = '/legal/form';
  static const String firCaseDetail = '/legal/detail';
  
  // Reports & Audit Routes
  static const String reportList = '/reports';
  static const String reportViewer = '/reports/viewer';
  static const String auditLog = '/reports/audit';
  
  // AgriForm Portal Routes
  static const String formCatalog = '/agri-forms';
  static const String formSubmission = '/agri-forms/submit';
  static const String submissionList = '/agri-forms/submissions';
  
  // Administration Routes
  static const String userManagement = '/admin/users';
  static const String roleManagement = '/admin/roles';
  static const String permissionMatrix = '/admin/permissions';
  
  // Profile Routes
  static const String userProfile = '/profile';
  static const String changePassword = '/profile/password';
  static const String settings = '/settings';
  
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      dashboard: (context) => const DashboardScreen(),
      
      // Role-based Dashboards
      fieldOfficerDashboard: (context) => const FieldOfficerDashboard(),
      labAnalystDashboard: (context) => const LabAnalystDashboard(),
      qcInspectorDashboard: (context) => const QcInspectorDashboard(),
      daoDashboard: (context) => const DaoDashboard(),
      legalOfficerDashboard: (context) => const LegalOfficerDashboard(),
      labCoordinatorDashboard: (context) => const LabCoordinatorDashboard(),
      hqMonitoringDashboard: (context) => const HQMonitoringDashboard(),
      districtAdminDashboard: (context) => const DistrictAdminDashboard(),
      adminDashboard: (context) => const AdminDashboard(),
      
      // Field Execution
      fieldExecutionList: (context) => const FieldExecutionListScreen(),
      fieldExecutionForm: (context) => const FieldExecutionFormScreen(),
      fieldExecutionDetail: (context) => const FieldExecutionDetailScreen(),
      productScan: (context) => const ProductScanScreen(),
      
      // Seizure Logging
      seizureList: (context) => const SeizureListScreen(),
      seizureForm: (context) => const SeizureFormScreen(),
      seizureDetail: (context) => const SeizureDetailScreen(),
      
      // Lab Interface
      labSampleList: (context) => const LabSampleListScreen(),
      labSampleForm: (context) => const LabSampleFormScreen(),
      labSampleDetail: (context) => const LabSampleDetailScreen(),
      testResultForm: (context) => const TestResultFormScreen(),
      
      // Legal Module
      firCaseList: (context) => const FIRCaseListScreen(),
      firCaseForm: (context) => const FIRCaseFormScreen(),
      firCaseDetail: (context) => const FIRCaseDetailScreen(),
      
      // Reports & Audit
      reportList: (context) => const ReportListScreen(),
      reportViewer: (context) => const ReportViewerScreen(),
      auditLog: (context) => const AuditLogScreen(),
      
      // AgriForm Portal
      formCatalog: (context) => const FormCatalogScreen(),
      formSubmission: (context) => const FormSubmissionScreen(),
      submissionList: (context) => const SubmissionListScreen(),
      
      // Administration
      userManagement: (context) => const UserManagementScreen(),
      roleManagement: (context) => const RoleManagementScreen(),
      permissionMatrix: (context) => const PermissionMatrixScreen(),
      
      // Profile
      userProfile: (context) => const UserProfileScreen(),
      changePassword: (context) => const ChangePasswordScreen(),
      settings: (context) => const SettingsScreen(),
    };
  }
  
  // Route guards for permission checking
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Add permission checking logic here
    return null;
  }
}

// Route arguments classes
class FieldExecutionArguments {
  final String? inspectionId;
  final String? executionId;
  
  FieldExecutionArguments({this.inspectionId, this.executionId});
}

class SeizureArguments {
  final String? fieldExecutionId;
  final String? seizureId;
  
  SeizureArguments({this.fieldExecutionId, this.seizureId});
}

class LabSampleArguments {
  final String? seizureId;
  final String? sampleId;
  
  LabSampleArguments({this.seizureId, this.sampleId});
}

class FIRCaseArguments {
  final String? seizureId;
  final String? labSampleId;
  final String? caseId;
  
  FIRCaseArguments({this.seizureId, this.labSampleId, this.caseId});
}

class ReportArguments {
  final String reportType;
  final Map<String, dynamic>? filters;
  
  ReportArguments({required this.reportType, this.filters});
}
