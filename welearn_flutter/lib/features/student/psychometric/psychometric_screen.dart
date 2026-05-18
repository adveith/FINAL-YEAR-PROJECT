import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/psychometric_model.dart';
import '../../../core/theme/app_theme.dart';

final _psychometricTestsProvider =
    FutureProvider<List<PsychometricTestModel>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.psychometricTests);
  final list = (res.data['data'] ?? res.data['tests'] ?? []) as List;
  return list
      .map((t) =>
          PsychometricTestModel.fromJson(t as Map<String, dynamic>))
      .toList();
});

final _psychometricResultsProvider =
    FutureProvider<List<PsychometricResultModel>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.psychometricResults);
  final list = (res.data['data'] ?? res.data['results'] ?? []) as List;
  return list
      .map((r) =>
          PsychometricResultModel.fromJson(r as Map<String, dynamic>))
      .toList();
});

class StudentPsychometricScreen extends ConsumerWidget {
  const StudentPsychometricScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tests = ref.watch(_psychometricTestsProvider);
    final results = ref.watch(_psychometricResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Psychometric Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfo(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_psychometricTestsProvider);
          ref.invalidate(_psychometricResultsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(),
              const SizedBox(height: 24),
              const Text(
                'Available Tests',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              tests.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('$e'),
                data: (list) => Column(
                  children: list
                      .map((t) => _TestCard(
                            test: t,
                            onStart: () => _startTest(context, t.id, ref),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'My Results',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              results.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    const Center(child: Text('No results yet')),
                data: (list) => list.isEmpty
                    ? const Center(
                        child: Text(
                          'Complete a test to see your results',
                          style: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                      )
                    : Column(
                        children: list
                            .map((r) => _ResultCard(result: r))
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discover Yourself',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Take psychometric assessments to understand your strengths, personality, and career potential.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _startTest(BuildContext context, String testId, WidgetRef ref) {
    // Navigate to test screen
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Starting test $testId...')));
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('About Psychometric Tests'),
        content: const Text(
          'Psychometric tests are scientific assessments that measure your psychological attributes — personality, intelligence, aptitude, and more. Results are used to guide your career path and personal development.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _TestCard extends StatelessWidget {
  final PsychometricTestModel test;
  final VoidCallback onStart;
  const _TestCard({required this.test, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.psychology_outlined,
                color: Color(0xFF059669)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  '${test.questionCount} questions · ${test.durationMinutes} min',
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          test.isCompleted
              ? const Icon(Icons.check_circle,
                  color: AppTheme.success)
              : FilledButton(
                  onPressed: onStart,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Start'),
                ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final PsychometricResultModel result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.testId,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (result.interpretation != null) ...
            [
              const SizedBox(height: 8),
              Text(result.interpretation!,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF065F46))),
            ],
        ],
      ),
    );
  }
}
