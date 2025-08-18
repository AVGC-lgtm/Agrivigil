import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/recent_activity_card.dart';

class DashboardModule extends StatefulWidget {
  const DashboardModule({super.key});

  @override
  State<DashboardModule> createState() => _DashboardModuleState();
}

class _DashboardModuleState extends State<DashboardModule> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Text(
            'Welcome back, ${authProvider.user?.name ?? 'User'}!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Here\'s an overview of your agricultural inspection activities',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 24),

          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isSmallScreen ? 2 : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isSmallScreen ? 1.2 : 1.5,
            children: const [
              StatCard(
                title: 'Total Inspections',
                value: '245',
                icon: Icons.assignment,
                color: AppTheme.primaryColor,
                trend: '+12%',
                trendUp: true,
              ),
              StatCard(
                title: 'Active Seizures',
                value: '18',
                icon: Icons.inventory_2,
                color: Colors.orange,
                trend: '+5%',
                trendUp: true,
              ),
              StatCard(
                title: 'Lab Samples',
                value: '92',
                icon: Icons.science,
                color: Colors.blue,
                trend: '-3%',
                trendUp: false,
              ),
              StatCard(
                title: 'Legal Cases',
                value: '7',
                icon: Icons.gavel,
                color: Colors.purple,
                trend: '+2%',
                trendUp: true,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Charts Section
          if (!isSmallScreen) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Monthly Inspection Chart
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monthly Inspection Trends',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 300,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 20,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey.shade200,
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 20,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: const TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        const months = [
                                          'Jan',
                                          'Feb',
                                          'Mar',
                                          'Apr',
                                          'May',
                                          'Jun'
                                        ];
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            months[value.toInt()],
                                            style: const TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                minX: 0,
                                maxX: 5,
                                minY: 0,
                                maxY: 100,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: const [
                                      FlSpot(0, 45),
                                      FlSpot(1, 52),
                                      FlSpot(2, 48),
                                      FlSpot(3, 65),
                                      FlSpot(4, 58),
                                      FlSpot(5, 72),
                                    ],
                                    isCurved: true,
                                    color: AppTheme.primaryColor,
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 4,
                                          color: Colors.white,
                                          strokeWidth: 2,
                                          strokeColor: AppTheme.primaryColor,
                                        );
                                      },
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: AppTheme.primaryColor.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Category Distribution
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Inspection Categories',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 300,
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    value: 35,
                                    title: '35%',
                                    color: AppTheme.primaryColor,
                                    radius: 80,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: 25,
                                    title: '25%',
                                    color: Colors.orange,
                                    radius: 80,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: 20,
                                    title: '20%',
                                    color: Colors.blue,
                                    radius: 80,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: 20,
                                    title: '20%',
                                    color: Colors.purple,
                                    radius: 80,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Legend
                          Column(
                            children: [
                              _buildLegendItem('Fertilizers', AppTheme.primaryColor),
                              _buildLegendItem('Pesticides', Colors.orange),
                              _buildLegendItem('Seeds', Colors.blue),
                              _buildLegendItem('Others', Colors.purple),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],

          // Recent Activities
          Text(
            'Recent Activities',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...List.generate(
            5,
            (index) => RecentActivityCard(
              title: _getActivityTitle(index),
              subtitle: _getActivitySubtitle(index),
              time: _getActivityTime(index),
              icon: _getActivityIcon(index),
              iconColor: _getActivityColor(index),
              onTap: () {
                // Navigate to detail
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _getActivityTitle(int index) {
    final activities = [
      'New Inspection Completed',
      'Sample Sent to Lab',
      'Seizure Logged',
      'Lab Report Received',
      'FIR Case Filed',
    ];
    return activities[index % activities.length];
  }

  String _getActivitySubtitle(int index) {
    final subtitles = [
      'District: Pune | Location: Market Yard',
      'Sample Code: LAB-2024-0045',
      'Product: DAP Fertilizer | Quantity: 500kg',
      'Result: Non-compliant | Sample: LAB-2024-0038',
      'Case No: FIR-2024-0012 | Accused: ABC Traders',
    ];
    return subtitles[index % subtitles.length];
  }

  String _getActivityTime(int index) {
    final times = [
      '2 hours ago',
      '4 hours ago',
      'Yesterday',
      '2 days ago',
      '3 days ago',
    ];
    return times[index % times.length];
  }

  IconData _getActivityIcon(int index) {
    final icons = [
      Icons.assignment_turned_in,
      Icons.science,
      Icons.inventory_2,
      Icons.description,
      Icons.gavel,
    ];
    return icons[index % icons.length];
  }

  Color _getActivityColor(int index) {
    final colors = [
      AppTheme.successColor,
      Colors.blue,
      Colors.orange,
      AppTheme.warningColor,
      Colors.purple,
    ];
    return colors[index % colors.length];
  }
}
