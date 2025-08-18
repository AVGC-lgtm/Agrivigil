import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/theme.dart';
import '../../../models/inspection_model.dart';
import '../../../routes/app_routes.dart';

class FieldExecutionDetailScreen extends StatelessWidget {
  const FieldExecutionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Get actual execution data from arguments or service
    final execution = _getMockExecution();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(execution.fieldcode),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              // TODO: Generate PDF report
            },
            tooltip: 'Export PDF',
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
              color: AppTheme.primaryColor,
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Execution Completed',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Submitted on ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
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
                  // Dealer Information
                  _buildSection(
                    context,
                    'Dealer Information',
                    [
                      _buildDetailRow('Dealer Name:', execution.dealerName),
                      _buildDetailRow('Registration No:', execution.registrationNo ?? 'N/A'),
                    ],
                  ),

                  // Product Information
                  _buildSection(
                    context,
                    'Product Information',
                    [
                      _buildDetailRow('Company:', execution.companyname),
                      _buildDetailRow('Product:', execution.productname),
                      _buildDetailRow('Type:', execution.fertilizerType),
                      _buildDetailRow('Batch No:', execution.batchNo ?? 'N/A'),
                      _buildDetailRow(
                        'Manufacturing Date:',
                        execution.manufactureImportDate != null
                            ? DateFormat('dd/MM/yyyy').format(execution.manufactureImportDate!)
                            : 'N/A',
                      ),
                    ],
                  ),

                  // Physical Inspection
                  _buildSection(
                    context,
                    'Physical Inspection',
                    [
                      _buildDetailRow('Stock Position:', execution.stockPosition ?? 'N/A'),
                      _buildDetailRow('Physical Condition:', execution.physicalCondition ?? 'N/A'),
                      _buildDetailRow('Sample Code:', execution.sampleCode ?? 'N/A'),
                    ],
                  ),

                  // Evidence Photos
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Evidence Photos',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildPhotoCard(context, 'Product Photo', execution.productphoto),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildPhotoCard(context, 'Document Photo', execution.document),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Actions
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.seizureForm,
                          arguments: SeizureArguments(fieldExecutionId: execution.id.toString()),
                        );
                      },
                      icon: const Icon(Icons.inventory_2),
                      label: const Text('Log Seizure'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.warningColor,
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

  Widget _buildPhotoCard(BuildContext context, String label, String photoUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const Center(
              child: Icon(
                Icons.image,
                size: 48,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  FieldExecutionModel _getMockExecution() {
    return FieldExecutionModel(
      id: 1,
      inspectionid: 'INSP-001',
      fieldcode: 'EXEC-2024-001',
      companyname: 'ABC Fertilizers',
      productname: 'NPK 10:26:26',
      dealerName: 'XYZ Agro Store',
      registrationNo: 'REG-12345',
      samplingDate: DateTime.now(),
      fertilizerType: 'Complex Fertilizer',
      batchNo: 'BATCH-2024-001',
      manufactureImportDate: DateTime.now().subtract(const Duration(days: 30)),
      stockReceiptDate: DateTime.now().subtract(const Duration(days: 15)),
      sampleCode: 'SAMP-001',
      stockPosition: 'Good',
      physicalCondition: 'Satisfactory',
      document: 'doc_url',
      productphoto: 'photo_url',
      userid: 'user1',
    );
  }
}
