import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/recent_activity_card.dart';
import '../../widgets/app_drawer.dart';
import '../../routes/app_routes.dart';

class LegalOfficerDashboard extends StatefulWidget {
  const LegalOfficerDashboard({super.key});

  @override
  State<LegalOfficerDashboard> createState() => _LegalOfficerDashboardState();
}

class _LegalOfficerDashboardState extends State<LegalOfficerDashboard> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Officer Dashboard'),
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
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.userProfile);
            },
          ),
        ],
      ),
      drawer: AppDrawer(
        selectedModule: 'legal',
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
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back,',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.name ?? 'Legal Officer',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Legal Department - ${DateTime.now().toString().split(' ')[0]}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Statistics Cards
              Text(
                'Case Statistics',
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
                    title: 'Active Cases',
                    value: '24',
                    icon: Icons.gavel,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.firCaseList);
                    },
                  ),
                  StatCard(
                    title: 'Pending Review',
                    value: '8',
                    icon: Icons.pending_actions,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.firCaseList);
                    },
                  ),
                  StatCard(
                    title: 'Court Hearings',
                    value: '5',
                    icon: Icons.account_balance,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.firCaseList);
                    },
                  ),
                  StatCard(
                    title: 'Closed Cases',
                    value: '142',
                    icon: Icons.check_circle,
                    color: Colors.green,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.firCaseList);
                    },
                  ),
                ],
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
                      icon: Icons.add_circle,
                      title: 'New FIR Case',
                      subtitle: 'Register a new FIR case',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.firCaseForm);
                      },
                    ),
                    const Divider(),
                    _buildQuickActionTile(
                      context,
                      icon: Icons.search,
                      title: 'Case Search',
                      subtitle: 'Search existing cases',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.firCaseList);
                      },
                    ),
                    const Divider(),
                    _buildQuickActionTile(
                      context,
                      icon: Icons.document_scanner,
                      title: 'Legal Documents',
                      subtitle: 'Manage legal documents',
                      onTap: () {
                        // Navigate to documents
                      },
                    ),
                    const Divider(),
                    _buildQuickActionTile(
                      context,
                      icon: Icons.calendar_today,
                      title: 'Court Calendar',
                      subtitle: 'View upcoming hearings',
                      onTap: () {
                        // Navigate to calendar
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Recent Activity
              Text(
                'Recent Cases',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  RecentActivityCard(
                    title: 'FIR/2024/001234',
                    subtitle: 'Pesticide violation - Hearing scheduled',
                    time: '2 hours ago',
                    icon: Icons.gavel,
                    iconColor: Colors.orange,
                  ),
                  RecentActivityCard(
                    title: 'FIR/2024/001233',
                    subtitle: 'Fertilizer adulteration - Evidence submitted',
                    time: '5 hours ago',
                    icon: Icons.folder,
                    iconColor: Colors.blue,
                  ),
                  RecentActivityCard(
                    title: 'FIR/2024/001232',
                    subtitle: 'Seed quality issue - Case closed',
                    time: '1 day ago',
                    icon: Icons.check_circle,
                    iconColor: Colors.green,
                  ),
                  // Additional entries would go here
                ],
              ),
              const SizedBox(height: 20),

              // Pending Tasks
              Text(
                'Pending Tasks',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  children: [
                    _buildTaskItem(
                      'Submit evidence for FIR/2024/001234',
                      'Due: Tomorrow',
                      Icons.upload_file,
                    ),
                    const Divider(),
                    _buildTaskItem(
                      'Review lab reports for 3 cases',
                      'Due: In 3 days',
                      Icons.science,
                    ),
                    const Divider(),
                    _buildTaskItem(
                      'Prepare hearing documents',
                      'Due: In 5 days',
                      Icons.description,
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
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
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

  Widget _buildTaskItem(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.amber.shade700),
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
      ],
    );
  }
}
