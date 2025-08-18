import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../../utils/theme.dart';
import '../../../routes/app_routes.dart';
import '../../../services/inspection_service.dart';
import '../../../models/inspection_model.dart';

class FieldExecutionFormScreen extends StatefulWidget {
  const FieldExecutionFormScreen({super.key});

  @override
  State<FieldExecutionFormScreen> createState() => _FieldExecutionFormScreenState();
}

class _FieldExecutionFormScreenState extends State<FieldExecutionFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final InspectionService _inspectionService = InspectionService();
  final ImagePicker _picker = ImagePicker();
  
  InspectionTaskModel? _inspection;
  bool _isLoading = true;
  File? _productImage;
  File? _documentImage;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInspection();
    });
  }

  Future<void> _loadInspection() async {
    final args = ModalRoute.of(context)?.settings.arguments as FieldExecutionArguments?;
    if (args?.inspectionId != null) {
      try {
        final inspection = await _inspectionService.getInspectionById(args!.inspectionId!);
        setState(() {
          _inspection = inspection;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading inspection: $e'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Field Execution'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.productScan),
            tooltip: 'Scan Product',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Inspection Info Card
              if (_inspection != null)
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inspection Details',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Code:', _inspection!.inspectioncode),
                        _buildInfoRow('Location:', '${_inspection!.location}, ${_inspection!.district}'),
                        _buildInfoRow('Target Type:', _inspection!.targetType),
                        _buildInfoRow('Date:', DateFormat('dd MMM yyyy').format(DateTime.parse(_inspection!.datetime))),
                      ],
                    ),
                  ),
                ),

              // Dealer Information
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dealer Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'dealer_name',
                        decoration: const InputDecoration(
                          labelText: 'Dealer Name',
                          prefixIcon: Icon(Icons.store),
                        ),
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'registration_no',
                        decoration: const InputDecoration(
                          labelText: 'Registration Number',
                          prefixIcon: Icon(Icons.assignment_ind),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Product Information
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'company_name',
                        decoration: const InputDecoration(
                          labelText: 'Company/Manufacturer',
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'product_name',
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                          prefixIcon: Icon(Icons.inventory),
                        ),
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderDropdown<String>(
                        name: 'fertilizer_type',
                        decoration: const InputDecoration(
                          labelText: 'Product Type',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'fertilizer', child: Text('Fertilizer')),
                          DropdownMenuItem(value: 'pesticide', child: Text('Pesticide')),
                          DropdownMenuItem(value: 'seed', child: Text('Seed')),
                          DropdownMenuItem(value: 'other', child: Text('Other')),
                        ],
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'batch_no',
                        decoration: const InputDecoration(
                          labelText: 'Batch Number',
                          prefixIcon: Icon(Icons.numbers),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FormBuilderDateTimePicker(
                              name: 'manufacture_date',
                              decoration: const InputDecoration(
                                labelText: 'Manufacturing Date',
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              inputType: InputType.date,
                              format: DateFormat('dd/MM/yyyy'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FormBuilderDateTimePicker(
                              name: 'stock_receipt_date',
                              decoration: const InputDecoration(
                                labelText: 'Stock Receipt Date',
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              inputType: InputType.date,
                              format: DateFormat('dd/MM/yyyy'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Physical Inspection
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Physical Inspection',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'stock_position',
                        decoration: const InputDecoration(
                          labelText: 'Stock Position',
                          prefixIcon: Icon(Icons.inventory_2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderDropdown<String>(
                        name: 'physical_condition',
                        decoration: const InputDecoration(
                          labelText: 'Physical Condition',
                          prefixIcon: Icon(Icons.remove_red_eye),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'good', child: Text('Good')),
                          DropdownMenuItem(value: 'satisfactory', child: Text('Satisfactory')),
                          DropdownMenuItem(value: 'poor', child: Text('Poor')),
                          DropdownMenuItem(value: 'damaged', child: Text('Damaged')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FormBuilderCheckboxGroup<String>(
                        name: 'observations',
                        decoration: const InputDecoration(
                          labelText: 'Observations',
                        ),
                        options: const [
                          FormBuilderFieldOption(value: 'proper_labeling', child: Text('Proper Labeling')),
                          FormBuilderFieldOption(value: 'intact_packaging', child: Text('Intact Packaging')),
                          FormBuilderFieldOption(value: 'no_contamination', child: Text('No Contamination')),
                          FormBuilderFieldOption(value: 'proper_storage', child: Text('Proper Storage')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Sampling Information
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sampling Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderSwitch(
                        name: 'sample_collected',
                        title: const Text('Sample Collected'),
                        initialValue: false,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'sample_code',
                        decoration: const InputDecoration(
                          labelText: 'Sample Code',
                          prefixIcon: Icon(Icons.qr_code),
                        ),
                      ),
                    ],
                  ),
                ),
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
                            child: _buildPhotoUpload(
                              'Product Photo',
                              _productImage,
                              () => _pickImage(true),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildPhotoUpload(
                              'Document Photo',
                              _documentImage,
                              () => _pickImage(false),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.save),
                  label: const Text('Submit Field Execution'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUpload(String label, File? image, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to capture',
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

  Future<void> _pickImage(bool isProduct) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    
    if (image != null) {
      setState(() {
        if (isProduct) {
          _productImage = File(image.path);
        } else {
          _documentImage = File(image.path);
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      
      if (_productImage == null || _documentImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please capture both product and document photos'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // TODO: Upload images and save field execution data
        
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;
        Navigator.pop(context); // Close loading
        
        // Show success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Field execution submitted successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        
        // Navigate to seizure form if needed
        final shouldLogSeizure = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Log Seizure?'),
            content: const Text('Do you want to log a seizure for this inspection?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );
        
        if (shouldLogSeizure == true && mounted) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.seizureForm,
            arguments: SeizureArguments(fieldExecutionId: 'EXEC-001'), // TODO: Use actual ID
          );
        } else {
          Navigator.pop(context);
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context); // Close loading
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting execution: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
