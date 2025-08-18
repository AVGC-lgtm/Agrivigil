import 'package:flutter/material.dart';
import '../../../utils/theme.dart';
import '../../../routes/app_routes.dart';

class LabSampleDetailScreen extends StatelessWidget {
  const LabSampleDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Lab Sample Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              // TODO: Generate PDF report
            },
            tooltip: 'Export Report',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sample Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Sample Code:', 'LAB-2024-001'),
                    _buildDetailRow('Product Type:', 'NPK Fertilizer'),
                    _buildDetailRow('Batch No:', 'BATCH-001'),
                    _buildDetailRow('Status:', 'Under Test'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (true) // If results available
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Results',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildResultTable(),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
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

  Widget _buildResultTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: const [
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text('Parameter', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text('Standard', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text('Result', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            const TableCell(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text('Nitrogen'),
              ),
            ),
            const TableCell(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text('10%'),
              ),
            ),
            const TableCell(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text('9.8%'),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.check_circle, color: AppTheme.successColor, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
