import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  String _selectedModule = 'dashboard';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
        elevation: 0,
        backgroundColor: Colors.white,
        leading: isSmallScreen
            ? IconButton(
                icon: const Icon(Icons.menu, color: AppTheme.primaryColor),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _scaffoldKey.currentState?.openDrawer();
                },
              )
            : null,
        title: Row(
          children: [
            if (!isSmallScreen) ...[
              Hero(
                tag: 'app_logo',
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppConstants.appName,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else
              Text(
                MenuDefinitions.getMenuById(_selectedModule)?.name ??
                AppConstants.appName,
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        actions: [
          // Notification Icon (placeholder for future implementation)
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: AppTheme.textSecondary),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              // TODO: Implement notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          
          // User Info with improved design
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showUserMenu(context);
                },
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.shade50,
                        Colors.grey.shade100,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryColor.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.transparent,
                          child: Text(
                            authProvider.user?.name?.substring(0, 1).toUpperCase() ??
                            authProvider.user?.email.substring(0, 1).toUpperCase() ??
                            'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      if (!isSmallScreen) ...[
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authProvider.user?.name ?? 'User',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
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
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
          
          // Main Content with animation
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _getModuleWidget(_selectedModule),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showUserMenu(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 200,
        AppBar().preferredSize.height + 10,
        20,
        0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.person_outline, color: AppTheme.primaryColor),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.settings_outlined, color: AppTheme.primaryColor),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ),
        const PopupMenuItem(
          enabled: false,
          height: 1,
          child: Divider(),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.errorColor),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ),
      ],
    );
  }
  
  void _showLogoutDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout,
                  color: AppTheme.errorColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Confirm Logout',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to logout from AgriVigil?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  if (auth.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  return Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            await auth.logout();
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                              // Navigate to login screen
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login',
                                (route) => false,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: AppTheme.errorColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(MenuDefinition menu, String permission) {
    final isSelected = _selectedModule == menu.id;
    final isReadOnly = permission == AppConstants.permissionRead;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _selectedModule = menu.id;
              _animationController.forward(from: 0);
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.15),
                        AppTheme.primaryColor.withOpacity(0.05),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    menu.icon,
                    size: 20,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
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
                      if (menu.description != null && isSelected)
                        Text(
                          menu.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                    ],
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
                if (isSelected)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppTheme.primaryColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
