import '../routes/app_routes.dart';

class RoleDashboardMapper {
  // Map role names to their dashboard routes
  static String getDashboardRoute(String? roleName) {
    if (roleName == null) return AppRoutes.dashboard;
    
    // Normalize role name
    final normalizedRole = roleName.toLowerCase().trim();
    
    switch (normalizedRole) {
      case 'field officer':
        return AppRoutes.fieldOfficerDashboard;
      
      case 'lab analyst':
        return AppRoutes.labAnalystDashboard;
      
      case 'qc inspector':
        return AppRoutes.qcInspectorDashboard;
      
      case 'district agriculture officer':
      case 'dao':
        return AppRoutes.daoDashboard;
      
      case 'legal officer':
        return AppRoutes.legalOfficerDashboard;
      
      case 'lab coordinator':
        return AppRoutes.labCoordinatorDashboard;
      
      case 'hq monitoring':
        return AppRoutes.hqMonitoringDashboard;
      
      case 'district admin':
        return AppRoutes.districtAdminDashboard;
      
      case 'super admin':
      case 'admin':
        return AppRoutes.adminDashboard;
      
      default:
        return AppRoutes.dashboard; // Default dashboard for unknown roles
    }
  }
  
  // Get dashboard title based on role
  static String getDashboardTitle(String? roleName) {
    if (roleName == null) return 'Dashboard';
    
    final normalizedRole = roleName.toLowerCase().trim();
    
    switch (normalizedRole) {
      case 'field officer':
        return 'Field Officer Dashboard';
      
      case 'lab analyst':
        return 'Lab Analyst Dashboard';
      
      case 'qc inspector':
        return 'QC Inspector Dashboard';
      
      case 'district agriculture officer':
      case 'dao':
        return 'District Agriculture Officer';
      
      case 'legal officer':
        return 'Legal Officer Dashboard';
      
      case 'lab coordinator':
        return 'Lab Coordinator Dashboard';
      
      case 'hq monitoring':
        return 'HQ Monitoring Dashboard';
      
      case 'district admin':
        return 'District Admin Dashboard';
      
      case 'super admin':
      case 'admin':
        return 'Admin Dashboard';
      
      default:
        return 'Dashboard';
    }
  }
}
