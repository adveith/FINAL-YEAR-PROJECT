import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/models/session_model.dart';

final _myBookingsProvider =
    FutureProvider<List<CounselingBookingModel>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.counselingBookings);
  final list = (res.data['data'] ?? res.data['bookings'] ?? []) as List;
  return list
      .map((b) =>
          CounselingBookingModel.fromJson(b as Map<String, dynamic>))
      .toList();
});

final _counselingCategoriesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.counselingCategories);
  final list = (res.data['data'] ?? res.data['categories'] ?? []) as List;
  return list.cast<Map<String, dynamic>>();
});

class StudentAppointmentsScreen extends ConsumerWidget {
  const StudentAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(_myBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counseling Sessions'),
        actions: [
          FilledButton.icon(
            onPressed: () => _showBookingSheet(context, ref),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Book'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(_myBookingsProvider),
        child: bookings.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (list) => list.isEmpty
              ? _emptyState(context, ref)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _BookingCard(booking: list[i]),
                ),
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_outlined,
              size: 72, color: Color(0xFFCBD5E1)),
          const SizedBox(height: 16),
          const Text(
            'No sessions booked yet',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569)),
          ),
          const SizedBox(height: 8),
          const Text(
            'Book a counseling session with our experts',
            style: TextStyle(color: Color(0xFF94A3B8)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => _showBookingSheet(context, ref),
            child: const Text('Book a Session'),
          ),
        ],
      ),
    );
  }

  void _showBookingSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _BookingSheet(onBooked: () {
        ref.invalidate(_myBookingsProvider);
      }),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final CounselingBookingModel booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(booking.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.counselorName ?? 'Counselor',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                DateFormat('dd MMM yyyy').format(booking.date),
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_outlined,
                  size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                booking.timeSlot,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
          if (booking.category != null) ...
            [
              const SizedBox(height: 6),
              Text(
                booking.category!,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ],
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF22C55E);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'completed':
        return const Color(0xFF6366F1);
      default:
        return const Color(0xFF94A3B8);
    }
  }
}

class _BookingSheet extends ConsumerStatefulWidget {
  final VoidCallback onBooked;
  const _BookingSheet({required this.onBooked});

  @override
  ConsumerState<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends ConsumerState<_BookingSheet> {
  String? _categoryId;
  DateTime? _date;
  String? _timeSlot;
  bool _loading = false;

  Future<void> _book() async {
    if (_categoryId == null || _date == null || _timeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    setState(() => _loading = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.post(ApiEndpoints.counselingBookings, data: {
        'categoryId': _categoryId,
        'date': _date!.toIso8601String(),
        'timeSlot': _timeSlot,
      });
      widget.onBooked();
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session booked successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(_counselingCategoriesProvider);

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
          const Text(
            'Book a Counseling Session',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          categories.when(
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text('$e'),
            data: (cats) => DropdownButtonFormField<String>(
              value: _categoryId,
              hint: const Text('Select category'),
              decoration: const InputDecoration(labelText: 'Category'),
              items: cats
                  .map((c) => DropdownMenuItem(
                        value: c['_id'] as String?,
                        child: Text(c['name'] as String? ?? ''),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _categoryId = v),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined),
            title: Text(_date == null
                ? 'Select date'
                : '${_date!.day}/${_date!.month}/${_date!.year}'),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate:
                    DateTime.now().add(const Duration(days: 60)),
              );
              if (picked != null) setState(() => _date = picked);
            },
          ),
          DropdownButtonFormField<String>(
            value: _timeSlot,
            hint: const Text('Select time slot'),
            decoration: const InputDecoration(labelText: 'Time Slot'),
            items: [
              '09:00 AM', '10:00 AM', '11:00 AM',
              '12:00 PM', '02:00 PM', '03:00 PM',
              '04:00 PM', '05:00 PM',
            ]
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _timeSlot = v),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _book,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Confirm Booking'),
            ),
          ),
        ],
      ),
    );
  }
}
