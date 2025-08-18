import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/theme.dart';
import '../../../models/seizure_model.dart';
import '../../../routes/app_routes.dart';

class FIRCaseListScreen extends StatefulWidget {
  const FIRCaseListScreen({super.key});

  @override
  State<FIRCaseListScreen> createState() => _FIRCaseListScreenState();
}

class _FIRCaseListScreenState extends State<FIRCaseListScreen> {
  List<FIRCaseModel> _cases = [];
  bool _isLoading = false;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    setState(() => _isLoading = true);
    
    // Mock data - replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _cases = _getMockCases();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('FIR Cases'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
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
                          'Legal Cases',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage FIR and legal proceedings',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.firCaseForm,
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('New FIR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
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
                      _buildFilterChip('Filed', 'filed'),
                      _buildFilterChip('Under Investigation', 'investigation'),
                      _buildFilterChip('In Court', 'court'),
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
                    'Total Cases',
                    '${_cases.length}',
                    Icons.gavel,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Active',
                    '${_cases.where((c) => c.fircode.isNotEmpty).length}',
                    Icons.pending_actions,
                    AppTheme.warningColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Resolved',
                    '0',
                    Icons.check_circle,
                    AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Cases List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _cases.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.gavel,
                              size: 64,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No FIR cases',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Legal cases will appear here',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textMuted,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _cases.length,
                        itemBuilder: (context, index) {
                          final firCase = _cases[index];
                          return _buildCaseCard(firCase);
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
          _loadCases();
        },
        backgroundColor: Colors.grey.shade100,
        selectedColor: Colors.purple.withOpacity(0.2),
        checkmarkColor: Colors.purple,
        labelStyle: TextStyle(
          color: isSelected ? Colors.purple : AppTheme.textPrimary,
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

  Widget _buildCaseCard(FIRCaseModel firCase) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.firCaseDetail,
          arguments: FIRCaseArguments(caseId: firCase.id.toString()),
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
                    firCase.fircode,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Filed',
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.local_police, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      firCase.policeStation,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Accused: ${firCase.accusedParty}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.warning_amber, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Violations: ${firCase.violationType.join(', ')}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: AppTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    '${firCase.district}, ${firCase.state}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.firCaseDetail,
                      arguments: FIRCaseArguments(caseId: firCase.id.toString()),
                    ),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<FIRCaseModel> _getMockCases() {
    return [
      FIRCaseModel(
        id: 1,
        fircode: 'FIR-2024-001',
        policeStation: 'Shivajinagar Police Station',
        accusedParty: 'ABC Fertilizers Pvt Ltd',
        suspectName: 'John Doe',
        entityType: 'company',
        district: 'Pune',
        state: 'Maharashtra',
        licenseNo: 'LIC-2024-123',
        contactNo: '9876543210',
        brandName: 'Super Grow',
        fertilizerType: 'NPK Fertilizer',
        batchNo: 'BATCH-001',
        violationType: ['adulteration', 'mislabeling'],
        userId: 'user1',
      ),
      FIRCaseModel(
        id: 2,
        fircode: 'FIR-2024-002',
        policeStation: 'City Police Station',
        accusedParty: 'XYZ Agro Shop',
        suspectName: 'Jane Smith',
        entityType: 'shop',
        district: 'Nashik',
        state: 'Maharashtra',
        violationType: ['expired_product', 'no_license'],
        userId: 'user1',
      ),
    ];
  }
}
