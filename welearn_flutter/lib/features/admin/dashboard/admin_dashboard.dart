import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../shared/widgets/stat_card.dart';

final _adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.adminStats);
  return res.data as Map<String, dynamic>;
});

final _adminRecentUsersProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.adminUsers, queryParameters: {'limit': '5', 'sort': '-createdAt'});
  final data = res.data as Map<String, dynamic>;
  return data['users'] as List<dynamic>? ?? [];
});

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(_adminStatsProvider);
    final usersAsync = ref.watch(_adminRecentUsersProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_adminStatsProvider);
          ref.invalidate(_adminRecentUsersProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colors.primary, colors.primary.withBlue(200)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Admin Dashboard', style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text('Platform overview', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
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
                  statsAsync.when(
                    loading: () => _ShimmerGrid(),
                    error: (e, _) => Text('Error: $e'),
                    data: (stats) => GridView.count(
                      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.4,
                      children: [
                        StatCard(title: 'Total Users', value: '${stats['totalUsers'] ?? 0}', icon: Icons.people, color: colors.primary),
                        StatCard(title: 'Total Courses', value: '${stats['totalCourses'] ?? 0}', icon: Icons.library_books, color: Colors.green),
                        StatCard(title: 'Revenue', value: '₹${_formatNum(stats['totalRevenue'])}', icon: Icons.currency_rupee, color: Colors.orange),
                        StatCard(title: 'Sessions', value: '${stats['totalSessions'] ?? 0}', icon: Icons.video_call, color: colors.secondary),
                        StatCard(title: 'Schools', value: '${stats['totalSchools'] ?? 0}', icon: Icons.account_balance, color: Colors.teal),
                        StatCard(title: 'Active Today', value: '${stats['activeToday'] ?? 0}', icon: Icons.trending_up, color: Colors.purple),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Quick Actions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2.5,
                    children: [
                      _AdminAction(icon: Icons.manage_accounts, label: 'Manage Users', color: colors.primary, onTap: () => context.go('/admin/users')),
                      _AdminAction(icon: Icons.library_books, label: 'Manage Courses', color: Colors.green, onTap: () => context.go('/admin/courses')),
                      _AdminAction(icon: Icons.receipt_long, label: 'Payments', color: Colors.orange, onTap: () => context.go('/admin/payments')),
                      _AdminAction(icon: Icons.settings, label: 'Settings', color: Colors.grey, onTap: () => context.go('/admin/settings')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Users', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () => context.go('/admin/users'), child: const Text('See All')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  usersAsync.when(
                    loading: () => Column(children: List.generate(4, (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100,
                        child: Container(height: 68, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                      ),
                    ))),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (users) => Column(
                      children: users.map((u) {
                        final user = u as Map<String, dynamic>;
                        final name = user['name'] as String? ?? 'Unknown';
                        final email = user['email'] as String? ?? '';
                        final role = user['role'] as String? ?? '';
                        final isActive = user['isActive'] as bool? ?? false;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: colors.primary.withOpacity(0.15),
                              child: Text(name[0].toUpperCase(), style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
                            ),
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('$email • $role'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(isActive ? 'Active' : 'Inactive', style: TextStyle(fontSize: 11, color: isActive ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNum(dynamic value) {
    if (value == null) return '0';
    final num = (value as num).toDouble();
    if (num >= 100000) return '${(num / 100000).toStringAsFixed(1)}L';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}K';
    return num.toStringAsFixed(0);
  }
}

class _AdminAction extends StatelessWidget {
  const _AdminAction({required this.icon, required this.label, required this.color, required this.onTap});
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
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 13)),
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
      mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.4,
      children: List.generate(6, (_) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100,
        child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
      )),
    );
  }
}
