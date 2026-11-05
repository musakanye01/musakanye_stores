import 'package:flutter/foundation.dart';
import 'package:pos_tablet/ui/sales/cart_item.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';

class CartViewModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;

  int get itemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  int get totalCents => _items.fold(0, (sum, i) => sum + i.totalCents);

  int quantityOf(String variantId) {
    final index = _indexOf(variantId);
    return index == -1 ? 0 : _items[index].quantity;
  }

  /// Returns false when the cart already holds all available stock.
  bool add(CatalogueItem item) {
    final index = _indexOf(item.variantId);

    if (index == -1) {
      if (item.stockOnHand < 1) return false;
      _items.add(
        CartItem(
          variantId: item.variantId,
          name: item.displayName,
          unitPriceCents: item.priceCents,
          availableStock: item.stockOnHand,
        ),
      );
    } else {
      final line = _items[index];
      if (line.quantity >= item.stockOnHand) return false;
      _items[index] = line.copyWith(
        quantity: line.quantity + 1,
        availableStock: item.stockOnHand, // fresher than the stored snapshot
      );
    }

    notifyListeners();
    return true;
  }

  bool increase(String variantId) {
    final index = _indexOf(variantId);
    if (index == -1) return false;

    final line = _items[index];
    if (line.quantity >= line.availableStock) return false;

    _items[index] = line.copyWith(quantity: line.quantity + 1);
    notifyListeners();
    return true;
  }

  /// Lowers the quantity; removes the line at zero.
  void decrease(String variantId) {
    final index = _indexOf(variantId);
    if (index == -1) return;

    final line = _items[index];
    if (line.quantity <= 1) {
      _items.removeAt(index);
    } else {
      _items[index] = line.copyWith(quantity: line.quantity - 1);
    }
    notifyListeners();
  }

  void remove(String variantId) {
    final before = _items.length;
    _items.removeWhere((i) => i.variantId == variantId);
    if (_items.length != before) notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }

  int _indexOf(String variantId) =>
      _items.indexWhere((i) => i.variantId == variantId);
}
