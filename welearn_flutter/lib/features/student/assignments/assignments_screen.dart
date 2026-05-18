import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

final _assignmentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.myAssignments);
  final data = res.data as Map<String, dynamic>;
  return data['assignments'] as List<dynamic>? ?? [];
});

final _submissionsProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.mySubmissions);
  final data = res.data as Map<String, dynamic>;
  return data['submissions'] as List<dynamic>? ?? [];
});

class StudentAssignmentsScreen extends ConsumerWidget {
  const StudentAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(_assignmentsProvider);
    final submissionsAsync = ref.watch(_submissionsProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Assignments'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Pending'), Tab(text: 'Submitted')],
          ),
        ),
        body: TabBarView(
          children: [
            assignmentsAsync.when(
              loading: () => _ShimmerList(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (assignments) {
                final now = DateTime.now();
                final pending = assignments.where((a) {
                  final m = a as Map<String, dynamic>;
                  final dueDate = DateTime.tryParse(m['dueDate'] as String? ?? '');
                  final submitted = m['submitted'] as bool? ?? false;
                  return !submitted;
                }).toList();

                pending.sort((a, b) {
                  final aDate = DateTime.tryParse((a as Map)['dueDate'] as String? ?? '') ?? DateTime(2099);
                  final bDate = DateTime.tryParse((b as Map)['dueDate'] as String? ?? '') ?? DateTime(2099);
                  return aDate.compareTo(bDate);
                });

                if (pending.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt, size: 64, color: Colors.green),
                        const SizedBox(height: 16),
                        Text('All caught up!', style: theme.textTheme.titleMedium?.copyWith(color: colors.onSurfaceVariant)),
                        Text('No pending assignments', style: TextStyle(color: colors.onSurfaceVariant)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(_assignmentsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: pending.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) => _AssignmentCard(
                      assignment: pending[i] as Map<String, dynamic>,
                      onSubmit: () => _showSubmitSheet(ctx, ref, pending[i] as Map<String, dynamic>),
                    ),
                  ),
                );
              },
            ),
            submissionsAsync.when(
              loading: () => _ShimmerList(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (submissions) {
                if (submissions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment, size: 64, color: colors.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text('No submissions yet', style: TextStyle(color: colors.onSurfaceVariant)),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(_submissionsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: submissions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) => _SubmissionCard(submission: submissions[i] as Map<String, dynamic>),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSubmitSheet(BuildContext context, WidgetRef ref, Map<String, dynamic> assignment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SubmitAssignmentSheet(assignment: assignment, ref: ref),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.assignment, required this.onSubmit});
  final Map<String, dynamic> assignment;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final title = assignment['title'] as String? ?? 'Assignment';
    final desc = assignment['description'] as String? ?? '';
    final dueDate = DateTime.tryParse(assignment['dueDate'] as String? ?? '');
    final courseData = assignment['course'];
    final courseName = courseData is Map ? courseData['title'] as String? ?? '' : '';
    final now = DateTime.now();
    final isOverdue = dueDate != null && dueDate.isBefore(now);
    final isDueSoon = dueDate != null && !isOverdue && dueDate.difference(now).inDays <= 2;

    Color urgencyColor = Colors.grey;
    String urgencyLabel = 'Normal';
    if (isOverdue) { urgencyColor = Colors.red; urgencyLabel = 'Overdue'; }
    else if (isDueSoon) { urgencyColor = Colors.orange; urgencyLabel = 'Due Soon'; }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: urgencyColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(urgencyLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: urgencyColor)),
                ),
              ],
            ),
            if (courseName.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(courseName, style: TextStyle(color: colors.primary, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
            if (desc.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(desc, style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            if (dueDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: urgencyColor),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${dueDate.day}/${dueDate.month}/${dueDate.year} at ${dueDate.hour.toString().padLeft(2, '0')}:${dueDate.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 13, color: urgencyColor, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isOverdue ? null : onSubmit,
                icon: const Icon(Icons.upload_file, size: 18),
                label: Text(isOverdue ? 'Overdue - Contact Instructor' : 'Submit Assignment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({required this.submission});
  final Map<String, dynamic> submission;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final assignmentData = submission['assignment'];
    final title = assignmentData is Map ? assignmentData['title'] as String? ?? 'Assignment' : 'Assignment';
    final submittedAt = DateTime.tryParse(submission['submittedAt'] as String? ?? '');
    final grade = submission['grade'] as num?;
    final feedback = submission['feedback'] as String? ?? '';
    final status = submission['status'] as String? ?? 'submitted';

    Color statusColor;
    switch (status) {
      case 'graded': statusColor = Colors.green; break;
      case 'late': statusColor = Colors.orange; break;
      default: statusColor = Colors.blue;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(status.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                ),
              ],
            ),
            if (submittedAt != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Text('Submitted: ${submittedAt.day}/${submittedAt.month}/${submittedAt.year}', style: const TextStyle(fontSize: 13, color: Colors.green)),
                ],
              ),
            ],
            if (grade != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.primary.withOpacity(0.3)),
                    ),
                    child: Text('Grade: $grade', style: TextStyle(fontWeight: FontWeight.bold, color: colors.primary)),
                  ),
                ],
              ),
            ],
            if (feedback.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Instructor Feedback', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(feedback, style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SubmitAssignmentSheet extends ConsumerStatefulWidget {
  const _SubmitAssignmentSheet({required this.assignment, required this.ref});
  final Map<String, dynamic> assignment;
  final WidgetRef ref;

  @override
  ConsumerState<_SubmitAssignmentSheet> createState() => _SubmitAssignmentSheetState();
}

class _SubmitAssignmentSheetState extends ConsumerState<_SubmitAssignmentSheet> {
  final _notesCtrl = TextEditingController();
  PlatformFile? _selectedFile;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Submit Assignment', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(widget.assignment['title'] as String? ?? '', style: TextStyle(color: colors.onSurfaceVariant)),
            const SizedBox(height: 16),
            if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: colors.errorContainer, borderRadius: BorderRadius.circular(8)),
                child: Text(_error!, style: TextStyle(color: colors.onErrorContainer)),
              ),
            OutlinedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: Text(_selectedFile == null ? 'Attach File' : _selectedFile!.name),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes / Comments (optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  Future<void> _submit() async {
    final assignmentId = widget.assignment['_id'] as String? ?? '';
    setState(() { _loading = true; _error = null; });
    try {
      final client = ref.read(apiClientProvider);
      if (_selectedFile != null && _selectedFile!.path != null) {
        await client.uploadFile(
          ApiEndpoints.submitAssignment(assignmentId),
          filePath: _selectedFile!.path!,
          fieldName: 'file',
          data: {'notes': _notesCtrl.text.trim()},
        );
      } else {
        await client.post(ApiEndpoints.submitAssignment(assignmentId), data: {
          'notes': _notesCtrl.text.trim(),
        });
      }
      ref.invalidate(_assignmentsProvider);
      ref.invalidate(_submissionsProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }
}

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(height: 140, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
      ),
    );
  }
}
