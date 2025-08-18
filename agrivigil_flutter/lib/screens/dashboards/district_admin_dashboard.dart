import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/recent_activity_card.dart';
import '../../routes/app_routes.dart';

class DistrictAdminDashboard extends StatefulWidget {
  const DistrictAdminDashboard({super.key});

  @override
  State<DistrictAdminDashboard> createState() => _DistrictAdminDashboardState();
}

class _DistrictAdminDashboardState extends State<DistrictAdminDashboard> {
  bool _isLoading = false;
  String _selectedView = 'overview';

  // Mock data
  final Map<String, dynamic> _districtStats = {
    'total_officers': 45,
    'active_inspections': 12,
    'pending_cases': 8,
    'monthly_target': 150,
    'completed_inspections': 132,
    'compliance_rate': 94.5,
  };

  final List<Map<String, dynamic>> _teamPerformance = [
    {
      'name': 'Team Alpha',
      'leader': 'John Doe',
      'inspections': 45,
      'seizures': 3
    },
    {
      'name': 'Team Beta',
      'leader': 'Jane Smith',
      'inspections': 38,
      'seizures': 2
    },
    {
      'name': 'Team Gamma',
      'leader': 'Bob Wilson',
      'inspections': 42,
      'seizures': 4
    },
    {
      'name': 'Team Delta',
      'leader': 'Alice Brown',
      'inspections': 35,
      'seizures': 1
    },
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('District Administration'),
        backgroundColor: Colors.brown,
        elevation: 0,
        actions: [
          // View Selector
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _selectedView,
              dropdownColor: Colors.brown,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items: const [
                DropdownMenuItem(
                  value: 'overview',
                  child:
                      Text('Overview', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: 'teams',
                  child: Text('Teams', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: 'resources',
                  child:
                      Text('Resources', style: TextStyle(color: Colors.white)),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedView = value!);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
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
        selectedModule: 'district',
        onModuleSelected: (module) {
          // Handle module selection
          Navigator.pop(context);
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _isLoading = true);
          await Future.delayed(const Duration(seconds: 1));
          setState(() => _isLoading = false);
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildSelectedView(),
      ),
    );
  }

  Widget _buildSelectedView() {
    switch (_selectedView) {
      case 'teams':
        return _buildTeamsView();
      case 'resources':
        return _buildResourcesView();
      default:
        return _buildOverviewView();
    }
  }

  Widget _buildOverviewView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // District Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.brown, Colors.brown.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
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
                        const Text(
                          'DISTRICT COMMAND',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'District Central',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            const Text(
                              'Zone A • 15 Blocks',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green, width: 1),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, color: Colors.green, size: 8),
                              SizedBox(width: 4),
                              Text(
                                'OPERATIONAL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_districtStats['total_officers']} Active Officers',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Monthly Target Progress',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          '${_districtStats['completed_inspections']}/${_districtStats['monthly_target']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _districtStats['completed_inspections'] /
                          _districtStats['monthly_target'],
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.lightGreen),
                      minHeight: 8,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Stats
          Text(
            'District Operations',
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
                title: 'Active Inspections',
                value: '${_districtStats['active_inspections']}',
                icon: Icons.assignment,
                color: Colors.blue,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.fieldExecutionList);
                },
              ),
              StatCard(
                title: 'Pending Cases',
                value: '${_districtStats['pending_cases']}',
                icon: Icons.pending_actions,
                color: Colors.orange,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.firCaseList);
                },
              ),
              StatCard(
                title: 'Compliance Rate',
                value: '${_districtStats['compliance_rate']}%',
                icon: Icons.verified,
                color: Colors.green,
                onTap: () {},
              ),
              StatCard(
                title: 'Field Teams',
                value: '${_teamPerformance.length}',
                icon: Icons.groups,
                color: Colors.purple,
                onTap: () {
                  setState(() => _selectedView = 'teams');
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Performance Chart
          Text(
            'Weekly Performance Trend',
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
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        return Text(
                          days[value.toInt() % 7],
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 18),
                      const FlSpot(1, 22),
                      const FlSpot(2, 20),
                      const FlSpot(3, 25),
                      const FlSpot(4, 23),
                      const FlSpot(5, 15),
                      const FlSpot(6, 12),
                    ],
                    isCurved: true,
                    color: Colors.brown,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.brown.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Recent Activities
          Text(
            'Recent District Activities',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              RecentActivityCard(
                title: 'New Inspection Started',
                subtitle: 'Block A - Team Alpha deployed',
                time: '10 minutes ago',
                icon: Icons.play_circle,
                iconColor: Colors.green,
              ),
              RecentActivityCard(
                title: 'Seizure Reported',
                subtitle: 'Block C - Pesticide violation',
                time: '1 hour ago',
                icon: Icons.report,
                iconColor: Colors.red,
              ),
              RecentActivityCard(
                title: 'Lab Sample Collected',
                subtitle: 'Block B - 5 samples sent to lab',
                time: '3 hours ago',
                icon: Icons.science,
                iconColor: Colors.blue,
              ),
              RecentActivityCard(
                title: 'Team Briefing Completed',
                subtitle: 'Weekly coordination meeting',
                time: '5 hours ago',
                icon: Icons.meeting_room,
                iconColor: Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Field Team Management',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),

          // Team Cards
          ..._teamPerformance
              .map((team) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  team['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Team Leader: ${team['leader']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildTeamStat('Inspections',
                                '${team['inspections']}', Icons.assignment),
                            _buildTeamStat('Seizures', '${team['seizures']}',
                                Icons.report),
                            _buildTeamStat('Members', '8', Icons.people),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.message, size: 16),
                              label: const Text('Message'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.visibility, size: 16),
                              label: const Text('View Details'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildResourcesView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resource Allocation',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),

          // Resource Categories
          _buildResourceCard(
            'Vehicles',
            '12 Available',
            Icons.directions_car,
            Colors.blue,
            [
              {
                'name': 'Inspection Van #1',
                'status': 'In Use',
                'team': 'Team Alpha'
              },
              {'name': 'Inspection Van #2', 'status': 'Available', 'team': '-'},
              {
                'name': 'Mobile Lab Unit',
                'status': 'In Use',
                'team': 'Team Beta'
              },
            ],
          ),
          const SizedBox(height: 16),
          _buildResourceCard(
            'Equipment',
            '45 Items',
            Icons.build,
            Colors.orange,
            [
              {
                'name': 'Testing Kits',
                'status': '120 Available',
                'team': 'Stock'
              },
              {
                'name': 'Sample Containers',
                'status': '200 Available',
                'team': 'Stock'
              },
              {
                'name': 'GPS Devices',
                'status': '8 In Use',
                'team': 'Field Teams'
              },
            ],
          ),
          const SizedBox(height: 16),
          _buildResourceCard(
            'Personnel',
            '45 Officers',
            Icons.people,
            Colors.green,
            [
              {
                'name': 'Field Officers',
                'status': '32 Active',
                'team': 'Field'
              },
              {'name': 'Lab Technicians', 'status': '8 Active', 'team': 'Lab'},
              {'name': 'Support Staff', 'status': '5 Active', 'team': 'Office'},
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.brown, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildResourceCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    List<Map<String, String>> items,
  ) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items
              .map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item['name']!),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: item['status']!.contains('Available')
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item['status']!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: item['status']!.contains('Available')
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (item['team'] != '-' && item['team'] != 'Stock')
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  item['team']!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}
