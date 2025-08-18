import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/permission_provider.dart';
import '../models/menu_model.dart';
import '../utils/theme.dart';
import '../config/supabase_config.dart';

class AppDrawer extends StatelessWidget {
  final String selectedModule;
  final Function(String) onModuleSelected;

  const AppDrawer({
    super.key,
    required this.selectedModule,
    required this.onModuleSelected,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final permissionProvider = Provider.of<PermissionProvider>(context);

    return Drawer(
      child: Column(
        children: [
          // Header
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withGreen(200),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.agriculture,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.appName,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Inspection & Monitoring',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // User Info
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile');
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        child: Text(
                          authProvider.user?.name?.substring(0, 1).toUpperCase() ??
                              authProvider.user?.email
                                  .substring(0, 1)
                                  .toUpperCase() ??
                              'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authProvider.user?.name ?? 'User',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              authProvider.user?.role?.name ?? 'Role',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 10,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (authProvider.isSuperUser)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'SUPER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                    ],
                  ),
                  ),
                ),
              ],
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Super Admin Navigation Options
                if (authProvider.isSuperUser) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'SUPER ADMIN TOOLS',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  _buildSuperAdminItem(
                    context,
                    icon: Icons.dashboard_customize,
                    title: 'Switch Dashboard',
                    subtitle: 'Access any role dashboard',
                    onTap: () => _showDashboardSwitcher(context),
                  ),
                  _buildSuperAdminItem(
                    context,
                    icon: Icons.admin_panel_settings,
                    title: 'System Administration',
                    subtitle: 'Manage users and permissions',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/admin/users');
                    },
                  ),
                  _buildSuperAdminItem(
                    context,
                    icon: Icons.storage,
                    title: 'Database Management',
                    subtitle: 'View and manage database',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Database management coming soon'),
                        ),
                      );
                    },
                  ),
                  _buildSuperAdminItem(
                    context,
                    icon: Icons.bug_report,
                    title: 'Debug Console',
                    subtitle: 'System diagnostics and logs',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/reports/audit');
                    },
                  ),
                  const Divider(thickness: 2, height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'REGULAR MODULES',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
                
                // Regular Menu Items
                ...permissionProvider
                    .getAccessibleMenus()
                    .map((menu) => _buildDrawerItem(
                          context,
                          menu,
                          permissionProvider.getMenuPermission(menu.id),
                        )),
                const Divider(),
                
                // Additional Options
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                const Divider(),
                
                // Logout with enhanced UI
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: AppTheme.errorColor,
                  ),
                  title: Text(
                    'Logout',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  onTap: () => _handleLogout(context),
                ),
              ],
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              children: [
                Text(
                  AppConstants.companyName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
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
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    MenuDefinition menu,
    String permission,
  ) {
    final isSelected = selectedModule == menu.id;
    final isReadOnly = permission == AppConstants.permissionRead;

    return ListTile(
      selected: isSelected,
      selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
      leading: Icon(
        menu.icon,
        color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
      ),
      title: Text(
        menu.name,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color:
                  isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
      ),
      trailing: isReadOnly
          ? Container(
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
            )
          : null,
      onTap: () {
        onModuleSelected(menu.id);
      },
    );
  }

  Widget _buildSuperAdminItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withOpacity(0.05),
                  Colors.amber.withOpacity(0.02),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.amber.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: Colors.amber.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.amber.shade700,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDashboardSwitcher(BuildContext context) {
    final dashboards = [
      {'name': 'Field Officer Dashboard', 'route': '/field-officer-dashboard', 'icon': Icons.agriculture},
      {'name': 'Lab Analyst Dashboard', 'route': '/lab-analyst-dashboard', 'icon': Icons.science},
      {'name': 'QC Inspector Dashboard', 'route': '/qc-inspector-dashboard', 'icon': Icons.verified_user},
      {'name': 'DAO Dashboard', 'route': '/dao-dashboard', 'icon': Icons.business_center},
      {'name': 'Legal Officer Dashboard', 'route': '/legal-officer-dashboard', 'icon': Icons.gavel},
      {'name': 'Lab Coordinator Dashboard', 'route': '/lab-coordinator-dashboard', 'icon': Icons.biotech},
      {'name': 'HQ Monitoring Dashboard', 'route': '/hq-monitoring-dashboard', 'icon': Icons.monitor_heart},
      {'name': 'District Admin Dashboard', 'route': '/district-admin-dashboard', 'icon': Icons.location_city},
      {'name': 'Admin Dashboard', 'route': '/admin-dashboard', 'icon': Icons.admin_panel_settings},
      {'name': 'Main Dashboard', 'route': '/dashboard', 'icon': Icons.dashboard},
    ];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.dashboard_customize,
                      color: Colors.amber.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Switch Dashboard',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Access any role dashboard',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: dashboards.length,
                  itemBuilder: (context, index) {
                    final dashboard = dashboards[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(dialogContext);
                            Navigator.pop(context); // Close drawer
                            Navigator.pushReplacementNamed(
                              context,
                              dashboard['route'] as String,
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.borderLight),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    dashboard['icon'] as IconData,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    dashboard['name'] as String,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: AppTheme.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    Navigator.pop(context); // Close drawer
    
    final confirmed = await showDialog<bool>(
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
                          onPressed: () => Navigator.pop(dialogContext, false),
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
                          onPressed: () => Navigator.pop(dialogContext, true),
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

    if (confirmed == true && context.mounted) {
      await authProvider.logout();
      // Navigate to login screen after logout
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    }
  }
}
