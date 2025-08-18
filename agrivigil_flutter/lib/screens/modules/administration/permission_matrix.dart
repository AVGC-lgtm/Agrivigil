import 'package:flutter/material.dart';
import '../../../utils/theme.dart';

class PermissionMatrixScreen extends StatelessWidget {
  const PermissionMatrixScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Matrix'),
      ),
      body: Center(
        child: Text(
          'Permission matrix configuration',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
