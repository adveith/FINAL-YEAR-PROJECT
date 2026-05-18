class AppConstants {
  // Base URL – override with env variable at build time
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.welearn.in/api/v1',
  );

  // Auth
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'cached_user';
  static const String fcmTokenKey = 'fcm_token';

  // Agora
  static const String agoraAppId = String.fromEnvironment(
    'AGORA_APP_ID',
    defaultValue: '',
  );

  // Razorpay
  static const String razorpayKey = String.fromEnvironment(
    'RAZORPAY_KEY',
    defaultValue: '',
  );

  // Pagination
  static const int defaultPageSize = 20;

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 60000;

  // User Roles
  static const String roleStudent = 'student';
  static const String roleSchool = 'school';
  static const String roleFacilitator = 'facilitator';
  static const String roleCounselor = 'counselor';
  static const String roleDoctor = 'doctor';
  static const String roleParent = 'parent';
  static const String roleIndividual = 'individual';
  static const String roleAdmin = 'admin';
  static const String roleSuperAdmin = 'superadmin';
  static const String roleParticipant = 'participant';
}
