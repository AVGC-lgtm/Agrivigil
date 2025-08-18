import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  // Sign in with email and password
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'com.agrivigil.app://reset-password',
      );
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  // Update password
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  // Update user profile
  Future<UserResponse> updateProfile({
    String? fullName,
    String? phone,
    String? department,
    String? designation,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (fullName != null) data['full_name'] = fullName;
      if (phone != null) data['phone'] = phone;
      if (department != null) data['department'] = department;
      if (designation != null) data['designation'] = designation;

      final response = await _supabase.auth.updateUser(
        UserAttributes(data: data),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Get user role
  Future<String?> getUserRole() async {
    try {
      if (currentUser == null) return null;

      final response = await _supabase
          .from('users')
          .select('role')
          .eq('id', currentUser!.id)
          .single();

      return response['role'] as String?;
    } catch (e) {
      throw Exception('Failed to get user role: $e');
    }
  }

  // Check if user has permission
  Future<bool> hasPermission(String permission) async {
    try {
      if (currentUser == null) return false;

      final response = await _supabase.rpc(
        'check_user_permission',
        params: {
          'user_id': currentUser!.id,
          'permission_name': permission,
        },
      );

      return response as bool;
    } catch (e) {
      return false;
    }
  }

  // Get user permissions
  Future<List<String>> getUserPermissions() async {
    try {
      if (currentUser == null) return [];

      final response = await _supabase.rpc(
        'get_user_permissions',
        params: {'user_id': currentUser!.id},
      );

      return List<String>.from(response as List);
    } catch (e) {
      return [];
    }
  }

  // Listen to auth state changes
  Stream<AuthState> authStateChanges() {
    return _supabase.auth.onAuthStateChange;
  }

  // Verify OTP
  Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
    required OtpType type,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: type,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  // Resend OTP
  Future<void> resendOTP({
    required String email,
    required OtpType type,
  }) async {
    try {
      if (type == OtpType.signup) {
        await _supabase.auth.resend(
          type: OtpType.signup,
          email: email,
        );
      } else {
        await _supabase.auth.resend(
          type: OtpType.recovery,
          email: email,
        );
      }
    } catch (e) {
      throw Exception('Failed to resend OTP: $e');
    }
  }

  // Check if email exists
  Future<bool> emailExists(String email) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  // Get user details
  Future<UserModel?> getUserDetails(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Update last login
  Future<void> updateLastLogin() async {
    try {
      if (currentUser == null) return;

      await _supabase
          .from('users')
          .update({'last_login': DateTime.now().toIso8601String()})
          .eq('id', currentUser!.id);
    } catch (e) {
      // Silent fail for last login update
    }
  }
}
