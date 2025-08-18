import 'package:flutter/material.dart';
import '../../../utils/theme.dart';
import '../../../services/user_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserService _userService = UserService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _userService.getUsers();
      setState(() {
        _users = users.map((user) => {
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'role': user.role?.name ?? 'N/A',
          'officer_code': user.officerCode ?? 'N/A',
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'User Management',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton.icon(
                  onPressed: _showCreateUserDialog,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add User'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Role')),
                        DataColumn(label: Text('Officer Code')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: _users.map((user) {
                        return DataRow(
                          cells: [
                            DataCell(Text(user['name'] ?? 'N/A')),
                            DataCell(Text(user['email'] ?? 'N/A')),
                            DataCell(Text(user['role'] ?? 'N/A')),
                            DataCell(Text(user['officer_code'] ?? 'N/A')),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _editUser(user),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  color: AppTheme.errorColor,
                                  onPressed: () => _deleteUser(user),
                                ),
                              ],
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showCreateUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: const Text('User creation form would appear here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadUsers();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _editUser(Map<String, dynamic> user) {
    // Implementation for editing user
  }

  void _deleteUser(Map<String, dynamic> user) {
    // Implementation for deleting user
  }
}
