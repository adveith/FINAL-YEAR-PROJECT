import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final _doctorPatientsListProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.doctorPatients);
  final data = res.data as Map<String, dynamic>;
  return data['patients'] as List<dynamic>? ?? [];
});

class DoctorPatientsScreen extends ConsumerStatefulWidget {
  const DoctorPatientsScreen({super.key});

  @override
  ConsumerState<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends ConsumerState<DoctorPatientsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_doctorPatientsListProvider);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('My Patients')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search patients...',
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
                  baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100,
                  child: Container(height: 88, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                ),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (patients) {
                final filtered = _query.isEmpty
                    ? patients
                    : patients.where((p) {
                        final m = p as Map<String, dynamic>;
                        return (m['name'] as String? ?? '').toLowerCase().contains(_query);
                      }).toList();

                if (filtered.isEmpty) return const Center(child: Text('No patients found'));

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(_doctorPatientsListProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final p = filtered[i] as Map<String, dynamic>;
                      return _PatientCard(
                        patient: p,
                        onDiagnose: () => _showDiagnoseSheet(ctx, p['_id'] as String? ?? ''),
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

  void _showDiagnoseSheet(BuildContext context, String patientId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _DiagnoseSheet(patientId: patientId, ref: ref),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.patient, required this.onDiagnose});
  final Map<String, dynamic> patient;
  final VoidCallback onDiagnose;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final name = patient['name'] as String? ?? 'Unknown';
    final age = patient['age'] as int?;
    final gender = patient['gender'] as String? ?? '';
    final condition = patient['primaryCondition'] as String? ?? '';
    final lastVisit = patient['lastVisit'] as String? ?? '';
    final visitCount = patient['totalVisits'] as int? ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colors.primary.withOpacity(0.15),
                  radius: 24,
                  child: Text(name[0].toUpperCase(), style: TextStyle(fontSize: 20, color: colors.primary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (age != null || gender.isNotEmpty)
                        Text(
                          [if (age != null) '$age yrs', if (gender.isNotEmpty) gender].join(' • '),
                          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                        ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: onDiagnose,
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  child: const Text('Diagnose'),
                ),
              ],
            ),
            if (condition.isNotEmpty || lastVisit.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (condition.isNotEmpty)
                    Expanded(child: _InfoChip(icon: Icons.medical_services, label: condition)),
                  if (lastVisit.isNotEmpty)
                    _InfoChip(icon: Icons.history, label: 'Last: $lastVisit'),
                  if (visitCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _InfoChip(icon: Icons.repeat, label: '$visitCount visits'),
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _DiagnoseSheet extends ConsumerStatefulWidget {
  const _DiagnoseSheet({required this.patientId, required this.ref});
  final String patientId;
  final WidgetRef ref;

  @override
  ConsumerState<_DiagnoseSheet> createState() => _DiagnoseSheetState();
}

class _DiagnoseSheetState extends ConsumerState<_DiagnoseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisCtrl = TextEditingController();
  final _prescriptionCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _diagnosisCtrl.dispose();
    _prescriptionCtrl.dispose();
    _notesCtrl.dispose();
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
              Text('Add Diagnosis', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (_error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.errorContainer, borderRadius: BorderRadius.circular(8)),
                  child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
                ),
              TextFormField(
                controller: _diagnosisCtrl,
                decoration: const InputDecoration(labelText: 'Diagnosis'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _prescriptionCtrl,
                decoration: const InputDecoration(labelText: 'Prescription'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Diagnosis'),
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
      await client.post(ApiEndpoints.doctorDiagnosis, data: {
        'patientId': widget.patientId,
        'diagnosis': _diagnosisCtrl.text.trim(),
        'prescription': _prescriptionCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }
}
