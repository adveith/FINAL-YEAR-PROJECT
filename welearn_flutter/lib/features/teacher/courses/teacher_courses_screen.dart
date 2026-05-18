import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final _teacherCoursesListProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.facilitatorCourses);
  final data = res.data as Map<String, dynamic>;
  return data['courses'] as List<dynamic>? ?? [];
});

class TeacherCoursesScreen extends ConsumerWidget {
  const TeacherCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_teacherCoursesListProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Course',
            onPressed: () => _showCreateCourseSheet(context, ref),
          ),
        ],
      ),
      body: async.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, __) => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
          ),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (courses) {
          if (courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_add, size: 64, color: colors.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('No courses yet', style: theme.textTheme.titleMedium?.copyWith(color: colors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => _showCreateCourseSheet(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Create First Course'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_teacherCoursesListProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final course = courses[i] as Map<String, dynamic>;
                return _TeacherCourseCard(course: course, ref: ref);
              },
            ),
          );
        },
      ),
    );
  }

  void _showCreateCourseSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CreateCourseSheet(ref: ref),
    );
  }
}

class _TeacherCourseCard extends StatelessWidget {
  const _TeacherCourseCard({required this.course, required this.ref});
  final Map<String, dynamic> course;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final title = course['title'] as String? ?? 'Untitled';
    final desc = course['description'] as String? ?? '';
    final enrolled = course['enrolledCount'] as int? ?? 0;
    final isPublished = course['isPublished'] as bool? ?? false;
    final price = course['price'] as num? ?? 0;
    final rating = (course['averageRating'] as num?)?.toStringAsFixed(1) ?? '0.0';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPublished ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isPublished ? 'Live' : 'Draft',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isPublished ? Colors.green.shade700 : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
            if (desc.isNotEmpty) ...
              [const SizedBox(height: 4), Text(desc, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis)],
            const SizedBox(height: 12),
            Row(
              children: [
                _CourseStat(icon: Icons.people, value: '$enrolled students'),
                const SizedBox(width: 16),
                _CourseStat(icon: Icons.star, value: '$rating'),
                const SizedBox(width: 16),
                _CourseStat(icon: Icons.currency_rupee, value: price == 0 ? 'Free' : '₹$price'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showModulesSheet(context),
                    child: const Text('Modules'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _togglePublish(context),
                    child: Text(isPublished ? 'Unpublish' : 'Publish'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showModulesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ModulesSheet(courseId: course['_id'] as String? ?? ''),
    );
  }

  Future<void> _togglePublish(BuildContext context) async {
    try {
      final client = ref.read(apiClientProvider);
      final id = course['_id'] as String? ?? '';
      await client.patch('${ApiEndpoints.courseById(id)}/publish', data: {});
      ref.invalidate(_teacherCoursesListProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

class _CourseStat extends StatelessWidget {
  const _CourseStat({required this.icon, required this.value});
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _ModulesSheet extends ConsumerWidget {
  const _ModulesSheet({required this.courseId});
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesAsync = ref.watch(FutureProvider<List<dynamic>>((r) async {
      final client = r.read(apiClientProvider);
      final res = await client.get(ApiEndpoints.modules(courseId));
      final data = res.data as Map<String, dynamic>;
      return data['modules'] as List<dynamic>? ?? [];
    }).future);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, ctrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Course Modules', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: modulesAsync == null
                ? const Center(child: CircularProgressIndicator())
                : FutureBuilder<List<dynamic>>(
                    future: modulesAsync as Future<List<dynamic>>?,
                    builder: (_, snap) {
                      if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (!snap.hasData || snap.data!.isEmpty) return const Center(child: Text('No modules yet'));
                      return ListView.builder(
                        controller: ctrl,
                        itemCount: snap.data!.length,
                        itemBuilder: (ctx, i) {
                          final module = snap.data![i] as Map<String, dynamic>;
                          return ListTile(
                            leading: CircleAvatar(child: Text('${i + 1}')),
                            title: Text(module['title'] as String? ?? ''),
                            subtitle: Text('${(module['lectures'] as List?)?.length ?? 0} lectures'),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CreateCourseSheet extends ConsumerStatefulWidget {
  const _CreateCourseSheet({required this.ref});
  final WidgetRef ref;

  @override
  ConsumerState<_CreateCourseSheet> createState() => _CreateCourseSheetState();
}

class _CreateCourseSheetState extends ConsumerState<_CreateCourseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
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
              Text('Create Course', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (_error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer, borderRadius: BorderRadius.circular(8)),
                  child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
                ),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Course Title'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(labelText: 'Price (0 for free)', prefixText: '₹'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Create Course'),
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
      await client.post(ApiEndpoints.courses, data: {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': double.tryParse(_priceCtrl.text) ?? 0,
      });
      ref.invalidate(_teacherCoursesListProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }
}
