import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/enhanced_permission_provider.dart';
import '../../../utils/theme.dart';
import '../../../models/qc_models.dart';

class QCApprovalWorkflow extends StatefulWidget {
  const QCApprovalWorkflow({super.key});

  @override
  State<QCApprovalWorkflow> createState() => _QCApprovalWorkflowState();
}

class _QCApprovalWorkflowState extends State<QCApprovalWorkflow> {
  String _filterType = 'pending';
  
  // Mock approval items
  final List<Map<String, dynamic>> _approvalItems = [
    {
      'id': '1',
      'type': 'QC Inspection',
      'code': 'QC-2024-001',
      'title': 'NPK Fertilizer Quality Check',
      'submittedBy': 'John Doe',
      'submittedAt': DateTime.now().subtract(const Duration(hours: 2)),
      'level': 'L1',
      'status': 'pending',
      'priority': 'high',
      'department': 'QC',
    },
    {
      'id': '2',
      'type': 'Lab Report',
      'code': 'LAB-2024-045',
      'title': 'Pesticide Sample Analysis',
      'submittedBy': 'Lab Analyst',
      'submittedAt': DateTime.now().subtract(const Duration(days: 1)),
      'level': 'L2',
      'status': 'pending',
      'priority': 'medium',
      'department': 'LAB',
    },
    {
      'id': '3',
      'type': 'Compliance Deviation',
      'code': 'DEV-2024-012',
      'title': 'Moisture Content Deviation',
      'submittedBy': 'QC Inspector',
      'submittedAt': DateTime.now().subtract(const Duration(days: 2)),
      'level': 'L3',
      'status': 'approved',
      'priority': 'low',
      'department': 'QC',
      'approvedBy': 'QC Manager',
      'approvedAt': DateTime.now().subtract(const Duration(hours: 12)),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final permissionProvider = Provider.of<EnhancedPermissionProvider>(context);
    final userRole = permissionProvider.userRole;
    
    final filteredItems = _approvalItems.where((item) {
      if (_filterType == 'all') return true;
      return item['status'] == _filterType;
    }).toList();

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
                          'Approval Workflow',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage pending approvals and review history',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                    if (userRole != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.approval,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Approval Level: ${_getApprovalLevel(userRole.id)}',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Filters
                Row(
                  children: [
                    _buildFilterChip('Pending', 'pending', Icons.pending),
                    _buildFilterChip('Approved', 'approved', Icons.check_circle),
                    _buildFilterChip('Rejected', 'rejected', Icons.cancel),
                    _buildFilterChip('All', 'all', Icons.all_inclusive),
                  ],
                ),
              ],
            ),
          ),
          
          // Stats
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStatCard(
                  'Pending My Approval',
                  '8',
                  Icons.hourglass_empty,
                  AppTheme.warningColor,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Approved Today',
                  '5',
                  Icons.check_circle,
                  AppTheme.successColor,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Total This Week',
                  '24',
                  Icons.assessment,
                  AppTheme.primaryColor,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Average TAT',
                  '2.5h',
                  Icons.timer,
                  Colors.blue,
                ),
              ],
            ),
          ),
          
          // Approval Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return _buildApprovalCard(item, permissionProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _filterType == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _filterType = value);
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApprovalCard(Map<String, dynamic> item, EnhancedPermissionProvider permissionProvider) {
    final canApprove = _canApproveItem(item, permissionProvider);
    final statusColor = _getStatusColor(item['status']);
    final priorityColor = _getPriorityColor(item['priority']);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showApprovalDetails(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getTypeColor(item['type']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(item['type']),
                      color: _getTypeColor(item['type']),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item['code'],
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: priorityColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item['priority'].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: priorityColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['title'],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: 14, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              'Submitted by ${item['submittedBy']}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.access_time, size: 14, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              _formatTimeAgo(item['submittedAt']),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item['status'].toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Approval Level and Actions
              Row(
                children: [
                  // Approval Level
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.security, size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Level ${item['level']} Approval',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Department
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      item['department'],
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Actions
                  if (item['status'] == 'pending' && canApprove) ...[
                    TextButton.icon(
                      onPressed: () => _approveItem(item),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _rejectItem(item),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                      ),
                    ),
                  ] else if (item['status'] == 'approved') ...[
                    Row(
                      children: [
                        Icon(Icons.check_circle, size: 16, color: AppTheme.successColor),
                        const SizedBox(width: 4),
                        Text(
                          'Approved by ${item['approvedBy']}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.successColor,
                              ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              
              // Workflow Progress
              if (item['status'] == 'pending') ...[
                const SizedBox(height: 16),
                _buildWorkflowProgress(item),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkflowProgress(Map<String, dynamic> item) {
    final steps = ['Submitted', 'L1 Review', 'L2 Review', 'L3 Review', 'Completed'];
    final currentStep = _getCurrentStep(item['level']);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Approval Progress',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(steps.length * 2 - 1, (index) {
            if (index.isOdd) {
              return Expanded(
                child: Container(
                  height: 2,
                  color: index ~/ 2 < currentStep
                      ? AppTheme.primaryColor
                      : Colors.grey.shade300,
                ),
              );
            }
            
            final stepIndex = index ~/ 2;
            final isCompleted = stepIndex < currentStep;
            final isCurrent = stepIndex == currentStep;
            
            return Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppTheme.primaryColor
                    : isCurrent
                        ? AppTheme.warningColor
                        : Colors.grey.shade300,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isCurrent ? Colors.white : AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            );
          }),
        ),
      ],
    );
  }

  String _getApprovalLevel(String roleId) {
    final levelMap = {
      'QC_INSPECTOR': 'L1',
      'QC_SUPERVISOR': 'L2',
      'QC_MANAGER': 'L3',
      'QC_HEAD': 'L4',
    };
    return levelMap[roleId] ?? 'N/A';
  }

  int _getCurrentStep(String level) {
    switch (level) {
      case 'L1':
        return 1;
      case 'L2':
        return 2;
      case 'L3':
        return 3;
      default:
        return 0;
    }
  }

  bool _canApproveItem(Map<String, dynamic> item, EnhancedPermissionProvider permissionProvider) {
    // Check if user has the right approval level
    final userLevel = _getApprovalLevel(permissionProvider.userRole?.id ?? '');
    return userLevel == item['level'];
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.warningColor;
      case 'approved':
        return AppTheme.successColor;
      case 'rejected':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'QC Inspection':
        return AppTheme.primaryColor;
      case 'Lab Report':
        return Colors.blue;
      case 'Compliance Deviation':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'QC Inspection':
        return Icons.assignment_turned_in;
      case 'Lab Report':
        return Icons.science;
      case 'Compliance Deviation':
        return Icons.warning;
      default:
        return Icons.description;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  void _showApprovalDetails(Map<String, dynamic> item) {
    // Implementation for showing approval details
  }

  void _approveItem(Map<String, dynamic> item) {
    // Implementation for approving item
  }

  void _rejectItem(Map<String, dynamic> item) {
    // Implementation for rejecting item
  }
}
