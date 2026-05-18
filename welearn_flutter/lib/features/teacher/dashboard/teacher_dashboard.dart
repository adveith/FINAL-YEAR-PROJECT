import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../auth/auth_provider.dart';

final _teacherDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.dashboard);
  return res.data as Map<String, dynamic>;
});

final _teacherCoursesProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.facilitatorCourses);
  final data = res.data as Map<String, dynamic>;
  return data['courses'] as List<dynamic>? ?? [];
});

final _teacherSessionsProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.mySessions);
  final data = res.data as Map<String, dynamic>;
  return data['sessions'] as List<dynamic>? ?? [];
});

class TeacherDashboard extends ConsumerWidget {
  const TeacherDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(_teacherDashboardProvider);
    final coursesAsync = ref.watch(_teacherCoursesProvider);
    final sessionsAsync = ref.watch(_teacherSessionsProvider);
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_teacherDashboardProvider);
          ref.invalidate(_teacherCoursesProvider);
          ref.invalidate(_teacherSessionsProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [const Color(0xFF7C3AED), const Color(0xFF2563EB)],
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
                            'Welcome, ${user?.name?.split(' ').first ?? 'Teacher'}!',
                            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text('Facilitator Dashboard', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
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
                    error: (e, _) => const SizedBox.shrink(),
                    data: (data) {
                      final stats = data['stats'] as Map<String, dynamic>? ?? {};
                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.5,
                        children: [
                          StatCard(title: 'My Courses', value: '${stats['totalCourses'] ?? 0}', icon: Icons.menu_book, color: colors.primary),
                          StatCard(title: 'Students', value: '${stats['totalStudents'] ?? 0}', icon: Icons.people, color: colors.secondary),
                          StatCard(title: 'Sessions', value: '${stats['totalSessions'] ?? 0}', icon: Icons.video_call, color: Colors.green),
                          StatCard(title: 'Avg Rating', value: '${(stats['avgRating'] as num?)?.toStringAsFixed(1) ?? '0.0'}★', icon: Icons.star, color: Colors.amber),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('My Courses', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () => context.go('/teacher/courses'), child: const Text('See All')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  coursesAsync.when(
                    loading: () => _ShimmerList(),
                    error: (e, _) => const SizedBox.shrink(),
                    data: (courses) {
                      if (courses.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text('No courses yet'));
                      return Column(
                        children: courses.take(3).map((c) {
                          final course = c as Map<String, dynamic>;
                          return _CourseTile(course: course);
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Upcoming Sessions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () => context.go('/teacher/sessions'), child: const Text('See All')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  sessionsAsync.when(
                    loading: () => _ShimmerList(),
                    error: (e, _) => const SizedBox.shrink(),
                    data: (sessions) {
                      final upcoming = sessions.where((s) {
                        final m = s as Map<String, dynamic>;
                        final start = DateTime.tryParse(m['startTime'] as String? ?? '');
                        return start != null && start.isAfter(DateTime.now());
                      }).take(3).toList();
                      if (upcoming.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text('No upcoming sessions'));
                      return Column(
                        children: upcoming.map((s) {
                          final session = s as Map<String, dynamic>;
                          return _SessionTile(session: session);
                        }).toList(),
                      );
                    },
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

class _CourseTile extends StatelessWidget {
  const _CourseTile({required this.course});
  final Map<String, dynamic> course;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final title = course['title'] as String? ?? 'Untitled';
    final enrolled = course['enrolledCount'] as int? ?? 0;
    final isPublished = course['isPublished'] as bool? ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.menu_book, color: colors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$enrolled enrolled'),
        trailing: Chip(
          label: Text(isPublished ? 'Live' : 'Draft', style: const TextStyle(fontSize: 11)),
          backgroundColor: isPublished ? Colors.green.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});
  final Map<String, dynamic> session;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final title = session['title'] as String? ?? 'Session';
    final start = DateTime.tryParse(session['startTime'] as String? ?? '');
    final timeStr = start != null
        ? '${start.day}/${start.month} at ${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}'
        : 'TBD';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.video_call, color: Colors.green),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(timeStr),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _ShimmerGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: List.generate(
        4,
        (_) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
        ),
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(height: 68, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
          ),
        ),
      ),
    );
  }
}
