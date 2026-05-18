import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/cosmos_model.dart';
import '../../../core/theme/app_theme.dart';

final _myCosmosReportsProvider =
    FutureProvider<List<CosmosReportModel>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.cosmosMyReports);
  final list = (res.data['data'] ?? res.data['reports'] ?? []) as List;
  return list
      .map((r) =>
          CosmosReportModel.fromJson(r as Map<String, dynamic>))
      .toList();
});

class StudentCosmosScreen extends ConsumerWidget {
  const StudentCosmosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(_myCosmosReportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WeLearn Cosmos ✨'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showGenerateSheet(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(_myCosmosReportsProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroBanner(),
              const SizedBox(height: 24),
              _buildTypeSelector(context, ref),
              const SizedBox(height: 24),
              const Text(
                'My Reports',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              reports.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('$e')),
                data: (list) => list.isEmpty
                    ? _emptyState(context, ref)
                    : Column(
                        children: list
                            .map((r) => _CosmosReportCard(report: r))
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFFDB2777)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MindMatrix · Cosmos',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Unlock insights from Vedic Astrology and Numerology to guide your career, relationships, and personal growth.',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _CosmosChip('Astrology'),
              SizedBox(width: 8),
              _CosmosChip('Numerology'),
              SizedBox(width: 8),
              _CosmosChip('Career Insights'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _TypeCard(
            title: 'Astrology',
            subtitle: 'Birth chart & planetary insights',
            icon: Icons.stars_outlined,
            color: AppTheme.cosmosGold,
            onTap: () => _showGenerateSheet(context, ref,
                type: 'astrology'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TypeCard(
            title: 'Numerology',
            subtitle: 'Life path & destiny numbers',
            icon: Icons.calculate_outlined,
            color: AppTheme.cosmosPurple,
            onTap: () => _showGenerateSheet(context, ref,
                type: 'numerology'),
          ),
        ),
      ],
    );
  }

  Widget _emptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.auto_awesome_outlined,
              size: 72, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          const Text(
            'No cosmic reports yet',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Generate your first cosmic report',
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => _showGenerateSheet(context, ref),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Report'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.cosmosPurple,
            ),
          ),
        ],
      ),
    );
  }

  void _showGenerateSheet(BuildContext context, WidgetRef ref,
      {String type = 'combined'}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _GenerateReportSheet(
        initialType: type,
        onGenerated: () => ref.invalidate(_myCosmosReportsProvider),
      ),
    );
  }
}

class _CosmosChip extends StatelessWidget {
  final String label;
  const _CosmosChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _TypeCard(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: color)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}

class _CosmosReportCard extends StatelessWidget {
  final CosmosReportModel report;
  const _CosmosReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.cosmosPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    report.reportType.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.cosmosPurple,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                if (report.createdAt != null)
                  Text(
                    '${report.createdAt!.day}/${report.createdAt!.month}/${report.createdAt!.year}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
              ],
            ),
            if (report.sunSign != null) ...
              [
                const SizedBox(height: 10),
                Row(
                  children: [
                    _cosmosItem('Sun', report.sunSign!),
                    const SizedBox(width: 16),
                    if (report.moonSign != null)
                      _cosmosItem('Moon', report.moonSign!),
                    const SizedBox(width: 16),
                    if (report.risingSign != null)
                      _cosmosItem('Rising', report.risingSign!),
                  ],
                ),
              ],
            if (report.lifePathNumber != null) ...
              [
                const SizedBox(height: 10),
                Row(
                  children: [
                    _cosmosItem('Life Path', report.lifePathNumber!),
                    const SizedBox(width: 16),
                    if (report.destinyNumber != null)
                      _cosmosItem('Destiny', report.destinyNumber!),
                  ],
                ),
              ],
            if (report.summary != null) ...
              [
                const SizedBox(height: 12),
                Text(
                  report.summary!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF475569), height: 1.5),
                ),
              ],
          ],
        ),
      ),
    );
  }

  Widget _cosmosItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500)),
        Text(value,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1B4B))),
      ],
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (report.summary != null) ...
                [
                  const Text('Summary',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(report.summary!,
                      style: const TextStyle(height: 1.6, fontSize: 14)),
                ],
              if (report.careerInsight != null) ...
                [
                  const SizedBox(height: 20),
                  const Text('Career Insights',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(report.careerInsight!,
                      style: const TextStyle(height: 1.6, fontSize: 14)),
                ],
              if (report.relationshipInsight != null) ...
                [
                  const SizedBox(height: 20),
                  const Text('Relationship',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(report.relationshipInsight!,
                      style: const TextStyle(height: 1.6, fontSize: 14)),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GenerateReportSheet extends ConsumerStatefulWidget {
  final String initialType;
  final VoidCallback onGenerated;
  const _GenerateReportSheet(
      {required this.initialType, required this.onGenerated});

  @override
  ConsumerState<_GenerateReportSheet> createState() =>
      _GenerateReportSheetState();
}

class _GenerateReportSheetState
    extends ConsumerState<_GenerateReportSheet> {
  final _nameCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();
  final _birthTimeCtrl = TextEditingController();
  final _birthPlaceCtrl = TextEditingController();
  bool _loading = false;
  late String _type;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _birthDateCtrl.dispose();
    _birthTimeCtrl.dispose();
    _birthPlaceCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_nameCtrl.text.isEmpty || _birthDateCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name and birth date are required')));
      return;
    }
    setState(() => _loading = true);
    try {
      final client = ref.read(apiClientProvider);
      final input = CosmosInputModel(
        fullName: _nameCtrl.text.trim(),
        birthDate: _birthDateCtrl.text.trim(),
        birthTime: _birthTimeCtrl.text.trim().isEmpty
            ? null
            : _birthTimeCtrl.text.trim(),
        birthPlace: _birthPlaceCtrl.text.trim().isEmpty
            ? null
            : _birthPlaceCtrl.text.trim(),
      );
      await client.post(
        _type == 'astrology'
            ? ApiEndpoints.cosmosAstrology
            : _type == 'numerology'
                ? ApiEndpoints.cosmosNumerology
                : ApiEndpoints.cosmosReport,
        data: {...input.toJson(), 'reportType': _type},
      );
      widget.onGenerated();
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cosmic report generated!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Generate Cosmic Report',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'astrology', label: Text('Astrology')),
              ButtonSegment(value: 'numerology', label: Text('Numerology')),
              ButtonSegment(value: 'combined', label: Text('Combined')),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration:
                const InputDecoration(labelText: 'Full Name (as per birth certificate)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _birthDateCtrl,
            decoration: const InputDecoration(
              labelText: 'Date of Birth (YYYY-MM-DD)',
              hintText: 'e.g. 1999-05-15',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _birthTimeCtrl,
            decoration: const InputDecoration(
              labelText: 'Time of Birth (optional)',
              hintText: 'e.g. 14:30',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _birthPlaceCtrl,
            decoration: const InputDecoration(
              labelText: 'Place of Birth (optional)',
              hintText: 'e.g. Mumbai, India',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _generate,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.cosmosPurple,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Generate Report ✨'),
            ),
          ),
        ],
      ),
    );
  }
}
