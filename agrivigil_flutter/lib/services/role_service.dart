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

  // Fetch specific roles for registration (excluding Super Admin)
  Future<List<RoleModel>> getRegistrationRoles() async {
    try {
      final response = await _supabase
          .from('roles')
          .select()
          .neq('name', 'Super Admin')
          .order('name', ascending: true);

      return (response as List)
          .map((json) => RoleModel.fromJson(json))
          .toList();
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

  // Initialize default roles
  Future<void> initializeDefaultRoles() async {
    final defaultRoles = [
      {'name': 'Field Officer', 'description': 'Field inspection and execution officer'},
      {'name': 'District Agriculture Officer', 'description': 'District level agriculture officer'},
      {'name': 'Legal Officer', 'description': 'Legal and compliance officer'},
      {'name': 'Lab Coordinator', 'description': 'Laboratory coordination and management'},
      {'name': 'HQ Monitoring', 'description': 'Headquarters monitoring team'},
      {'name': 'District Admin', 'description': 'District administration'},
      {'name': 'QC Inspector', 'description': 'Quality Control inspector'},
      {'name': 'Lab Analyst', 'description': 'Laboratory analyst'},
      {'name': 'QC Manager', 'description': 'Quality Control manager'},
      {'name': 'QC Supervisor', 'description': 'Quality Control supervisor'},
      {'name': 'QC Department Head', 'description': 'Head of Quality Control department'},
      {'name': 'Super Admin', 'description': 'System administrator with full access'},
    ];

    for (final role in defaultRoles) {
      await createRoleIfNotExists(role['name']!, role['description']!);
    }
  }
}