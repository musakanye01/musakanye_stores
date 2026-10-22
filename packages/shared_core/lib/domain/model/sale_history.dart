import 'package:shared_core/domain/model/sale_line_item.dart';

class SaleHistory {
  const SaleHistory({
    required this.id,
    required this.cashierId,
    required this.totalCents,
    required this.status,
    required this.createdAt,
    required this.paymentMethod,
    this.items = const [],
  });

  final String id;
  final String cashierId;
  final int totalCents;
  final String status;
  final DateTime createdAt;
  final String paymentMethod;
  final List<SaleLineItem> items;

  factory SaleHistory.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];

    return SaleHistory(
      id: json['id'] as String,
      cashierId: json['cashier_id'] as String,
      totalCents: (json['total_cents'] as num).toInt(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      paymentMethod: json['payment_method'] as String? ?? 'Unknown',
      items: rawItems
          .map(
            (item) =>
                SaleLineItem.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
  }
}
