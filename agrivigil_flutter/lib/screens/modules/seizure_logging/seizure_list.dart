import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/theme.dart';
import '../../../models/seizure_model.dart';
import '../../../routes/app_routes.dart';

class SeizureListScreen extends StatefulWidget {
  const SeizureListScreen({super.key});

  @override
  State<SeizureListScreen> createState() => _SeizureListScreenState();
}

class _SeizureListScreenState extends State<SeizureListScreen> {
  List<SeizureModel> _seizures = [];
  bool _isLoading = false;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadSeizures();
  }

  Future<void> _loadSeizures() async {
    setState(() => _isLoading = true);
    
    // Mock data - replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _seizures = _getMockSeizures();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Seizure Records'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header with stats
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
                          'Seizure Management',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track and manage seizure records',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.seizureForm,
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('New Seizure'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
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
                      _buildFilterChip('Pending', 'pending'),
                      _buildFilterChip('Dispatched', 'dispatched'),
                      _buildFilterChip('Analyzed', 'analyzed'),
                      _buildFilterChip('Closed', 'closed'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Stats Cards
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Seizures',
                    '${_seizures.length}',
                    Icons.inventory_2,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Pending Lab',
                    '${_seizures.where((s) => s.status == 'pending').length}',
                    Icons.pending,
                    AppTheme.warningColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Completed',
                    '${_seizures.where((s) => s.status == 'closed').length}',
                    Icons.check_circle,
                    AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Seizure List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _seizures.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No seizure records',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create a new seizure record to get started',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textMuted,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _seizures.length,
                        itemBuilder: (context, index) {
                          final seizure = _seizures[index];
                          return _buildSeizureCard(seizure);
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
          _loadSeizures();
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
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
          ),
        ],
      ),
    );
  }

  Widget _buildSeizureCard(SeizureModel seizure) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.seizureDetail,
          arguments: SeizureArguments(seizureId: seizure.id),
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
                  Text(
                    seizure.seizurecode,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  _buildStatusChip(seizure.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${seizure.location}, ${seizure.district}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    seizure.fertilizerType ?? 'Unknown Product',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.inventory, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${seizure.quantity ?? 0} kg',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    seizure.seizureDate != null
                        ? DateFormat('dd MMM yyyy').format(seizure.seizureDate!)
                        : 'No date',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                  ),
                  const Spacer(),
                  if (seizure.status == 'pending')
                    TextButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.labSampleForm,
                        arguments: LabSampleArguments(seizureId: seizure.id),
                      ),
                      icon: const Icon(Icons.science, size: 16),
                      label: const Text('Send to Lab'),
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
      case 'pending':
        color = AppTheme.warningColor;
        text = 'Pending';
        icon = Icons.pending;
        break;
      case 'dispatched':
        color = Colors.blue;
        text = 'Dispatched';
        icon = Icons.local_shipping;
        break;
      case 'analyzed':
        color = Colors.purple;
        text = 'Analyzed';
        icon = Icons.science;
        break;
      case 'closed':
        color = AppTheme.successColor;
        text = 'Closed';
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

  List<SeizureModel> _getMockSeizures() {
    return [
      SeizureModel(
        id: '1',
        seizurecode: 'SEIZ-2024-001',
        fieldExecutionId: 1,
        location: 'Market Yard',
        district: 'Pune',
        taluka: 'Haveli',
        premisesType: ['shop', 'warehouse'],
        fertilizerType: 'NPK Fertilizer',
        batchNo: 'BATCH-001',
        quantity: 500,
        estimatedValue: '₹25,000',
        witnessName: 'John Doe',
        evidencePhotos: [],
        status: 'pending',
        seizureDate: DateTime.now().subtract(const Duration(days: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now(),
        userId: 'user1',
      ),
      SeizureModel(
        id: '2',
        seizurecode: 'SEIZ-2024-002',
        fieldExecutionId: 2,
        location: 'Agricultural Store',
        district: 'Nashik',
        premisesType: ['shop'],
        fertilizerType: 'Pesticide',
        quantity: 200,
        estimatedValue: '₹15,000',
        evidencePhotos: [],
        status: 'dispatched',
        seizureDate: DateTime.now().subtract(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
        userId: 'user1',
      ),
      SeizureModel(
        id: '3',
        seizurecode: 'SEIZ-2024-003',
        fieldExecutionId: 3,
        location: 'Farm Storage',
        district: 'Ahmednagar',
        premisesType: ['warehouse'],
        fertilizerType: 'Urea',
        quantity: 1000,
        estimatedValue: '₹50,000',
        evidencePhotos: [],
        status: 'closed',
        seizureDate: DateTime.now().subtract(const Duration(days: 10)),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
        userId: 'user1',
      ),
    ];
  }
}
