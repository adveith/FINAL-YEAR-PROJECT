import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';

final _paymentHistoryProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.myPayments);
  final data = res.data as Map<String, dynamic>;
  return data['payments'] as List<dynamic>? ?? [];
});

final _availablePackagesProvider = FutureProvider<List<dynamic>>((ref) async {
  final client = ref.read(apiClientProvider);
  final res = await client.get(ApiEndpoints.packages);
  final data = res.data as Map<String, dynamic>;
  return data['packages'] as List<dynamic>? ?? [];
});

class StudentPaymentsScreen extends ConsumerStatefulWidget {
  const StudentPaymentsScreen({super.key});

  @override
  ConsumerState<StudentPaymentsScreen> createState() => _StudentPaymentsScreenState();
}

class _StudentPaymentsScreenState extends ConsumerState<StudentPaymentsScreen> {
  late Razorpay _razorpay;
  String? _processingPackageId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final client = ref.read(apiClientProvider);
      await client.post(ApiEndpoints.verifyPayment, data: {
        'razorpay_payment_id': response.paymentId,
        'razorpay_order_id': response.orderId,
        'razorpay_signature': response.signature,
        'packageId': _processingPackageId,
      });
      ref.invalidate(_paymentHistoryProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful! Package activated.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment verification failed: $e'), backgroundColor: Colors.orange),
        );
      }
    }
    setState(() => _processingPackageId = null);
  }

  void _onPaymentError(PaymentFailureResponse response) {
    setState(() => _processingPackageId = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}'), backgroundColor: Colors.red),
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    setState(() => _processingPackageId = null);
  }

  Future<void> _initiatePayment(Map<String, dynamic> package) async {
    final packageId = package['_id'] as String? ?? '';
    final price = package['price'] as num? ?? 0;
    final name = package['name'] as String? ?? 'Package';

    setState(() => _processingPackageId = packageId);

    try {
      final client = ref.read(apiClientProvider);
      final res = await client.post(ApiEndpoints.createOrder, data: {
        'packageId': packageId,
        'amount': (price * 100).toInt(),
      });
      final data = res.data as Map<String, dynamic>;
      final orderId = data['orderId'] as String? ?? data['id'] as String? ?? '';

      final options = {
        'key': AppConstants.razorpayKey,
        'amount': (price * 100).toInt(),
        'name': 'WeLearn',
        'description': name,
        'order_id': orderId,
        'prefill': {'contact': '', 'email': ''},
        'theme': {'color': '#2563EB'},
      };

      _razorpay.open(options);
    } catch (e) {
      setState(() => _processingPackageId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create order: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(_paymentHistoryProvider);
    final packagesAsync = ref.watch(_availablePackagesProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payments'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Packages'), Tab(text: 'History')],
          ),
        ),
        body: TabBarView(
          children: [
            // Packages tab
            packagesAsync.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100,
                  child: Container(height: 220, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
                ),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (packages) {
                if (packages.isEmpty) return const Center(child: Text('No packages available'));
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(_availablePackagesProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: packages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (ctx, i) {
                      final pkg = packages[i] as Map<String, dynamic>;
                      final isProcessing = _processingPackageId == pkg['_id'];
                      return _PackageTile(package: pkg, isProcessing: isProcessing, onPurchase: () => _initiatePayment(pkg));
                    },
                  ),
                );
              },
            ),
            // History tab
            historyAsync.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300, highlightColor: Colors.grey.shade100,
                  child: Container(height: 72, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
                ),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (payments) {
                if (payments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: colors.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text('No payment history', style: TextStyle(color: colors.onSurfaceVariant)),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(_paymentHistoryProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: payments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) => _PaymentHistoryTile(payment: payments[i] as Map<String, dynamic>),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageTile extends StatelessWidget {
  const _PackageTile({required this.package, required this.isProcessing, required this.onPurchase});
  final Map<String, dynamic> package;
  final bool isProcessing;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final name = package['name'] as String? ?? 'Package';
    final price = package['price'] as num? ?? 0;
    final billingCycle = package['billingCycle'] as String? ?? 'monthly';
    final features = package['features'] as List<dynamic>? ?? [];
    final maxStudents = package['maxStudents'] as int?;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.secondary],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: colors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price == 0 ? 'FREE' : '₹${price.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 36),
                ),
                if (price != 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6, left: 4),
                    child: Text('/$billingCycle', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  ),
              ],
            ),
            if (maxStudents != null) Text('Up to $maxStudents students', style: const TextStyle(color: Colors.white70)),
            if (features.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...features.take(5).map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(f.toString(), style: const TextStyle(color: Colors.white70, fontSize: 13))),
                  ],
                ),
              )),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isProcessing ? null : (price == 0 ? null : onPurchase),
                style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: colors.primary),
                child: isProcessing
                    ? SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary))
                    : Text(price == 0 ? 'Current Plan' : 'Purchase Now', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentHistoryTile extends StatelessWidget {
  const _PaymentHistoryTile({required this.payment});
  final Map<String, dynamic> payment;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final packageData = payment['package'];
    final packageName = packageData is Map ? packageData['name'] as String? ?? 'Package' : 'Package';
    final amount = payment['amount'] as num? ?? 0;
    final status = payment['status'] as String? ?? 'pending';
    final createdAt = DateTime.tryParse(payment['createdAt'] as String? ?? '');

    Color statusColor;
    switch (status) {
      case 'paid': statusColor = Colors.green; break;
      case 'failed': statusColor = Colors.red; break;
      default: statusColor = Colors.orange;
    }

    return Card(
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(status == 'paid' ? Icons.check_circle : Icons.pending, color: statusColor),
        ),
        title: Text(packageName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: createdAt != null
            ? Text('${createdAt.day}/${createdAt.month}/${createdAt.year}', style: const TextStyle(fontSize: 12))
            : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('₹${amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
              child: Text(status.toUpperCase(), style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
