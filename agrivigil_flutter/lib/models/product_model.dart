class ProductModel {
  final String id;
  final String category;
  final String company;
  final String name;
  final String? activeIngredient;
  final String? composition;
  final List<String> packaging;
  final String? batchFormat;
  final List<String> commonCounterfeitMarkers;
  final Map<String, dynamic>? mrp;
  final List<String> hologramFeatures;
  final String? bagColor;
  final double? subsidizedRate;
  final List<String> varieties;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.category,
    required this.company,
    required this.name,
    this.activeIngredient,
    this.composition,
    required this.packaging,
    this.batchFormat,
    required this.commonCounterfeitMarkers,
    this.mrp,
    required this.hologramFeatures,
    this.bagColor,
    this.subsidizedRate,
    required this.varieties,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      category: json['category'],
      company: json['company'],
      name: json['name'],
      activeIngredient: json['activeIngredient'],
      composition: json['composition'],
      packaging: List<String>.from(json['packaging']),
      batchFormat: json['batchFormat'],
      commonCounterfeitMarkers:
          List<String>.from(json['commonCounterfeitMarkers']),
      mrp: json['mrp'],
      hologramFeatures: List<String>.from(json['hologramFeatures']),
      bagColor: json['bagColor'],
      subsidizedRate: json['subsidizedRate']?.toDouble(),
      varieties: List<String>.from(json['varieties']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'company': company,
      'name': name,
      'activeIngredient': activeIngredient,
      'composition': composition,
      'packaging': packaging,
      'batchFormat': batchFormat,
      'commonCounterfeitMarkers': commonCounterfeitMarkers,
      'mrp': mrp,
      'hologramFeatures': hologramFeatures,
      'bagColor': bagColor,
      'subsidizedRate': subsidizedRate,
      'varieties': varieties,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ScanResultModel {
  final String id;
  final String company;
  final String product;
  final String batchNumber;
  final double authenticityScore;
  final List<String> issues;
  final String recommendation;
  final String geoLocation;
  final String timestamp;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? productId;

  ScanResultModel({
    required this.id,
    required this.company,
    required this.product,
    required this.batchNumber,
    required this.authenticityScore,
    required this.issues,
    required this.recommendation,
    required this.geoLocation,
    required this.timestamp,
    required this.createdAt,
    required this.updatedAt,
    this.productId,
  });

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      id: json['id'],
      company: json['company'],
      product: json['product'],
      batchNumber: json['batchNumber'],
      authenticityScore: json['authenticityScore'].toDouble(),
      issues: List<String>.from(json['issues']),
      recommendation: json['recommendation'],
      geoLocation: json['geoLocation'],
      timestamp: json['timestamp'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      productId: json['productId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company': company,
      'product': product,
      'batchNumber': batchNumber,
      'authenticityScore': authenticityScore,
      'issues': issues,
      'recommendation': recommendation,
      'geoLocation': geoLocation,
      'timestamp': timestamp,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'productId': productId,
    };
  }
}
