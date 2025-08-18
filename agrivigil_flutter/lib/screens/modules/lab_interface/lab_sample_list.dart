import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/theme.dart';
import '../../../models/seizure_model.dart';
import '../../../routes/app_routes.dart';

class LabSampleListScreen extends StatefulWidget {
  const LabSampleListScreen({super.key});

  @override
  State<LabSampleListScreen> createState() => _LabSampleListScreenState();
}

class _LabSampleListScreenState extends State<LabSampleListScreen> {
  List<LabSampleModel> _samples = [];
  bool _isLoading = false;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadSamples();
  }

  Future<void> _loadSamples() async {
    setState(() => _isLoading = true);
    
    // Mock data - replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _samples = _getMockSamples();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Header
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
                          'Lab Interface',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track and manage lab samples',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.labSampleForm,
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Register Sample'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      _buildFilterChip('In Transit', 'in-transit'),
                      _buildFilterChip('Received', 'received'),
                      _buildFilterChip('Under Test', 'under-test'),
                      _buildFilterChip('Completed', 'completed'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Stats Cards
          Container(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: isSmallScreen ? 2 : 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isSmallScreen ? 1.5 : 2,
              children: [
                _buildStatCard('Total Samples', '126', Icons.science, Colors.blue),
                _buildStatCard('Pending', '18', Icons.pending, AppTheme.warningColor),
                _buildStatCard('In Progress', '12', Icons.autorenew, Colors.orange),
                _buildStatCard('Completed', '96', Icons.check_circle, AppTheme.successColor),
              ],
            ),
          ),
          
          // Sample List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _samples.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.science_outlined,
                              size: 64,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No lab samples',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Lab samples will appear here',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textMuted,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _samples.length,
                        itemBuilder: (context, index) {
                          final sample = _samples[index];
                          return _buildSampleCard(sample);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _filterStatus = value);
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleCard(LabSampleModel sample) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.labSampleDetail,
          arguments: LabSampleArguments(sampleId: sample.id.toString()),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                        sample.samplecode,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Department: ${sample.department}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  _buildStatusChip(sample.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    sample.sampleDesc,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.inventory_2, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'From: ${sample.seizureId}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Dispatched: ${sample.dispatchedAt != null ? DateFormat('dd MMM yyyy').format(sample.dispatchedAt!) : 'Not dispatched'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                  ),
                  if (sample.receivedAt != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.check, size: 16, color: AppTheme.successColor),
                    const SizedBox(width: 4),
                    Text(
                      'Received: ${DateFormat('dd MMM yyyy').format(sample.receivedAt!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                          ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              // Progress Bar
              if (sample.status == 'under-test') ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Test Progress',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '60%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (sample.status == 'received' || sample.status == 'under-test')
                    TextButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.testResultForm,
                        arguments: LabSampleArguments(sampleId: sample.id.toString()),
                      ),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Enter Results'),
                    ),
                  TextButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.labSampleDetail,
                      arguments: LabSampleArguments(sampleId: sample.id.toString()),
                    ),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    IconData icon;
    
    switch (status) {
      case 'in-transit':
        color = AppTheme.warningColor;
        text = 'In Transit';
        icon = Icons.local_shipping;
        break;
      case 'received':
        color = Colors.blue;
        text = 'Received';
        icon = Icons.inbox;
        break;
      case 'under-test':
        color = Colors.orange;
        text = 'Under Test';
        icon = Icons.science;
        break;
      case 'completed':
        color = AppTheme.successColor;
        text = 'Completed';
        icon = Icons.check_circle;
        break;
      default:
        color = Colors.grey;
        text = status;
        icon = Icons.help_outline;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<LabSampleModel> _getMockSamples() {
    return [
      LabSampleModel(
        id: 1,
        samplecode: 'LAB-2024-001',
        department: 'Quality Control',
        sampleDesc: 'NPK Fertilizer Sample',
        district: 'Pune',
        status: 'under-test',
        collectedAt: DateTime.now().subtract(const Duration(days: 4)),
        dispatchedAt: DateTime.now().subtract(const Duration(days: 3)),
        receivedAt: DateTime.now().subtract(const Duration(days: 2)),
        underTesting: true,
        resultStatus: null,
        reportSentAt: null,
        officerName: 'Officer Smith',
        remarks: 'Sample collected from market',
        userId: 'user1',
        seizureId: 'SEIZ-001',
      ),
      LabSampleModel(
        id: 2,
        samplecode: 'LAB-2024-002',
        department: 'Quality Control',
        sampleDesc: 'Pesticide Sample',
        district: 'Nashik',
        status: 'completed',
        collectedAt: DateTime.now().subtract(const Duration(days: 8)),
        dispatchedAt: DateTime.now().subtract(const Duration(days: 7)),
        receivedAt: DateTime.now().subtract(const Duration(days: 6)),
        underTesting: false,
        resultStatus: 'Failed',
        reportSentAt: DateTime.now().subtract(const Duration(days: 1)),
        officerName: 'Officer Johnson',
        remarks: 'Failed quality standards',
        userId: 'user1',
        seizureId: 'SEIZ-002',
      ),
    ];
  }
}
