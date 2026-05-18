import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/course_card.dart';
import '../../auth/auth_provider.dart';

final _individualDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.dashboard);
  return res.data as Map<String, dynamic>;
});

final _individualEnrollmentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.myEnrollments);
  final data = res.data as Map<String, dynamic>;
  return data['enrollments'] as List<dynamic>? ?? [];
});

class IndividualDashboard extends ConsumerWidget {
  const IndividualDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(_individualDashboardProvider);
    final enrollmentsAsync = ref.watch(_individualEnrollmentsProvider);
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_individualDashboardProvider);
          ref.invalidate(_individualEnrollmentsProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Hi, ${user?.name?.split(' ').first ?? 'Learner'}!',
                            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text('Your personal learning hub', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  dashAsync.when(
                    loading: () => _ShimmerGrid(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (data) {
                      final stats = data['stats'] as Map<String, dynamic>? ?? {};
                      return GridView.count(
                        crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.5,
                        children: [
                          StatCard(title: 'Enrolled', value: '${stats['enrolledCourses'] ?? 0}', icon: Icons.play_lesson, color: colors.primary),
                          StatCard(title: 'Completed', value: '${stats['completedCourses'] ?? 0}', icon: Icons.check_circle, color: Colors.green),
                          StatCard(title: 'Hours Spent', value: '${stats['hoursSpent'] ?? 0}h', icon: Icons.timer, color: colors.secondary),
                          StatCard(title: 'Certificates', value: '${stats['certificates'] ?? 0}', icon: Icons.workspace_premium, color: Colors.amber),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Continue Learning', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () => context.go('/individual/courses'), child: const Text('Browse All')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  enrollmentsAsync.when(
                    loading: () => _ShimmerCourses(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (enrollments) {
                      if (enrollments.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: colors.surfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            children: [
                              Icon(Icons.school, size: 40, color: colors.onSurfaceVariant),
                              const SizedBox(height: 8),
                              Text('No courses enrolled yet', style: TextStyle(color: colors.onSurfaceVariant)),
                              const SizedBox(height: 12),
                              FilledButton(onPressed: () => context.go('/individual/courses'), child: const Text('Browse Courses')),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: enrollments.length > 3 ? 3 : enrollments.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) {
                          final e = enrollments[i] as Map<String, dynamic>;
                          final courseData = e['course'];
                          final course = courseData is Map<String, dynamic> ? courseData : <String, dynamic>{};
                          final progress = (e['progressPercentage'] as num?)?.toDouble() ?? 0;
                          return _EnrollmentCard(course: course, progress: progress);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('Quick Actions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _QuickAction(icon: Icons.video_call, label: 'Book Session', color: Colors.green, onTap: () => context.go('/individual/sessions'))),
                      const SizedBox(width: 12),
                      Expanded(child: _QuickAction(icon: Icons.auto_awesome, label: 'Cosmos', color: const Color(0xFF7C3AED), onTap: () => context.go('/individual/cosmos'))),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnrollmentCard extends StatelessWidget {
  const _EnrollmentCard({required this.course, required this.progress});
  final Map<String, dynamic> course;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final title = course['title'] as String? ?? 'Course';
    final instructor = course['instructor'];
    final instructorName = instructor is Map ? instructor['name'] as String? ?? '' : '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            if (instructorName.isNotEmpty) Text('by $instructorName', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(width: 10),
                Text('${progress.toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: colors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _ShimmerGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.5,
      children: List.generate(4, (_) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100,
        child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
      )),
    );
  }
}

class _ShimmerCourses extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: List.generate(3, (_) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100,
        child: Container(height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
      ),
    )));
  }
}
