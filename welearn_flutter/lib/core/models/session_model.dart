class SessionModel {
  final String id;
  final String? counselorId;
  final String? counselorName;
  final String? counselorPhoto;
  final String? studentId;
  final String? studentName;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String? agoraChannel;
  final String? agoraToken;
  final String? meetingLink;
  final String? notes;
  final String? type;

  const SessionModel({
    required this.id,
    this.counselorId,
    this.counselorName,
    this.counselorPhoto,
    this.studentId,
    this.studentName,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.agoraChannel,
    this.agoraToken,
    this.meetingLink,
    this.notes,
    this.type,
  });

  bool get isUpcoming => startTime.isAfter(DateTime.now());
  bool get isOngoing =>
      DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);
  bool get isPast => endTime.isBefore(DateTime.now());

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    final counselor = json['counselor'] as Map<String, dynamic>?;
    final student = json['student'] as Map<String, dynamic>?;
    return SessionModel(
      id: json['_id'] as String? ?? '',
      counselorId:
          counselor?['_id'] as String? ?? json['counselor'] as String?,
      counselorName: counselor?['name'] as String?,
      counselorPhoto: counselor?['profilePhoto'] as String?,
      studentId: student?['_id'] as String? ?? json['student'] as String?,
      studentName: student?['name'] as String?,
      startTime: DateTime.parse(
          json['startTime'] as String? ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(
          json['endTime'] as String? ?? DateTime.now().toIso8601String()),
      status: json['status'] as String? ?? 'scheduled',
      agoraChannel: json['agoraChannel'] as String?,
      agoraToken: json['agoraToken'] as String?,
      meetingLink: json['meetingLink'] as String?,
      notes: json['notes'] as String?,
      type: json['type'] as String?,
    );
  }
}

class CounselingBookingModel {
  final String id;
  final String? studentId;
  final String? studentName;
  final String? counselorId;
  final String? counselorName;
  final DateTime date;
  final String timeSlot;
  final String status;
  final String? category;
  final String? type;
  final double? fee;
  final String? paymentStatus;

  const CounselingBookingModel({
    required this.id,
    this.studentId,
    this.studentName,
    this.counselorId,
    this.counselorName,
    required this.date,
    required this.timeSlot,
    required this.status,
    this.category,
    this.type,
    this.fee,
    this.paymentStatus,
  });

  factory CounselingBookingModel.fromJson(Map<String, dynamic> json) {
    final student = json['student'] as Map<String, dynamic>?;
    final counselor = json['counselor'] as Map<String, dynamic>?;
    return CounselingBookingModel(
      id: json['_id'] as String? ?? '',
      studentId: student?['_id'] as String? ?? json['student'] as String?,
      studentName: student?['name'] as String?,
      counselorId:
          counselor?['_id'] as String? ?? json['counselor'] as String?,
      counselorName: counselor?['name'] as String?,
      date: DateTime.parse(
          json['date'] as String? ?? DateTime.now().toIso8601String()),
      timeSlot: json['timeSlot'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      category: json['category'] as String?,
      type: json['type'] as String?,
      fee: (json['fee'] as num?)?.toDouble(),
      paymentStatus: json['paymentStatus'] as String?,
    );
  }
}
