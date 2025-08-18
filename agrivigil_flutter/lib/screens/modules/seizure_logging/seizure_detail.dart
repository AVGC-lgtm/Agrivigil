import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/theme.dart';
import '../../../models/seizure_model.dart';
import '../../../routes/app_routes.dart';

class SeizureDetailScreen extends StatelessWidget {
  const SeizureDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Get actual seizure data from arguments or service
    final seizure = _getMockSeizure();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(seizure.seizurecode),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              // TODO: Generate PDF report
            },
            tooltip: 'Export PDF',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  // TODO: Navigate to edit
                  break;
                case 'delete':
                  _showDeleteConfirmation(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: AppTheme.errorColor),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: _getStatusColor(seizure.status),
              child: Column(
                children: [
                  Icon(
                    _getStatusIcon(seizure.status),
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getStatusText(seizure.status),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Seized on ${DateFormat('dd MMM yyyy').format(seizure.seizureDate!)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Quick Actions
                  if (seizure.status == 'pending')
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      color: AppTheme.infoColor.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppTheme.infoColor,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Action Required',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Send samples to lab for testing',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
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
                      ),
                    ),

                  // Location Information
                  _buildSection(
                    context,
                    'Location Information',
                    [
                      _buildDetailRow('Location:', seizure.location),
                      _buildDetailRow('District:', seizure.district),
                      _buildDetailRow('Taluka:', seizure.taluka ?? 'N/A'),
                      _buildDetailRow(
                        'Premises Type:',
                        seizure.premisesType.join(', '),
                      ),
                    ],
                  ),

                  // Product Information
                  _buildSection(
                    context,
                    'Product Information',
                    [
                      _buildDetailRow('Product Type:', seizure.fertilizerType ?? 'N/A'),
                      _buildDetailRow('Batch No:', seizure.batchNo ?? 'N/A'),
                      _buildDetailRow('Quantity:', '${seizure.quantity ?? 0} kg'),
                      _buildDetailRow('Estimated Value:', seizure.estimatedValue ?? 'N/A'),
                    ],
                  ),

                  // Seizure Details
                  _buildSection(
                    context,
                    'Seizure Details',
                    [
                      _buildDetailRow('Seizure Code:', seizure.seizurecode),
                      _buildDetailRow(
                        'Seizure Date:',
                        seizure.seizureDate != null
                            ? DateFormat('dd/MM/yyyy').format(seizure.seizureDate!)
                            : 'N/A',
                      ),
                      _buildDetailRow('Memo No:', seizure.memoNo ?? 'N/A'),
                      _buildDetailRow('Witness Name:', seizure.witnessName ?? 'N/A'),
                      _buildDetailRow('Officer Name:', seizure.officerName ?? 'N/A'),
                    ],
                  ),

                  // Evidence
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Evidence',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Photos (${seizure.evidencePhotos.length})',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 100,
                            child: seizure.evidencePhotos.isEmpty
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'No photos available',
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: seizure.evidencePhotos.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        width: 100,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.image,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          if (seizure.videoEvidence != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.videocam,
                                    color: AppTheme.primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Video evidence available'),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.play_circle_outline),
                                    onPressed: () {
                                      // TODO: Play video
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Actions Timeline
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Action Timeline',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 16),
                          _buildTimelineItem(
                            context,
                            'Seizure Created',
                            DateFormat('dd MMM yyyy, hh:mm a').format(seizure.createdAt),
                            Icons.inventory_2,
                            AppTheme.warningColor,
                            true,
                          ),
                          // Lab samples timeline item removed as labSamples property doesn't exist
                          if (seizure.status == 'closed')
                            _buildTimelineItem(
                              context,
                              'Case Closed',
                              DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
                              Icons.check_circle,
                              AppTheme.successColor,
                              false,
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Related Actions
                  if (seizure.status != 'closed')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.firCaseForm,
                          arguments: FIRCaseArguments(seizureId: seizure.id),
                        ),
                        icon: const Icon(Icons.gavel),
                        label: const Text('Create FIR Case'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
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

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool showLine,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            if (showLine)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.warningColor;
      case 'dispatched':
        return Colors.blue;
      case 'analyzed':
        return Colors.purple;
      case 'closed':
        return AppTheme.successColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'dispatched':
        return Icons.local_shipping;
      case 'analyzed':
        return Icons.science;
      case 'closed':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Seizure Pending Lab Analysis';
      case 'dispatched':
        return 'Sample Dispatched to Lab';
      case 'analyzed':
        return 'Lab Analysis Completed';
      case 'closed':
        return 'Case Closed';
      default:
        return status;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Seizure?'),
        content: const Text(
          'Are you sure you want to delete this seizure record? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Delete seizure
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  SeizureModel _getMockSeizure() {
    return SeizureModel(
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
      memoNo: 'MEMO-2024-001',
      witnessName: 'John Doe',
      officerName: 'Officer Smith',
      evidencePhotos: ['photo1.jpg', 'photo2.jpg'],
      videoEvidence: 'video1.mp4',
      status: 'pending',
      seizureDate: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
      userId: 'user1',
    );
  }
}
