import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/theme.dart';
import '../../../models/seizure_model.dart';
import '../../../routes/app_routes.dart';

class FIRCaseDetailScreen extends StatelessWidget {
  const FIRCaseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Get actual FIR case data from arguments or service
    final firCase = _getMockFIRCase();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(firCase.fircode),
        backgroundColor: Colors.white,
        elevation: 0,
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
                case 'update_status':
                  _showStatusUpdateDialog(context);
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
                value: 'update_status',
                child: Row(
                  children: [
                    Icon(Icons.update, size: 20),
                    SizedBox(width: 8),
                    Text('Update Status'),
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
              color: Colors.purple,
              child: Column(
                children: [
                  const Icon(
                    Icons.gavel,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'FIR Filed',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Case is under investigation',
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
                  // Police Station Information
                  _buildSection(
                    context,
                    'Police Station',
                    [
                      _buildDetailRow('Station:', firCase.policeStation),
                      _buildDetailRow('FIR Code:', firCase.fircode),
                      _buildDetailRow('Filed Date:', DateFormat('dd/MM/yyyy').format(DateTime.now())),
                    ],
                  ),

                  // Accused Party Information
                  _buildSection(
                    context,
                    'Accused Party',
                    [
                      _buildDetailRow('Entity Type:', firCase.entityType.toUpperCase()),
                      _buildDetailRow('Party Name:', firCase.accusedParty),
                      _buildDetailRow('Suspect:', firCase.suspectName),
                      _buildDetailRow('License No:', firCase.licenseNo ?? 'N/A'),
                      _buildDetailRow('Contact:', firCase.contactNo ?? 'N/A'),
                    ],
                  ),

                  // Address
                  _buildSection(
                    context,
                    'Address',
                    [
                      _buildDetailRow('Street:', firCase.street1 ?? 'N/A'),
                      if (firCase.street2 != null)
                        _buildDetailRow('', firCase.street2!),
                      _buildDetailRow('Village:', firCase.village ?? 'N/A'),
                      _buildDetailRow('District:', firCase.district),
                      _buildDetailRow('State:', firCase.state),
                    ],
                  ),

                  // Product Information
                  if (firCase.brandName != null || firCase.fertilizerType != null)
                    _buildSection(
                      context,
                      'Product Information',
                      [
                        if (firCase.brandName != null)
                          _buildDetailRow('Brand:', firCase.brandName!),
                        if (firCase.fertilizerType != null)
                          _buildDetailRow('Type:', firCase.fertilizerType!),
                        if (firCase.batchNo != null)
                          _buildDetailRow('Batch No:', firCase.batchNo!),
                        if (firCase.manufactureDate != null)
                          _buildDetailRow(
                            'Manufacture Date:',
                            DateFormat('dd/MM/yyyy').format(firCase.manufactureDate!),
                          ),
                        if (firCase.expiryDate != null)
                          _buildDetailRow(
                            'Expiry Date:',
                            DateFormat('dd/MM/yyyy').format(firCase.expiryDate!),
                          ),
                      ],
                    ),

                  // Violations
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Violations',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: firCase.violationType.map((violation) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.errorColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppTheme.errorColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  violation.replaceAll('_', ' ').toUpperCase(),
                                  style: TextStyle(
                                    color: AppTheme.errorColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Evidence
                  if (firCase.evidence != null)
                    _buildSection(
                      context,
                      'Evidence',
                      [
                        Text(
                          firCase.evidence!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),

                  // Remarks
                  if (firCase.remarks != null)
                    _buildSection(
                      context,
                      'Remarks',
                      [
                        Text(
                          firCase.remarks!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),

                  // Case Timeline
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Case Timeline',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 16),
                          _buildTimelineItem(
                            context,
                            'FIR Filed',
                            DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
                            Icons.gavel,
                            Colors.purple,
                            true,
                          ),
                          _buildTimelineItem(
                            context,
                            'Investigation Started',
                            'Pending',
                            Icons.search,
                            Colors.orange,
                            true,
                          ),
                          _buildTimelineItem(
                            context,
                            'Court Proceedings',
                            'Not Started',
                            Icons.account_balance,
                            Colors.grey,
                            false,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: View related seizure
                          },
                          icon: const Icon(Icons.inventory_2),
                          label: const Text('View Seizure'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Add investigation update
                          },
                          icon: const Icon(Icons.add_comment),
                          label: const Text('Add Update'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                          ),
                        ),
                      ),
                    ],
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
            width: 120,
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

  void _showStatusUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Case Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Under Investigation'),
              leading: Radio<String>(
                value: 'investigation',
                groupValue: 'investigation',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('In Court'),
              leading: Radio<String>(
                value: 'court',
                groupValue: 'investigation',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('Closed'),
              leading: Radio<String>(
                value: 'closed',
                groupValue: 'investigation',
                onChanged: (value) {},
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
                  content: Text('Status updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  FIRCaseModel _getMockFIRCase() {
    return FIRCaseModel(
      id: 1,
      fircode: 'FIR-2024-001',
      policeStation: 'Shivajinagar Police Station',
      accusedParty: 'ABC Fertilizers Pvt Ltd',
      suspectName: 'John Doe',
      entityType: 'company',
      street1: '123, Main Street',
      street2: 'Near Market Yard',
      village: 'Shivajinagar',
      district: 'Pune',
      state: 'Maharashtra',
      licenseNo: 'LIC-2024-123',
      contactNo: '9876543210',
      brandName: 'Super Grow',
      fertilizerType: 'NPK Fertilizer',
      batchNo: 'BATCH-001',
      manufactureDate: DateTime.now().subtract(const Duration(days: 90)),
      expiryDate: DateTime.now().add(const Duration(days: 270)),
      violationType: ['adulteration', 'mislabeling', 'expired_product'],
      evidence: 'Samples collected and sent to lab for testing. Photos and videos of the premises have been documented.',
      remarks: 'Acting on a tip-off, inspection was conducted and substandard fertilizer was found.',
      userId: 'user1',
      labSampleId: 1,
    );
  }
}
