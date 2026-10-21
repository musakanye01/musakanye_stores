class SaleLine {
  final String variantId;
  final int quantity;
  const SaleLine({required this.variantId, required this.quantity});

  Map<String, dynamic> toJson() => {
        'variant_id': variantId,
        'quantity': quantity,
      };
}

class SaleResult {
  final String saleId;
  final int totalCents;
  final bool duplicate;

  const SaleResult({
    required this.saleId,
    required this.totalCents,
    required this.duplicate,
  });

  factory SaleResult.fromJson(Map<String, dynamic> json) => SaleResult(
        saleId: json['sale_id'] as String,
        totalCents: (json['total_cents'] as num).toInt(),
        duplicate: json['duplicate'] as bool? ?? false,
      );
}