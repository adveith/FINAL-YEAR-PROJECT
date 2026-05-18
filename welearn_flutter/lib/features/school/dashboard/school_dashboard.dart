import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/user_model.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../auth/auth_provider.dart';

final _schoolDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.dashboard);
  return res.data as Map<String, dynamic>;
});

final _schoolStudentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.schoolStudents);
  final data = res.data as Map<String, dynamic>;
  return data['students'] as List<dynamic>? ?? [];
});

class SchoolDashboard extends ConsumerWidget {
  const SchoolDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(_schoolDashboardProvider);
    final studentsAsync = ref.watch(_schoolStudentsProvider);
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_schoolDashboardProvider);
          ref.invalidate(_schoolStudentsProvider);
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
                      colors: [colors.primary, colors.secondary],
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
                            'School Portal',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user?.name ?? '',
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                          ),
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
                    loading: () => _ShimmerStats(),
                    error: (e, _) => _ErrorCard(message: e.toString()),
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
                          StatCard(
                            title: 'Total Students',
                            value: '${stats['totalStudents'] ?? 0}',
                            icon: Icons.people,
                            color: colors.primary,
                          ),
                          StatCard(
                            title: 'Teachers',
                            value: '${stats['totalTeachers'] ?? 0}',
                            icon: Icons.school,
                            color: colors.secondary,
                          ),
                          StatCard(
                            title: 'Active Courses',
                            value: '${stats['activeCourses'] ?? 0}',
                            icon: Icons.menu_book,
                            color: Colors.green,
                          ),
                          StatCard(
                            title: 'Avg Attendance',
                            value: '${stats['avgAttendance'] ?? 0}%',
                            icon: Icons.check_circle,
                            color: Colors.orange,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('Recent Students', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  studentsAsync.when(
                    loading: () => _ShimmerList(),
                    error: (e, _) => _ErrorCard(message: e.toString()),
                    data: (students) {
                      if (students.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('No students enrolled yet'),
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: students.length > 5 ? 5 : students.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) {
                          final s = students[i] as Map<String, dynamic>;
                          return ListTile(
                            tileColor: colors.surfaceVariant.withOpacity(0.3),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            leading: CircleAvatar(
                              backgroundColor: colors.primary.withOpacity(0.2),
                              child: Text(
                                (s['name'] as String? ?? 'S')[0].toUpperCase(),
                                style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(s['name'] as String? ?? ''),
                            subtitle: Text(s['email'] as String? ?? ''),
                            trailing: Chip(
                              label: Text(
                                s['isActive'] == true ? 'Active' : 'Inactive',
                                style: const TextStyle(fontSize: 11),
                              ),
                              backgroundColor: s['isActive'] == true
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.red.withOpacity(0.15),
                            ),
                          );
                        },
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

class _ShimmerStats extends StatelessWidget {
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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 64,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
      ),
    );
  }
}
