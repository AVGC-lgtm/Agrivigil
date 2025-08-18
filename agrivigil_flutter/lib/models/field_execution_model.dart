class FieldExecutionModel {
  final String id;
  final String executionCode;
  final String location;
  final String district;
  final DateTime scheduledDate;
  final String inspectionType;
  final String? assignedOfficerId;
  final Map<String, dynamic>? assignedOfficer;
  final String status;
  final String? remarks;
  final DateTime createdAt;
  final DateTime? updatedAt;

  FieldExecutionModel({
    required this.id,
    required this.executionCode,
    required this.location,
    required this.district,
    required this.scheduledDate,
    required this.inspectionType,
    this.assignedOfficerId,
    this.assignedOfficer,
    required this.status,
    this.remarks,
    required this.createdAt,
    this.updatedAt,
  });

  factory FieldExecutionModel.fromJson(Map<String, dynamic> json) {
    return FieldExecutionModel(
      id: json['id'] ?? '',
      executionCode: json['execution_code'] ?? '',
      location: json['location'] ?? '',
      district: json['district'] ?? '',
      scheduledDate: DateTime.parse(json['scheduled_date']),
      inspectionType: json['inspection_type'] ?? '',
      assignedOfficerId: json['assigned_officer_id'],
      assignedOfficer: json['assigned_officer'],
      status: json['status'] ?? 'scheduled',
      remarks: json['remarks'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'execution_code': executionCode,
      'location': location,
      'district': district,
      'scheduled_date': scheduledDate.toIso8601String(),
      'inspection_type': inspectionType,
      'assigned_officer_id': assignedOfficerId,
      'assigned_officer': assignedOfficer,
      'status': status,
      'remarks': remarks,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Scheduled';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String get officerName {
    if (assignedOfficer != null) {
      return assignedOfficer!['name'] ?? 'Unknown Officer';
    }
    return 'Unassigned';
  }
}