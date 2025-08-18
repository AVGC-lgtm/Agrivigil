import 'role_model.dart';

class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? officerCode;
  final String roleId;
  final RoleModel? role;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.officerCode,
    required this.roleId,
    this.role,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      officerCode: json['officer_code'], // Changed to match database column
      roleId: json['role_id'], // Changed to match database column
      role: json['role'] != null ? RoleModel.fromJson(json['role']) : null,
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
      createdAt: DateTime.parse(json['created_at']), // Changed to match database column
      updatedAt: DateTime.parse(json['updated_at']), // Changed to match database column
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'officerCode': officerCode,
      'roleId': roleId,
      'role': role?.toJson(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
  
  // Helper methods to access metadata fields
  String? get phone => metadata?['phone'] as String?;
  String? get department => metadata?['department'] as String?;
  String? get district => metadata?['district'] as String?;
  String? get registeredAt => metadata?['registeredAt'] as String?;
}



class RolePermissionModel {
  final String id;
  final String? roleId;
  final List<String> menuId;
  final List<String> authType;
  final DateTime createdAt;
  final DateTime updatedAt;

  RolePermissionModel({
    required this.id,
    this.roleId,
    required this.menuId,
    required this.authType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RolePermissionModel.fromJson(Map<String, dynamic> json) {
    return RolePermissionModel(
      id: json['id'],
      roleId: json['role_id'], // Changed to match database column
      menuId: List<String>.from(json['menu_id']), // Changed to match database column
      authType: List<String>.from(json['auth_type']), // Changed to match database column
      createdAt: DateTime.parse(json['created_at']), // Changed to match database column
      updatedAt: DateTime.parse(json['updated_at']), // Changed to match database column
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roleId': roleId,
      'menuId': menuId,
      'authType': authType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
