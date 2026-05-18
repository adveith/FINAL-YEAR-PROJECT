import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../auth/auth_provider.dart';

final _parentDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.dashboard);
  return res.data as Map<String, dynamic>;
});

final _parentChildrenProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.parentChildren);
  final data = res.data as Map<String, dynamic>;
  return data['children'] as List<dynamic>? ?? [];
});

class ParentDashboard extends ConsumerWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(_parentDashboardProvider);
    final childrenAsync = ref.watch(_parentChildrenProvider);
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_parentDashboardProvider);
          ref.invalidate(_parentChildrenProvider);
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
                      colors: [Color(0xFFD97706), Color(0xFFDC2626)],
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
                            'Hello, ${user?.name?.split(' ').first ?? 'Parent'}!',
                            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text('Track your children\'s progress', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
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
                          StatCard(title: 'Children', value: '${stats['totalChildren'] ?? 0}', icon: Icons.child_care, color: colors.primary),
                          StatCard(title: 'Active Courses', value: '${stats['activeCourses'] ?? 0}', icon: Icons.menu_book, color: Colors.green),
                          StatCard(title: 'Sessions Done', value: '${stats['sessionsCompleted'] ?? 0}', icon: Icons.video_call, color: colors.secondary),
                          StatCard(title: 'Avg Progress', value: '${stats['avgProgress'] ?? 0}%', icon: Icons.trending_up, color: Colors.orange),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('My Children', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () => context.go('/parent/children'), child: const Text('Manage')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  childrenAsync.when(
                    loading: () => _ShimmerList(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (children) {
                      if (children.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: colors.surfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            children: [
                              Icon(Icons.child_care, size: 40, color: colors.onSurfaceVariant),
                              const SizedBox(height: 8),
                              Text('No children linked yet', style: TextStyle(color: colors.onSurfaceVariant)),
                            ],
                          ),
                        );
                      }
                      return Column(
                        children: children.map((c) => _ChildProgressCard(child: c as Map<String, dynamic>)).toList(),
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

class _ChildProgressCard extends StatelessWidget {
  const _ChildProgressCard({required this.child});
  final Map<String, dynamic> child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final name = child['name'] as String? ?? 'Unknown';
    final grade = child['grade'] as String? ?? '';
    final progress = (child['overallProgress'] as num?)?.toDouble() ?? 0;
    final courses = child['enrolledCourses'] as int? ?? 0;
    final sessions = child['completedSessions'] as int? ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colors.primary.withOpacity(0.15),
                  child: Text(name[0].toUpperCase(), style: TextStyle(fontSize: 18, color: colors.primary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (grade.isNotEmpty) Text('Grade $grade', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13)),
                    ],
                  ),
                ),
                Text('${progress.toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colors.primary)),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
              minHeight: 8,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatPill(icon: Icons.menu_book, label: '$courses Courses', color: Colors.green)),
                const SizedBox(width: 8),
                Expanded(child: _StatPill(icon: Icons.video_call, label: '$sessions Sessions', color: colors.secondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
        ],
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

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: List.generate(3, (_) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100,
        child: Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
      ),
    )));
  }
}
