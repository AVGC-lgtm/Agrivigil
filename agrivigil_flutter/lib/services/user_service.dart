import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserService {
  final _supabase = Supabase.instance.client;

  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select('*, role:roles(*)')
          .order('createdAt', ascending: false);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<UserModel> getUserById(String id) async {
    try {
      final response = await _supabase
          .from('users')
          .select('*, role:roles(*)')
          .eq('id', id)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  Future<UserModel> createUser({
    required String email,
    required String name,
    required String password,
    required String roleId,
    String? officerCode,
  }) async {
    try {
      final response = await _supabase
          .from('users')
          .insert({
            'email': email,
            'name': name,
            'password': password, // In production, hash the password
            'role_id': roleId,
            'officer_code': officerCode,
          })
          .select('*, role:roles(*)')
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<UserModel> updateUser({
    required String id,
    String? name,
    String? roleId,
    String? officerCode,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (roleId != null) updates['role_id'] = roleId;
      if (officerCode != null) updates['officer_code'] = officerCode;

      final response = await _supabase
          .from('users')
          .update(updates)
          .eq('id', id)
          .select('*, role:roles(*)')
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _supabase.from('users').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Failed to check email: $e');
    }
  }

  Future<UserModel> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // First verify old password
      final user = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .eq('password', oldPassword)
          .maybeSingle();

      if (user == null) {
        throw Exception('Invalid old password');
      }

      // Update password
      final response = await _supabase
          .from('users')
          .update({'password': newPassword})
          .eq('id', userId)
          .select('*, role:roles(*)')
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
}
