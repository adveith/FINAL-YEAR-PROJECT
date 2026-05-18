class PaymentModel {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final String status;
  final String purpose;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? description;
  final DateTime? createdAt;

  const PaymentModel({
    required this.id,
    required this.userId,
    required this.amount,
    this.currency = 'INR',
    required this.status,
    required this.purpose,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.description,
    this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: json['_id'] as String? ?? '',
        userId: json['user'] is String
            ? json['user'] as String
            : (json['user'] as Map?)?['_id'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        currency: json['currency'] as String? ?? 'INR',
        status: json['status'] as String? ?? 'pending',
        purpose: json['purpose'] as String? ?? '',
        razorpayOrderId: json['razorpayOrderId'] as String?,
        razorpayPaymentId: json['razorpayPaymentId'] as String?,
        description: json['description'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
      );
}

class RazorpayOrder {
  final String orderId;
  final double amount;
  final String currency;
  final String key;
  final String name;
  final String description;

  const RazorpayOrder({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.key,
    required this.name,
    required this.description,
  });

  factory RazorpayOrder.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return RazorpayOrder(
      orderId: data['orderId'] as String? ?? data['id'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      currency: data['currency'] as String? ?? 'INR',
      key: data['key'] as String? ?? '',
      name: data['name'] as String? ?? 'WeLearn',
      description: data['description'] as String? ?? '',
    );
  }
}
