import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_provider.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/student/student_shell.dart';
import '../../features/school/school_shell.dart';
import '../../features/teacher/teacher_shell.dart';
import '../../features/counselor/counselor_shell.dart';
import '../../features/doctor/doctor_shell.dart';
import '../../features/parent/parent_shell.dart';
import '../../features/individual/individual_shell.dart';
import '../../features/admin/admin_shell.dart';
import '../../features/superadmin/superadmin_shell.dart';
import '../constants/app_constants.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoading = authState is AsyncLoading;
      final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;
      final location = state.uri.toString();

      if (isLoading) return '/splash';

      final isOnAuth = location == '/login' || location == '/register';

      if (!isAuthenticated && !isOnAuth && location != '/splash') {
        return '/login';
      }

      if (isAuthenticated && isOnAuth) {
        return _homeForRole(authState.valueOrNull?.user?.role);
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      // Student
      ShellRoute(
        builder: (_, state, child) => StudentShell(child: child),
        routes: [
          GoRoute(path: '/student/dashboard', builder: (_, __) => const StudentDashboardWrapper()),
          GoRoute(path: '/student/courses', builder: (_, __) => const StudentCoursesWrapper()),
          GoRoute(path: '/student/assignments', builder: (_, __) => const StudentAssignmentsWrapper()),
          GoRoute(path: '/student/appointments', builder: (_, __) => const StudentAppointmentsWrapper()),
          GoRoute(path: '/student/payments', builder: (_, __) => const StudentPaymentsWrapper()),
          GoRoute(path: '/student/psychometric', builder: (_, __) => const StudentPsychometricWrapper()),
          GoRoute(path: '/student/cosmos', builder: (_, __) => const StudentCosmosWrapper()),
          GoRoute(path: '/student/workroom', builder: (_, __) => const StudentWorkroomWrapper()),
        ],
      ),

      // School
      ShellRoute(
        builder: (_, state, child) => SchoolShell(child: child),
        routes: [
          GoRoute(path: '/school/dashboard', builder: (_, __) => const SchoolDashboardWrapper()),
          GoRoute(path: '/school/students', builder: (_, __) => const SchoolStudentsWrapper()),
          GoRoute(path: '/school/teachers', builder: (_, __) => const SchoolTeachersWrapper()),
          GoRoute(path: '/school/marks', builder: (_, __) => const SchoolMarksWrapper()),
        ],
      ),

      // Teacher
      ShellRoute(
        builder: (_, state, child) => TeacherShell(child: child),
        routes: [
          GoRoute(path: '/teacher/dashboard', builder: (_, __) => const TeacherDashboardWrapper()),
          GoRoute(path: '/teacher/courses', builder: (_, __) => const TeacherCoursesWrapper()),
          GoRoute(path: '/teacher/sessions', builder: (_, __) => const TeacherSessionsWrapper()),
        ],
      ),

      // Counselor
      ShellRoute(
        builder: (_, state, child) => CounselorShell(child: child),
        routes: [
          GoRoute(path: '/counselor/dashboard', builder: (_, __) => const CounselorDashboardWrapper()),
          GoRoute(path: '/counselor/sessions', builder: (_, __) => const CounselorSessionsWrapper()),
          GoRoute(path: '/counselor/bookings', builder: (_, __) => const CounselorBookingsWrapper()),
        ],
      ),

      // Doctor
      ShellRoute(
        builder: (_, state, child) => DoctorShell(child: child),
        routes: [
          GoRoute(path: '/doctor/dashboard', builder: (_, __) => const DoctorDashboardWrapper()),
          GoRoute(path: '/doctor/patients', builder: (_, __) => const DoctorPatientsWrapper()),
        ],
      ),

      // Parent
      ShellRoute(
        builder: (_, state, child) => ParentShell(child: child),
        routes: [
          GoRoute(path: '/parent/dashboard', builder: (_, __) => const ParentDashboardWrapper()),
          GoRoute(path: '/parent/children', builder: (_, __) => const ParentChildrenWrapper()),
        ],
      ),

      // Individual
      ShellRoute(
        builder: (_, state, child) => IndividualShell(child: child),
        routes: [
          GoRoute(path: '/individual/dashboard', builder: (_, __) => const IndividualDashboardWrapper()),
          GoRoute(path: '/individual/courses', builder: (_, __) => const IndividualCoursesWrapper()),
        ],
      ),

      // Admin
      ShellRoute(
        builder: (_, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/admin/dashboard', builder: (_, __) => const AdminDashboardWrapper()),
          GoRoute(path: '/admin/users', builder: (_, __) => const AdminUsersWrapper()),
          GoRoute(path: '/admin/courses', builder: (_, __) => const AdminCoursesWrapper()),
        ],
      ),

      // SuperAdmin
      ShellRoute(
        builder: (_, state, child) => SuperAdminShell(child: child),
        routes: [
          GoRoute(path: '/superadmin/dashboard', builder: (_, __) => const SuperAdminDashboardWrapper()),
          GoRoute(path: '/superadmin/schools', builder: (_, __) => const SuperAdminSchoolsWrapper()),
          GoRoute(path: '/superadmin/packages', builder: (_, __) => const SuperAdminPackagesWrapper()),
        ],
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});

String _homeForRole(String? role) {
  switch (role) {
    case AppConstants.roleStudent:
      return '/student/dashboard';
    case AppConstants.roleSchool:
      return '/school/dashboard';
    case AppConstants.roleFacilitator:
      return '/teacher/dashboard';
    case AppConstants.roleCounselor:
      return '/counselor/dashboard';
    case AppConstants.roleDoctor:
      return '/doctor/dashboard';
    case AppConstants.roleParent:
      return '/parent/dashboard';
    case AppConstants.roleIndividual:
      return '/individual/dashboard';
    case AppConstants.roleAdmin:
      return '/admin/dashboard';
    case AppConstants.roleSuperAdmin:
      return '/superadmin/dashboard';
    default:
      return '/login';
  }
}

// Route wrappers (placeholder builders that resolve to actual screens)
class StudentDashboardWrapper extends StatelessWidget {
  const StudentDashboardWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class StudentCoursesWrapper extends StatelessWidget {
  const StudentCoursesWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class StudentAssignmentsWrapper extends StatelessWidget {
  const StudentAssignmentsWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class StudentAppointmentsWrapper extends StatelessWidget {
  const StudentAppointmentsWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class StudentPaymentsWrapper extends StatelessWidget {
  const StudentPaymentsWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class StudentPsychometricWrapper extends StatelessWidget {
  const StudentPsychometricWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class StudentCosmosWrapper extends StatelessWidget {
  const StudentCosmosWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class StudentWorkroomWrapper extends StatelessWidget {
  const StudentWorkroomWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class SchoolDashboardWrapper extends StatelessWidget {
  const SchoolDashboardWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class SchoolStudentsWrapper extends StatelessWidget {
  const SchoolStudentsWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class SchoolTeachersWrapper extends StatelessWidget {
  const SchoolTeachersWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class SchoolMarksWrapper extends StatelessWidget {
  const SchoolMarksWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class TeacherDashboardWrapper extends StatelessWidget {
  const TeacherDashboardWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class TeacherCoursesWrapper extends StatelessWidget {
  const TeacherCoursesWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class TeacherSessionsWrapper extends StatelessWidget {
  const TeacherSessionsWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class CounselorDashboardWrapper extends StatelessWidget {
  const CounselorDashboardWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class CounselorSessionsWrapper extends StatelessWidget {
  const CounselorSessionsWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class CounselorBookingsWrapper extends StatelessWidget {
  const CounselorBookingsWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class DoctorDashboardWrapper extends StatelessWidget {
  const DoctorDashboardWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class DoctorPatientsWrapper extends StatelessWidget {
  const DoctorPatientsWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class ParentDashboardWrapper extends StatelessWidget {
  const ParentDashboardWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class ParentChildrenWrapper extends StatelessWidget {
  const ParentChildrenWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class IndividualDashboardWrapper extends StatelessWidget {
  const IndividualDashboardWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class IndividualCoursesWrapper extends StatelessWidget {
  const IndividualCoursesWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class AdminDashboardWrapper extends StatelessWidget {
  const AdminDashboardWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class AdminUsersWrapper extends StatelessWidget {
  const AdminUsersWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class AdminCoursesWrapper extends StatelessWidget {
  const AdminCoursesWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class SuperAdminDashboardWrapper extends StatelessWidget {
  const SuperAdminDashboardWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class SuperAdminSchoolsWrapper extends StatelessWidget {
  const SuperAdminSchoolsWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
class SuperAdminPackagesWrapper extends StatelessWidget {
  const SuperAdminPackagesWrapper({super.key});
  @override Widget build(BuildContext context) => const SizedBox();
}
