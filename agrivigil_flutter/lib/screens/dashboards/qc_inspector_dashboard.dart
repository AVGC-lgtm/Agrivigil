import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/stat_card.dart';
import '../../routes/app_routes.dart';

class QcInspectorDashboard extends StatefulWidget {
  const QcInspectorDashboard({super.key});

  @override
  State<QcInspectorDashboard> createState() => _QcInspectorDashboardState();
}

class _QcInspectorDashboardState extends State<QcInspectorDashboard> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      drawer: AppDrawer(
        selectedModule: 'qc-module',
        onModuleSelected: (module) {
          // Handle module selection if needed
        },
      ),
      appBar: AppBar(
        title: const Text('QC Inspector Dashboard'),
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
                      backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.verified_user,
                        size: 30,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${user?.name ?? 'QC Inspector'}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'Inspector ID: ${user?.officerCode ?? 'N/A'}',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          Text(
                            'Zone: ${user?.metadata?['district'] ?? 'N/A'}',
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

            // QC Stats
            Text(
              'Quality Control Overview',
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
                  value: '8',
                  icon: Icons.fact_check,
                  color: AppTheme.primaryColor,
                ),
                StatCard(
                  title: 'Non-Compliance',
                  value: '3',
                  icon: Icons.warning,
                  color: AppTheme.warningColor,
                ),
                StatCard(
                  title: 'Approved',
                  value: '5',
                  icon: Icons.check_circle,
                  color: AppTheme.successColor,
                ),
                StatCard(
                  title: 'Pending Review',
                  value: '7',
                  icon: Icons.pending,
                  color: AppTheme.infoColor,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Compliance Rate
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compliance Rate',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: 0.75,
                      minHeight: 20,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.successColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '75% Compliance Rate This Month',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'QC Actions',
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
                  () {},
                ),
                _buildActionCard(
                  context,
                  'Compliance Check',
                  Icons.rule,
                  () {},
                ),
                _buildActionCard(
                  context,
                  'Review Reports',
                  Icons.assessment,
                  () {},
                ),
                _buildActionCard(
                  context,
                  'ABC Analysis',
                  Icons.analytics,
                  () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Inspections
            Text(
              'Recent QC Inspections',
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
                  final status = index % 3 == 0 ? 'Approved' : (index % 3 == 1 ? 'Rejected' : 'Pending');
                  final statusColor = status == 'Approved' 
                      ? AppTheme.successColor 
                      : (status == 'Rejected' ? AppTheme.errorColor : AppTheme.warningColor);
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withOpacity(0.1),
                      child: Icon(
                        status == 'Approved' 
                            ? Icons.check 
                            : (status == 'Rejected' ? Icons.close : Icons.hourglass_empty),
                        color: statusColor,
                        size: 20,
                      ),
                    ),
                    title: Text('QC-${DateTime.now().year}-${1000 + index}'),
                    subtitle: Text('${['NPK Fertilizer', 'Pesticide Batch', 'Seeds Quality', 'Organic Fertilizer', 'Chemical Testing'][index]} - $status'),
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
              color: AppTheme.secondaryColor,
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
