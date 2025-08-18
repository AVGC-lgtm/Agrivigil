import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/permission_provider.dart';
import '../../utils/theme.dart';
import '../../config/supabase_config.dart';
import '../../services/user_service.dart';
import '../../services/role_service.dart';
import '../../models/user_model.dart';
import '../../models/role_model.dart';
import '../../widgets/data_table_card.dart';

class AdministrationModule extends StatefulWidget {
  const AdministrationModule({super.key});

  @override
  State<AdministrationModule> createState() => _AdministrationModuleState();
}

class _AdministrationModuleState extends State<AdministrationModule>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserService _userService = UserService();
  final RoleService _roleService = RoleService();

  List<UserModel> _users = [];
  List<RoleModel> _roles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final users = await _userService.getUsers();
      final roles = await _roleService.getAllRoles();
      setState(() {
        _users = users;
        _roles = roles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionProvider = Provider.of<PermissionProvider>(context);
    final canEdit = permissionProvider.canEdit('administration');

    return Column(
      children: [
        // Tab Bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(text: 'Users', icon: Icon(Icons.people)),
              Tab(text: 'Roles', icon: Icon(Icons.security)),
              Tab(text: 'Permissions', icon: Icon(Icons.lock)),
            ],
          ),
        ),
        
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildUsersTab(canEdit),
              _buildRolesTab(canEdit),
              _buildPermissionsTab(canEdit),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsersTab(bool canEdit) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'User Management',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (canEdit)
                ElevatedButton.icon(
                  onPressed: _showAddUserDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add User'),
                ),
            ],
          ),
          const SizedBox(height: 24),
          
          DataTableCard(
            title: 'All Users',
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Officer Code')),
              DataColumn(label: Text('Role')),
              DataColumn(label: Text('Created')),
              DataColumn(label: Text('Actions')),
            ],
            rows: _users.map((user) {
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.primaryColor,
                          child: Text(
                            user.name?.substring(0, 1).toUpperCase() ?? 
                            user.email.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(user.name ?? 'N/A'),
                      ],
                    ),
                  ),
                  DataCell(Text(user.email)),
                  DataCell(Text(user.officerCode ?? 'N/A')),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.role?.name ?? 'N/A',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(_formatDate(user.createdAt))),
                  DataCell(
                    Row(
                      children: [
                        if (canEdit) ...[
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _showEditUserDialog(user),
                            tooltip: 'Edit User',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            color: AppTheme.errorColor,
                            onPressed: () => _confirmDeleteUser(user),
                            tooltip: 'Delete User',
                          ),
                        ] else
                          IconButton(
                            icon: const Icon(Icons.visibility, size: 20),
                            onPressed: () => _showUserDetails(user),
                            tooltip: 'View Details',
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRolesTab(bool canEdit) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Role Management',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (canEdit)
                ElevatedButton.icon(
                  onPressed: _showAddRoleDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Role'),
                ),
            ],
          ),
          const SizedBox(height: 24),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _roles.length,
            itemBuilder: (context, index) {
              final role = _roles[index];
              return Card(
                child: InkWell(
                  onTap: () => _showRoleDetails(role),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.security,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                role.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (canEdit)
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 20),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditRoleDialog(role);
                                  } else if (value == 'delete') {
                                    _confirmDeleteRole(role);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 16),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete,
                                            size: 16,
                                            color: AppTheme.errorColor),
                                        SizedBox(width: 8),
                                        Text('Delete',
                                            style: TextStyle(
                                                color: AppTheme.errorColor)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        if (role.description != null)
                          Text(
                            role.description!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text(
                          'Created: ${_formatDate(role.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textMuted,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsTab(bool canEdit) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Role Permissions Matrix',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Configure module access permissions for each role',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.successColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppTheme.successColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Full Access',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.warningColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppTheme.warningColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Read Only',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.errorColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'No Access',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Permission matrix would go here
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('Permission Matrix Grid'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddUserDialog() {
    // Implementation for add user dialog
  }

  void _showEditUserDialog(UserModel user) {
    // Implementation for edit user dialog
  }

  void _confirmDeleteUser(UserModel user) {
    // Implementation for delete confirmation
  }

  void _showUserDetails(UserModel user) {
    // Implementation for showing user details
  }

  void _showAddRoleDialog() {
    // Implementation for add role dialog
  }

  void _showEditRoleDialog(RoleModel role) {
    // Implementation for edit role dialog
  }

  void _confirmDeleteRole(RoleModel role) {
    // Implementation for delete confirmation
  }

  void _showRoleDetails(RoleModel role) {
    // Implementation for showing role details
  }
}
