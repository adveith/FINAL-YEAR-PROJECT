import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final _counselorAllSessionsProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.counselorSessions);
  final data = res.data as Map<String, dynamic>;
  return data['sessions'] as List<dynamic>? ?? [];
});

class CounselorSessionsScreen extends ConsumerWidget {
  const CounselorSessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_counselorAllSessionsProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Sessions'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Live'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (sessions) {
            final now = DateTime.now();
            final upcoming = sessions.where((s) {
              final m = s as Map<String, dynamic>;
              final start = DateTime.tryParse(m['startTime'] as String? ?? '');
              final end = DateTime.tryParse(m['endTime'] as String? ?? '');
              return start != null && start.isAfter(now);
            }).toList();
            final live = sessions.where((s) {
              final m = s as Map<String, dynamic>;
              final start = DateTime.tryParse(m['startTime'] as String? ?? '');
              final end = DateTime.tryParse(m['endTime'] as String? ?? '');
              return start != null && end != null && start.isBefore(now) && end.isAfter(now);
            }).toList();
            final completed = sessions.where((s) {
              final m = s as Map<String, dynamic>;
              final end = DateTime.tryParse(m['endTime'] as String? ?? '');
              return end != null && end.isBefore(now);
            }).toList();

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(_counselorAllSessionsProvider),
              child: TabBarView(
                children: [
                  _buildSessionList(context, upcoming, 'No upcoming sessions'),
                  _buildSessionList(context, live, 'No live sessions', isLive: true),
                  _buildSessionList(context, completed, 'No completed sessions'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSessionList(BuildContext context, List<dynamic> sessions, String empty, {bool isLive = false}) {
    if (sessions.isEmpty) return Center(child: Text(empty, style: const TextStyle(color: Colors.grey)));
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) => _CounselorSessionCard(session: sessions[i] as Map<String, dynamic>, isLive: isLive),
    );
  }
}

class _CounselorSessionCard extends StatelessWidget {
  const _CounselorSessionCard({required this.session, this.isLive = false});
  final Map<String, dynamic> session;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final studentData = session['student'];
    final studentName = studentData is Map ? studentData['name'] as String? ?? 'Student' : 'Student';
    final start = DateTime.tryParse(session['startTime'] as String? ?? '');
    final end = DateTime.tryParse(session['endTime'] as String? ?? '');
    final channelName = session['channelName'] as String? ?? session['_id'] as String? ?? '';
    final notes = session['notes'] as String? ?? '';
    final status = session['status'] as String? ?? 'pending';

    Color statusColor;
    switch (status) {
      case 'confirmed': statusColor = Colors.green; break;
      case 'cancelled': statusColor = Colors.red; break;
      case 'completed': statusColor = Colors.blue; break;
      default: statusColor = Colors.orange;
    }

    String timeStr = 'TBD';
    if (start != null) {
      timeStr = '${start.day}/${start.month}/${start.year} • ${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
      if (end != null) timeStr += ' - ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isLive)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                    child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                Expanded(
                  child: Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(status.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(timeStr, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(notes, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13)),
            ],
            if (isLive || status == 'confirmed') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.push('/video-call/$channelName'),
                      icon: const Icon(Icons.video_call, size: 18),
                      label: const Text('Join Session'),
                      style: FilledButton.styleFrom(backgroundColor: isLive ? Colors.green : colors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
