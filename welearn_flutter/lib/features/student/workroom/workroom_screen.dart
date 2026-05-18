import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final _workroomsProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.workrooms);
  final data = res.data as Map<String, dynamic>;
  return data['workrooms'] as List<dynamic>? ?? [];
});

final _workroomDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, workroomId) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.workroomById(workroomId));
  return res.data as Map<String, dynamic>;
});

class StudentWorkroomScreen extends ConsumerWidget {
  const StudentWorkroomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_workroomsProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('WorkRoom'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateWorkroomSheet(context, ref),
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
            child: Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
          ),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (workrooms) {
          if (workrooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.workspaces, size: 64, color: colors.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('No workrooms yet', style: theme.textTheme.titleMedium?.copyWith(color: colors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Text('Collaborative spaces for group learning', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13)),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _showCreateWorkroomSheet(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Create WorkRoom'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_workroomsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: workrooms.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => _WorkroomCard(
                workroom: workrooms[i] as Map<String, dynamic>,
                onTap: () => _openWorkroom(ctx, ref, workrooms[i] as Map<String, dynamic>),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateWorkroomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CreateWorkroomSheet(ref: ref),
    );
  }

  void _openWorkroom(BuildContext context, WidgetRef ref, Map<String, dynamic> workroom) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _WorkroomDetailPage(workroom: workroom)),
    );
  }
}

class _WorkroomCard extends StatelessWidget {
  const _WorkroomCard({required this.workroom, required this.onTap});
  final Map<String, dynamic> workroom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final name = workroom['name'] as String? ?? 'WorkRoom';
    final desc = workroom['description'] as String? ?? '';
    final members = workroom['members'] as List<dynamic>? ?? [];
    final type = workroom['type'] as String? ?? 'group';
    final isPrivate = workroom['isPrivate'] as bool? ?? false;

    Color typeColor;
    switch (type) {
      case 'study_group': typeColor = Colors.blue; break;
      case 'project': typeColor = Colors.purple; break;
      default: typeColor = colors.primary;
    }

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.workspaces, color: typeColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                            if (isPrivate) const Icon(Icons.lock, size: 14, color: Colors.grey),
                          ],
                        ),
                        if (desc.isNotEmpty) Text(desc, style: const TextStyle(fontSize: 13, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(type.replaceAll('_', ' ').toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: typeColor)),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.people, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${members.length} members', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkroomDetailPage extends ConsumerStatefulWidget {
  const _WorkroomDetailPage({required this.workroom});
  final Map<String, dynamic> workroom;

  @override
  ConsumerState<_WorkroomDetailPage> createState() => _WorkroomDetailPageState();
}

class _WorkroomDetailPageState extends ConsumerState<_WorkroomDetailPage> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<dynamic> _messages = [];
  bool _sendingMessage = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final client = ref.read(apiClientProvider);
      final workroomId = widget.workroom['_id'] as String? ?? '';
      final res = await client.get(ApiEndpoints.workroomMessages(workroomId));
      final data = res.data as Map<String, dynamic>;
      setState(() => _messages = data['messages'] as List<dynamic>? ?? []);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.workroom['name'] as String? ?? 'WorkRoom';
    final members = widget.workroom['members'] as List<dynamic>? ?? [];
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name),
            Text('${members.length} members', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () => _showMembersSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 48, color: colors.onSurfaceVariant),
                        const SizedBox(height: 8),
                        Text('No messages yet. Start the conversation!', style: TextStyle(color: colors.onSurfaceVariant)),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (ctx, i) {
                      final msg = _messages[i] as Map<String, dynamic>;
                      final sender = msg['sender'];
                      final senderName = sender is Map ? sender['name'] as String? ?? 'User' : 'User';
                      final content = msg['content'] as String? ?? '';
                      final createdAt = DateTime.tryParse(msg['createdAt'] as String? ?? '');
                      return _MessageBubble(senderName: senderName, content: content, time: createdAt);
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surface,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageCtrl,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: colors.surfaceVariant,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sendingMessage ? null : _sendMessage,
                  icon: _sendingMessage
                      ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sendingMessage = true);
    try {
      final client = ref.read(apiClientProvider);
      final workroomId = widget.workroom['_id'] as String? ?? '';
      await client.post(ApiEndpoints.workroomMessages(workroomId), data: {'content': text});
      _messageCtrl.clear();
      await _loadMessages();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        }
      });
    } catch (_) {}
    setState(() => _sendingMessage = false);
  }

  void _showMembersSheet(BuildContext context) {
    final members = widget.workroom['members'] as List<dynamic>? ?? [];
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(padding: const EdgeInsets.all(16), child: Text('Members (${members.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
          ...members.map((m) {
            final member = m as Map<String, dynamic>;
            final name = member['name'] as String? ?? 'Member';
            return ListTile(
              leading: CircleAvatar(child: Text(name[0].toUpperCase())),
              title: Text(name),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.senderName, required this.content, this.time});
  final String senderName;
  final String content;
  final DateTime? time;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: colors.primary.withOpacity(0.15),
            child: Text(senderName[0].toUpperCase(), style: TextStyle(fontSize: 12, color: colors.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(senderName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    if (time != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(content, style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateWorkroomSheet extends ConsumerStatefulWidget {
  const _CreateWorkroomSheet({required this.ref});
  final WidgetRef ref;

  @override
  ConsumerState<_CreateWorkroomSheet> createState() => _CreateWorkroomSheetState();
}

class _CreateWorkroomSheetState extends ConsumerState<_CreateWorkroomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _type = 'study_group';
  bool _isPrivate = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
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
              Text('Create WorkRoom', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (_error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer, borderRadius: BorderRadius.circular(8)),
                  child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
                ),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'WorkRoom Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'study_group', child: Text('Study Group')),
                  DropdownMenuItem(value: 'project', child: Text('Project Room')),
                  DropdownMenuItem(value: 'general', child: Text('General')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'study_group'),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _isPrivate,
                onChanged: (v) => setState(() => _isPrivate = v),
                title: const Text('Private Room'),
                subtitle: const Text('Only invited members can join'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Create WorkRoom'),
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
      await client.post(ApiEndpoints.workrooms, data: {
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'type': _type,
        'isPrivate': _isPrivate,
      });
      ref.invalidate(_workroomsProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }
}

import 'package:flutter/scheduler.dart';
