import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../utils/theme.dart';

class FormSubmissionScreen extends StatelessWidget {
  const FormSubmissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formTitle = ModalRoute.of(context)?.settings.arguments as String? ?? 'Form';

    return Scaffold(
      appBar: AppBar(
        title: Text(formTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Applicant Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'name',
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'mobile',
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.numeric(),
                          FormBuilderValidators.minLength(10),
                          FormBuilderValidators.maxLength(10),
                        ]),
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Form submitted successfully'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Submit Form'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
