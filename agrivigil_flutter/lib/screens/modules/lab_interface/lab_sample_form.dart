import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../utils/theme.dart';
import '../../../routes/app_routes.dart';

class LabSampleFormScreen extends StatefulWidget {
  const LabSampleFormScreen({super.key});

  @override
  State<LabSampleFormScreen> createState() => _LabSampleFormScreenState();
}

class _LabSampleFormScreenState extends State<LabSampleFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Register Lab Sample'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
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
                      FormBuilderTextField(
                        name: 'sample_quantity',
                        decoration: const InputDecoration(
                          labelText: 'Sample Quantity',
                          prefixIcon: Icon(Icons.scale),
                        ),
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderDropdown<String>(
                        name: 'lab_name',
                        decoration: const InputDecoration(
                          labelText: 'Lab Name',
                          prefixIcon: Icon(Icons.science),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'central', child: Text('Central Lab, Pune')),
                          DropdownMenuItem(value: 'regional', child: Text('Regional Lab, Nashik')),
                          DropdownMenuItem(value: 'district', child: Text('District Lab, Satara')),
                        ],
                        validator: FormBuilderValidators.required(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(Icons.send),
                  label: const Text('Send to Lab'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      Navigator.pop(context); // Close loading
      Navigator.pop(context); // Go back
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sample sent to lab successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }
}
