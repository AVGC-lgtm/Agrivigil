import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/enhanced_permission_provider.dart';
import '../../../utils/theme.dart';
import '../../../models/qc_models.dart';

class QCInspectionList extends StatefulWidget {
  const QCInspectionList({super.key});

  @override
  State<QCInspectionList> createState() => _QCInspectionListState();
}

class _QCInspectionListState extends State<QCInspectionList> {
  String _filterStatus = 'all';
  String _filterType = 'all';
  final _searchController = TextEditingController();

  // Mock data - replace with API calls
  final List<QCInspection> _inspections = [
    QCInspection(
      id: '1',
      inspectionCode: 'QC-2024-001',
      processType: 'routine',
      scheduledDate: DateTime.now().subtract(const Duration(days: 2)),
      assignedOfficerId: 'user1',
      assignedOfficerName: 'John Doe',
      status: QCStatus.completed,
      checkpoints: [],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    QCInspection(
      id: '2',
      inspectionCode: 'QC-2024-002',
      processType: 'complaint-based',
      scheduledDate: DateTime.now(),
      assignedOfficerId: 'user2',
      assignedOfficerName: 'Jane Smith',
      status: QCStatus.inProgress,
      checkpoints: [],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final permissionProvider = Provider.of<EnhancedPermissionProvider>(context);
    final canCreate = permissionProvider.hasPermission('qc_module', 'create_qc_inspection');
    final canApprove = permissionProvider.hasPermission('qc_module', 'approve_qc_inspection');

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Filters and Search
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search inspections...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (canCreate)
                      ElevatedButton.icon(
                        onPressed: _showCreateInspectionDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('New Inspection'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all', _filterStatus, (value) {
                        setState(() => _filterStatus = value);
                      }),
                      _buildFilterChip('Pending', 'pending', _filterStatus, (value) {
                        setState(() => _filterStatus = value);
                      }),
                      _buildFilterChip('In Progress', 'inProgress', _filterStatus, (value) {
                        setState(() => _filterStatus = value);
                      }),
                      _buildFilterChip('Awaiting Approval', 'awaitingApproval', _filterStatus, (value) {
                        setState(() => _filterStatus = value);
                      }),
                      _buildFilterChip('Completed', 'completed', _filterStatus, (value) {
                        setState(() => _filterStatus = value);
                      }),
                      const SizedBox(width: 16),
                      const Text('Type:', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      _buildFilterChip('All Types', 'all', _filterType, (value) {
                        setState(() => _filterType = value);
                      }),
                      _buildFilterChip('Routine', 'routine', _filterType, (value) {
                        setState(() => _filterType = value);
                      }),
                      _buildFilterChip('Complaint Based', 'complaint-based', _filterType, (value) {
                        setState(() => _filterType = value);
                      }),
                      _buildFilterChip('Special', 'special', _filterType, (value) {
                        setState(() => _filterType = value);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Inspection List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _inspections.length,
              itemBuilder: (context, index) {
                final inspection = _inspections[index];
                return _buildInspectionCard(inspection, canApprove);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String groupValue, Function(String) onSelected) {
    final isSelected = value == groupValue;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(value),
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

  Widget _buildInspectionCard(QCInspection inspection, bool canApprove) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showInspectionDetails(inspection),
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
                        inspection.inspectionCode,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _getTypeIcon(inspection.processType),
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatProcessType(inspection.processType),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _buildStatusChip(inspection.status),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.person,
                      'Inspector',
                      inspection.assignedOfficerName,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.calendar_today,
                      'Scheduled',
                      _formatDate(inspection.scheduledDate),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Checkpoints Completed',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '7/10',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.7,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getStatusColor(inspection.status),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showInspectionDetails(inspection),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View'),
                  ),
                  if (canApprove && inspection.status == QCStatus.awaitingApproval) ...[
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _approveInspection(inspection),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _rejectInspection(inspection),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textMuted),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(QCStatus status) {
    final color = _getStatusColor(status);
    final text = _getStatusText(status);
    
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
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
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

  Color _getStatusColor(QCStatus status) {
    switch (status) {
      case QCStatus.pending:
        return Colors.grey;
      case QCStatus.inProgress:
        return AppTheme.primaryColor;
      case QCStatus.awaitingApproval:
        return AppTheme.warningColor;
      case QCStatus.approved:
        return AppTheme.successColor;
      case QCStatus.rejected:
        return AppTheme.errorColor;
      case QCStatus.completed:
        return Colors.blue;
      case QCStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(QCStatus status) {
    switch (status) {
      case QCStatus.pending:
        return 'Pending';
      case QCStatus.inProgress:
        return 'In Progress';
      case QCStatus.awaitingApproval:
        return 'Awaiting Approval';
      case QCStatus.approved:
        return 'Approved';
      case QCStatus.rejected:
        return 'Rejected';
      case QCStatus.completed:
        return 'Completed';
      case QCStatus.cancelled:
        return 'Cancelled';
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'routine':
        return Icons.schedule;
      case 'complaint-based':
        return Icons.warning;
      case 'special':
        return Icons.star;
      default:
        return Icons.assignment;
    }
  }

  String _formatProcessType(String type) {
    return type.split('-').map((word) => 
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCreateInspectionDialog() {
    // Implementation for creating new inspection
  }

  void _showInspectionDetails(QCInspection inspection) {
    // Implementation for showing inspection details
  }

  void _approveInspection(QCInspection inspection) {
    // Implementation for approving inspection
  }

  void _rejectInspection(QCInspection inspection) {
    // Implementation for rejecting inspection
  }
}
