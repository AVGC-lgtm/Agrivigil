import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/theme.dart';
import '../../../routes/app_routes.dart';

class ReportItem {
  final String id;
  final String title;
  final String type;
  final String period;
  final DateTime generatedDate;
  final IconData icon;
  final Color color;

  ReportItem({
    required this.id,
    required this.title,
    required this.type,
    required this.period,
    required this.generatedDate,
    required this.icon,
    required this.color,
  });
}

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  String _selectedReportType = 'all';
  String _selectedPeriod = 'month';
  bool _isLoading = false;

  final List<ReportItem> _reports = [
    ReportItem(
      id: '1',
      title: 'Monthly Inspection Report',
      type: 'inspection',
      period: 'January 2024',
      generatedDate: DateTime.now().subtract(const Duration(days: 5)),
      icon: Icons.assignment,
      color: AppTheme.primaryColor,
    ),
    ReportItem(
      id: '2',
      title: 'Seizure Analysis Report',
      type: 'seizure',
      period: 'Q4 2023',
      generatedDate: DateTime.now().subtract(const Duration(days: 10)),
      icon: Icons.inventory_2,
      color: AppTheme.errorColor,
    ),
    ReportItem(
      id: '3',
      title: 'Lab Test Results Summary',
      type: 'lab',
      period: 'December 2023',
      generatedDate: DateTime.now().subtract(const Duration(days: 15)),
      icon: Icons.science,
      color: Colors.blue,
    ),
    ReportItem(
      id: '4',
      title: 'Legal Cases Report',
      type: 'legal',
      period: 'January 2024',
      generatedDate: DateTime.now().subtract(const Duration(days: 3)),
      icon: Icons.gavel,
      color: Colors.purple,
    ),
    ReportItem(
      id: '5',
      title: 'Performance Dashboard',
      type: 'performance',
      period: 'January 2024',
      generatedDate: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.dashboard,
      color: Colors.orange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.auditLog),
            tooltip: 'Audit Log',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header & Filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reports & Analytics',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Generate and view various reports',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),
                // Report Type Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      _buildFilterChip('Inspection', 'inspection'),
                      _buildFilterChip('Seizure', 'seizure'),
                      _buildFilterChip('Lab', 'lab'),
                      _buildFilterChip('Legal', 'legal'),
                      _buildFilterChip('Performance', 'performance'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Period Filter
                Row(
                  children: [
                    const Text('Period: '),
                    const SizedBox(width: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'week', label: Text('Week')),
                        ButtonSegment(value: 'month', label: Text('Month')),
                        ButtonSegment(value: 'quarter', label: Text('Quarter')),
                        ButtonSegment(value: 'year', label: Text('Year')),
                      ],
                      selected: {_selectedPeriod},
                      onSelectionChanged: (Set<String> selection) {
                        setState(() {
                          _selectedPeriod = selection.first;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Quick Actions
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    context,
                    'Generate Report',
                    Icons.add_chart,
                    AppTheme.primaryColor,
                    () => _showGenerateReportDialog(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    context,
                    'Schedule Report',
                    Icons.schedule,
                    Colors.orange,
                    () => _showScheduleReportDialog(context),
                  ),
                ),
              ],
            ),
          ),

          // Reports List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _reports.length,
                    itemBuilder: (context, index) {
                      final report = _reports[index];
                      if (_selectedReportType != 'all' &&
                          report.type != _selectedReportType) {
                        return const SizedBox.shrink();
                      }
                      return _buildReportCard(context, report);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedReportType == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _selectedReportType = value);
        },
        backgroundColor: Colors.grey.shade100,
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, ReportItem report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.reportViewer,
          arguments: ReportArguments(reportType: report.type),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: report.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  report.icon,
                  color: report.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.period,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Generated ${DateFormat('dd MMM yyyy').format(report.generatedDate)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.reportViewer,
                      arguments: ReportArguments(reportType: report.type),
                    ),
                    color: AppTheme.primaryColor,
                  ),
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () => _downloadReport(report),
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGenerateReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate New Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Inspection Report'),
              subtitle: const Text('Generate inspection summary'),
              onTap: () {
                Navigator.pop(context);
                _generateReport('inspection');
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Seizure Report'),
              subtitle: const Text('Generate seizure analysis'),
              onTap: () {
                Navigator.pop(context);
                _generateReport('seizure');
              },
            ),
            ListTile(
              leading: const Icon(Icons.science),
              title: const Text('Lab Report'),
              subtitle: const Text('Generate lab test summary'),
              onTap: () {
                Navigator.pop(context);
                _generateReport('lab');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showScheduleReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Report'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Report Type',
                hintText: 'Select report type',
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Frequency',
                hintText: 'Daily, Weekly, Monthly',
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Recipients',
                hintText: 'Enter email addresses',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report scheduled successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _generateReport(String type) {
    setState(() => _isLoading = true);
    
    // Simulate report generation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$type report generated successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    });
  }

  void _downloadReport(ReportItem report) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${report.title}...'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }
}
