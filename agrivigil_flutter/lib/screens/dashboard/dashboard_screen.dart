import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/permission_provider.dart';
import '../../models/menu_model.dart';
import '../../utils/theme.dart';
import '../../config/supabase_config.dart';
import '../../widgets/app_drawer.dart';
import '../modules/dashboard_module.dart';
import '../modules/administration_module.dart';
import '../modules/inspection_planning_module.dart';
import '../modules/field_execution_module.dart';
import '../modules/seizure_logging_module.dart';
import '../modules/lab_interface_module.dart';
import '../modules/legal_module.dart';
import '../modules/reports_audit_module.dart';
import '../modules/agri_forms_module.dart';
import '../modules/qc_module/qc_dashboard.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedModule = 'dashboard';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _getModuleWidget(String moduleId) {
    switch (moduleId) {
      case 'dashboard':
        return const DashboardModule();
      case 'administration':
        return const AdministrationModule();
      case 'inspection-planning':
        return const InspectionPlanningModule();
      case 'field-execution':
        return const FieldExecutionModule();
      case 'seizure-logging':
        return const SeizureLoggingModule();
      case 'lab-interface':
        return const LabInterfaceModule();
      case 'legal-module':
        return const LegalModule();
      case 'report-audit':
        return const ReportsAuditModule();
      case 'agri-forms-module':
        return const AgriFormsModule();
      case 'qc-module':
        return const QCDashboard();
      default:
        return const DashboardModule();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final permissionProvider = Provider.of<PermissionProvider>(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: isSmallScreen
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              )
            : null,
        title: Row(
          children: [
            if (!isSmallScreen) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.agriculture,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(AppConstants.appName),
            ] else
              Text(
                MenuDefinitions.getMenuById(_selectedModule)?.name ?? 
                AppConstants.appName,
              ),
          ],
        ),
        actions: [
          // User Info
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    authProvider.user?.name?.substring(0, 1).toUpperCase() ?? 
                    authProvider.user?.email.substring(0, 1).toUpperCase() ?? 
                    'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authProvider.user?.name ?? 'User',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      authProvider.user?.role?.name ?? 'Role',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && mounted) {
                await authProvider.logout();
              }
            },
          ),
        ],
      ),
      drawer: isSmallScreen
          ? AppDrawer(
              selectedModule: _selectedModule,
              onModuleSelected: (moduleId) {
                setState(() {
                  _selectedModule = moduleId;
                });
                Navigator.pop(context);
              },
            )
          : null,
      body: Row(
        children: [
          // Side Navigation (for larger screens)
          if (!isSmallScreen)
            Container(
              width: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  right: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Column(
                children: [
                  // Menu Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      children: permissionProvider.getAccessibleMenus()
                          .map((menu) => _buildMenuItem(
                                menu,
                                permissionProvider.getMenuPermission(menu.id),
                              ))
                          .toList(),
                    ),
                  ),
                  
                  // Footer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppConstants.companyName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Contact: ${AppConstants.companyContact}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          // Main Content
          Expanded(
            child: _getModuleWidget(_selectedModule),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(MenuDefinition menu, String permission) {
    final isSelected = _selectedModule == menu.id;
    final isReadOnly = permission == AppConstants.permissionRead;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedModule = menu.id;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  menu.icon,
                  size: 20,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    menu.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (isReadOnly)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Read Only',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade800,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
