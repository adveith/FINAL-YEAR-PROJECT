import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final _facilitatorStudentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.facilitatorStudents);
  final data = res.data as Map<String, dynamic>;
  return data['students'] as List<dynamic>? ?? [];
});

class TeacherStudentsScreen extends ConsumerStatefulWidget {
  const TeacherStudentsScreen({super.key});

  @override
  ConsumerState<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends ConsumerState<TeacherStudentsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_facilitatorStudentsProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('My Students')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search students...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() { _query = ''; _searchCtrl.clear(); }))
                    : null,
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(height: 68, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                ),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (students) {
                final filtered = _query.isEmpty
                    ? students
                    : students.where((s) {
                        final m = s as Map<String, dynamic>;
                        return (m['name'] as String? ?? '').toLowerCase().contains(_query) ||
                            (m['email'] as String? ?? '').toLowerCase().contains(_query);
                      }).toList();

                if (filtered.isEmpty) return const Center(child: Text('No students found'));

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(_facilitatorStudentsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final s = filtered[i] as Map<String, dynamic>;
                      final name = s['name'] as String? ?? 'Unknown';
                      final email = s['email'] as String? ?? '';
                      final progress = (s['courseProgress'] as num?)?.toDouble() ?? 0;

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colors.primary.withOpacity(0.15),
                            child: Text(name[0].toUpperCase(), style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(email, style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: progress / 100,
                                      backgroundColor: colors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(4),
                                      minHeight: 6,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('${progress.toInt()}%', style: const TextStyle(fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
