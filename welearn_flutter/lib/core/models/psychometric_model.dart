class PsychometricTestModel {
  final String id;
  final String title;
  final String description;
  final String type;
  final int questionCount;
  final int durationMinutes;
  final bool isCompleted;
  final DateTime? completedAt;
  final PsychometricResultModel? result;

  const PsychometricTestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.questionCount,
    required this.durationMinutes,
    this.isCompleted = false,
    this.completedAt,
    this.result,
  });

  factory PsychometricTestModel.fromJson(Map<String, dynamic> json) =>
      PsychometricTestModel(
        id: json['_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        type: json['type'] as String? ?? '',
        questionCount: json['questionCount'] as int? ?? 0,
        durationMinutes: json['durationMinutes'] as int? ?? 30,
        isCompleted: json['isCompleted'] as bool? ?? false,
        completedAt: json['completedAt'] != null
            ? DateTime.tryParse(json['completedAt'] as String)
            : null,
        result: json['result'] != null
            ? PsychometricResultModel.fromJson(
                json['result'] as Map<String, dynamic>)
            : null,
      );
}

class PsychometricQuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final int order;

  const PsychometricQuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.order,
  });

  factory PsychometricQuestionModel.fromJson(Map<String, dynamic> json) =>
      PsychometricQuestionModel(
        id: json['_id'] as String? ?? '',
        question: json['question'] as String? ?? '',
        options: (json['options'] as List<dynamic>? ?? [])
            .map((o) => o.toString())
            .toList(),
        order: json['order'] as int? ?? 0,
      );
}

class PsychometricResultModel {
  final String id;
  final String testId;
  final Map<String, dynamic> scores;
  final String? interpretation;
  final String? recommendation;
  final DateTime? completedAt;

  const PsychometricResultModel({
    required this.id,
    required this.testId,
    required this.scores,
    this.interpretation,
    this.recommendation,
    this.completedAt,
  });

  factory PsychometricResultModel.fromJson(Map<String, dynamic> json) =>
      PsychometricResultModel(
        id: json['_id'] as String? ?? '',
        testId: json['test'] as String? ?? '',
        scores: json['scores'] as Map<String, dynamic>? ?? {},
        interpretation: json['interpretation'] as String?,
        recommendation: json['recommendation'] as String?,
        completedAt: json['completedAt'] != null
            ? DateTime.tryParse(json['completedAt'] as String)
            : null,
      );
}
