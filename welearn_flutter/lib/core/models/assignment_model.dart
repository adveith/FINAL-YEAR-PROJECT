class AssignmentModel {
  final String id;
  final String title;
  final String description;
  final String courseId;
  final String? courseName;
  final String? moduleId;
  final double maxMarks;
  final DateTime dueDate;
  final bool isSubmitted;
  final SubmissionModel? mySubmission;
  final DateTime? createdAt;

  const AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    this.courseName,
    this.moduleId,
    required this.maxMarks,
    required this.dueDate,
    this.isSubmitted = false,
    this.mySubmission,
    this.createdAt,
  });

  bool get isOverdue =>
      dueDate.isBefore(DateTime.now()) && !isSubmitted;

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    final course = json['course'] as Map<String, dynamic>?;
    return AssignmentModel(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      courseId: course?['_id'] as String? ?? json['course'] as String? ?? '',
      courseName: course?['title'] as String?,
      moduleId: json['module'] as String?,
      maxMarks: (json['maxMarks'] as num?)?.toDouble() ?? 100,
      dueDate: DateTime.parse(
          json['dueDate'] as String? ?? DateTime.now().toIso8601String()),
      isSubmitted: json['isSubmitted'] as bool? ?? false,
      mySubmission: json['mySubmission'] != null
          ? SubmissionModel.fromJson(
              json['mySubmission'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

class SubmissionModel {
  final String id;
  final String assignmentId;
  final String studentId;
  final String? content;
  final String? fileUrl;
  final double? marksObtained;
  final String? feedback;
  final String status;
  final DateTime? submittedAt;

  const SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    this.content,
    this.fileUrl,
    this.marksObtained,
    this.feedback,
    this.status = 'submitted',
    this.submittedAt,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) =>
      SubmissionModel(
        id: json['_id'] as String? ?? '',
        assignmentId: json['assignment'] as String? ?? '',
        studentId: json['student'] as String? ?? '',
        content: json['content'] as String?,
        fileUrl: json['fileUrl'] as String?,
        marksObtained: (json['marksObtained'] as num?)?.toDouble(),
        feedback: json['feedback'] as String?,
        status: json['status'] as String? ?? 'submitted',
        submittedAt: json['submittedAt'] != null
            ? DateTime.tryParse(json['submittedAt'] as String)
            : null,
      );
}

class AssessmentModel {
  final String id;
  final String title;
  final String courseId;
  final String? courseName;
  final int totalMarks;
  final int durationMinutes;
  final bool isAttempted;
  final double? score;
  final List<QuestionModel> questions;

  const AssessmentModel({
    required this.id,
    required this.title,
    required this.courseId,
    this.courseName,
    required this.totalMarks,
    required this.durationMinutes,
    this.isAttempted = false,
    this.score,
    this.questions = const [],
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json) {
    final course = json['course'] as Map<String, dynamic>?;
    return AssessmentModel(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      courseId: course?['_id'] as String? ?? json['course'] as String? ?? '',
      courseName: course?['title'] as String?,
      totalMarks: json['totalMarks'] as int? ?? 100,
      durationMinutes: json['durationMinutes'] as int? ?? 60,
      isAttempted: json['isAttempted'] as bool? ?? false,
      score: (json['score'] as num?)?.toDouble(),
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final int? correctOption;
  final int marks;

  const QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    this.correctOption,
    this.marks = 1,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
        id: json['_id'] as String? ?? '',
        question: json['question'] as String? ?? '',
        options: (json['options'] as List<dynamic>? ?? [])
            .map((o) => o.toString())
            .toList(),
        correctOption: json['correctOption'] as int?,
        marks: json['marks'] as int? ?? 1,
      );
}
