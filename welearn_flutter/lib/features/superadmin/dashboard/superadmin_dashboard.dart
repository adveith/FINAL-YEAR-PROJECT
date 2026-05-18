import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../shared/widgets/stat_card.dart';

final _superAdminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.superAdminStats);
  return res.data as Map<String, dynamic>;
});

final _superAdminRevenueProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.superAdminRevenue);
  final data = res.data as Map<String, dynamic>;
  return data['monthlyRevenue'] as List<dynamic>? ?? [];
});

class SuperAdminDashboard extends ConsumerWidget {
  const SuperAdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(_superAdminStatsProvider);
    final revenueAsync = ref.watch(_superAdminRevenueProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_superAdminStatsProvider);
          ref.invalidate(_superAdminRevenueProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0F172A), Color(0xFF1E3A5F)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.admin_panel_settings, color: Colors.amber, size: 28),
                              const SizedBox(width: 8),
                              Text('SuperAdmin', style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text('Platform Control Center', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white60)),
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
                    loading: () => _ShimmerGrid(count: 6),
                    error: (e, _) => Text('Error: $e'),
                    data: (stats) => GridView.count(
                      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.4,
                      children: [
                        StatCard(title: 'Total Schools', value: '${stats['totalSchools'] ?? 0}', icon: Icons.account_balance, color: colors.primary),
                        StatCard(title: 'Total Users', value: _fmt(stats['totalUsers']), icon: Icons.people, color: Colors.green),
                        StatCard(title: 'MRR', value: '₹${_fmtRevenue(stats['mrr'])}', icon: Icons.show_chart, color: Colors.orange),
                        StatCard(title: 'ARR', value: '₹${_fmtRevenue(stats['arr'])}', icon: Icons.bar_chart, color: colors.secondary),
                        StatCard(title: 'Active Packs', value: '${stats['activePackages'] ?? 0}', icon: Icons.card_membership, color: Colors.purple),
                        StatCard(title: 'Churn Rate', value: '${stats['churnRate'] ?? 0}%', icon: Icons.trending_down, color: Colors.red),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Revenue Trend', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  revenueAsync.when(
                    loading: () => Shimmer.fromColors(
                      baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100,
                      child: Container(height: 220, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (monthly) {
                      if (monthly.isEmpty) return const SizedBox.shrink();
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox(
                            height: 180,
                            child: BarChart(
                              BarChartData(
                                gridData: FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                titlesData: FlTitlesData(
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (v, meta) {
                                        final idx = v.toInt();
                                        if (idx < 0 || idx >= monthly.length) return const SizedBox.shrink();
                                        final m = monthly[idx] as Map<String, dynamic>;
                                        return Text(m['month'] as String? ?? '', style: const TextStyle(fontSize: 10));
                                      },
                                    ),
                                  ),
                                ),
                                barGroups: monthly.asMap().entries.map((e) {
                                  final m = e.value as Map<String, dynamic>;
                                  return BarChartGroupData(x: e.key, barRods: [
                                    BarChartRodData(
                                      toY: (m['revenue'] as num? ?? 0).toDouble(),
                                      color: colors.primary,
                                      width: 16,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                    ),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('Management', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.8,
                    children: [
                      _MgmtCard(icon: Icons.account_balance, label: 'Schools', sub: 'Manage all schools', color: colors.primary, onTap: () => context.go('/superadmin/schools')),
                      _MgmtCard(icon: Icons.card_membership, label: 'Packages', sub: 'Plans & pricing', color: Colors.orange, onTap: () => context.go('/superadmin/packages')),
                      _MgmtCard(icon: Icons.insights, label: 'Analytics', sub: 'Platform metrics', color: Colors.green, onTap: () => context.go('/superadmin/analytics')),
                      _MgmtCard(icon: Icons.admin_panel_settings, label: 'Settings', sub: 'Global config', color: Colors.grey, onTap: () => context.go('/superadmin/settings')),
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

  String _fmt(dynamic v) {
    if (v == null) return '0';
    final n = (v as num).toInt();
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)}L';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  String _fmtRevenue(dynamic v) {
    if (v == null) return '0';
    final n = (v as num).toDouble();
    if (n >= 10000000) return '${(n / 10000000).toStringAsFixed(2)}Cr';
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(2)}L';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toStringAsFixed(0);
  }
}

class _MgmtCard extends StatelessWidget {
  const _MgmtCard({required this.icon, required this.label, required this.sub, required this.color, required this.onTap});
  final IconData icon;
  final String label, sub;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _ShimmerGrid extends StatelessWidget {
  const _ShimmerGrid({required this.count});
  final int count;
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.4,
      children: List.generate(count, (_) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100,
        child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
      )),
    );
  }
}
