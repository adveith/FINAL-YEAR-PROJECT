import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final _adminUsersProvider = FutureProvider.family<Map<String, dynamic>, Map<String, String>>((ref, params) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.adminUsers, queryParameters: params);
  return res.data as Map<String, dynamic>;
});

const _roles = ['all', 'student', 'school', 'facilitator', 'counselor', 'doctor', 'parent', 'individual', 'admin'];

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _selectedRole = 'all';

  Map<String, String> get _params => {
    if (_selectedRole != 'all') 'role': _selectedRole,
    if (_query.isNotEmpty) 'search': _query,
    'limit': '50',
  };

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_adminUsersProvider(_params));
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() { _query = ''; _searchCtrl.clear(); }))
                    : null,
              ),
              onSubmitted: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _roles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final role = _roles[i];
                final selected = _selectedRole == role;
                return ChoiceChip(
                  label: Text(role == 'all' ? 'All' : role.capitalize()),
                  selected: selected,
                  onSelected: (v) { if (v) setState(() => _selectedRole = role); },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: async.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 8,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100,
                  child: Container(height: 72, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                ),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (data) {
                final users = data['users'] as List<dynamic>? ?? [];
                final total = data['total'] as int? ?? 0;

                if (users.isEmpty) return const Center(child: Text('No users found'));

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(_adminUsersProvider(_params)),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: users.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      if (i == 0) return Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('$total users found', style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13)));
                      final user = users[i - 1] as Map<String, dynamic>;
                      return _AdminUserTile(user: user, ref: ref, params: _params);
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

class _AdminUserTile extends StatelessWidget {
  const _AdminUserTile({required this.user, required this.ref, required this.params});
  final Map<String, dynamic> user;
  final WidgetRef ref;
  final Map<String, String> params;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final name = user['name'] as String? ?? 'Unknown';
    final email = user['email'] as String? ?? '';
    final role = user['role'] as String? ?? '';
    final isActive = user['isActive'] as bool? ?? false;
    final userId = user['_id'] as String? ?? '';

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colors.primary.withOpacity(0.15),
          child: Text(name[0].toUpperCase(), style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$email • $role', style: const TextStyle(fontSize: 12)),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleAction(context, action, userId, isActive),
          itemBuilder: (_) => [
            PopupMenuItem(value: 'toggle', child: Text(isActive ? 'Deactivate' : 'Activate')),
            const PopupMenuItem(value: 'delete', child: Text('Delete User', style: TextStyle(color: Colors.red))),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(isActive ? 'Active' : 'Inactive', style: TextStyle(fontSize: 11, color: isActive ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.w600)),
                const Icon(Icons.arrow_drop_down, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, String action, String userId, bool isActive) async {
    if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete User'),
          content: const Text('This action cannot be undone. Are you sure?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
          ],
        ),
      );
      if (confirm != true) return;
      try {
        final client = ref.read(apiClientProvider);
        await client.delete(ApiEndpoints.adminUserById(userId));
        ref.invalidate(_adminUsersProvider(params));
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } else if (action == 'toggle') {
      try {
        final client = ref.read(apiClientProvider);
        await client.patch(ApiEndpoints.adminToggleUserStatus(userId), data: {'isActive': !isActive});
        ref.invalidate(_adminUsersProvider(params));
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}

extension StringExtension on String {
  String capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1);
}
