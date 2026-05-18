class CourseModel {
  final String id;
  final String title;
  final String description;
  final String? thumbnail;
  final double price;
  final double? discountedPrice;
  final String? categoryId;
  final String? categoryName;
  final String? subCategoryId;
  final String? subCategoryName;
  final String? instructorId;
  final String? instructorName;
  final double rating;
  final int reviewCount;
  final int enrolledCount;
  final String? level;
  final String? language;
  final int? durationMinutes;
  final bool isPublished;
  final DateTime? createdAt;
  final List<ModuleModel> modules;

  const CourseModel({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnail,
    required this.price,
    this.discountedPrice,
    this.categoryId,
    this.categoryName,
    this.subCategoryId,
    this.subCategoryName,
    this.instructorId,
    this.instructorName,
    this.rating = 0,
    this.reviewCount = 0,
    this.enrolledCount = 0,
    this.level,
    this.language,
    this.durationMinutes,
    this.isPublished = true,
    this.createdAt,
    this.modules = const [],
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final instructor = json['instructor'] as Map<String, dynamic>?;
    final category = json['category'] as Map<String, dynamic>?;
    return CourseModel(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      thumbnail: json['thumbnail'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountedPrice: (json['discountedPrice'] as num?)?.toDouble(),
      categoryId: category?['_id'] as String? ?? json['category'] as String?,
      categoryName: category?['name'] as String?,
      instructorId:
          instructor?['_id'] as String? ?? json['instructor'] as String?,
      instructorName: instructor?['name'] as String?,
      rating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      enrolledCount: json['enrolledStudents'] as int? ?? 0,
      level: json['level'] as String?,
      language: json['language'] as String?,
      durationMinutes: json['durationMinutes'] as int?,
      isPublished: json['isPublished'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      modules: (json['modules'] as List<dynamic>? ?? [])
          .map((m) => ModuleModel.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ModuleModel {
  final String id;
  final String title;
  final String? description;
  final int order;
  final List<LectureModel> lectures;

  const ModuleModel({
    required this.id,
    required this.title,
    this.description,
    required this.order,
    this.lectures = const [],
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) => ModuleModel(
        id: json['_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        order: json['order'] as int? ?? 0,
        lectures: (json['lectures'] as List<dynamic>? ?? [])
            .map((l) => LectureModel.fromJson(l as Map<String, dynamic>))
            .toList(),
      );
}

class LectureModel {
  final String id;
  final String title;
  final String? description;
  final String? videoUrl;
  final int? durationSeconds;
  final bool isFree;
  final int order;
  final String? resourceUrl;

  const LectureModel({
    required this.id,
    required this.title,
    this.description,
    this.videoUrl,
    this.durationSeconds,
    this.isFree = false,
    required this.order,
    this.resourceUrl,
  });

  factory LectureModel.fromJson(Map<String, dynamic> json) => LectureModel(
        id: json['_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        videoUrl: json['videoUrl'] as String?,
        durationSeconds: json['durationSeconds'] as int?,
        isFree: json['isFree'] as bool? ?? false,
        order: json['order'] as int? ?? 0,
        resourceUrl: json['resourceUrl'] as String?,
      );
}

class EnrollmentModel {
  final String id;
  final String courseId;
  final String? courseName;
  final String? courseThumbnail;
  final double progressPercent;
  final String status;
  final DateTime? enrolledAt;
  final DateTime? completedAt;

  const EnrollmentModel({
    required this.id,
    required this.courseId,
    this.courseName,
    this.courseThumbnail,
    this.progressPercent = 0,
    this.status = 'active',
    this.enrolledAt,
    this.completedAt,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    final course = json['course'] as Map<String, dynamic>?;
    return EnrollmentModel(
      id: json['_id'] as String? ?? '',
      courseId: course?['_id'] as String? ?? json['course'] as String? ?? '',
      courseName: course?['title'] as String?,
      courseThumbnail: course?['thumbnail'] as String?,
      progressPercent: (json['progressPercent'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'active',
      enrolledAt: json['enrolledAt'] != null
          ? DateTime.tryParse(json['enrolledAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
    );
  }
}
