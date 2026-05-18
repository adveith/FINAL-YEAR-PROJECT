class PackageModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final int durationDays;
  final List<String> features;
  final bool isActive;
  final String? type;

  const PackageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.currency = 'INR',
    required this.durationDays,
    this.features = const [],
    this.isActive = true,
    this.type,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) => PackageModel(
        id: json['_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        currency: json['currency'] as String? ?? 'INR',
        durationDays: json['durationDays'] as int? ?? 30,
        features: (json['features'] as List<dynamic>? ?? [])
            .map((f) => f.toString())
            .toList(),
        isActive: json['isActive'] as bool? ?? true,
        type: json['type'] as String?,
      );
}

class UserPackageModel {
  final String id;
  final PackageModel? package;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final bool isExpired;

  const UserPackageModel({
    required this.id,
    this.package,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.isExpired = false,
  });

  int get daysRemaining => endDate.difference(DateTime.now()).inDays;

  factory UserPackageModel.fromJson(Map<String, dynamic> json) {
    final pkg = json['package'] as Map<String, dynamic>?;
    final now = DateTime.now();
    final endDate = DateTime.parse(
        json['endDate'] as String? ?? now.toIso8601String());
    return UserPackageModel(
      id: json['_id'] as String? ?? '',
      package: pkg != null ? PackageModel.fromJson(pkg) : null,
      startDate: DateTime.parse(
          json['startDate'] as String? ?? now.toIso8601String()),
      endDate: endDate,
      status: json['status'] as String? ?? 'active',
      isExpired: endDate.isBefore(now),
    );
  }
}

class CertificateModel {
  final String id;
  final String courseId;
  final String? courseName;
  final String? certificateUrl;
  final DateTime? issuedAt;

  const CertificateModel({
    required this.id,
    required this.courseId,
    this.courseName,
    this.certificateUrl,
    this.issuedAt,
  });

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    final course = json['course'] as Map<String, dynamic>?;
    return CertificateModel(
      id: json['_id'] as String? ?? '',
      courseId: course?['_id'] as String? ?? json['course'] as String? ?? '',
      courseName: course?['title'] as String?,
      certificateUrl: json['certificateUrl'] as String?,
      issuedAt: json['issuedAt'] != null
          ? DateTime.tryParse(json['issuedAt'] as String)
          : null,
    );
  }
}
