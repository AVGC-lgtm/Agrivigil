class InspectionTaskModel {
  final String id;
  final String inspectioncode;
  final String userId;
  final String datetime;
  final String state;
  final String district;
  final String taluka;
  final String location;
  final String addressland;
  final String targetType;
  final List<String> typeofpremises;
  final List<String> visitpurpose;
  final List<String> equipment;
  final String totaltarget;
  final String achievedtarget;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  InspectionTaskModel({
    required this.id,
    required this.inspectioncode,
    required this.userId,
    required this.datetime,
    required this.state,
    required this.district,
    required this.taluka,
    required this.location,
    required this.addressland,
    required this.targetType,
    required this.typeofpremises,
    required this.visitpurpose,
    required this.equipment,
    required this.totaltarget,
    required this.achievedtarget,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InspectionTaskModel.fromJson(Map<String, dynamic> json) {
    return InspectionTaskModel(
      id: json['id'],
      inspectioncode: json['inspectioncode'],
      userId: json['userId'],
      datetime: json['datetime'],
      state: json['state'],
      district: json['district'],
      taluka: json['taluka'],
      location: json['location'],
      addressland: json['addressland'],
      targetType: json['targetType'],
      typeofpremises: List<String>.from(json['typeofpremises']),
      visitpurpose: List<String>.from(json['visitpurpose']),
      equipment: List<String>.from(json['equipment']),
      totaltarget: json['totaltarget'],
      achievedtarget: json['achievedtarget'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inspectioncode': inspectioncode,
      'userId': userId,
      'datetime': datetime,
      'state': state,
      'district': district,
      'taluka': taluka,
      'location': location,
      'addressland': addressland,
      'targetType': targetType,
      'typeofpremises': typeofpremises,
      'visitpurpose': visitpurpose,
      'equipment': equipment,
      'totaltarget': totaltarget,
      'achievedtarget': achievedtarget,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class FieldExecutionModel {
  final int id;
  final String inspectionid;
  final String fieldcode;
  final String companyname;
  final String productname;
  final String dealerName;
  final String? registrationNo;
  final DateTime? samplingDate;
  final String fertilizerType;
  final String? batchNo;
  final DateTime? manufactureImportDate;
  final DateTime? stockReceiptDate;
  final String? sampleCode;
  final String? stockPosition;
  final String? physicalCondition;
  final String? specificationFco;
  final String? compositionAnalysis;
  final String? variation;
  final double? moisture;
  final double? totalN;
  final double? nh4n;
  final double? nh4no3n;
  final double? ureaN;
  final double? totalP2o5;
  final double? nacSolubleP2o5;
  final double? citricSolubleP2o5;
  final double? waterSolubleP2o5;
  final double? waterSolubleK2o;
  final String? particleSize;
  final String document;
  final String productphoto;
  final String userid;

  FieldExecutionModel({
    required this.id,
    required this.inspectionid,
    required this.fieldcode,
    required this.companyname,
    required this.productname,
    required this.dealerName,
    this.registrationNo,
    this.samplingDate,
    required this.fertilizerType,
    this.batchNo,
    this.manufactureImportDate,
    this.stockReceiptDate,
    this.sampleCode,
    this.stockPosition,
    this.physicalCondition,
    this.specificationFco,
    this.compositionAnalysis,
    this.variation,
    this.moisture,
    this.totalN,
    this.nh4n,
    this.nh4no3n,
    this.ureaN,
    this.totalP2o5,
    this.nacSolubleP2o5,
    this.citricSolubleP2o5,
    this.waterSolubleP2o5,
    this.waterSolubleK2o,
    this.particleSize,
    required this.document,
    required this.productphoto,
    required this.userid,
  });

  factory FieldExecutionModel.fromJson(Map<String, dynamic> json) {
    return FieldExecutionModel(
      id: json['id'],
      inspectionid: json['inspectionid'],
      fieldcode: json['fieldcode'],
      companyname: json['companyname'],
      productname: json['productname'],
      dealerName: json['dealer_name'],
      registrationNo: json['registration_no'],
      samplingDate: json['sampling_date'] != null
          ? DateTime.parse(json['sampling_date'])
          : null,
      fertilizerType: json['fertilizer_type'],
      batchNo: json['batch_no'],
      manufactureImportDate: json['manufacture_import_date'] != null
          ? DateTime.parse(json['manufacture_import_date'])
          : null,
      stockReceiptDate: json['stock_receipt_date'] != null
          ? DateTime.parse(json['stock_receipt_date'])
          : null,
      sampleCode: json['sample_code'],
      stockPosition: json['stock_position'],
      physicalCondition: json['physical_condition'],
      specificationFco: json['specification_fco'],
      compositionAnalysis: json['composition_analysis'],
      variation: json['variation'],
      moisture: json['moisture'] != null
          ? double.parse(json['moisture'].toString())
          : null,
      totalN: json['total_n'] != null
          ? double.parse(json['total_n'].toString())
          : null,
      nh4n: json['nh4n'] != null
          ? double.parse(json['nh4n'].toString())
          : null,
      nh4no3n: json['nh4no3n'] != null
          ? double.parse(json['nh4no3n'].toString())
          : null,
      ureaN: json['urea_n'] != null
          ? double.parse(json['urea_n'].toString())
          : null,
      totalP2o5: json['total_p2o5'] != null
          ? double.parse(json['total_p2o5'].toString())
          : null,
      nacSolubleP2o5: json['nac_soluble_p2o5'] != null
          ? double.parse(json['nac_soluble_p2o5'].toString())
          : null,
      citricSolubleP2o5: json['citric_soluble_p2o5'] != null
          ? double.parse(json['citric_soluble_p2o5'].toString())
          : null,
      waterSolubleP2o5: json['water_soluble_p2o5'] != null
          ? double.parse(json['water_soluble_p2o5'].toString())
          : null,
      waterSolubleK2o: json['water_soluble_k2o'] != null
          ? double.parse(json['water_soluble_k2o'].toString())
          : null,
      particleSize: json['particle_size'],
      document: json['document'],
      productphoto: json['productphoto'],
      userid: json['userid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inspectionid': inspectionid,
      'fieldcode': fieldcode,
      'companyname': companyname,
      'productname': productname,
      'dealer_name': dealerName,
      'registration_no': registrationNo,
      'sampling_date': samplingDate?.toIso8601String(),
      'fertilizer_type': fertilizerType,
      'batch_no': batchNo,
      'manufacture_import_date': manufactureImportDate?.toIso8601String(),
      'stock_receipt_date': stockReceiptDate?.toIso8601String(),
      'sample_code': sampleCode,
      'stock_position': stockPosition,
      'physical_condition': physicalCondition,
      'specification_fco': specificationFco,
      'composition_analysis': compositionAnalysis,
      'variation': variation,
      'moisture': moisture,
      'total_n': totalN,
      'nh4n': nh4n,
      'nh4no3n': nh4no3n,
      'urea_n': ureaN,
      'total_p2o5': totalP2o5,
      'nac_soluble_p2o5': nacSolubleP2o5,
      'citric_soluble_p2o5': citricSolubleP2o5,
      'water_soluble_p2o5': waterSolubleP2o5,
      'water_soluble_k2o': waterSolubleK2o,
      'particle_size': particleSize,
      'document': document,
      'productphoto': productphoto,
      'userid': userid,
    };
  }
}
