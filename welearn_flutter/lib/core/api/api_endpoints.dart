class ApiEndpoints {
  // ── Auth / User ──────────────────────────────────────────────────────────
  static const String login = '/user/login';
  static const String register = '/user/register';
  static const String logout = '/user/logout';
  static const String refreshToken = '/user/refresh-token';
  static const String myProfile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String changePassword = '/user/change-password';
  static const String forgotPassword = '/user/forgot-password';
  static const String resetPassword = '/user/reset-password';
  static const String verifyEmail = '/user/verify-email';
  static const String sendOtp = '/otp/send';
  static const String verifyOtp = '/otp/verify';

  // ── FCM ─────────────────────────────────────────────────────────────────
  static const String registerFcmToken = '/fcm/register';
  static const String unregisterFcmToken = '/fcm/unregister';

  // ── Dashboard ────────────────────────────────────────────────────────────
  static const String dashboard = '/dashboard';
  static const String adminDashboard = '/admin/dashboard';

  // ── Courses ──────────────────────────────────────────────────────────────
  static const String courses = '/course';
  static String courseDetail(String id) => '/course/$id';
  static const String courseCategories = '/course-categories';
  static const String courseSubCategories = '/course-sub-categories';
  static const String myCourses = '/enrollments/my';
  static const String enrollments = '/enrollments';
  static String enrollment(String id) => '/enrollments/$id';
  static const String purchaseCourse = '/purchase';

  // ── Modules & Lectures ───────────────────────────────────────────────────
  static const String modules = '/modules';
  static String modulesByCourse(String courseId) => '/modules?courseId=$courseId';
  static String moduleDetail(String id) => '/modules/$id';
  static const String lectures = '/lectures';
  static String lecturesByModule(String moduleId) => '/lectures?moduleId=$moduleId';
  static String lectureDetail(String id) => '/lectures/$id';
  static const String courseProgress = '/progress';
  static String courseProgressById(String id) => '/progress/$id';

  // ── Assessments & Assignments ────────────────────────────────────────────
  static const String assessments = '/assessments';
  static String assessmentDetail(String id) => '/assessments/$id';
  static const String assignments = '/assignments';
  static String assignmentDetail(String id) => '/assignments/$id';
  static const String submissions = '/submissions';
  static String submissionsByAssignment(String id) => '/submissions?assignmentId=$id';
  static const String mySubmissions = '/submissions/my';

  // ── Batches ──────────────────────────────────────────────────────────────
  static const String batches = '/batches';
  static String batchDetail(String id) => '/batches/$id';
  static String batchesByCourse(String courseId) => '/batches?courseId=$courseId';

  // ── Counseling ───────────────────────────────────────────────────────────
  static const String sessions = '/sessions';
  static String sessionDetail(String id) => '/sessions/$id';
  static const String counselingBookings = '/counseling-booking';
  static String counselingBookingDetail(String id) => '/counseling-booking/$id';
  static const String counselingCategories = '/counseling-categories';
  static const String counselorTiers = '/counselor-tiers';
  static const String counselorSlots = '/counsellor-slot';
  static const String counselorProfile = '/counselor-profile';
  static const String counselorSetup = '/counselor-setup';
  static String generateAgoraToken(String sessionId) =>
      '/sessions/$sessionId/generate-token';

  // ── School ───────────────────────────────────────────────────────────────
  static const String school = '/school';
  static const String schoolStudents = '/school/students';
  static const String schoolTeachers = '/school/teachers';
  static const String schoolPolicy = '/schoolpolicy';
  static const String academicGroups = '/academic-groups';
  static const String newStudents = '/new-students';

  // ── Student Profile ──────────────────────────────────────────────────────
  static const String studentProfile = '/student';
  static const String studentMedicalHistory = '/student-medical-history';
  static const String studentDiagnoses = '/diagnosis';
  static String diagnosisDetail(String id) => '/diagnosis/$id';

  // ── Facilitator / Teacher ────────────────────────────────────────────────
  static const String facilitators = '/facilitator';
  static String facilitatorDetail(String id) => '/facilitator/$id';

  // ── Doctor ───────────────────────────────────────────────────────────────
  static const String doctor = '/doctor';
  static String doctorDetail(String id) => '/doctor/$id';

  // ── Parent ───────────────────────────────────────────────────────────────
  static const String parentProfile = '/parent-profile';

  // ── Individual ───────────────────────────────────────────────────────────
  static const String individuals = '/individuals';
  static const String individualProfile = '/individual-profile';
  static const String individualAcademicProfile = '/individualacademicprofile';

  // ── Payments ─────────────────────────────────────────────────────────────
  static const String payments = '/payments';
  static const String createOrder = '/payments/create-order';
  static const String verifyPayment = '/payments/verify';
  static const String paymentHistory = '/payments/my';
  static const String packages = '/package';
  static const String packageServices = '/package-services';
  static const String userPackages = '/user-packages';
  static const String discounts = '/discounts';
  static const String serviceOffers = '/service-offers';

  // ── Psychometric ─────────────────────────────────────────────────────────
  static const String psychometric = '/psychometric';
  static const String psychometricTests = '/psychometric/tests';
  static const String psychometricStart = '/psychometric/start';
  static const String psychometricSubmit = '/psychometric/submit';
  static const String psychometricResults = '/psychometric/results';

  // ── MindMatrix / Cosmos ──────────────────────────────────────────────────
  static const String cosmos = '/cosmos';
  static const String cosmosAstrology = '/cosmos/astrology';
  static const String cosmosNumerology = '/cosmos/numerology';
  static const String cosmosReport = '/cosmos/report';
  static const String cosmosMyReports = '/cosmos/my-reports';

  // ── AI ───────────────────────────────────────────────────────────────────
  static const String ai = '/ai';
  static const String aiChat = '/ai/chat';
  static const String aiCareerGuide = '/ai/career-guide';

  // ── Certificates ─────────────────────────────────────────────────────────
  static const String certificates = '/certificates';
  static const String myCertificates = '/certificates/my';

  // ── Reviews & Feedback ───────────────────────────────────────────────────
  static const String reviews = '/reviews';
  static String reviewsByCourse(String id) => '/reviews?courseId=$id';
  static const String feedback = '/feedback';

  // ── Reports ──────────────────────────────────────────────────────────────
  static const String reports = '/reports';
  static const String myReports = '/reports/my';

  // ── Documents ────────────────────────────────────────────────────────────
  static const String documents = '/documents';
  static const String myDocuments = '/documents/my';

  // ── WorkRoom ─────────────────────────────────────────────────────────────
  static const String workroom = '/workroom';

  // ── Leave ────────────────────────────────────────────────────────────────
  static const String leaves = '/leaves';

  // ── Admin ────────────────────────────────────────────────────────────────
  static const String adminUsers = '/admin/users';
  static const String adminCourses = '/admin/courses';
  static const String adminReports = '/admin/reports';
  static const String adminPayments = '/admin/payments';

  // ── SuperAdmin ───────────────────────────────────────────────────────────
  static const String superAdminAdmins = '/superadmin/admins';
  static const String superAdminStats = '/superadmin/stats';
  static const String superAdminSchools = '/superadmin/schools';
  static const String superAdminPackages = '/superadmin/packages';
}
