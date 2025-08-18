import 'package:flutter/material.dart';
import '../../../utils/theme.dart';

class RoleManagementScreen extends StatelessWidget {
  const RoleManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Role Management'),
      ),
      body: Center(
        child: Text(
          'Role management functionality',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
