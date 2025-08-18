import 'package:flutter/material.dart';
import '../../../utils/theme.dart';
import '../../../routes/app_routes.dart';

class FormCatalogScreen extends StatelessWidget {
  const FormCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final forms = [
      {'title': 'Fertilizer License Application', 'icon': Icons.assignment, 'status': 'active'},
      {'title': 'Pesticide Registration', 'icon': Icons.bug_report, 'status': 'active'},
      {'title': 'Seed Certification', 'icon': Icons.grass, 'status': 'active'},
      {'title': 'Dealer Registration', 'icon': Icons.store, 'status': 'active'},
      {'title': 'Import Permit', 'icon': Icons.local_shipping, 'status': 'coming_soon'},
      {'title': 'Quality Complaint', 'icon': Icons.warning, 'status': 'active'},
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
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
                          'Agri-Forms Portal',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Digital forms for agricultural services',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.submissionList,
                      ),
                      icon: const Icon(Icons.history),
                      label: const Text('My Submissions'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: forms.length,
              itemBuilder: (context, index) {
                final form = forms[index];
                final isActive = form['status'] == 'active';
                
                return Card(
                  child: InkWell(
                    onTap: isActive
                        ? () => Navigator.pushNamed(
                              context,
                              AppRoutes.formSubmission,
                              arguments: form['title'],
                            )
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: (isActive ? AppTheme.primaryColor : Colors.grey)
                                  .withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              form['icon'] as IconData,
                              size: 32,
                              color: isActive ? AppTheme.primaryColor : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            form['title'] as String,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isActive ? null : Colors.grey,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          if (!isActive)
                            Text(
                              'Coming Soon',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.warningColor,
                                  ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
