class RoleModel {
  final String id;
  final String name;
  final String code;
  final String? description;
  final String dashboardRoute;
  final int priority;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RoleModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.dashboardRoute,
    required this.priority,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'],
      dashboardRoute: json['dashboard_route'] ?? '',
      priority: json['priority'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'dashboard_route': dashboardRoute,
      'priority': priority,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'RoleModel(id: $id, name: $name, code: $code, dashboardRoute: $dashboardRoute)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoleModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
