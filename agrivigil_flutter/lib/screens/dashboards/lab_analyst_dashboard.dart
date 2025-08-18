import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/stat_card.dart';
import '../../routes/app_routes.dart';
import 'package:fl_chart/fl_chart.dart';

class LabAnalystDashboard extends StatefulWidget {
  const LabAnalystDashboard({super.key});

  @override
  State<LabAnalystDashboard> createState() => _LabAnalystDashboardState();
}

class _LabAnalystDashboardState extends State<LabAnalystDashboard> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      drawer: AppDrawer(
        selectedModule: 'laboratory',
        onModuleSelected: (module) {
          // Handle module selection if needed
        },
      ),
      appBar: AppBar(
        title: const Text('Lab Analyst Dashboard'),
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
                      backgroundColor: AppTheme.infoColor.withOpacity(0.1),
                      child: Icon(
                        Icons.science,
                        size: 30,
                        color: AppTheme.infoColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${user?.name ?? 'Lab Analyst'}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'Lab ID: ${user?.officerCode ?? 'N/A'}',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          Text(
                            'Location: ${user?.metadata?['district'] ?? 'N/A'} Lab',
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

            // Lab Stats
            Text(
              'Lab Overview',
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
                  title: 'Pending Tests',
                  value: '15',
                  icon: Icons.hourglass_empty,
                  color: AppTheme.warningColor,
                ),
                StatCard(
                  title: 'In Progress',
                  value: '8',
                  icon: Icons.science,
                  color: AppTheme.infoColor,
                ),
                StatCard(
                  title: 'Completed Today',
                  value: '12',
                  icon: Icons.check_circle,
                  color: AppTheme.successColor,
                ),
                StatCard(
                  title: 'Failed Samples',
                  value: '3',
                  icon: Icons.error,
                  color: AppTheme.errorColor,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Lab Actions',
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
                  'New Test',
                  Icons.add_task,
                  () => Navigator.pushNamed(context, AppRoutes.testResultForm),
                ),
                _buildActionCard(
                  context,
                  'View Samples',
                  Icons.inventory_2,
                  () => Navigator.pushNamed(context, AppRoutes.labSampleList),
                ),
                _buildActionCard(
                  context,
                  'Test Reports',
                  Icons.description,
                  () => Navigator.pushNamed(context, AppRoutes.reportList),
                ),
                _buildActionCard(
                  context,
                  'Equipment',
                  Icons.precision_manufacturing,
                  () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Test Progress Chart
            Text(
              'Test Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: 15,
                          title: 'Pending',
                          color: AppTheme.warningColor,
                          radius: 60,
                        ),
                        PieChartSectionData(
                          value: 8,
                          title: 'In Progress',
                          color: AppTheme.infoColor,
                          radius: 60,
                        ),
                        PieChartSectionData(
                          value: 12,
                          title: 'Completed',
                          color: AppTheme.successColor,
                          radius: 60,
                        ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recent Test Results
            Text(
              'Recent Test Results',
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
                  final isPass = index % 2 == 0;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: (isPass ? AppTheme.successColor : AppTheme.errorColor).withOpacity(0.1),
                      child: Icon(
                        isPass ? Icons.check : Icons.close,
                        color: isPass ? AppTheme.successColor : AppTheme.errorColor,
                        size: 20,
                      ),
                    ),
                    title: Text('Sample #LAB${2024000 + index}'),
                    subtitle: Text('${isPass ? 'Passed' : 'Failed'} - NPK Test'),
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
              color: AppTheme.infoColor,
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
