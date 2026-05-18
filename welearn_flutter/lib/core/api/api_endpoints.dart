class ApiEndpoints {
  // ─── Auth / User ────────────────────────────────────────────────────────────
  // These go to the standard user.route.js — no /mobile prefix
  static const String login = '/user/login';
  static const String register = '/user/register';
  static const String logout = '/user/logout';
  static const String profile = '/user/profile';
  static const String refreshToken = '/user/refresh-token';
  static const String forgotPassword = '/user/forgot-password';
  static const String resetPassword = '/user/reset-password';
  static const String changePassword = '/user/change-password';
  static const String verifyEmail = '/user/verify-email';
  static const String resendOtp = '/user/resend-otp';

  // ─── FCM / Notifications ─────────────────────────────────────────────────
  // Goes to existing fcm.routes.js — no /mobile prefix
  static const String fcmRegister = '/fcm/register';
  static const String fcmUnregister = '/fcm/unregister';

  // ─── Psychometric ────────────────────────────────────────────────────────
  // Goes to existing psychometric.routes.js — no /mobile prefix
  static const String psychometricTests = '/psychometric/tests';
  static const String psychometricResults = '/psychometric/results';
  static String startPsychometric(String testId) => '/psychometric/$testId/start';
  static String submitPsychometric(String testId) => '/psychometric/$testId/submit';

  // ─── MindMatrix / Cosmos ─────────────────────────────────────────────────
  // Goes to existing cosmos.routes.js — no /mobile prefix
  static const String cosmosMyReports = '/cosmos/my-reports';
  static const String cosmosAstrology = '/cosmos/astrology';
  static const String cosmosNumerology = '/cosmos/numerology';
  static const String cosmosCombined = '/cosmos/combined';
  static String cosmosReportById(String id) => '/cosmos/reports/$id';

  // ─── AI ──────────────────────────────────────────────────────────────────
  static const String aiChat = '/ai/chat';
  static const String aiRecommendations = '/ai/recommendations';

  // ─── Courses (public/existing routes) ────────────────────────────────────
  static const String courses = '/course';
  static String courseById(String id) => '/course/$id';
  static String coursePublish(String id) => '/course/$id/publish';
  static const String featuredCourses = '/course/featured';
  static const String courseCategories = '/course-categories';

  // ─── Modules / Lectures ──────────────────────────────────────────────────
  static String modules(String courseId) => '/modules?courseId=$courseId';
  static String moduleById(String courseId, String moduleId) => '/modules/$moduleId';
  static String lectures(String courseId, String moduleId) => '/lectures?moduleId=$moduleId';
  static String lectureById(String courseId, String moduleId, String lectureId) => '/lectures/$lectureId';
  static String lectureProgress(String lectureId) => '/lectures/$lectureId/progress';

  // ─── Assessments ─────────────────────────────────────────────────────────
  static const String assessments = '/assessments';
  static String assessmentById(String id) => '/assessments/$id';
  static String startAssessment(String id) => '/assessments/$id/start';
  static String submitAssessment(String id) => '/assessments/$id/submit';

  // ─── Reviews ─────────────────────────────────────────────────────────────
  static String courseReviews(String courseId) => '/reviews?courseId=$courseId';
  static String submitReview(String courseId) => '/reviews';

  // ─── Documents ───────────────────────────────────────────────────────────
  static const String documents = '/documents';
  static String documentById(String id) => '/documents/$id';

  // ─── Certificates ────────────────────────────────────────────────────────
  static const String certificates = '/certificates';
  static String certificateById(String id) => '/certificates/$id';
  static String downloadCertificate(String id) => '/certificates/$id/download';

  // ─── Leave / Attendance ──────────────────────────────────────────────────
  static const String leaveRequests = '/leaves';
  static const String myLeaveRequests = '/leaves/my';
  static String leaveById(String id) => '/leaves/$id';

  // ─── Batches ─────────────────────────────────────────────────────────────
  static const String batches = '/batches';
  static String batchById(String id) => '/batches/$id';
  static String batchStudents(String id) => '/batches/$id/students';

  // ═══════════════════════════════════════════════════════════════════════════
  // MOBILE API — all endpoints below go to /api/v1/mobile/...
  // Handled by mobile.route.js + mobile.controller.js
  // ═══════════════════════════════════════════════════════════════════════════

  // ─── Dashboard ───────────────────────────────────────────────────────────
  static const String dashboard = '/mobile/dashboard';

  // ─── Sessions ────────────────────────────────────────────────────────────
  static const String sessions = '/sessions';
  static const String mySessions = '/mobile/sessions/my';
  static String sessionById(String id) => '/sessions/$id';
  static const String agoraToken = '/mobile/sessions/agora-token';

  // ─── Enrollments ─────────────────────────────────────────────────────────
  static const String enrollments = '/enrollments';
  static const String myEnrollments = '/mobile/enrollments/my';
  static String enrollCourse(String courseId) => '/enrollments/$courseId';
  static String courseProgress(String enrollmentId) => '/enrollments/$enrollmentId/progress';

  // ─── Counseling ──────────────────────────────────────────────────────────
  static const String counselingBooking = '/counseling-booking';
  static const String counselorSessions = '/mobile/counseling-booking/counselor';
  static const String counselorBookings = '/mobile/counseling-booking/pending';
  static String updateBookingStatus(String id) => '/mobile/counseling-booking/$id/status';
  static String bookingById(String id) => '/counseling-booking/$id';

  // ─── Assignments ─────────────────────────────────────────────────────────
  static const String assignments = '/assignments';
  static const String myAssignments = '/mobile/assignments/my';
  static String assignmentById(String id) => '/assignments/$id';
  static String submitAssignment(String id) => '/assignments/$id/submit';
  static const String mySubmissions = '/mobile/submissions/my';
  static String submissionById(String id) => '/submissions/$id';
  static String gradeSubmission(String id) => '/submissions/$id/grade';

  // ─── School ──────────────────────────────────────────────────────────────
  static const String schoolStudents = '/mobile/school/students';
  static const String schoolAddStudent = '/mobile/school/students/add';
  static const String schoolTeachers = '/mobile/school/teachers';
  static const String schoolAddTeacher = '/mobile/school/teachers/add';
  static const String schoolBulkImport = '/mobile/school/students/bulk-import';
  static const String schoolMarks = '/mobile/school/marks';
  static const String schoolReports = '/mobile/school/reports';
  static const String schoolAttendance = '/mobile/school/attendance';

  // ─── Facilitator / Teacher ───────────────────────────────────────────────
  static const String facilitatorCourses = '/mobile/facilitator/courses';
  static const String facilitatorStudents = '/mobile/facilitator/students';
  static const String facilitatorBatches = '/mobile/facilitator/batches';

  // ─── Doctor ──────────────────────────────────────────────────────────────
  static const String doctorPatients = '/mobile/doctor/patients';
  static const String doctorAppointments = '/mobile/doctor/appointments';
  static const String doctorDiagnosis = '/mobile/doctor/diagnosis';
  static String doctorPatientById(String id) => '/mobile/doctor/patients/$id';

  // ─── Parent ──────────────────────────────────────────────────────────────
  static const String parentChildren = '/mobile/parent/children';
  static const String parentLinkChild = '/mobile/parent/children/link';
  static String parentChildProgress(String childId) => '/mobile/parent/children/$childId/progress';

  // ─── Individual ──────────────────────────────────────────────────────────
  static const String individualProfile = '/individual-profile';
  static const String individualSessions = '/mobile/sessions/my';

  // ─── Payments ────────────────────────────────────────────────────────────
  static const String myPayments = '/mobile/payments/my';
  static const String createOrder = '/mobile/payments/create-order';
  static const String verifyPayment = '/mobile/payments/verify';
  static const String paymentById = '/mobile/payments';

  // ─── Packages ────────────────────────────────────────────────────────────
  static const String packages = '/mobile/packages';
  static String packageById(String id) => '/mobile/packages/$id';

  // ─── WorkRoom ────────────────────────────────────────────────────────────
  static const String workrooms = '/mobile/workroom';
  static String workroomById(String id) => '/mobile/workroom/$id';
  static String workroomMessages(String id) => '/mobile/workroom/$id/messages';
  static String workroomMembers(String id) => '/mobile/workroom/$id/members';

  // ─── Admin ───────────────────────────────────────────────────────────────
  static const String adminStats = '/mobile/admin/stats';
  static const String adminUsers = '/mobile/admin/users';
  static String adminUserById(String id) => '/mobile/admin/users/$id';
  static String adminToggleUserStatus(String id) => '/mobile/admin/users/$id/toggle-status';
  static const String adminCourses = '/mobile/admin/courses';
  static String adminCourseById(String id) => '/mobile/admin/courses/$id';
  static const String adminPayments = '/mobile/admin/payments';
  static const String adminReports = '/mobile/admin/reports';
  static const String adminSettings = '/mobile/admin/settings';

  // ─── SuperAdmin ──────────────────────────────────────────────────────────
  static const String superAdminStats = '/mobile/superadmin/stats';
  static const String superAdminRevenue = '/mobile/superadmin/revenue';
  static const String superAdminSchools = '/mobile/superadmin/schools';
  static String superAdminSchoolById(String id) => '/mobile/superadmin/schools/$id';
  static const String superAdminCreateSchool = '/mobile/superadmin/schools/create';
  static const String superAdminAssignPackage = '/mobile/superadmin/schools/assign-package';
  static const String superAdminUsers = '/mobile/superadmin/users';
  static const String superAdminAnalytics = '/mobile/superadmin/analytics';
  static const String superAdminSettings = '/mobile/superadmin/settings';
}
