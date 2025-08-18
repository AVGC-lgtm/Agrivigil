import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/enhanced_permission_provider.dart';
import '../../../utils/theme.dart';
import '../../../models/qc_models.dart';

class QCComplianceManagement extends StatefulWidget {
  const QCComplianceManagement({super.key});

  @override
  State<QCComplianceManagement> createState() => _QCComplianceManagementState();
}

class _QCComplianceManagementState extends State<QCComplianceManagement> {
  String _selectedRegulation = 'all';
  
  // Mock compliance data
  final List<QCCompliance> _complianceRules = [
    QCCompliance(
      id: '1',
      regulationType: 'FCO',
      regulationCode: 'FCO-2024-NPK',
      description: 'NPK Fertilizer Standards',
      applicableProducts: ['NPK 10:26:26', 'NPK 12:32:16', 'NPK 20:20:0'],
      parameters: [
        ComplianceParameter(
          name: 'Nitrogen Content',
          testMethod: 'IS 2430-1988',
          minValue: 9.5,
          maxValue: 10.5,
          unit: '%',
          frequency: 'batch-wise',
        ),
        ComplianceParameter(
          name: 'Phosphorus Content',
          testMethod: 'IS 2430-1988',
          minValue: 25.5,
          maxValue: 26.5,
          unit: '%',
          frequency: 'batch-wise',
        ),
      ],
      isMandatory: true,
      effectiveFrom: DateTime(2024, 1, 1),
    ),
    QCCompliance(
      id: '2',
      regulationType: 'BIS',
      regulationCode: 'BIS-1234-2024',
      description: 'Pesticide Formulation Standards',
      applicableProducts: ['Insecticides', 'Fungicides', 'Herbicides'],
      parameters: [
        ComplianceParameter(
          name: 'Active Ingredient',
          testMethod: 'HPLC Method',
          minValue: 95,
          maxValue: 105,
          unit: '% of label claim',
          frequency: 'monthly',
        ),
      ],
      isMandatory: true,
      effectiveFrom: DateTime(2024, 3, 1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final permissionProvider = Provider.of<EnhancedPermissionProvider>(context);
    final canManage = permissionProvider.hasPermission('qc_module', 'manage_compliance');

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
                          'Compliance Management',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage regulatory compliance and standards',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                    if (canManage)
                      ElevatedButton.icon(
                        onPressed: _showAddComplianceDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Compliance Rule'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildRegulationChip('All', 'all'),
                      _buildRegulationChip('FCO', 'FCO'),
                      _buildRegulationChip('BIS', 'BIS'),
                      _buildRegulationChip('State Regulation', 'State'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Compliance List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _complianceRules.length,
              itemBuilder: (context, index) {
                final compliance = _complianceRules[index];
                return _buildComplianceCard(compliance, canManage);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegulationChip(String label, String value) {
    final isSelected = value == _selectedRegulation;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _selectedRegulation = value);
        },
      ),
    );
  }

  Widget _buildComplianceCard(QCCompliance compliance, bool canManage) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        childrenPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getRegulationColor(compliance.regulationType).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.rule,
            color: _getRegulationColor(compliance.regulationType),
          ),
        ),
        title: Text(
          compliance.description,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRegulationColor(compliance.regulationType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    compliance.regulationType,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getRegulationColor(compliance.regulationType),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  compliance.regulationCode,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const Spacer(),
                if (compliance.isMandatory)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Mandatory',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canManage) ...[
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _editCompliance(compliance),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                color: AppTheme.errorColor,
                onPressed: () => _deleteCompliance(compliance),
              ),
            ],
          ],
        ),
        children: [
          // Applicable Products
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Applicable Products',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: compliance.applicableProducts.map((product) {
                  return Chip(
                    label: Text(product),
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Parameters
          Text(
            'Compliance Parameters',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          ...compliance.parameters.map((param) => _buildParameterCard(param)),
          
          const SizedBox(height: 16),
          // Effective Date
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Effective from: ${_formatDate(compliance.effectiveFrom)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              if (compliance.effectiveTo != null) ...[
                const SizedBox(width: 16),
                Text(
                  'to ${_formatDate(compliance.effectiveTo!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParameterCard(ComplianceParameter param) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  param.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  'Method: ${param.testMethod}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${param.minValue} - ${param.maxValue}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  param.unit,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.infoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              param.frequency,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.infoColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRegulationColor(String type) {
    switch (type) {
      case 'FCO':
        return Colors.blue;
      case 'BIS':
        return Colors.green;
      case 'State Regulation':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddComplianceDialog() {
    // Implementation for adding compliance rule
  }

  void _editCompliance(QCCompliance compliance) {
    // Implementation for editing compliance
  }

  void _deleteCompliance(QCCompliance compliance) {
    // Implementation for deleting compliance
  }
}
