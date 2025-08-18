import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/app_drawer.dart';
import '../../routes/app_routes.dart';
import '../../services/lab_service.dart';

class LabCoordinatorDashboard extends StatefulWidget {
  const LabCoordinatorDashboard({super.key});

  @override
  State<LabCoordinatorDashboard> createState() =>
      _LabCoordinatorDashboardState();
}

class _LabCoordinatorDashboardState extends State<LabCoordinatorDashboard> {
  final LabService _labService = LabService();
  Map<String, dynamic> _labStats = {};
  List<Map<String, dynamic>> _pendingSamples = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() => _isLoading = true);

      // Load lab statistics
      final stats = await _labService.getLabStatistics();

      // Load pending samples
      final samples = await _labService.getLabSamples(
        status: 'pending',
        limit: 5,
      );

      setState(() {
        _labStats = stats;
        _pendingSamples = samples;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Coordinator Dashboard'),
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
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
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
        selectedModule: 'lab',
        onModuleSelected: (module) {
          // Handle module selection
          Navigator.pop(context);
        },
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                            Colors.teal,
                            Colors.teal.shade700,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lab Operations Center',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.white70,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.name ?? 'Lab Coordinator',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.science,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Active Labs: 5',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
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
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.biotech,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_labStats['total'] ?? 0}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Total Samples',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sample Statistics
                    Text(
                      'Sample Processing Status',
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
                          title: 'Pending',
                          value: '${_labStats['pending'] ?? 0}',
                          icon: Icons.pending_actions,
                          color: Colors.orange,
                          onTap: () {
                            Navigator.pushNamed(
                                context, AppRoutes.labSampleList);
                          },
                        ),
                        StatCard(
                          title: 'In Progress',
                          value: '${_labStats['in_progress'] ?? 0}',
                          icon: Icons.science,
                          color: Colors.blue,
                          onTap: () {
                            Navigator.pushNamed(
                                context, AppRoutes.labSampleList);
                          },
                        ),
                        StatCard(
                          title: 'Tested',
                          value: '${_labStats['tested'] ?? 0}',
                          icon: Icons.check_circle,
                          color: Colors.green,
                          onTap: () {
                            Navigator.pushNamed(
                                context, AppRoutes.labSampleList);
                          },
                        ),
                        StatCard(
                          title: 'Completed',
                          value: '${_labStats['completed'] ?? 0}',
                          icon: Icons.done_all,
                          color: Colors.teal,
                          onTap: () {
                            Navigator.pushNamed(
                                context, AppRoutes.labSampleList);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Lab Performance Chart
                    Text(
                      'Weekly Performance',
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
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 20,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const days = [
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat',
                                    'Sun'
                                  ];
                                  return Text(
                                    days[value.toInt() % 7],
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(7, (index) {
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: (index + 1) * 2.5,
                                  color: Colors.teal,
                                  width: 20,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(4),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quick Actions
                    Text(
                      'Quick Actions',
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
                          _buildQuickActionTile(
                            context,
                            icon: Icons.assignment,
                            title: 'Assign Samples',
                            subtitle: 'Distribute samples to analysts',
                            onTap: () {
                              Navigator.pushNamed(
                                  context, AppRoutes.labSampleList);
                            },
                          ),
                          const Divider(),
                          _buildQuickActionTile(
                            context,
                            icon: Icons.speed,
                            title: 'Priority Samples',
                            subtitle: 'View high-priority test requests',
                            onTap: () {
                              // Navigate to priority samples
                            },
                          ),
                          const Divider(),
                          _buildQuickActionTile(
                            context,
                            icon: Icons.analytics,
                            title: 'Lab Reports',
                            subtitle: 'Generate lab performance reports',
                            onTap: () {
                              Navigator.pushNamed(
                                  context, AppRoutes.reportList);
                            },
                          ),
                          const Divider(),
                          _buildQuickActionTile(
                            context,
                            icon: Icons.group,
                            title: 'Analyst Management',
                            subtitle: 'Manage lab analysts and workload',
                            onTap: () {
                              // Navigate to analyst management
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Pending Samples
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Pending Samples',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, AppRoutes.labSampleList);
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._pendingSamples
                        .map((sample) => _buildSampleCard(sample)),

                    const SizedBox(height: 20),

                    // Lab Capacity
                    Text(
                      'Lab Capacity Status',
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
                          _buildLabCapacityItem(
                              'Central Lab', 65, Colors.green),
                          const SizedBox(height: 12),
                          _buildLabCapacityItem(
                              'District Lab A', 80, Colors.orange),
                          const SizedBox(height: 12),
                          _buildLabCapacityItem(
                              'District Lab B', 45, Colors.green),
                          const SizedBox(height: 12),
                          _buildLabCapacityItem(
                              'Mobile Lab Unit 1', 90, Colors.red),
                          const SizedBox(height: 12),
                          _buildLabCapacityItem(
                              'Mobile Lab Unit 2', 30, Colors.green),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildQuickActionTile(
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
          color: Colors.teal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.teal,
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

  Widget _buildSampleCard(Map<String, dynamic> sample) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.science,
              color: Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sample['sample_code'] ?? 'Sample',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  sample['sample_type'] ?? 'Unknown Type',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Pending',
              style: TextStyle(
                fontSize: 11,
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabCapacityItem(String labName, int capacity, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              labName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '$capacity%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: capacity / 100,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}
