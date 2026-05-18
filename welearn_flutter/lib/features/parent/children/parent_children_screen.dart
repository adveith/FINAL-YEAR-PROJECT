import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final _childrenDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, childId) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.parentChildProgress(childId));
  return res.data as Map<String, dynamic>;
});

final _allChildrenProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.parentChildren);
  final data = res.data as Map<String, dynamic>;
  return data['children'] as List<dynamic>? ?? [];
});

class ParentChildrenScreen extends ConsumerWidget {
  const ParentChildrenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_allChildrenProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Children\'s Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showLinkChildSheet(context, ref),
          ),
        ],
      ),
      body: async.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (_, __) => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          ),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (children) {
          if (children.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.child_care, size: 64, color: colors.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('No children linked', style: theme.textTheme.titleMedium?.copyWith(color: colors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => _showLinkChildSheet(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Link Child Account'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_allChildrenProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: children.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (ctx, i) {
                final child = children[i] as Map<String, dynamic>;
                final childId = child['_id'] as String? ?? '';
                return _ChildDetailCard(child: child, childId: childId);
              },
            ),
          );
        },
      ),
    );
  }

  void _showLinkChildSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _LinkChildSheet(ref: ref),
    );
  }
}

class _ChildDetailCard extends ConsumerWidget {
  const _ChildDetailCard({required this.child, required this.childId});
  final Map<String, dynamic> child;
  final String childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(_childrenDetailProvider(childId));
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final name = child['name'] as String? ?? 'Unknown';
    final grade = child['grade'] as String? ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colors.primary.withOpacity(0.15),
                  child: Text(name[0].toUpperCase(), style: TextStyle(fontSize: 20, color: colors.primary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      if (grade.isNotEmpty) Text('Grade $grade', style: TextStyle(color: colors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            detailAsync.when(
              loading: () => Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
              ),
              error: (e, _) => Text('Failed to load progress: $e', style: const TextStyle(color: Colors.red)),
              data: (detail) {
                final enrollments = detail['enrollments'] as List<dynamic>? ?? [];
                final overallProgress = (detail['overallProgress'] as num?)?.toDouble() ?? 0;
                final completedCourses = detail['completedCourses'] as int? ?? 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Overall Progress', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                        Text('${overallProgress.toInt()}%', style: TextStyle(fontWeight: FontWeight.bold, color: colors.primary, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: overallProgress / 100,
                      backgroundColor: colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 10,
                    ),
                    const SizedBox(height: 16),
                    Text('Enrolled Courses (${enrollments.length})', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ...enrollments.take(3).map((e) {
                      final enrollment = e as Map<String, dynamic>;
                      final courseData = enrollment['course'];
                      final courseTitle = courseData is Map ? courseData['title'] as String? ?? 'Course' : 'Course';
                      final progress = (enrollment['progressPercentage'] as num?)?.toDouble() ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(child: Text(courseTitle, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 100,
                              child: LinearProgressIndicator(
                                value: progress / 100,
                                backgroundColor: colors.surfaceVariant,
                                borderRadius: BorderRadius.circular(4),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('${progress.toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      );
                    }),
                    if (enrollments.length > 3)
                      Text('+${enrollments.length - 3} more courses', style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkChildSheet extends ConsumerStatefulWidget {
  const _LinkChildSheet({required this.ref});
  final WidgetRef ref;

  @override
  ConsumerState<_LinkChildSheet> createState() => _LinkChildSheetState();
}

class _LinkChildSheetState extends ConsumerState<_LinkChildSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              Text('Link Child Account', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Enter your child\'s registered email address', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              if (_error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer, borderRadius: BorderRadius.circular(8)),
                  child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
                ),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Child\'s Email', prefixIcon: Icon(Icons.email_outlined)),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Link Child'),
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
    setState(() { _loading = true; _error = null; });
    try {
      final client = ref.read(apiClientProvider);
      await client.post(ApiEndpoints.parentLinkChild, data: {'childEmail': _emailCtrl.text.trim()});
      ref.invalidate(_allChildrenProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }
}
