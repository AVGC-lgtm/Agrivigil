import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../config/supabase_config.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  UserModel? _user;
  bool _isLoading = true;
  bool _isSuperUser = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSuperUser => _isSuperUser;
  String? get error => _error;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString('userId');
      final storedIsSuperUser = prefs.getBool('isSuperUser') ?? false;

      if (storedUserId != null) {
        // Fetch user data from Supabase
        final response = await _supabase
            .from('users')
            .select('*, role:roles(*)')
            .eq('id', storedUserId)
            .single();

        if (response != null) {
          _user = UserModel.fromJson(response);
          _isSuperUser = storedIsSuperUser;
        }
      }
    } catch (e) {
      print('Auth check error: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check for super user
      if (email == AppConstants.superUserEmail &&
          password == AppConstants.superUserPassword) {
        return await _handleSuperUserLogin();
      }

      // Normal user login
      final response = await _supabase
          .from('users')
          .select('*, role:roles(*)')
          .eq('email', email)
          .eq('password', password) // In production, use proper hashing
          .single();

      if (response != null) {
        _user = UserModel.fromJson(response);
        _isSuperUser = false;

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', _user!.id);
        await prefs.setBool('isSuperUser', false);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid credentials';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> _handleSuperUserLogin() async {
    try {
      // Check if super user exists in database
      final response = await _supabase
          .from('users')
          .select('*, role:roles(*)')
          .eq('email', AppConstants.superUserEmail)
          .maybeSingle();

      if (response != null) {
        _user = UserModel.fromJson(response);
      } else {
        // Create super user if not exists
        final roleResponse = await _supabase
            .from('roles')
            .select()
            .eq('name', 'Super Admin')
            .maybeSingle();

        String roleId;
        if (roleResponse != null) {
          roleId = roleResponse['id'];
        } else {
          // Create Super Admin role
          final newRole = await _supabase
              .from('roles')
              .insert({
                'name': 'Super Admin',
                'description': 'System Administrator with full access',
              })
              .select()
              .single();
          roleId = newRole['id'];
        }

        // Create super user
        final newUser = await _supabase
            .from('users')
            .insert({
              'email': AppConstants.superUserEmail,
              'name': AppConstants.superUserName,
              'officer_code': AppConstants.superUserCode,
              'password': AppConstants.superUserPassword,
              'role_id': roleId,
            })
            .select('*, role:roles(*)')
            .single();

        _user = UserModel.fromJson(newUser);
      }

      _isSuperUser = true;

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', _user!.id);
      await prefs.setBool('isSuperUser', true);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Super user login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String officerCode,
    required String roleId,
    required String phone,
    required String department,
    required String district,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Check if user already exists
      final existingUser = await _supabase
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        _error = 'An account with this email already exists';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if officer code already exists
      final existingOfficer = await _supabase
          .from('users')
          .select()
          .eq('officer_code', officerCode)
          .maybeSingle();

      if (existingOfficer != null) {
        _error = 'This officer code is already registered';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create user with additional metadata
      final newUser = await _supabase
          .from('users')
          .insert({
            'email': email,
            'password': password, // In production, use proper hashing
            'name': name,
            'officer_code': officerCode, // Changed to match database column name
            'role_id': roleId, // Changed to match database column name
            'metadata': {
              'phone': phone,
              'department': department,
              'district': district,
              'registeredAt': DateTime.now().toIso8601String(),
            },
          })
          .select()
          .single();

      if (newUser != null) {
        // Create audit log for registration
        await _supabase.from('audit_logs').insert({
          'user_id': newUser['id'],
          'action': 'USER_REGISTERED',
          'module': 'AUTH',
          'details': {
            'name': name,
            'email': email,
            'role_id': roleId,
            'district': district,
          },
        });

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Registration failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Add a small delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Create audit log for logout
      if (_user != null) {
        try {
          await _supabase.from('audit_logs').insert({
            'user_id': _user!.id,
            'action': 'USER_LOGOUT',
            'module': 'AUTH',
            'details': {
              'email': _user!.email,
              'role': _user!.role?.name,
              'timestamp': DateTime.now().toIso8601String(),
            },
          });
        } catch (e) {
          print('Failed to create logout audit log: $e');
        }
      }

      _user = null;
      _isSuperUser = false;
      _error = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Logout failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
