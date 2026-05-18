import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final _schoolsListProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.superAdminSchools);
  final data = res.data as Map<String, dynamic>;
  return data['schools'] as List<dynamic>? ?? [];
});

class SuperAdminSchoolsScreen extends ConsumerStatefulWidget {
  const SuperAdminSchoolsScreen({super.key});

  @override
  ConsumerState<SuperAdminSchoolsScreen> createState() => _SuperAdminSchoolsScreenState();
}

class _SuperAdminSchoolsScreenState extends ConsumerState<SuperAdminSchoolsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_schoolsListProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schools'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateSchoolSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search schools...',
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
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100,
                  child: Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                ),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (schools) {
                final filtered = _query.isEmpty
                    ? schools
                    : schools.where((s) => (s as Map<String, dynamic>)['name'].toString().toLowerCase().contains(_query)).toList();

                if (filtered.isEmpty) return const Center(child: Text('No schools found'));

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(_schoolsListProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final school = filtered[i] as Map<String, dynamic>;
                      return _SchoolCard(school: school, ref: ref);
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

  void _showCreateSchoolSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CreateSchoolSheet(),
    );
  }
}

class _SchoolCard extends StatelessWidget {
  const _SchoolCard({required this.school, required this.ref});
  final Map<String, dynamic> school;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final name = school['name'] as String? ?? 'Unknown';
    final email = school['email'] as String? ?? '';
    final students = school['studentCount'] as int? ?? 0;
    final teachers = school['teacherCount'] as int? ?? 0;
    final packageData = school['currentPackage'];
    final packageName = packageData is Map ? packageData['name'] as String? ?? 'Free' : 'Free';
    final isActive = school['isActive'] as bool? ?? false;
    final schoolId = school['_id'] as String? ?? '';

    return Card(
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
                    color: colors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.account_balance, color: colors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(isActive ? 'Active' : 'Inactive', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? Colors.green.shade700 : Colors.red.shade700)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _Metric(label: 'Students', value: '$students')),
                Expanded(child: _Metric(label: 'Teachers', value: '$teachers')),
                Expanded(child: _Metric(label: 'Package', value: packageName)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _assignPackage(context, schoolId),
                    child: const Text('Assign Package'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _toggleStatus(context, schoolId, isActive),
                    style: FilledButton.styleFrom(backgroundColor: isActive ? Colors.red : Colors.green),
                    child: Text(isActive ? 'Deactivate' : 'Activate'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _assignPackage(BuildContext context, String schoolId) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AssignPackageSheet(schoolId: schoolId, ref: ref),
    );
  }

  Future<void> _toggleStatus(BuildContext context, String schoolId, bool isActive) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.patch(ApiEndpoints.superAdminSchoolById(schoolId), data: {'isActive': !isActive});
      ref.invalidate(_schoolsListProvider);
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _AssignPackageSheet extends ConsumerWidget {
  const _AssignPackageSheet({required this.schoolId, required this.ref});
  final String schoolId;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef innerRef) {
    final packagesAsync = innerRef.watch(FutureProvider<List<dynamic>>((r) async {
      final client = r.read(apiClientProvider);
      final res = await client.get(ApiEndpoints.packages);
      final data = res.data as Map<String, dynamic>;
      return data['packages'] as List<dynamic>? ?? [];
    }).future);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      expand: false,
      builder: (_, ctrl) => Column(
        children: [
          Padding(padding: const EdgeInsets.all(16), child: Text('Assign Package', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: packagesAsync as Future<List<dynamic>>?,
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snap.hasData || snap.data!.isEmpty) return const Center(child: Text('No packages available'));
                return ListView.builder(
                  controller: ctrl,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snap.data!.length,
                  itemBuilder: (ctx, i) {
                    final pkg = snap.data![i] as Map<String, dynamic>;
                    final name = pkg['name'] as String? ?? '';
                    final price = pkg['price'] as num? ?? 0;
                    return ListTile(
                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('₹$price/month'),
                      trailing: FilledButton(
                        onPressed: () async {
                          try {
                            final client = ref.read(apiClientProvider);
                            await client.post(ApiEndpoints.superAdminAssignPackage, data: {'schoolId': schoolId, 'packageId': pkg['_id']});
                            ref.invalidate(_schoolsListProvider);
                            if (ctx.mounted) Navigator.pop(ctx);
                          } catch (e) {
                            if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
                          }
                        },
                        child: const Text('Assign'),
                      ),
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

class _CreateSchoolSheet extends ConsumerStatefulWidget {
  const _CreateSchoolSheet();

  @override
  ConsumerState<_CreateSchoolSheet> createState() => _CreateSchoolSheetState();
}

class _CreateSchoolSheetState extends ConsumerState<_CreateSchoolSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create School Account', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer, borderRadius: BorderRadius.circular(8)),
                    child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
                  ),
                TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'School Name'), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress, validator: (v) => v == null || !v.contains('@') ? 'Valid email required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                TextFormField(controller: _passwordCtrl, decoration: const InputDecoration(labelText: 'Admin Password'), obscureText: true, validator: (v) => v == null || v.length < 8 ? 'Min 8 chars' : null),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Create School'),
                  ),
                ),
              ],
            ),
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
      await client.post(ApiEndpoints.superAdminCreateSchool, data: {
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'password': _passwordCtrl.text,
        'role': 'school',
      });
      ref.invalidate(_schoolsListProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }
}
