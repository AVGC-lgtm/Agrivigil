import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/app_drawer.dart';
import '../../routes/app_routes.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrator Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.userProfile);
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        selectedModule: 'admin',
        onModuleSelected: (module) {
          // Handle module selection
          Navigator.pop(context);
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh dashboard data
          setState(() {});
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple,
                      Colors.deepPurple.shade700,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'System Administrator',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white70,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.name ?? 'Administrator',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildSystemStat('Active Users', '234', Icons.people),
                        const SizedBox(width: 16),
                        _buildSystemStat('Departments', '12', Icons.business),
                        const SizedBox(width: 16),
                        _buildSystemStat('Uptime', '99.9%', Icons.trending_up),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // System Overview
              Text(
                'System Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  StatCard(
                    title: 'Total Users',
                    value: '1,234',
                    icon: Icons.group,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.userManagement);
                    },
                  ),
                  StatCard(
                    title: 'Active Sessions',
                    value: '89',
                    icon: Icons.online_prediction,
                    color: Colors.green,
                    onTap: () {},
                  ),
                  StatCard(
                    title: 'Total Inspections',
                    value: '5,678',
                    icon: Icons.assignment,
                    color: Colors.orange,
                    onTap: () {},
                  ),
                  StatCard(
                    title: 'System Alerts',
                    value: '3',
                    icon: Icons.warning,
                    color: Colors.red,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Quick Administration
              Text(
                'Quick Administration',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildAdminActionTile(
                      context,
                      icon: Icons.person_add,
                      title: 'User Management',
                      subtitle: 'Add, edit, or remove users',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.userManagement);
                      },
                    ),
                    const Divider(),
                    _buildAdminActionTile(
                      context,
                      icon: Icons.security,
                      title: 'Role Management',
                      subtitle: 'Configure roles and permissions',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.roleManagement);
                      },
                    ),
                    const Divider(),
                    _buildAdminActionTile(
                      context,
                      icon: Icons.vpn_key,
                      title: 'Permission Matrix',
                      subtitle: 'Manage system permissions',
                      onTap: () {
                        Navigator.pushNamed(
                            context, AppRoutes.permissionMatrix);
                      },
                    ),
                    const Divider(),
                    _buildAdminActionTile(
                      context,
                      icon: Icons.history,
                      title: 'Audit Logs',
                      subtitle: 'View system activity logs',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.auditLog);
                      },
                    ),
                    const Divider(),
                    _buildAdminActionTile(
                      context,
                      icon: Icons.backup,
                      title: 'Backup & Restore',
                      subtitle: 'Manage system backups',
                      onTap: () {},
                    ),
                    const Divider(),
                    _buildAdminActionTile(
                      context,
                      icon: Icons.analytics,
                      title: 'System Reports',
                      subtitle: 'Generate system reports',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.reportList);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // System Performance
              Text(
                'System Performance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          const FlSpot(0, 3),
                          const FlSpot(1, 1),
                          const FlSpot(2, 4),
                          const FlSpot(3, 2),
                          const FlSpot(4, 5),
                          const FlSpot(5, 3),
                          const FlSpot(6, 4),
                        ],
                        isCurved: true,
                        color: Colors.deepPurple,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.deepPurple.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Recent System Activities
              Text(
                'Recent System Activities',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildActivityItem(
                      'New user registered',
                      'john.doe@example.com',
                      '5 minutes ago',
                      Icons.person_add,
                      Colors.blue,
                    ),
                    const Divider(),
                    _buildActivityItem(
                      'Role permissions updated',
                      'Field Officer role modified',
                      '1 hour ago',
                      Icons.security,
                      Colors.orange,
                    ),
                    const Divider(),
                    _buildActivityItem(
                      'System backup completed',
                      'Automatic daily backup',
                      '3 hours ago',
                      Icons.backup,
                      Colors.green,
                    ),
                    const Divider(),
                    _buildActivityItem(
                      'Database maintenance',
                      'Optimization completed',
                      '6 hours ago',
                      Icons.storage,
                      Colors.purple,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.deepPurple,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
