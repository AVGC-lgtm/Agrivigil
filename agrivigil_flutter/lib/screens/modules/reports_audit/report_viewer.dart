import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../utils/theme.dart';

class ReportViewerScreen extends StatefulWidget {
  const ReportViewerScreen({super.key});

  @override
  State<ReportViewerScreen> createState() => _ReportViewerScreenState();
}

class _ReportViewerScreenState extends State<ReportViewerScreen> {
  bool _isLoading = false;
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Report Viewer'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareReport,
            tooltip: 'Share Report',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadReport,
            tooltip: 'Download PDF',
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printReport,
            tooltip: 'Print Report',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Report Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Inspection Report',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'Period: January 2024',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'Generated: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Tabs
                Container(
                  color: Colors.white,
                  child: Row(
                    children: [
                      _buildTab('Summary', 0),
                      _buildTab('Charts', 1),
                      _buildTab('Details', 2),
                      _buildTab('Insights', 3),
                    ],
                  ),
                ),
                
                // Tab Content
                Expanded(
                  child: IndexedStack(
                    index: _selectedTab,
                    children: [
                      _buildSummaryTab(),
                      _buildChartsTab(),
                      _buildDetailsTab(),
                      _buildInsightsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Key Metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Inspections',
                  '142',
                  Icons.assignment,
                  AppTheme.primaryColor,
                  '+12%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Seizures Made',
                  '28',
                  Icons.inventory_2,
                  AppTheme.errorColor,
                  '+5%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Lab Tests',
                  '45',
                  Icons.science,
                  Colors.blue,
                  '+8%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Legal Cases',
                  '12',
                  Icons.gavel,
                  Colors.purple,
                  '-3%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Executive Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Executive Summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'During January 2024, the field execution team conducted 142 inspections across various districts, resulting in 28 seizures of substandard agricultural products. Lab testing revealed that 65% of seized samples failed to meet quality standards. Legal action has been initiated in 12 cases.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Key Findings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Key Findings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildFindingItem('Most violations found in NPK fertilizers'),
                  _buildFindingItem('Pune district had highest seizure rate'),
                  _buildFindingItem('Adulteration was the primary violation type'),
                  _buildFindingItem('Compliance improved by 15% compared to last month'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Pie Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Violations by Type',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: 35,
                            title: '35%',
                            color: AppTheme.primaryColor,
                            radius: 80,
                          ),
                          PieChartSectionData(
                            value: 25,
                            title: '25%',
                            color: AppTheme.errorColor,
                            radius: 80,
                          ),
                          PieChartSectionData(
                            value: 20,
                            title: '20%',
                            color: Colors.blue,
                            radius: 80,
                          ),
                          PieChartSectionData(
                            value: 20,
                            title: '20%',
                            color: Colors.orange,
                            radius: 80,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLegendItem('Adulteration', AppTheme.primaryColor),
                      _buildLegendItem('Mislabeling', AppTheme.errorColor),
                      _buildLegendItem('Expired', Colors.blue),
                      _buildLegendItem('Other', Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Bar Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Trend',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        barGroups: [
                          BarChartGroupData(x: 0, barRods: [
                            BarChartRodData(toY: 120, color: AppTheme.primaryColor),
                          ]),
                          BarChartGroupData(x: 1, barRods: [
                            BarChartRodData(toY: 135, color: AppTheme.primaryColor),
                          ]),
                          BarChartGroupData(x: 2, barRods: [
                            BarChartRodData(toY: 142, color: AppTheme.primaryColor),
                          ]),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                switch (value.toInt()) {
                                  case 0:
                                    return const Text('Nov');
                                  case 1:
                                    return const Text('Dec');
                                  case 2:
                                    return const Text('Jan');
                                  default:
                                    return const Text('');
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // District-wise Breakdown
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'District-wise Breakdown',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildDataRow('Pune', '45 inspections, 8 seizures'),
                  _buildDataRow('Nashik', '38 inspections, 6 seizures'),
                  _buildDataRow('Ahmednagar', '32 inspections, 7 seizures'),
                  _buildDataRow('Solapur', '27 inspections, 7 seizures'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Product Categories
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Categories Inspected',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildDataRow('NPK Fertilizers', '42 samples'),
                  _buildDataRow('Pesticides', '35 samples'),
                  _buildDataRow('Seeds', '28 samples'),
                  _buildDataRow('Urea', '37 samples'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: AppTheme.warningColor),
                      const SizedBox(width: 8),
                      Text(
                        'Key Insights',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInsightCard(
                    'High Risk Areas',
                    'Markets in urban areas show 40% higher violation rates',
                    Colors.red,
                  ),
                  _buildInsightCard(
                    'Seasonal Pattern',
                    'Violations increase by 25% during harvest season',
                    Colors.orange,
                  ),
                  _buildInsightCard(
                    'Compliance Improvement',
                    'Regular inspections led to 15% improvement in compliance',
                    Colors.green,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.recommend, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Recommendations',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildRecommendation('Increase inspection frequency in high-risk areas'),
                  _buildRecommendation('Focus on NPK fertilizer testing'),
                  _buildRecommendation('Strengthen lab testing capabilities'),
                  _buildRecommendation('Improve coordination with legal department'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String change) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: change.startsWith('+') ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFindingItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 20, color: AppTheme.successColor),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String title, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(description),
        ],
      ),
    );
  }

  Widget _buildRecommendation(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.arrow_forward, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _shareReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing report...')),
    );
  }

  void _downloadReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading PDF...')),
    );
  }

  void _printReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preparing for print...')),
    );
  }
}
