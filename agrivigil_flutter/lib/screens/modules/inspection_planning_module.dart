import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/permission_provider.dart';
import '../../utils/theme.dart';
import '../../models/inspection_model.dart';
import '../../services/inspection_service.dart';
import '../../widgets/inspection_card.dart';

class InspectionPlanningModule extends StatefulWidget {
  const InspectionPlanningModule({super.key});

  @override
  State<InspectionPlanningModule> createState() =>
      _InspectionPlanningModuleState();
}

class _InspectionPlanningModuleState extends State<InspectionPlanningModule> {
  final _formKey = GlobalKey<FormBuilderState>();
  final InspectionService _inspectionService = InspectionService();
  
  List<InspectionTaskModel> _inspections = [];
  bool _isLoading = true;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadInspections();
  }

  Future<void> _loadInspections() async {
    setState(() => _isLoading = true);
    try {
      final inspections = await _inspectionService.getInspections();
      setState(() {
        _inspections = inspections;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading inspections: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  List<InspectionTaskModel> get filteredInspections {
    if (_filterStatus == 'all') return _inspections;
    return _inspections.where((i) => i.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final permissionProvider = Provider.of<PermissionProvider>(context);
    final canEdit = permissionProvider.canEdit('inspection-planning');
    final isSmallScreen = MediaQuery.of(context).size.width < 768;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inspection Planning',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Schedule and manage field inspection visits',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
              if (canEdit && !isSmallScreen)
                ElevatedButton.icon(
                  onPressed: () => _showCreateInspectionDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('New Inspection'),
                ),
            ],
          ),
          
          if (canEdit && isSmallScreen) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showCreateInspectionDialog(),
                icon: const Icon(Icons.add),
                label: const Text('New Inspection'),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Stats Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isSmallScreen ? 2 : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isSmallScreen ? 1.5 : 2,
            children: [
              _buildStatCard(
                'Total',
                _inspections.length.toString(),
                Icons.assignment,
                Colors.blue,
              ),
              _buildStatCard(
                'Scheduled',
                _inspections
                    .where((i) => i.status == 'scheduled')
                    .length
                    .toString(),
                Icons.schedule,
                AppTheme.warningColor,
              ),
              _buildStatCard(
                'In Progress',
                _inspections
                    .where((i) => i.status == 'in-progress')
                    .length
                    .toString(),
                Icons.play_circle,
                AppTheme.primaryColor,
              ),
              _buildStatCard(
                'Completed',
                _inspections
                    .where((i) => i.status == 'completed')
                    .length
                    .toString(),
                Icons.check_circle,
                AppTheme.successColor,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Filters
          Row(
            children: [
              Text(
                'Filter by Status:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 16),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _filterStatus == 'all',
                    onSelected: (selected) {
                      setState(() => _filterStatus = 'all');
                    },
                  ),
                  FilterChip(
                    label: const Text('Scheduled'),
                    selected: _filterStatus == 'scheduled',
                    onSelected: (selected) {
                      setState(() => _filterStatus = 'scheduled');
                    },
                  ),
                  FilterChip(
                    label: const Text('In Progress'),
                    selected: _filterStatus == 'in-progress',
                    onSelected: (selected) {
                      setState(() => _filterStatus = 'in-progress');
                    },
                  ),
                  FilterChip(
                    label: const Text('Completed'),
                    selected: _filterStatus == 'completed',
                    onSelected: (selected) {
                      setState(() => _filterStatus = 'completed');
                    },
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Inspection List
          if (filteredInspections.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No inspections found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredInspections.length,
              itemBuilder: (context, index) {
                final inspection = filteredInspections[index];
                return InspectionCard(
                  inspection: inspection,
                  onTap: () => _showInspectionDetails(inspection),
                  onEdit: canEdit
                      ? () => _showEditInspectionDialog(inspection)
                      : null,
                  onDelete: canEdit
                      ? () => _confirmDeleteInspection(inspection)
                      : null,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
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
      ),
    );
  }

  void _showCreateInspectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Create New Inspection',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Form Fields
                  FormBuilderDateTimePicker(
                    name: 'datetime',
                    decoration: const InputDecoration(
                      labelText: 'Inspection Date & Time',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    inputType: InputType.both,
                    format: DateFormat('dd/MM/yyyy HH:mm'),
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'state',
                          decoration: const InputDecoration(
                            labelText: 'State',
                            prefixIcon: Icon(Icons.map),
                          ),
                          validator: FormBuilderValidators.required(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'district',
                          decoration: const InputDecoration(
                            labelText: 'District',
                            prefixIcon: Icon(Icons.location_city),
                          ),
                          validator: FormBuilderValidators.required(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'taluka',
                          decoration: const InputDecoration(
                            labelText: 'Taluka',
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          validator: FormBuilderValidators.required(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'location',
                          decoration: const InputDecoration(
                            labelText: 'Location',
                            prefixIcon: Icon(Icons.place),
                          ),
                          validator: FormBuilderValidators.required(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  FormBuilderTextField(
                    name: 'addressland',
                    decoration: const InputDecoration(
                      labelText: 'Address/Landmark',
                      prefixIcon: Icon(Icons.home),
                    ),
                    maxLines: 2,
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),
                  
                  FormBuilderDropdown<String>(
                    name: 'targetType',
                    decoration: const InputDecoration(
                      labelText: 'Target Type',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'dealer', child: Text('Dealer')),
                      DropdownMenuItem(value: 'retailer', child: Text('Retailer')),
                      DropdownMenuItem(value: 'warehouse', child: Text('Warehouse')),
                      DropdownMenuItem(value: 'farm', child: Text('Farm')),
                    ],
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),
                  
                  FormBuilderCheckboxGroup<String>(
                    name: 'typeofpremises',
                    decoration: const InputDecoration(
                      labelText: 'Type of Premises',
                    ),
                    options: const [
                      FormBuilderFieldOption(value: 'shop', child: Text('Shop')),
                      FormBuilderFieldOption(value: 'godown', child: Text('Godown')),
                      FormBuilderFieldOption(value: 'factory', child: Text('Factory')),
                      FormBuilderFieldOption(value: 'field', child: Text('Field')),
                    ],
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),
                  
                  FormBuilderCheckboxGroup<String>(
                    name: 'visitpurpose',
                    decoration: const InputDecoration(
                      labelText: 'Visit Purpose',
                    ),
                    options: const [
                      FormBuilderFieldOption(value: 'inspection', child: Text('Routine Inspection')),
                      FormBuilderFieldOption(value: 'sampling', child: Text('Sampling')),
                      FormBuilderFieldOption(value: 'verification', child: Text('Verification')),
                      FormBuilderFieldOption(value: 'complaint', child: Text('Complaint Based')),
                    ],
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),
                  
                  FormBuilderCheckboxGroup<String>(
                    name: 'equipment',
                    decoration: const InputDecoration(
                      labelText: 'Equipment Required',
                    ),
                    options: const [
                      FormBuilderFieldOption(value: 'sampling-kit', child: Text('Sampling Kit')),
                      FormBuilderFieldOption(value: 'camera', child: Text('Camera')),
                      FormBuilderFieldOption(value: 'gps', child: Text('GPS Device')),
                      FormBuilderFieldOption(value: 'measuring-tools', child: Text('Measuring Tools')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'totaltarget',
                          decoration: const InputDecoration(
                            labelText: 'Total Target',
                            prefixIcon: Icon(Icons.flag),
                          ),
                          keyboardType: TextInputType.number,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                          ]),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FormBuilderTextField(
                          name: 'achievedtarget',
                          decoration: const InputDecoration(
                            labelText: 'Achieved Target',
                            prefixIcon: Icon(Icons.check_box),
                          ),
                          keyboardType: TextInputType.number,
                          initialValue: '0',
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            FormBuilderValidators.numeric(),
                          ]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _createInspection(),
                        icon: const Icon(Icons.save),
                        label: const Text('Create Inspection'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createInspection() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      
      try {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // Create inspection
        await _inspectionService.createInspection(values);

        // Dismiss loading and dialog
        if (mounted) {
          Navigator.pop(context); // Loading
          Navigator.pop(context); // Dialog
          
          // Show success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inspection created successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          
          // Reload inspections
          _loadInspections();
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Loading
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating inspection: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  void _showEditInspectionDialog(InspectionTaskModel inspection) {
    // Implementation similar to create dialog but with pre-filled values
  }

  void _showInspectionDetails(InspectionTaskModel inspection) {
    // Implementation to show inspection details
  }

  void _confirmDeleteInspection(InspectionTaskModel inspection) {
    // Implementation for delete confirmation
  }
}
