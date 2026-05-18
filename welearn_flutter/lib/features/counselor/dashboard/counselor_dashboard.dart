import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../auth/auth_provider.dart';

final _counselorDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.dashboard);
  return res.data as Map<String, dynamic>;
});

final _counselorUpcomingProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.counselorSessions, queryParameters: {'status': 'confirmed', 'upcoming': 'true'});
  final data = res.data as Map<String, dynamic>;
  return data['sessions'] as List<dynamic>? ?? [];
});

class CounselorDashboard extends ConsumerWidget {
  const CounselorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(_counselorDashboardProvider);
    final upcomingAsync = ref.watch(_counselorUpcomingProvider);
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_counselorDashboardProvider);
          ref.invalidate(_counselorUpcomingProvider);
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
                      colors: [Color(0xFF059669), Color(0xFF0284C7)],
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
                            'Welcome, ${user?.name?.split(' ').first ?? 'Counselor'}',
                            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text('Counselor Dashboard', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
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
                          StatCard(title: 'Total Sessions', value: '${stats['totalSessions'] ?? 0}', icon: Icons.video_camera_front, color: colors.primary),
                          StatCard(title: 'This Month', value: '${stats['sessionsThisMonth'] ?? 0}', icon: Icons.calendar_month, color: Colors.green),
                          StatCard(title: 'Active Clients', value: '${stats['activeClients'] ?? 0}', icon: Icons.people, color: colors.secondary),
                          StatCard(title: 'Avg Rating', value: '${(stats['avgRating'] as num?)?.toStringAsFixed(1) ?? '0.0'}★', icon: Icons.star, color: Colors.amber),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Today\'s Sessions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () => context.go('/counselor/sessions'), child: const Text('View All')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  upcomingAsync.when(
                    loading: () => _ShimmerList(),
                    error: (e, _) => const SizedBox.shrink(),
                    data: (sessions) {
                      final today = sessions.where((s) {
                        final m = s as Map<String, dynamic>;
                        final start = DateTime.tryParse(m['startTime'] as String? ?? '');
                        final now = DateTime.now();
                        return start != null && start.day == now.day && start.month == now.month && start.year == now.year;
                      }).toList();

                      if (today.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colors.surfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(child: Text('No sessions scheduled for today')),
                        );
                      }

                      return Column(
                        children: today.map((s) => _SessionCard(session: s as Map<String, dynamic>)).toList(),
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

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});
  final Map<String, dynamic> session;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final studentData = session['student'];
    final studentName = studentData is Map ? studentData['name'] as String? ?? 'Student' : 'Student';
    final start = DateTime.tryParse(session['startTime'] as String? ?? '');
    final channelName = session['channelName'] as String? ?? session['_id'] as String? ?? '';
    final now = DateTime.now();
    final isLive = start != null && start.isBefore(now.add(const Duration(minutes: 5)));

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colors.primary.withOpacity(0.15),
              child: Text(studentName[0].toUpperCase(), style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(studentName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (start != null)
                    Text(
                      '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                    ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () => context.push('/video-call/$channelName'),
              icon: const Icon(Icons.video_call, size: 18),
              label: const Text('Join'),
              style: FilledButton.styleFrom(
                backgroundColor: isLive ? Colors.green : colors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
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
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: List.generate(4, (_) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
      )),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (_) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(height: 72, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
        ),
      )),
    );
  }
}
