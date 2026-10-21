
class StockReceiptItem {
  final String receiptId;
  final String variantId;
  final String productName;
  final String? sku;
  final String? variantLabel;
  final int quantity;
  final String note;
  final String? reference;
  final String status;
  final DateTime receivedAt;

  const StockReceiptItem({
    required this.receiptId,
    required this.variantId,
    required this.productName,
    required this.sku,
    required this.variantLabel,
    required this.quantity,
    required this.note,
    required this.reference,
    required this.status,
    required this.receivedAt,
  });

  factory StockReceiptItem.fromJson(Map<String, dynamic> json) {
    final receipt =
        json['stock_receipts'] as Map<String, dynamic>? ?? {};
    final variant =
        json['product_variants'] as Map<String, dynamic>? ?? {};
    final product =
        variant['products'] as Map<String, dynamic>? ?? {};

    final size = variant['size'] as String?;
    final colour = variant['colour'] as String?;
    final labelParts = [size, colour]
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .toList();

    return StockReceiptItem(
      receiptId: receipt['id'] as String? ?? '',
      variantId: json['variant_id'] as String? ?? '',
      productName: product['name'] as String? ?? 'Unknown product',
      sku: variant['sku'] as String?,
      variantLabel:
          labelParts.isEmpty ? null : labelParts.join(' · '),
      quantity: (json['quantity'] as num).toInt(),
      note: json['note'] as String? ?? '',
      reference: receipt['reference'] as String?,
      status: receipt['status'] as String? ?? 'unknown',
      receivedAt: DateTime.parse(
        receipt['created_at'] as String,
      ),
    );
  }
}
