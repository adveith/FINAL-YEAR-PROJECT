import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final _teacherSessionsListProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.mySessions);
  final data = res.data as Map<String, dynamic>;
  return data['sessions'] as List<dynamic>? ?? [];
});

class TeacherSessionsScreen extends ConsumerWidget {
  const TeacherSessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_teacherSessionsListProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sessions'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Live'),
              Tab(text: 'Past'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateSessionSheet(context, ref),
            ),
          ],
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
            final past = sessions.where((s) {
              final m = s as Map<String, dynamic>;
              final end = DateTime.tryParse(m['endTime'] as String? ?? '');
              return end != null && end.isBefore(now);
            }).toList();

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(_teacherSessionsListProvider),
              child: TabBarView(
                children: [
                  _SessionList(sessions: upcoming, emptyText: 'No upcoming sessions'),
                  _SessionList(sessions: live, emptyText: 'No live sessions', isLive: true),
                  _SessionList(sessions: past, emptyText: 'No past sessions'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCreateSessionSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CreateSessionSheet(ref: ref),
    );
  }
}

class _SessionList extends StatelessWidget {
  const _SessionList({required this.sessions, required this.emptyText, this.isLive = false});
  final List<dynamic> sessions;
  final String emptyText;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Center(child: Text(emptyText, style: const TextStyle(color: Colors.grey)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) => _SessionCard(session: sessions[i] as Map<String, dynamic>, isLive: isLive),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, this.isLive = false});
  final Map<String, dynamic> session;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final title = session['title'] as String? ?? 'Session';
    final start = DateTime.tryParse(session['startTime'] as String? ?? '');
    final end = DateTime.tryParse(session['endTime'] as String? ?? '');
    final channelName = session['channelName'] as String? ?? session['_id'] as String? ?? '';

    String timeStr = 'TBD';
    if (start != null) {
      timeStr = '${start.day}/${start.month}/${start.year} ${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    }
    String durationStr = '';
    if (start != null && end != null) {
      final duration = end.difference(start);
      durationStr = '${duration.inMinutes} min';
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
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(timeStr, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                if (durationStr.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  const Icon(Icons.timer, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(durationStr, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ],
            ),
            if (isLive) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.push('/video-call/$channelName'),
                  icon: const Icon(Icons.video_call),
                  label: const Text('Join Session'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CreateSessionSheet extends ConsumerStatefulWidget {
  const _CreateSessionSheet({required this.ref});
  final WidgetRef ref;

  @override
  ConsumerState<_CreateSessionSheet> createState() => _CreateSessionSheetState();
}

class _CreateSessionSheetState extends ConsumerState<_CreateSessionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  DateTime? _startTime;
  DateTime? _endTime;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Session', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (_error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: theme.colorScheme.errorContainer, borderRadius: BorderRadius.circular(8)),
                  child: Text(_error!, style: TextStyle(color: theme.colorScheme.onErrorContainer)),
                ),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Session Title'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                  if (date == null) return;
                  final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if (time == null) return;
                  setState(() => _startTime = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(_startTime == null ? 'Select Start Time' : '${_startTime!.day}/${_startTime!.month} ${_startTime!.hour}:${_startTime!.minute.toString().padLeft(2, '0')}'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(context: context, initialDate: _startTime ?? DateTime.now(), firstDate: _startTime ?? DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                  if (date == null) return;
                  final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if (time == null) return;
                  setState(() => _endTime = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                },
                icon: const Icon(Icons.access_time),
                label: Text(_endTime == null ? 'Select End Time' : '${_endTime!.day}/${_endTime!.month} ${_endTime!.hour}:${_endTime!.minute.toString().padLeft(2, '0')}'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Create Session'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startTime == null || _endTime == null) {
      setState(() => _error = 'Please select start and end times');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final client = ref.read(apiClientProvider);
      await client.post(ApiEndpoints.sessions, data: {
        'title': _titleCtrl.text.trim(),
        'startTime': _startTime!.toIso8601String(),
        'endTime': _endTime!.toIso8601String(),
      });
      ref.invalidate(_teacherSessionsListProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }
}
