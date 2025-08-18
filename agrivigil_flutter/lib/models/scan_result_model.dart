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
  });

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      id: json['id'] ?? '',
      company: json['company'] ?? '',
      product: json['product'] ?? '',
      batchNumber: json['batch_number'] ?? '',
      authenticityScore: (json['authenticity_score'] ?? 0).toDouble(),
      issues: json['issues'] != null 
          ? List<String>.from(json['issues'])
          : [],
      recommendation: json['recommendation'] ?? '',
      geoLocation: json['geo_location'] ?? '',
      timestamp: json['timestamp'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company': company,
      'product': product,
      'batch_number': batchNumber,
      'authenticity_score': authenticityScore,
      'issues': issues,
      'recommendation': recommendation,
      'geo_location': geoLocation,
      'timestamp': timestamp,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isAuthentic => authenticityScore >= 80;
  bool get isSuspicious => authenticityScore >= 40 && authenticityScore < 80;
  bool get isCounterfeit => authenticityScore < 40;

  String get statusLabel {
    if (isAuthentic) return 'Authentic';
    if (isSuspicious) return 'Suspicious';
    return 'Counterfeit';
  }

  String get scoreLabel => '${authenticityScore.toStringAsFixed(0)}%';
}