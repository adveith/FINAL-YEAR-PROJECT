import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../features/auth/auth_provider.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/course_card.dart';
import '../../../core/models/course_model.dart';
import '../../../core/theme/app_theme.dart';

final _dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.dashboard);
  return (res.data['data'] ?? res.data) as Map<String, dynamic>;
});

final _myCoursesProvider = FutureProvider<List<EnrollmentModel>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.myCourses, queryParameters: {'limit': '5'});
  final list = (res.data['data'] ?? res.data['enrollments'] ?? []) as List;
  return list.map((e) => EnrollmentModel.fromJson(e as Map<String, dynamic>)).toList();
});

class StudentDashboard extends ConsumerWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final dashboard = ref.watch(_dashboardProvider);
    final myCourses = ref.watch(_myCoursesProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_dashboardProvider);
          ref.invalidate(_myCoursesProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E40AF), Color(0xFF7C3AED)],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Hello, ${user?.name.split(' ').first ?? 'Learner'} 👋',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Keep learning, keep growing',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.white),
                  onPressed: () {},
                ),
                GestureDetector(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundImage: user?.profilePhoto != null
                          ? NetworkImage(user!.profilePhoto!)
                          : null,
                      child: user?.profilePhoto == null
                          ? Text(user?.name.substring(0, 1) ?? 'S')
                          : null,
                    ),
                  ),
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: dashboard.when(
                  loading: _buildStatsShimmer,
                  error: (e, _) => Text('Error: $e'),
                  data: (data) => _buildStats(data),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: _buildQuickActions(context),
              ),
            ),

            const SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Continue Learning',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: myCourses.when(
                loading: () => SliverToBoxAdapter(child: _buildCoursesShimmer()),
                error: (e, _) => SliverToBoxAdapter(child: Text('$e')),
                data: (enrollments) => enrollments.isEmpty
                    ? SliverToBoxAdapter(
                        child: _buildEmptyState(
                            context, 'No enrolled courses yet'))
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) {
                            final e = enrollments[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _EnrolledCourseCard(enrollment: e),
                            );
                          },
                          childCount: enrollments.length,
                        ),
                      ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(Map<String, dynamic> data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        StatCard(
          title: 'Courses Enrolled',
          value: '${data['enrolledCourses'] ?? data['totalEnrollments'] ?? 0}',
          icon: Icons.school_outlined,
          color: const Color(0xFF2563EB),
        ),
        StatCard(
          title: 'Sessions Done',
          value: '${data['completedSessions'] ?? data['totalSessions'] ?? 0}',
          icon: Icons.video_call_outlined,
          color: AppTheme.success,
        ),
        StatCard(
          title: 'Assignments',
          value: '${data['pendingAssignments'] ?? 0}',
          icon: Icons.assignment_outlined,
          color: AppTheme.warning,
          subtitle: 'Pending',
        ),
        StatCard(
          title: 'Certificates',
          value: '${data['certificates'] ?? 0}',
          icon: Icons.workspace_premium_outlined,
          color: AppTheme.cosmosGold,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _Action('Book Session', Icons.calendar_month_outlined,
          const Color(0xFF7C3AED), '/student/appointments'),
      _Action('Psychometric', Icons.psychology_outlined,
          const Color(0xFF059669), '/student/psychometric'),
      _Action('WorkRoom', Icons.work_outlined,
          const Color(0xFFDC2626), '/student/workroom'),
      _Action('Payments', Icons.payment_outlined,
          const Color(0xFFD97706), '/student/payments'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: actions
              .map((a) => Expanded(
                    child: GestureDetector(
                      onTap: () => context.go(a.route),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: a.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: a.color.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            Icon(a.icon, color: a.color, size: 24),
                            const SizedBox(height: 6),
                            Text(
                              a.label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: a.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildStatsShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
        children: List.generate(
          4,
          (_) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoursesShimmer() {
    return Column(
      children: List.generate(
        3,
        (_) => Shimmer.fromColors(
          baseColor: Colors.grey[200]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 90,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.school_outlined,
                size: 64, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(color: Color(0xFF94A3B8))),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/student/courses'),
              child: const Text('Browse Courses'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnrolledCourseCard extends StatelessWidget {
  final EnrollmentModel enrollment;
  const _EnrolledCourseCard({required this.enrollment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: enrollment.courseThumbnail != null
                ? Image.network(
                    enrollment.courseThumbnail!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enrollment.courseName ?? 'Course',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: enrollment.progressPercent / 100,
                    backgroundColor: const Color(0xFFE2E8F0),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${enrollment.progressPercent.toInt()}% complete',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
        width: 64,
        height: 64,
        color: const Color(0xFFEFF6FF),
        child: const Icon(Icons.school_outlined,
            size: 28, color: Color(0xFF93C5FD)),
      );
}

class _Action {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  const _Action(this.label, this.icon, this.color, this.route);
}
