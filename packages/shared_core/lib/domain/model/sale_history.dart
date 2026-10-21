class SaleHistory {
  const SaleHistory({
    required this.id,
    required this.cashierId,
    required this.totalCents,
    required this.status,
    required this.createdAt,
    required this.paymentMethod,
  });

  final String id;
  final String cashierId;
  final int totalCents;
  final String status;
  final DateTime createdAt;
  final String paymentMethod;

  factory SaleHistory.fromJson(Map<String, dynamic> json) {
    return SaleHistory(
      id: json['id'] as String,
      cashierId: json['cashier_id'] as String,
      totalCents: (json['total_cents'] as num).toInt(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      paymentMethod: json['payment_method'] as String? ?? 'Unknown',
    );
  }
}