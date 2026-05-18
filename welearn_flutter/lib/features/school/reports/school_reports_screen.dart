import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final _schoolReportsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.schoolReports);
  return res.data as Map<String, dynamic>;
});

class SchoolReportsScreen extends ConsumerWidget {
  const SchoolReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_schoolReportsProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Analytics')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) {
          final enrollmentByMonth = data['enrollmentByMonth'] as List<dynamic>? ?? [];
          final subjectPerformance = data['subjectPerformance'] as List<dynamic>? ?? [];

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_schoolReportsProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Enrollment Trend', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (enrollmentByMonth.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
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
                                if (idx < 0 || idx >= enrollmentByMonth.length) return const SizedBox.shrink();
                                final m = enrollmentByMonth[idx] as Map<String, dynamic>;
                                return Text(m['month'] as String? ?? '', style: const TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: enrollmentByMonth.asMap().entries.map((e) {
                              final m = e.value as Map<String, dynamic>;
                              return FlSpot(e.key.toDouble(), (m['count'] as num? ?? 0).toDouble());
                            }).toList(),
                            isCurved: true,
                            color: colors.primary,
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: colors.primary.withOpacity(0.15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Text('Subject Performance', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...subjectPerformance.map((s) {
                  final sub = s as Map<String, dynamic>;
                  final avg = (sub['avgScore'] as num? ?? 0).toDouble();
                  final subject = sub['subject'] as String? ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(subject, style: const TextStyle(fontWeight: FontWeight.w500)),
                            Text('${avg.toStringAsFixed(1)}%', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: avg / 100,
                          backgroundColor: colors.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation(colors.primary),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
