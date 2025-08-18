import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/stat_card.dart';
import '../../routes/app_routes.dart';
import 'package:fl_chart/fl_chart.dart';

class FieldOfficerDashboard extends StatefulWidget {
  const FieldOfficerDashboard({super.key});

  @override
  State<FieldOfficerDashboard> createState() => _FieldOfficerDashboardState();
}

class _FieldOfficerDashboardState extends State<FieldOfficerDashboard> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      drawer: AppDrawer(
        selectedModule: 'field-execution',
        onModuleSelected: (module) {
          // Handle module selection if needed
        },
      ),
      appBar: AppBar(
        title: const Text('Field Officer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${user?.name ?? 'Field Officer'}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'Officer Code: ${user?.officerCode ?? 'N/A'}',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          Text(
                            'District: ${user?.metadata?['district'] ?? 'N/A'}',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Stats
            Text(
              'Today\'s Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                StatCard(
                  title: 'Inspections Today',
                  value: '5',
                  icon: Icons.assignment_turned_in,
                  color: AppTheme.primaryColor,
                ),
                StatCard(
                  title: 'Pending Tasks',
                  value: '3',
                  icon: Icons.pending_actions,
                  color: AppTheme.warningColor,
                ),
                StatCard(
                  title: 'Samples Collected',
                  value: '12',
                  icon: Icons.science,
                  color: AppTheme.infoColor,
                ),
                StatCard(
                  title: 'Seizures Made',
                  value: '2',
                  icon: Icons.block,
                  color: AppTheme.errorColor,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildActionCard(
                  context,
                  'New Inspection',
                  Icons.add_task,
                  () => Navigator.pushNamed(context, AppRoutes.fieldExecutionForm),
                ),
                _buildActionCard(
                  context,
                  'Scan Product',
                  Icons.qr_code_scanner,
                  () => Navigator.pushNamed(context, AppRoutes.productScan),
                ),
                _buildActionCard(
                  context,
                  'Log Seizure',
                  Icons.report_problem,
                  () => Navigator.pushNamed(context, AppRoutes.seizureForm),
                ),
                _buildActionCard(
                  context,
                  'View Tasks',
                  Icons.list_alt,
                  () => Navigator.pushNamed(context, AppRoutes.fieldExecutionList),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Activities
            Text(
              'Recent Activities',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text('Inspection at ${['ABC Farm', 'XYZ Store', 'PQR Warehouse', 'LMN Market', 'DEF Depot'][index]}'),
                    subtitle: Text('Completed ${index + 1} hours ago'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}
