import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';

final _pendingBookingsProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.counselorBookings, queryParameters: {'status': 'pending'});
  final data = res.data as Map<String, dynamic>;
  return data['bookings'] as List<dynamic>? ?? [];
});

class CounselorBookingsScreen extends ConsumerWidget {
  const CounselorBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_pendingBookingsProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Requests')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available, size: 64, color: colors.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('No pending booking requests', style: theme.textTheme.titleMedium?.copyWith(color: colors.onSurfaceVariant)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_pendingBookingsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => _BookingRequestCard(booking: bookings[i] as Map<String, dynamic>, ref: ref),
            ),
          );
        },
      ),
    );
  }
}

class _BookingRequestCard extends StatefulWidget {
  const _BookingRequestCard({required this.booking, required this.ref});
  final Map<String, dynamic> booking;
  final WidgetRef ref;

  @override
  State<_BookingRequestCard> createState() => _BookingRequestCardState();
}

class _BookingRequestCardState extends State<_BookingRequestCard> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final studentData = widget.booking['student'];
    final studentName = studentData is Map ? studentData['name'] as String? ?? 'Student' : 'Student';
    final studentEmail = studentData is Map ? studentData['email'] as String? ?? '' : '';
    final date = widget.booking['date'] as String? ?? '';
    final timeSlot = widget.booking['timeSlot'] as String? ?? '';
    final category = widget.booking['category'] as String? ?? '';
    final notes = widget.booking['notes'] as String? ?? '';
    final bookingId = widget.booking['_id'] as String? ?? '';

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
                  child: Text(studentName[0].toUpperCase(), style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (studentEmail.isNotEmpty) Text(studentEmail, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            if (date.isNotEmpty) _BookingInfo(icon: Icons.calendar_today, label: 'Date', value: date),
            if (timeSlot.isNotEmpty) _BookingInfo(icon: Icons.access_time, label: 'Time', value: timeSlot),
            if (category.isNotEmpty) _BookingInfo(icon: Icons.category, label: 'Category', value: category),
            if (notes.isNotEmpty) _BookingInfo(icon: Icons.notes, label: 'Notes', value: notes),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : () => _respond(bookingId, false),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Decline'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _loading ? null : () => _respond(bookingId, true),
                    icon: _loading
                        ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check, size: 16),
                    label: const Text('Accept'),
                    style: FilledButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _respond(String bookingId, bool accept) async {
    setState(() => _loading = true);
    try {
      final client = widget.ref.read(apiClientProvider);
      await client.patch(ApiEndpoints.updateBookingStatus(bookingId), data: {
        'status': accept ? 'confirmed' : 'cancelled',
      });
      widget.ref.invalidate(_pendingBookingsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _loading = false);
      }
    }
  }
}

class _BookingInfo extends StatelessWidget {
  const _BookingInfo({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Text('$label: ', style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
