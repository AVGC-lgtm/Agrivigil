import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/menu_model.dart';
import '../config/supabase_config.dart';
import 'auth_provider.dart';

class PermissionProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
  AuthProvider? _authProvider;
  Map<String, String> _permissions = {};
  bool _isLoading = false;
  String? _error;

  Map<String, String> get permissions => _permissions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    if (_authProvider == null || _authProvider!.user == null) {
      _permissions = {};
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // If super user, grant full access to all menus
      if (_authProvider!.isSuperUser) {
        _permissions = {};
        for (final menu in MenuDefinitions.allMenus) {
          _permissions[menu.id] = AppConstants.permissionFull;
        }
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Load permissions for normal user
      final roleId = _authProvider!.user!.roleId;
      final response = await _supabase
          .from('role_permissions')
          .select()
          .eq('roleId', roleId);

      if (response != null && response.isNotEmpty) {
        _permissions = {};
        
        // Initialize all permissions as None
        for (final menu in MenuDefinitions.allMenus) {
          _permissions[menu.id] = AppConstants.permissionNone;
        }

        // Set permissions based on role
        for (final perm in response) {
          final menuIds = List<String>.from(perm['menuId'] ?? []);
          final authTypes = List<String>.from(perm['authType'] ?? []);
          
          for (int i = 0; i < menuIds.length && i < authTypes.length; i++) {
            _permissions[menuIds[i]] = authTypes[i];
          }
        }
      }
    } catch (e) {
      _error = 'Failed to load permissions: ${e.toString()}';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool hasPermission(String menuId, {String requiredLevel = AppConstants.permissionRead}) {
    if (_authProvider?.isSuperUser ?? false) {
      return true;
    }

    final permission = _permissions[menuId];
    if (permission == null || permission == AppConstants.permissionNone) {
      return false;
    }

    if (requiredLevel == AppConstants.permissionFull) {
      return permission == AppConstants.permissionFull;
    }

    return permission == AppConstants.permissionFull || 
           permission == AppConstants.permissionRead;
  }

  bool canAccess(String menuId) {
    return hasPermission(menuId, requiredLevel: AppConstants.permissionRead);
  }

  bool canEdit(String menuId) {
    return hasPermission(menuId, requiredLevel: AppConstants.permissionFull);
  }

  String getMenuPermission(String menuId) {
    if (_authProvider?.isSuperUser ?? false) {
      return AppConstants.permissionFull;
    }
    return _permissions[menuId] ?? AppConstants.permissionNone;
  }

  List<MenuDefinition> getAccessibleMenus() {
    return MenuDefinitions.allMenus
        .where((menu) => canAccess(menu.id))
        .toList();
  }

  Future<void> refreshPermissions() async {
    await _loadPermissions();
  }
}
