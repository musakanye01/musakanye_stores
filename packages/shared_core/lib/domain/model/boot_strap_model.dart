class BootstrapCatalogueItem {
  const BootstrapCatalogueItem({
    required this.variantId,
    required this.productId,
    required this.productName,
    this.categoryId,
    this.categoryName,
    this.sku,
    this.size,
    this.colour,
    this.description,
    required this.priceCents,
    required this.stockOnHand,
  });

  final String variantId;
  final String productId;
  final String productName;
  final String? categoryId;
  final String? categoryName;
  final String? sku;
  final String? size;
  final String? colour;
  final String? description;
  final int priceCents;
  final int stockOnHand;

  factory BootstrapCatalogueItem.fromJson(Map<String, dynamic> json) {
    return BootstrapCatalogueItem(
      variantId: json['variant_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      categoryId: json['category_id'] as String?,
      categoryName: json['category_name'] as String?,
      sku: json['sku'] as String?,
      size: json['size'] as String?,
      colour: json['colour'] as String?,
      description: json['description'] as String?,
      priceCents: json['price_cents'] as int,
      stockOnHand: json['stock_on_hand'] as int,
    );
  }
}
