class CartItem {
  const CartItem({
    required this.variantId,
    required this.name,
    required this.unitPriceCents,
    required this.availableStock,
    this.quantity = 1,
  });

  final String variantId; // the thing that actually gets sold
  final String name;
  final int unitPriceCents;
  final int quantity;

  /// Stock seen when the line was added. A UI limit only; the sale write
  /// re-checks stock authoritatively.
  final int availableStock;

  int get totalCents => unitPriceCents * quantity;

  // Display-only, kept so screens not yet migrated still compile.
  // Never use these for arithmetic. Remove once the receipt/cart screens use cents.
  double get unitPrice => unitPriceCents / 100;
  double get total => totalCents / 100;

  CartItem copyWith({int? quantity, int? availableStock}) => CartItem(
    variantId: variantId,
    name: name,
    unitPriceCents: unitPriceCents,
    availableStock: availableStock ?? this.availableStock,
    quantity: quantity ?? this.quantity,
  );
}
