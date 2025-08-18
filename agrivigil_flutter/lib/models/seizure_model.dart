class SeizureModel {
  final String id;
  final String seizurecode;
  final int fieldExecutionId;
  final String location;
  final String district;
  final String? taluka;
  final List<String> premisesType;
  final String? fertilizerType;
  final String? batchNo;
  final double? quantity;
  final String? estimatedValue;
  final String? witnessName;
  final List<String> evidencePhotos;
  final String? videoEvidence;
  final String status;
  final String? remarks;
  final DateTime? seizureDate;
  final String? memoNo;
  final String? officerName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final String? scanResultId;

  SeizureModel({
    required this.id,
    required this.seizurecode,
    required this.fieldExecutionId,
    required this.location,
    required this.district,
    this.taluka,
    required this.premisesType,
    this.fertilizerType,
    this.batchNo,
    this.quantity,
    this.estimatedValue,
    this.witnessName,
    required this.evidencePhotos,
    this.videoEvidence,
    required this.status,
    this.remarks,
    this.seizureDate,
    this.memoNo,
    this.officerName,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    this.scanResultId,
  });

  factory SeizureModel.fromJson(Map<String, dynamic> json) {
    return SeizureModel(
      id: json['id'],
      seizurecode: json['seizurecode'],
      fieldExecutionId: json['fieldExecutionId'],
      location: json['location'],
      district: json['district'],
      taluka: json['taluka'],
      premisesType: List<String>.from(json['premises_type']),
      fertilizerType: json['fertilizer_type'],
      batchNo: json['batch_no'],
      quantity: json['quantity'] != null
          ? double.parse(json['quantity'].toString())
          : null,
      estimatedValue: json['estimatedValue'],
      witnessName: json['witnessName'],
      evidencePhotos: List<String>.from(json['evidencePhotos']),
      videoEvidence: json['videoEvidence'],
      status: json['status'],
      remarks: json['remarks'],
      seizureDate: json['seizure_date'] != null
          ? DateTime.parse(json['seizure_date'])
          : null,
      memoNo: json['memo_no'],
      officerName: json['officer_name'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      userId: json['userId'],
      scanResultId: json['scanResultId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seizurecode': seizurecode,
      'fieldExecutionId': fieldExecutionId,
      'location': location,
      'district': district,
      'taluka': taluka,
      'premises_type': premisesType,
      'fertilizer_type': fertilizerType,
      'batch_no': batchNo,
      'quantity': quantity,
      'estimatedValue': estimatedValue,
      'witnessName': witnessName,
      'evidencePhotos': evidencePhotos,
      'videoEvidence': videoEvidence,
      'status': status,
      'remarks': remarks,
      'seizure_date': seizureDate?.toIso8601String(),
      'memo_no': memoNo,
      'officer_name': officerName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
      'scanResultId': scanResultId,
    };
  }
}

class LabSampleModel {
  final int id;
  final String samplecode;
  final String department;
  final String sampleDesc;
  final String district;
  final String status;
  final DateTime? collectedAt;
  final DateTime? dispatchedAt;
  final DateTime? receivedAt;
  final bool underTesting;
  final String? resultStatus;
  final DateTime? reportSentAt;
  final String? officerName;
  final String? remarks;
  final String userId;
  final String? seizureId;

  LabSampleModel({
    required this.id,
    required this.samplecode,
    required this.department,
    required this.sampleDesc,
    required this.district,
    required this.status,
    this.collectedAt,
    this.dispatchedAt,
    this.receivedAt,
    required this.underTesting,
    this.resultStatus,
    this.reportSentAt,
    this.officerName,
    this.remarks,
    required this.userId,
    this.seizureId,
  });

  factory LabSampleModel.fromJson(Map<String, dynamic> json) {
    return LabSampleModel(
      id: json['id'],
      samplecode: json['samplecode'],
      department: json['department'],
      sampleDesc: json['sample_desc'],
      district: json['district'],
      status: json['status'],
      collectedAt: json['collected_at'] != null
          ? DateTime.parse(json['collected_at'])
          : null,
      dispatchedAt: json['dispatched_at'] != null
          ? DateTime.parse(json['dispatched_at'])
          : null,
      receivedAt: json['received_at'] != null
          ? DateTime.parse(json['received_at'])
          : null,
      underTesting: json['under_testing'],
      resultStatus: json['result_status'],
      reportSentAt: json['report_sent_at'] != null
          ? DateTime.parse(json['report_sent_at'])
          : null,
      officerName: json['officer_name'],
      remarks: json['remarks'],
      userId: json['userId'],
      seizureId: json['seizureId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'samplecode': samplecode,
      'department': department,
      'sample_desc': sampleDesc,
      'district': district,
      'status': status,
      'collected_at': collectedAt?.toIso8601String(),
      'dispatched_at': dispatchedAt?.toIso8601String(),
      'received_at': receivedAt?.toIso8601String(),
      'under_testing': underTesting,
      'result_status': resultStatus,
      'report_sent_at': reportSentAt?.toIso8601String(),
      'officer_name': officerName,
      'remarks': remarks,
      'userId': userId,
      'seizureId': seizureId,
    };
  }
}

class FIRCaseModel {
  final int id;
  final String fircode;
  final String policeStation;
  final String accusedParty;
  final String suspectName;
  final String entityType;
  final String? street1;
  final String? street2;
  final String? village;
  final String district;
  final String state;
  final String? licenseNo;
  final String? contactNo;
  final String? brandName;
  final String? fertilizerType;
  final String? batchNo;
  final DateTime? manufactureDate;
  final DateTime? expiryDate;
  final List<String> violationType;
  final String? evidence;
  final String? remarks;
  final String userId;
  final int? labSampleId;

  FIRCaseModel({
    required this.id,
    required this.fircode,
    required this.policeStation,
    required this.accusedParty,
    required this.suspectName,
    required this.entityType,
    this.street1,
    this.street2,
    this.village,
    required this.district,
    required this.state,
    this.licenseNo,
    this.contactNo,
    this.brandName,
    this.fertilizerType,
    this.batchNo,
    this.manufactureDate,
    this.expiryDate,
    required this.violationType,
    this.evidence,
    this.remarks,
    required this.userId,
    this.labSampleId,
  });

  factory FIRCaseModel.fromJson(Map<String, dynamic> json) {
    return FIRCaseModel(
      id: json['id'],
      fircode: json['fircode'],
      policeStation: json['police_station'],
      accusedParty: json['accused_party'],
      suspectName: json['suspect_name'],
      entityType: json['entity_type'],
      street1: json['street1'],
      street2: json['street2'],
      village: json['village'],
      district: json['district'],
      state: json['state'],
      licenseNo: json['license_no'],
      contactNo: json['contact_no'],
      brandName: json['brand_name'],
      fertilizerType: json['fertilizer_type'],
      batchNo: json['batch_no'],
      manufactureDate: json['manufacture_date'] != null
          ? DateTime.parse(json['manufacture_date'])
          : null,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : null,
      violationType: List<String>.from(json['violation_type']),
      evidence: json['evidence'],
      remarks: json['remarks'],
      userId: json['userId'],
      labSampleId: json['labSampleId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fircode': fircode,
      'police_station': policeStation,
      'accused_party': accusedParty,
      'suspect_name': suspectName,
      'entity_type': entityType,
      'street1': street1,
      'street2': street2,
      'village': village,
      'district': district,
      'state': state,
      'license_no': licenseNo,
      'contact_no': contactNo,
      'brand_name': brandName,
      'fertilizer_type': fertilizerType,
      'batch_no': batchNo,
      'manufacture_date': manufactureDate?.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'violation_type': violationType,
      'evidence': evidence,
      'remarks': remarks,
      'userId': userId,
      'labSampleId': labSampleId,
    };
  }
}
