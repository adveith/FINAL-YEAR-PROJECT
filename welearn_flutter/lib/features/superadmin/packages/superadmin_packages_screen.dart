import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final _packagesProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.packages);
  final data = res.data as Map<String, dynamic>;
  return data['packages'] as List<dynamic>? ?? [];
});

class SuperAdminPackagesScreen extends ConsumerWidget {
  const SuperAdminPackagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_packagesProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Packages & Pricing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreatePackageSheet(context, ref),
          ),
        ],
      ),
      body: async.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (_, __) => Shimmer.fromColors(
            baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100,
            child: Container(height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          ),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (packages) {
          if (packages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_membership, size: 64, color: colors.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('No packages created', style: theme.textTheme.titleMedium?.copyWith(color: colors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  FilledButton.icon(onPressed: () => _showCreatePackageSheet(context, ref), icon: const Icon(Icons.add), label: const Text('Create Package')),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_packagesProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: packages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (ctx, i) => _PackageCard(package: packages[i] as Map<String, dynamic>, ref: ref),
            ),
          );
        },
      ),
    );
  }

  void _showCreatePackageSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CreatePackageSheet(ref: ref),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.package, required this.ref});
  final Map<String, dynamic> package;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final name = package['name'] as String? ?? 'Package';
    final price = package['price'] as num? ?? 0;
    final billingCycle = package['billingCycle'] as String? ?? 'monthly';
    final features = package['features'] as List<dynamic>? ?? [];
    final maxStudents = package['maxStudents'] as int?;
    final isActive = package['isActive'] as bool? ?? true;
    final packageId = package['_id'] as String? ?? '';

    final gradients = [
      [const Color(0xFF2563EB), const Color(0xFF7C3AED)],
      [const Color(0xFF059669), const Color(0xFF0284C7)],
      [const Color(0xFFD97706), const Color(0xFFDC2626)],
      [const Color(0xFF7C3AED), const Color(0xFFEC4899)],
    ];
    final gradIdx = name.length % gradients.length;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradients[gradIdx]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                if (!isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Inactive', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32)),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 4),
                  child: Text('/$billingCycle', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ),
              ],
            ),
            if (maxStudents != null) ...[
              const SizedBox(height: 4),
              Text('Up to $maxStudents students', style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
            if (features.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...features.take(4).map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f.toString(), style: const TextStyle(color: Colors.white70, fontSize: 13))),
                  ],
                ),
              )),
              if (features.length > 4) Text('+${features.length - 4} more features', style: const TextStyle(color: Colors.white60, fontSize: 12)),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _editPackage(context),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)),
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _toggleActive(context, packageId, isActive),
                    style: FilledButton.styleFrom(backgroundColor: Colors.white24),
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

  void _editPackage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CreatePackageSheet(ref: ref, existing: package),
    );
  }

  Future<void> _toggleActive(BuildContext context, String packageId, bool isActive) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.patch(ApiEndpoints.packageById(packageId), data: {'isActive': !isActive});
      ref.invalidate(_packagesProvider);
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

class _CreatePackageSheet extends ConsumerStatefulWidget {
  const _CreatePackageSheet({required this.ref, this.existing});
  final WidgetRef ref;
  final Map<String, dynamic>? existing;

  @override
  ConsumerState<_CreatePackageSheet> createState() => _CreatePackageSheetState();
}

class _CreatePackageSheetState extends ConsumerState<_CreatePackageSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.existing?['name'] as String? ?? '');
  late final _priceCtrl = TextEditingController(text: '${widget.existing?['price'] ?? ''}');
  late final _maxStudentsCtrl = TextEditingController(text: '${widget.existing?['maxStudents'] ?? ''}');
  late final _featuresCtrl = TextEditingController(text: (widget.existing?['features'] as List<dynamic>?)?.join('\n') ?? '');
  String _billingCycle = widget.existing?['billingCycle'] as String? ?? 'monthly';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _maxStudentsCtrl.dispose();
    _featuresCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
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
                Text(isEdit ? 'Edit Package' : 'Create Package', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (_error != null)
                  Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer, borderRadius: BorderRadius.circular(8)), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer))),
                TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Package Name'), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _priceCtrl, decoration: const InputDecoration(labelText: 'Price', prefixText: '₹'), keyboardType: TextInputType.number, validator: (v) => v == null || double.tryParse(v) == null ? 'Valid price required' : null),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _billingCycle,
                  decoration: const InputDecoration(labelText: 'Billing Cycle'),
                  items: const [
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                    DropdownMenuItem(value: 'quarterly', child: Text('Quarterly')),
                    DropdownMenuItem(value: 'annually', child: Text('Annually')),
                  ],
                  onChanged: (v) => setState(() => _billingCycle = v ?? 'monthly'),
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _maxStudentsCtrl, decoration: const InputDecoration(labelText: 'Max Students (optional)'), keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextFormField(controller: _featuresCtrl, decoration: const InputDecoration(labelText: 'Features (one per line)'), maxLines: 4),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(isEdit ? 'Update Package' : 'Create Package'),
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
      final features = _featuresCtrl.text.split('\n').where((f) => f.trim().isNotEmpty).toList();
      final maxStudents = int.tryParse(_maxStudentsCtrl.text);
      final data = {
        'name': _nameCtrl.text.trim(),
        'price': double.parse(_priceCtrl.text),
        'billingCycle': _billingCycle,
        'features': features,
        if (maxStudents != null) 'maxStudents': maxStudents,
      };
      if (widget.existing != null) {
        await client.put(ApiEndpoints.packageById(widget.existing!['_id'] as String), data: data);
      } else {
        await client.post(ApiEndpoints.packages, data: data);
      }
      ref.invalidate(_packagesProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }
}
