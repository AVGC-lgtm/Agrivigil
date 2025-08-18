import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/stat_card.dart';
import '../../routes/app_routes.dart';
import 'package:fl_chart/fl_chart.dart';

class DaoDashboard extends StatefulWidget {
  const DaoDashboard({super.key});

  @override
  State<DaoDashboard> createState() => _DaoDashboardState();
}

class _DaoDashboardState extends State<DaoDashboard> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      drawer: AppDrawer(
        selectedModule: 'administration',
        onModuleSelected: (module) {
          // Handle module selection if needed
        },
      ),
      appBar: AppBar(
        title: const Text('District Agriculture Officer'),
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
                      backgroundColor: Colors.green.withOpacity(0.1),
                      child: const Icon(
                        Icons.account_balance,
                        size: 30,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${user?.name ?? 'DAO'}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'Officer ID: ${user?.officerCode ?? 'N/A'}',
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

            // District Overview
            Text(
              'District Overview',
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
                  title: 'Total Inspections',
                  value: '156',
                  icon: Icons.assignment,
                  color: AppTheme.primaryColor,
                ),
                StatCard(
                  title: 'Field Officers',
                  value: '12',
                  icon: Icons.people,
                  color: AppTheme.infoColor,
                ),
                StatCard(
                  title: 'Active Cases',
                  value: '28',
                  icon: Icons.gavel,
                  color: AppTheme.warningColor,
                ),
                StatCard(
                  title: 'Compliance Rate',
                  value: '82%',
                  icon: Icons.trending_up,
                  color: AppTheme.successColor,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Monthly Performance Chart
            Text(
              'Monthly Performance',
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
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 40,
                      barGroups: [
                        _makeGroupData(0, 20, 15),
                        _makeGroupData(1, 25, 18),
                        _makeGroupData(2, 30, 22),
                        _makeGroupData(3, 35, 28),
                        _makeGroupData(4, 32, 25),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final titles = ['Week 1', 'Week 2', 'Week 3', 'Week 4', 'Week 5'];
                              return Text(titles[value.toInt()], style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(enabled: true),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Management Actions
            Text(
              'Management Actions',
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
                  'View Reports',
                  Icons.assessment,
                  () => Navigator.pushNamed(context, AppRoutes.reportList),
                ),
                _buildActionCard(
                  context,
                  'Assign Tasks',
                  Icons.task_alt,
                  () {},
                ),
                _buildActionCard(
                  context,
                  'Team Overview',
                  Icons.groups,
                  () {},
                ),
                _buildActionCard(
                  context,
                  'Analytics',
                  Icons.analytics,
                  () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Team Performance
            Text(
              'Team Performance',
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
                  final performance = [85, 78, 92, 88, 75][index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        'FO${index + 1}',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text('Field Officer ${index + 1}'),
                    subtitle: Text('${[12, 8, 15, 10, 6][index]} inspections this week'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: performance >= 80 ? AppTheme.successColor.withOpacity(0.1) : AppTheme.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$performance%',
                        style: TextStyle(
                          color: performance >= 80 ? AppTheme.successColor : AppTheme.warningColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: AppTheme.primaryColor,
          width: 15,
        ),
        BarChartRodData(
          toY: y2,
          color: AppTheme.successColor,
          width: 15,
        ),
      ],
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
              color: Colors.green,
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
