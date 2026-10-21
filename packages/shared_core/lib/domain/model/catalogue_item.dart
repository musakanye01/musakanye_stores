/// One sellable unit: a product variant joined with its parent product.
class CatalogueItem {
  final String variantId;
  final String productId;
  final String productName;
  final String? categoryName;
  final String? sku;
  final String? size;
  final String? colour;
  final int priceCents;
  final int stockOnHand;

  const CatalogueItem({
    required this.variantId,
    required this.productId,
    required this.productName,
    required this.categoryName,
    required this.sku,
    required this.size,
    required this.colour,
    required this.priceCents,
    required this.stockOnHand,
  });

  double get price => priceCents / 100;
  bool get inStock => stockOnHand > 0;

  /// e.g. "0-3m · White", or null when the variant has neither.
  String? get variantLabel {
    final parts = [size, colour].whereType<String>().where((s) => s.isNotEmpty);
    return parts.isEmpty ? null : parts.join(' · ');
  }

  /// Name shown in the cart, e.g. "Baby Grow (0-3m · White)".
  String get displayName =>
      variantLabel == null ? productName : '$productName ($variantLabel)';

  factory CatalogueItem.fromJson(Map<String, dynamic> json) {
    final product = json['products'] as Map<String, dynamic>;
    final category = product['categories'] as Map<String, dynamic>?;

    return CatalogueItem(
      variantId: json['id'] as String,
      productId: product['id'] as String,
      productName: product['name'] as String,
      categoryName: category?['name'] as String?,
      sku: json['sku'] as String?,
      size: json['size'] as String?,
      colour: json['colour'] as String?,
      priceCents: (json['price_cents'] as num).toInt(),
      stockOnHand: (json['stock_on_hand'] as num).toInt(),
    );
  }
}