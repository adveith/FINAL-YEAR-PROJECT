import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../auth/auth_provider.dart';

final _doctorDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.dashboard);
  return res.data as Map<String, dynamic>;
});

final _doctorPatientsProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.doctorPatients);
  final data = res.data as Map<String, dynamic>;
  return data['patients'] as List<dynamic>? ?? [];
});

final _doctorAppointmentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.doctorAppointments, queryParameters: {'upcoming': 'true'});
  final data = res.data as Map<String, dynamic>;
  return data['appointments'] as List<dynamic>? ?? [];
});

class DoctorDashboard extends ConsumerWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(_doctorDashboardProvider);
    final patientsAsync = ref.watch(_doctorPatientsProvider);
    final appointmentsAsync = ref.watch(_doctorAppointmentsProvider);
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_doctorDashboardProvider);
          ref.invalidate(_doctorPatientsProvider);
          ref.invalidate(_doctorAppointmentsProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Dr. ${user?.name?.split(' ').last ?? 'Doctor'}',
                            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          Text('Doctor Dashboard', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  dashAsync.when(
                    loading: () => _ShimmerGrid(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (data) {
                      final stats = data['stats'] as Map<String, dynamic>? ?? {};
                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.5,
                        children: [
                          StatCard(title: 'Total Patients', value: '${stats['totalPatients'] ?? 0}', icon: Icons.sick, color: colors.primary),
                          StatCard(title: 'Today\'s Appt', value: '${stats['todayAppointments'] ?? 0}', icon: Icons.event_note, color: Colors.green),
                          StatCard(title: 'Reports Sent', value: '${stats['reportsSent'] ?? 0}', icon: Icons.assignment, color: colors.secondary),
                          StatCard(title: 'This Month', value: '${stats['monthlyConsults'] ?? 0}', icon: Icons.calendar_month, color: Colors.orange),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Upcoming Appointments', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () => context.go('/doctor/appointments'), child: const Text('See All')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  appointmentsAsync.when(
                    loading: () => _ShimmerList(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (appointments) {
                      if (appointments.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: colors.surfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                          child: const Center(child: Text('No upcoming appointments')),
                        );
                      }
                      return Column(
                        children: appointments.take(5).map((a) {
                          final appt = a as Map<String, dynamic>;
                          final patient = appt['patient'];
                          final patientName = patient is Map ? patient['name'] as String? ?? 'Patient' : 'Patient';
                          final date = appt['date'] as String? ?? '';
                          final time = appt['timeSlot'] as String? ?? '';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: colors.primary.withOpacity(0.15),
                                child: Text(patientName[0].toUpperCase(), style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(patientName, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text('$date • $time'),
                              trailing: const Icon(Icons.chevron_right),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Patients', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () => context.go('/doctor/patients'), child: const Text('See All')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  patientsAsync.when(
                    loading: () => _ShimmerList(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (patients) {
                      if (patients.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text('No patients yet'));
                      return Column(
                        children: patients.take(4).map((p) {
                          final patient = p as Map<String, dynamic>;
                          final name = patient['name'] as String? ?? 'Unknown';
                          final lastVisit = patient['lastVisit'] as String? ?? 'N/A';
                          final condition = patient['primaryCondition'] as String? ?? '';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: colors.secondary.withOpacity(0.15),
                                child: Text(name[0].toUpperCase(), style: TextStyle(color: colors.secondary, fontWeight: FontWeight.bold)),
                              ),
                              title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(condition.isNotEmpty ? condition : 'Last visit: $lastVisit'),
                              trailing: const Icon(Icons.chevron_right),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.5,
      children: List.generate(4, (_) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100,
        child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
      )),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: List.generate(3, (_) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100,
        child: Container(height: 68, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
      ),
    )));
  }
}
