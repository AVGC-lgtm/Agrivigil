import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../providers/enhanced_permission_provider.dart';
import '../../../utils/theme.dart';
import '../../../models/qc_models.dart';

class QCABCAnalysis extends StatefulWidget {
  const QCABCAnalysis({super.key});

  @override
  State<QCABCAnalysis> createState() => _QCABCAnalysisState();
}

class _QCABCAnalysisState extends State<QCABCAnalysis> {
  String _selectedAnalysisType = 'product';
  String _selectedTimeRange = '3months';
  
  // Mock ABC Analysis data
  final ABCAnalysis _mockAnalysis = ABCAnalysis(
    id: '1',
    analysisType: 'product',
    analysisDate: DateTime.now(),
    analyzedBy: 'QC Manager',
    categories: [
      ABCCategory(
        category: 'A',
        description: 'High priority items (70% of issues)',
        items: [
          ABCItem(
            itemId: '1',
            itemName: 'NPK 10:26:26',
            value: 45,
            cumulativePercentage: 45,
            priority: 'High',
          ),
          ABCItem(
            itemId: '2',
            itemName: 'DAP Fertilizer',
            value: 25,
            cumulativePercentage: 70,
            priority: 'High',
          ),
        ],
        percentage: 70,
        actionRequired: 'Increase inspection frequency, strict quality control',
      ),
      ABCCategory(
        category: 'B',
        description: 'Medium priority items (20% of issues)',
        items: [
          ABCItem(
            itemId: '3',
            itemName: 'Urea',
            value: 12,
            cumulativePercentage: 82,
            priority: 'Medium',
          ),
          ABCItem(
            itemId: '4',
            itemName: 'Pesticide X',
            value: 8,
            cumulativePercentage: 90,
            priority: 'Medium',
          ),
        ],
        percentage: 20,
        actionRequired: 'Regular monitoring, standard procedures',
      ),
      ABCCategory(
        category: 'C',
        description: 'Low priority items (10% of issues)',
        items: [
          ABCItem(
            itemId: '5',
            itemName: 'Seeds Type A',
            value: 5,
            cumulativePercentage: 95,
            priority: 'Low',
          ),
          ABCItem(
            itemId: '6',
            itemName: 'Others',
            value: 5,
            cumulativePercentage: 100,
            priority: 'Low',
          ),
        ],
        percentage: 10,
        actionRequired: 'Periodic review, minimal intervention',
      ),
    ],
    recommendations: 'Focus resources on Category A items for maximum impact',
    createdAt: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    final permissionProvider = Provider.of<EnhancedPermissionProvider>(context);
    final canPerformAnalysis = permissionProvider.hasPermission('qc_module', 'abc_analysis');

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header and Controls
            Container(
              padding: const EdgeInsets.all(16),
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
                            'ABC Analysis',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Prioritize quality control efforts based on impact',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                        ],
                      ),
                      if (canPerformAnalysis)
                        ElevatedButton.icon(
                          onPressed: _performNewAnalysis,
                          icon: const Icon(Icons.analytics),
                          label: const Text('New Analysis'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Analysis Type Selection
                  Row(
                    children: [
                      Text(
                        'Analysis Type:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 16),
                      ..._buildAnalysisTypeChips(),
                      const Spacer(),
                      Text(
                        'Time Range:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 16),
                      ..._buildTimeRangeChips(),
                    ],
                  ),
                ],
              ),
            ),
            
            // Analysis Results
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Pareto Chart
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pareto Chart - ${_getAnalysisTypeLabel(_selectedAnalysisType)}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 300,
                            child: _buildParetoChart(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Category Cards
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildCategoryCard(
                          _mockAnalysis.categories[0], // Category A
                          Colors.red,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCategoryCard(
                          _mockAnalysis.categories[1], // Category B
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCategoryCard(
                          _mockAnalysis.categories[2], // Category C
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Recommendations
                  Card(
                    color: AppTheme.infoColor.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: AppTheme.infoColor,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recommendations',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _mockAnalysis.recommendations,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _exportAnalysis,
                            icon: const Icon(Icons.download, size: 16),
                            label: const Text('Export'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.infoColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAnalysisTypeChips() {
    final types = [
      {'value': 'product', 'label': 'By Product'},
      {'value': 'manufacturer', 'label': 'By Manufacturer'},
      {'value': 'defect', 'label': 'By Defect Type'},
    ];
    
    return types.map((type) {
      final isSelected = _selectedAnalysisType == type['value'];
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(type['label']!),
          selected: isSelected,
          onSelected: (_) {
            setState(() => _selectedAnalysisType = type['value']!);
          },
        ),
      );
    }).toList();
  }

  List<Widget> _buildTimeRangeChips() {
    final ranges = [
      {'value': '1month', 'label': '1 Month'},
      {'value': '3months', 'label': '3 Months'},
      {'value': '6months', 'label': '6 Months'},
      {'value': '1year', 'label': '1 Year'},
    ];
    
    return ranges.map((range) {
      final isSelected = _selectedTimeRange == range['value'];
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(range['label']!),
          selected: isSelected,
          onSelected: (_) {
            setState(() => _selectedTimeRange = range['value']!);
          },
        ),
      );
    }).toList();
  }

  Widget _buildParetoChart() {
    // Flatten all items for the chart
    final allItems = <ABCItem>[];
    for (final category in _mockAnalysis.categories) {
      allItems.addAll(category.items);
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final item = allItems[group.x.toInt()];
              return BarTooltipItem(
                '${item.itemName}\n${item.value}%',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: const TextStyle(fontSize: 12),
                );
              },
              interval: 20,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < allItems.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      allItems[value.toInt()].itemName.length > 10
                          ? '${allItems[value.toInt()].itemName.substring(0, 10)}...'
                          : allItems[value.toInt()].itemName,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
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
        barGroups: allItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final color = _getCategoryColor(
            _mockAnalysis.categories.firstWhere(
              (cat) => cat.items.contains(item),
            ).category,
          );
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.value.toDouble(),
                color: color,
                width: 30,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryCard(ABCCategory category, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      category.category,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category ${category.category}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        '${category.percentage}% of total',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              category.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Top Items:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            ...category.items.take(3).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.arrow_right, size: 16, color: color),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.itemName,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${item.value}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Action Required:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.actionRequired,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'A':
        return Colors.red;
      case 'B':
        return Colors.orange;
      case 'C':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getAnalysisTypeLabel(String type) {
    switch (type) {
      case 'product':
        return 'Product Analysis';
      case 'manufacturer':
        return 'Manufacturer Analysis';
      case 'defect':
        return 'Defect Type Analysis';
      default:
        return 'Analysis';
    }
  }

  void _performNewAnalysis() {
    // Implementation for performing new analysis
  }

  void _exportAnalysis() {
    // Implementation for exporting analysis
  }
}
