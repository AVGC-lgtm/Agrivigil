import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../providers/enhanced_permission_provider.dart';
import '../../../utils/theme.dart';
import '../../../widgets/stat_card.dart';
import 'qc_inspection_list.dart';
import 'qc_compliance_management.dart';
import 'qc_abc_analysis.dart';
import 'qc_approval_workflow.dart';

class QCDashboard extends StatefulWidget {
  const QCDashboard({super.key});

  @override
  State<QCDashboard> createState() => _QCDashboardState();
}

class _QCDashboardState extends State<QCDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final permissionProvider = Provider.of<EnhancedPermissionProvider>(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
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
                          'Quality Control Department',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage quality inspections, compliance, and analysis',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                    if (!isSmallScreen && permissionProvider.userRole != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified_user,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              permissionProvider.userRole!.name,
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Stats Overview
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isSmallScreen ? 2 : 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isSmallScreen ? 1.2 : 1.5,
                  children: [
                    StatCard(
                      title: 'Pending Inspections',
                      value: '24',
                      icon: Icons.pending_actions,
                      color: AppTheme.warningColor,
                      trend: '+5%',
                      trendUp: true,
                    ),
                    StatCard(
                      title: 'Approved Today',
                      value: '12',
                      icon: Icons.check_circle,
                      color: AppTheme.successColor,
                      trend: '+15%',
                      trendUp: true,
                    ),
                    StatCard(
                      title: 'Non-Compliance',
                      value: '7',
                      icon: Icons.warning,
                      color: AppTheme.errorColor,
                      trend: '-8%',
                      trendUp: false,
                    ),
                    StatCard(
                      title: 'Lab Tests Pending',
                      value: '18',
                      icon: Icons.science,
                      color: Colors.blue,
                      trend: '+3%',
                      trendUp: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: isSmallScreen,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.primaryColor,
              tabs: [
                const Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
                const Tab(text: 'Inspections', icon: Icon(Icons.assignment)),
                const Tab(text: 'Compliance', icon: Icon(Icons.rule)),
                const Tab(text: 'ABC Analysis', icon: Icon(Icons.analytics)),
                const Tab(text: 'Approvals', icon: Icon(Icons.approval)),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                const QCInspectionList(),
                const QCComplianceManagement(),
                const QCABCAnalysis(),
                const QCApprovalWorkflow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compliance Trend Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quality Compliance Trend',
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
                                  '${value.toInt()}%',
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
                                  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'
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
                          // Compliance Rate
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 85),
                              FlSpot(1, 88),
                              FlSpot(2, 82),
                              FlSpot(3, 90),
                              FlSpot(4, 92),
                              FlSpot(5, 94),
                            ],
                            isCurved: true,
                            color: AppTheme.successColor,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.successColor.withOpacity(0.1),
                            ),
                          ),
                          // Non-Compliance Rate
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 15),
                              FlSpot(1, 12),
                              FlSpot(2, 18),
                              FlSpot(3, 10),
                              FlSpot(4, 8),
                              FlSpot(5, 6),
                            ],
                            isCurved: true,
                            color: AppTheme.errorColor,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.errorColor.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('Compliance Rate', AppTheme.successColor),
                      const SizedBox(width: 24),
                      _buildLegendItem('Non-Compliance Rate', AppTheme.errorColor),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Product Category Analysis
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inspection by Category',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: 40,
                                  title: '40%',
                                  color: Colors.blue,
                                  radius: 80,
                                ),
                                PieChartSectionData(
                                  value: 30,
                                  title: '30%',
                                  color: Colors.green,
                                  radius: 80,
                                ),
                                PieChartSectionData(
                                  value: 20,
                                  title: '20%',
                                  color: Colors.orange,
                                  radius: 80,
                                ),
                                PieChartSectionData(
                                  value: 10,
                                  title: '10%',
                                  color: Colors.purple,
                                  radius: 80,
                                ),
                              ],
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            _buildLegendItem('Fertilizers', Colors.blue),
                            _buildLegendItem('Pesticides', Colors.green),
                            _buildLegendItem('Seeds', Colors.orange),
                            _buildLegendItem('Others', Colors.purple),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Activities',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(5, (index) => _buildActivityItem(index)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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

  Widget _buildActivityItem(int index) {
    final activities = [
      {'title': 'QC Inspection Approved', 'time': '2 hours ago', 'icon': Icons.check_circle, 'color': AppTheme.successColor},
      {'title': 'Non-compliance detected', 'time': '4 hours ago', 'icon': Icons.warning, 'color': AppTheme.errorColor},
      {'title': 'Lab report submitted', 'time': '6 hours ago', 'icon': Icons.science, 'color': Colors.blue},
      {'title': 'ABC Analysis completed', 'time': '1 day ago', 'icon': Icons.analytics, 'color': Colors.orange},
      {'title': 'Compliance review pending', 'time': '2 days ago', 'icon': Icons.pending, 'color': AppTheme.warningColor},
    ];

    final activity = activities[index];
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (activity['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activity['icon'] as IconData,
              color: activity['color'] as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] as String,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  activity['time'] as String,
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
}
