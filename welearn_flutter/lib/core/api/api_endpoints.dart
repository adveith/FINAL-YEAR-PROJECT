class ApiEndpoints {
  // ─── Auth / User ────────────────────────────────────────────────────────────
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
  static const String fcmRegister = '/fcm/register';
  static const String fcmUnregister = '/fcm/unregister';

  // ─── Dashboard ───────────────────────────────────────────────────────────
  static const String dashboard = '/dashboard';

  // ─── Courses ─────────────────────────────────────────────────────────────
  static const String courses = '/courses';
  static String courseById(String id) => '/courses/$id';
  static String coursePublish(String id) => '/courses/$id/publish';
  static const String featuredCourses = '/courses/featured';
  static const String courseCategories = '/courses/categories';

  // ─── Modules / Lectures ──────────────────────────────────────────────────
  static String modules(String courseId) => '/courses/$courseId/modules';
  static String moduleById(String courseId, String moduleId) => '/courses/$courseId/modules/$moduleId';
  static String lectures(String courseId, String moduleId) => '/courses/$courseId/modules/$moduleId/lectures';
  static String lectureById(String courseId, String moduleId, String lectureId) => '/courses/$courseId/modules/$moduleId/lectures/$lectureId';
  static String lectureProgress(String lectureId) => '/lectures/$lectureId/progress';

  // ─── Enrollments ─────────────────────────────────────────────────────────
  static const String enrollments = '/enrollments';
  static const String myEnrollments = '/enrollments/my';
  static String enrollCourse(String courseId) => '/enrollments/$courseId';
  static String courseProgress(String enrollmentId) => '/enrollments/$enrollmentId/progress';

  // ─── Sessions ────────────────────────────────────────────────────────────
  static const String sessions = '/sessions';
  static const String mySessions = '/sessions/my';
  static String sessionById(String id) => '/sessions/$id';
  static const String agoraToken = '/sessions/agora-token';

  // ─── Counseling ──────────────────────────────────────────────────────────
  static const String counselingBooking = '/counseling-booking';
  static const String counselorSessions = '/counseling-booking/counselor';
  static const String counselorBookings = '/counseling-booking/pending';
  static String updateBookingStatus(String id) => '/counseling-booking/$id/status';
  static String bookingById(String id) => '/counseling-booking/$id';

  // ─── Assignments ─────────────────────────────────────────────────────────
  static const String assignments = '/assignments';
  static const String myAssignments = '/assignments/my';
  static String assignmentById(String id) => '/assignments/$id';
  static String submitAssignment(String id) => '/assignments/$id/submit';
  static const String mySubmissions = '/submissions/my';
  static String submissionById(String id) => '/submissions/$id';
  static String gradeSubmission(String id) => '/submissions/$id/grade';

  // ─── Assessments ─────────────────────────────────────────────────────────
  static const String assessments = '/assessments';
  static String assessmentById(String id) => '/assessments/$id';
  static String startAssessment(String id) => '/assessments/$id/start';
  static String submitAssessment(String id) => '/assessments/$id/submit';

  // ─── Psychometric ────────────────────────────────────────────────────────
  static const String psychometricTests = '/psychometric/tests';
  static const String psychometricResults = '/psychometric/results';
  static String startPsychometric(String testId) => '/psychometric/$testId/start';
  static String submitPsychometric(String testId) => '/psychometric/$testId/submit';

  // ─── MindMatrix / Cosmos ─────────────────────────────────────────────────
  static const String cosmosMyReports = '/cosmos/my-reports';
  static const String cosmosAstrology = '/cosmos/astrology';
  static const String cosmosNumerology = '/cosmos/numerology';
  static const String cosmosCombined = '/cosmos/combined';
  static String cosmosReportById(String id) => '/cosmos/reports/$id';

  // ─── School ──────────────────────────────────────────────────────────────
  static const String schoolStudents = '/school/students';
  static const String schoolAddStudent = '/school/students/add';
  static const String schoolTeachers = '/school/teachers';
  static const String schoolAddTeacher = '/school/teachers/add';
  static const String schoolBulkImport = '/school/students/bulk-import';
  static const String schoolMarks = '/school/marks';
  static const String schoolReports = '/school/reports';
  static const String schoolAttendance = '/school/attendance';

  // ─── Facilitator / Teacher ───────────────────────────────────────────────
  static const String facilitatorCourses = '/facilitator/courses';
  static const String facilitatorStudents = '/facilitator/students';
  static const String facilitatorBatches = '/facilitator/batches';

  // ─── Doctor ──────────────────────────────────────────────────────────────
  static const String doctorPatients = '/doctor/patients';
  static const String doctorAppointments = '/doctor/appointments';
  static const String doctorDiagnosis = '/doctor/diagnosis';
  static String doctorPatientById(String id) => '/doctor/patients/$id';

  // ─── Parent ──────────────────────────────────────────────────────────────
  static const String parentChildren = '/parent/children';
  static const String parentLinkChild = '/parent/children/link';
  static String parentChildProgress(String childId) => '/parent/children/$childId/progress';

  // ─── Individual ──────────────────────────────────────────────────────────
  static const String individualProfile = '/individual/profile';
  static const String individualSessions = '/individual/sessions';

  // ─── Payments ────────────────────────────────────────────────────────────
  static const String myPayments = '/payments/my';
  static const String createOrder = '/payments/create-order';
  static const String verifyPayment = '/payments/verify';
  static const String paymentById = '/payments';

  // ─── Packages ────────────────────────────────────────────────────────────
  static const String packages = '/packages';
  static String packageById(String id) => '/packages/$id';

  // ─── Certificates ────────────────────────────────────────────────────────
  static const String certificates = '/certificates';
  static String certificateById(String id) => '/certificates/$id';
  static String downloadCertificate(String id) => '/certificates/$id/download';

  // ─── WorkRoom ────────────────────────────────────────────────────────────
  static const String workrooms = '/workroom';
  static String workroomById(String id) => '/workroom/$id';
  static String workroomMessages(String id) => '/workroom/$id/messages';
  static String workroomMembers(String id) => '/workroom/$id/members';

  // ─── Leave / Attendance ──────────────────────────────────────────────────
  static const String leaveRequests = '/leave';
  static const String myLeaveRequests = '/leave/my';
  static String leaveById(String id) => '/leave/$id';

  // ─── AI ──────────────────────────────────────────────────────────────────
  static const String aiChat = '/ai/chat';
  static const String aiRecommendations = '/ai/recommendations';

  // ─── Reviews ─────────────────────────────────────────────────────────────
  static String courseReviews(String courseId) => '/courses/$courseId/reviews';
  static String submitReview(String courseId) => '/courses/$courseId/reviews';

  // ─── Documents ───────────────────────────────────────────────────────────
  static const String documents = '/documents';
  static String documentById(String id) => '/documents/$id';

  // ─── Admin ───────────────────────────────────────────────────────────────
  static const String adminStats = '/admin/stats';
  static const String adminUsers = '/admin/users';
  static String adminUserById(String id) => '/admin/users/$id';
  static String adminToggleUserStatus(String id) => '/admin/users/$id/toggle-status';
  static const String adminCourses = '/admin/courses';
  static String adminCourseById(String id) => '/admin/courses/$id';
  static const String adminPayments = '/admin/payments';
  static const String adminReports = '/admin/reports';
  static const String adminSettings = '/admin/settings';

  // ─── SuperAdmin ──────────────────────────────────────────────────────────
  static const String superAdminStats = '/superadmin/stats';
  static const String superAdminRevenue = '/superadmin/revenue';
  static const String superAdminSchools = '/superadmin/schools';
  static String superAdminSchoolById(String id) => '/superadmin/schools/$id';
  static const String superAdminCreateSchool = '/superadmin/schools/create';
  static const String superAdminAssignPackage = '/superadmin/schools/assign-package';
  static const String superAdminUsers = '/superadmin/users';
  static const String superAdminAnalytics = '/superadmin/analytics';
  static const String superAdminSettings = '/superadmin/settings';

  // ─── Batches ─────────────────────────────────────────────────────────────
  static const String batches = '/batches';
  static String batchById(String id) => '/batches/$id';
  static String batchStudents(String id) => '/batches/$id/students';
}
