import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../utils/theme.dart';

class TestResultFormScreen extends StatefulWidget {
  const TestResultFormScreen({super.key});

  @override
  State<TestResultFormScreen> createState() => _TestResultFormScreenState();
}

class _TestResultFormScreenState extends State<TestResultFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  
  final List<Map<String, dynamic>> _testParameters = [
    {'name': 'Nitrogen (N)', 'standard': '10.0', 'unit': '%'},
    {'name': 'Phosphorus (P2O5)', 'standard': '26.0', 'unit': '%'},
    {'name': 'Potassium (K2O)', 'standard': '26.0', 'unit': '%'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Enter Test Results'),
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
                        'Test Parameters',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(_testParameters.length, (index) {
                        final param = _testParameters[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      param['name'],
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      'Standard: ${param['standard']}${param['unit']}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppTheme.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: FormBuilderTextField(
                                  name: 'result_$index',
                                  decoration: InputDecoration(
                                    labelText: 'Result',
                                    suffixText: param['unit'],
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.numeric(),
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'remarks',
                        decoration: const InputDecoration(
                          labelText: 'Remarks',
                          prefixIcon: Icon(Icons.notes),
                        ),
                        maxLines: 3,
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
                  icon: const Icon(Icons.save),
                  label: const Text('Save Test Results'),
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
          content: Text('Test results saved successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }
}
