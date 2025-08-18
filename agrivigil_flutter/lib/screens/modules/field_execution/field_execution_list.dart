import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/permission_provider.dart';
import '../../../utils/theme.dart';
import '../../../models/inspection_model.dart';
import '../../../services/inspection_service.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/data_table_card.dart';

class FieldExecutionListScreen extends StatefulWidget {
  const FieldExecutionListScreen({super.key});

  @override
  State<FieldExecutionListScreen> createState() => _FieldExecutionListScreenState();
}

class _FieldExecutionListScreenState extends State<FieldExecutionListScreen> {
  final InspectionService _inspectionService = InspectionService();
  List<FieldExecutionModel> _executions = [];
  List<InspectionTaskModel> _inspections = [];
  bool _isLoading = true;
  String _filterStatus = 'all';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final inspections = await _inspectionService.getUserInspections(authProvider.user!.id);
      
      setState(() {
        _inspections = inspections.where((i) => i.status == 'scheduled' || i.status == 'in-progress').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionProvider = Provider.of<PermissionProvider>(context);
    final canCreate = permissionProvider.canEdit('field-execution');
    final isSmallScreen = MediaQuery.of(context).size.width < 768;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
                          'Field Execution',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Execute inspections and collect samples',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (canCreate) ...[
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.productScan,
                            ),
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text('Scan Product'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondaryColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search inspections...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          
          // Inspection List
          Expanded(
            child: _inspections.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No scheduled inspections',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Inspections will appear here when scheduled',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textMuted,
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _inspections.length,
                    itemBuilder: (context, index) {
                      final inspection = _inspections[index];
                      return _buildInspectionCard(inspection, canCreate);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionCard(InspectionTaskModel inspection, bool canExecute) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: canExecute
            ? () => Navigator.pushNamed(
                  context,
                  AppRoutes.fieldExecutionForm,
                  arguments: FieldExecutionArguments(inspectionId: inspection.id),
                )
            : null,
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
                        inspection.inspectioncode,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        inspection.targetType,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  _buildStatusChip(inspection.status),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${inspection.location}, ${inspection.taluka}, ${inspection.district}',
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
                  Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM yyyy').format(DateTime.parse(inspection.datetime)),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    'Target: ${inspection.achievedtarget}/${inspection.totaltarget}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                  ),
                ],
              ),
              if (canExecute) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.fieldExecutionForm,
                      arguments: FieldExecutionArguments(inspectionId: inspection.id),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Execution'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'scheduled':
        color = AppTheme.warningColor;
        text = 'Scheduled';
        break;
      case 'in-progress':
        color = AppTheme.primaryColor;
        text = 'In Progress';
        break;
      case 'completed':
        color = AppTheme.successColor;
        text = 'Completed';
        break;
      default:
        color = Colors.grey;
        text = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
