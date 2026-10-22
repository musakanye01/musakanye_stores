class SaleLineItem {
  const SaleLineItem({
    required this.id,
    required this.saleId,
    required this.variantId,
    required this.productName,
    required this.quantity,
    required this.unitPriceCents,
    required this.lineTotalCents,
    this.variantDescription,
  });

  final String id;
  final String saleId;
  final String variantId;
  final String productName;
  final String? variantDescription;
  final int quantity;
  final int unitPriceCents;
  final int lineTotalCents;

  factory SaleLineItem.fromJson(Map<String, dynamic> json) {
    return SaleLineItem(
      id: json['id'] as String,
      saleId: json['sale_id'] as String,
      variantId: json['variant_id'] as String,
      productName: json['product_name'] as String,
      variantDescription: json['variant_description'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      unitPriceCents: (json['unit_price_cents'] as num).toInt(),
      lineTotalCents: (json['line_total_cents'] as num).toInt(),
    );
  }
}
