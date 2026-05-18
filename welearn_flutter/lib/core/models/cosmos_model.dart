// MindMatrix – Cosmos (Astrology + Numerology)
class CosmosReportModel {
  final String id;
  final String userId;
  final String reportType; // 'astrology' | 'numerology' | 'combined'
  final Map<String, dynamic> astrologyData;
  final Map<String, dynamic> numerologyData;
  final String? sunSign;
  final String? moonSign;
  final String? risingSign;
  final String? lifePathNumber;
  final String? destinyNumber;
  final String? personalityNumber;
  final String? summary;
  final String? careerInsight;
  final String? relationshipInsight;
  final String? healthInsight;
  final DateTime? createdAt;

  const CosmosReportModel({
    required this.id,
    required this.userId,
    required this.reportType,
    this.astrologyData = const {},
    this.numerologyData = const {},
    this.sunSign,
    this.moonSign,
    this.risingSign,
    this.lifePathNumber,
    this.destinyNumber,
    this.personalityNumber,
    this.summary,
    this.careerInsight,
    this.relationshipInsight,
    this.healthInsight,
    this.createdAt,
  });

  factory CosmosReportModel.fromJson(Map<String, dynamic> json) =>
      CosmosReportModel(
        id: json['_id'] as String? ?? '',
        userId: json['user'] is String
            ? json['user'] as String
            : (json['user'] as Map?)?['_id'] as String? ?? '',
        reportType: json['reportType'] as String? ?? 'combined',
        astrologyData:
            json['astrologyData'] as Map<String, dynamic>? ?? {},
        numerologyData:
            json['numerologyData'] as Map<String, dynamic>? ?? {},
        sunSign: json['sunSign'] as String?,
        moonSign: json['moonSign'] as String?,
        risingSign: json['risingSign'] as String?,
        lifePathNumber: json['lifePathNumber']?.toString(),
        destinyNumber: json['destinyNumber']?.toString(),
        personalityNumber: json['personalityNumber']?.toString(),
        summary: json['summary'] as String?,
        careerInsight: json['careerInsight'] as String?,
        relationshipInsight: json['relationshipInsight'] as String?,
        healthInsight: json['healthInsight'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );
}

class CosmosInputModel {
  final String birthDate;
  final String? birthTime;
  final String? birthPlace;
  final String fullName;

  const CosmosInputModel({
    required this.birthDate,
    this.birthTime,
    this.birthPlace,
    required this.fullName,
  });

  Map<String, dynamic> toJson() => {
        'birthDate': birthDate,
        if (birthTime != null) 'birthTime': birthTime,
        if (birthPlace != null) 'birthPlace': birthPlace,
        'fullName': fullName,
      };
}
