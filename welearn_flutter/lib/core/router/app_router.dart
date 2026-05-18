import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_provider.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';

// Student
import '../../features/student/student_shell.dart';
import '../../features/student/dashboard/student_dashboard.dart';
import '../../features/student/courses/courses_screen.dart';
import '../../features/student/appointments/appointments_screen.dart';
import '../../features/student/psychometric/psychometric_screen.dart';
import '../../features/student/cosmos/cosmos_screen.dart';
import '../../features/student/assignments/assignments_screen.dart';
import '../../features/student/payments/payments_screen.dart';
import '../../features/student/workroom/workroom_screen.dart';

// School
import '../../features/school/school_shell.dart';
import '../../features/school/dashboard/school_dashboard.dart';
import '../../features/school/students/school_students_screen.dart';
import '../../features/school/teachers/school_teachers_screen.dart';
import '../../features/school/reports/school_reports_screen.dart';

// Teacher
import '../../features/teacher/teacher_shell.dart';
import '../../features/teacher/dashboard/teacher_dashboard.dart';
import '../../features/teacher/courses/teacher_courses_screen.dart';
import '../../features/teacher/sessions/teacher_sessions_screen.dart';
import '../../features/teacher/students/teacher_students_screen.dart';

// Counselor
import '../../features/counselor/counselor_shell.dart';
import '../../features/counselor/dashboard/counselor_dashboard.dart';
import '../../features/counselor/sessions/counselor_sessions_screen.dart';
import '../../features/counselor/bookings/counselor_bookings_screen.dart';

// Doctor
import '../../features/doctor/doctor_shell.dart';
import '../../features/doctor/dashboard/doctor_dashboard.dart';
import '../../features/doctor/patients/doctor_patients_screen.dart';

// Parent
import '../../features/parent/parent_shell.dart';
import '../../features/parent/dashboard/parent_dashboard.dart';
import '../../features/parent/children/parent_children_screen.dart';

// Individual
import '../../features/individual/individual_shell.dart';
import '../../features/individual/dashboard/individual_dashboard.dart';

// Admin
import '../../features/admin/admin_shell.dart';
import '../../features/admin/dashboard/admin_dashboard.dart';
import '../../features/admin/users/admin_users_screen.dart';

// SuperAdmin
import '../../features/superadmin/superadmin_shell.dart';
import '../../features/superadmin/dashboard/superadmin_dashboard.dart';
import '../../features/superadmin/schools/superadmin_schools_screen.dart';
import '../../features/superadmin/packages/superadmin_packages_screen.dart';

// Shared
import '../../features/shared/video_call/agora_video_call_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      if (isLoading) return null;

      final isAuth = authState.value?.isAuthenticated ?? false;
      final role = authState.value?.user?.role;
      final isSplash = state.matchedLocation == '/splash';
      final isAuth_ = state.matchedLocation.startsWith('/login') || state.matchedLocation.startsWith('/register');

      if (!isAuth && !isSplash && !isAuth_) return '/login';
      if (isAuth && isAuth_) return _homeForRole(role);
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      // Shared video call route (accessible from counselor, teacher, student)
      GoRoute(
        path: '/video-call/:channelName',
        builder: (_, state) => AgoraVideoCallScreen(channelName: state.pathParameters['channelName'] ?? ''),
      ),

      // ─── Student Shell ───────────────────────────────────────────────────
      ShellRoute(
        builder: (_, state, child) => StudentShell(child: child),
        routes: [
          GoRoute(path: '/student', builder: (_, __) => const StudentDashboard()),
          GoRoute(path: '/student/courses', builder: (_, __) => const CoursesScreen()),
          GoRoute(path: '/student/appointments', builder: (_, __) => const AppointmentsScreen()),
          GoRoute(path: '/student/psychometric', builder: (_, __) => const PsychometricScreen()),
          GoRoute(path: '/student/cosmos', builder: (_, __) => const CosmosScreen()),
          GoRoute(path: '/student/assignments', builder: (_, __) => const StudentAssignmentsScreen()),
          GoRoute(path: '/student/payments', builder: (_, __) => const StudentPaymentsScreen()),
          GoRoute(path: '/student/workroom', builder: (_, __) => const StudentWorkroomScreen()),
        ],
      ),

      // ─── School Shell ────────────────────────────────────────────────────
      ShellRoute(
        builder: (_, state, child) => SchoolShell(child: child),
        routes: [
          GoRoute(path: '/school', builder: (_, __) => const SchoolDashboard()),
          GoRoute(path: '/school/students', builder: (_, __) => const SchoolStudentsScreen()),
          GoRoute(path: '/school/teachers', builder: (_, __) => const SchoolTeachersScreen()),
          GoRoute(path: '/school/reports', builder: (_, __) => const SchoolReportsScreen()),
          GoRoute(path: '/school/settings', builder: (_, __) => const _PlaceholderScreen(title: 'School Settings')),
        ],
      ),

      // ─── Teacher Shell ───────────────────────────────────────────────────
      ShellRoute(
        builder: (_, state, child) => TeacherShell(child: child),
        routes: [
          GoRoute(path: '/teacher', builder: (_, __) => const TeacherDashboard()),
          GoRoute(path: '/teacher/courses', builder: (_, __) => const TeacherCoursesScreen()),
          GoRoute(path: '/teacher/sessions', builder: (_, __) => const TeacherSessionsScreen()),
          GoRoute(path: '/teacher/students', builder: (_, __) => const TeacherStudentsScreen()),
          GoRoute(path: '/teacher/profile', builder: (_, __) => const _PlaceholderScreen(title: 'Teacher Profile')),
        ],
      ),

      // ─── Counselor Shell ─────────────────────────────────────────────────
      ShellRoute(
        builder: (_, state, child) => CounselorShell(child: child),
        routes: [
          GoRoute(path: '/counselor', builder: (_, __) => const CounselorDashboard()),
          GoRoute(path: '/counselor/sessions', builder: (_, __) => const CounselorSessionsScreen()),
          GoRoute(path: '/counselor/bookings', builder: (_, __) => const CounselorBookingsScreen()),
          GoRoute(path: '/counselor/clients', builder: (_, __) => const _PlaceholderScreen(title: 'Clients')),
          GoRoute(path: '/counselor/profile', builder: (_, __) => const _PlaceholderScreen(title: 'Counselor Profile')),
        ],
      ),

      // ─── Doctor Shell ────────────────────────────────────────────────────
      ShellRoute(
        builder: (_, state, child) => DoctorShell(child: child),
        routes: [
          GoRoute(path: '/doctor', builder: (_, __) => const DoctorDashboard()),
          GoRoute(path: '/doctor/patients', builder: (_, __) => const DoctorPatientsScreen()),
          GoRoute(path: '/doctor/appointments', builder: (_, __) => const _PlaceholderScreen(title: 'Appointments')),
          GoRoute(path: '/doctor/reports', builder: (_, __) => const _PlaceholderScreen(title: 'Medical Reports')),
          GoRoute(path: '/doctor/profile', builder: (_, __) => const _PlaceholderScreen(title: 'Doctor Profile')),
        ],
      ),

      // ─── Parent Shell ────────────────────────────────────────────────────
      ShellRoute(
        builder: (_, state, child) => ParentShell(child: child),
        routes: [
          GoRoute(path: '/parent', builder: (_, __) => const ParentDashboard()),
          GoRoute(path: '/parent/children', builder: (_, __) => const ParentChildrenScreen()),
          GoRoute(path: '/parent/sessions', builder: (_, __) => const _PlaceholderScreen(title: 'Sessions')),
          GoRoute(path: '/parent/payments', builder: (_, __) => const _PlaceholderScreen(title: 'Payments')),
          GoRoute(path: '/parent/profile', builder: (_, __) => const _PlaceholderScreen(title: 'Parent Profile')),
        ],
      ),

      // ─── Individual Shell ────────────────────────────────────────────────
      ShellRoute(
        builder: (_, state, child) => IndividualShell(child: child),
        routes: [
          GoRoute(path: '/individual', builder: (_, __) => const IndividualDashboard()),
          GoRoute(path: '/individual/courses', builder: (_, __) => const CoursesScreen()),
          GoRoute(path: '/individual/sessions', builder: (_, __) => const AppointmentsScreen()),
          GoRoute(path: '/individual/cosmos', builder: (_, __) => const CosmosScreen()),
          GoRoute(path: '/individual/profile', builder: (_, __) => const _PlaceholderScreen(title: 'Profile')),
        ],
      ),

      // ─── Admin Shell ─────────────────────────────────────────────────────
      ShellRoute(
        builder: (_, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/admin', builder: (_, __) => const AdminDashboard()),
          GoRoute(path: '/admin/users', builder: (_, __) => const AdminUsersScreen()),
          GoRoute(path: '/admin/courses', builder: (_, __) => const _PlaceholderScreen(title: 'Course Management')),
          GoRoute(path: '/admin/payments', builder: (_, __) => const _PlaceholderScreen(title: 'Payment Reports')),
          GoRoute(path: '/admin/settings', builder: (_, __) => const _PlaceholderScreen(title: 'Admin Settings')),
        ],
      ),

      // ─── SuperAdmin Shell ────────────────────────────────────────────────
      ShellRoute(
        builder: (_, state, child) => SuperAdminShell(child: child),
        routes: [
          GoRoute(path: '/superadmin', builder: (_, __) => const SuperAdminDashboard()),
          GoRoute(path: '/superadmin/schools', builder: (_, __) => const SuperAdminSchoolsScreen()),
          GoRoute(path: '/superadmin/packages', builder: (_, __) => const SuperAdminPackagesScreen()),
          GoRoute(path: '/superadmin/analytics', builder: (_, __) => const _PlaceholderScreen(title: 'Platform Analytics')),
          GoRoute(path: '/superadmin/settings', builder: (_, __) => const _PlaceholderScreen(title: 'Global Settings')),
        ],
      ),
    ],
  );
});

String _homeForRole(String? role) {
  switch (role) {
    case 'student': return '/student';
    case 'school': return '/school';
    case 'facilitator': return '/teacher';
    case 'counselor': return '/counselor';
    case 'doctor': return '/doctor';
    case 'parent': return '/parent';
    case 'individual': return '/individual';
    case 'admin': return '/admin';
    case 'superadmin': return '/superadmin';
    default: return '/login';
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Coming soon', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
