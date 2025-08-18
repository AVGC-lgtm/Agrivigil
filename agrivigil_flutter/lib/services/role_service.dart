import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/role_model.dart';

class RoleService {
  final _supabase = Supabase.instance.client;

  // Fetch all roles from database
  Future<List<RoleModel>> getAllRoles() async {
    try {
      final response = await _supabase
          .from('roles')
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((json) => RoleModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching roles: $e');
      return [];
    }
  }

  // Fetch specific roles for registration (only the 4 main dashboard roles)
  Future<List<RoleModel>> getRegistrationRoles() async {
    try {
      final response = await _supabase
          .from('roles')
          .select()
          .order('name', ascending: true);

      // Filter to only include the 4 essential roles
      final allRoles = (response as List)
          .map((json) => RoleModel.fromJson(json))
          .toList();
      
      final essentialRoleNames = [
        'Field Officer',
        'Lab Analyst', 
        'QC Inspector',
        'District Agriculture Officer'
      ];
      
      return allRoles.where((role) => essentialRoleNames.contains(role.name)).toList();
    } catch (e) {
      print('Error fetching registration roles: $e');
      return [];
    }
  }

  // Get role by name
  Future<RoleModel?> getRoleByName(String name) async {
    try {
      final response = await _supabase
          .from('roles')
          .select()
          .eq('name', name)
          .maybeSingle();

      if (response != null) {
        return RoleModel.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error fetching role by name: $e');
      return null;
    }
  }

  // Create role if not exists
  Future<RoleModel?> createRoleIfNotExists(String name, String description) async {
    try {
      // Check if role exists
      final existing = await getRoleByName(name);
      if (existing != null) {
        return existing;
      }

      // Create new role
      final response = await _supabase
          .from('roles')
          .insert({
            'name': name,
            'description': description,
          })
          .select()
          .single();

      return RoleModel.fromJson(response);
    } catch (e) {
      print('Error creating role: $e');
      return null;
    }
  }

  // Initialize only the 4 essential roles for dashboards
  Future<void> initializeDefaultRoles() async {
    final defaultRoles = [
      {'name': 'Field Officer', 'description': 'Field inspection and execution officer'},
      {'name': 'Lab Analyst', 'description': 'Laboratory analysis and testing'},
      {'name': 'QC Inspector', 'description': 'Quality Control inspection'},
      {'name': 'District Agriculture Officer', 'description': 'District level agriculture officer'},
    ];

    for (final role in defaultRoles) {
      await createRoleIfNotExists(role['name']!, role['description']!);
    }
  }
}