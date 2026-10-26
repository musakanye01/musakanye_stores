import 'package:flutter/material.dart';
import 'package:pos_tablet/data/repository/product_repo.dart';
import 'package:pos_tablet/ui/sales/cart_item.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';

import 'package:shared_core/util/command.dart';
import 'package:shared_core/util/result.dart';

class CatalogueViewModel extends ChangeNotifier {
  final ProductRepository _productRepository;

  List<CatalogueItem> _items = [];
  String _searchQuery = '';
  final List<CartItem> _cart = [];

  late final Command0<void> loadCatalogue;

  CatalogueViewModel(this._productRepository) {
    loadCatalogue = Command0(_handleLoadCatalogue);
  }

  // ---- Catalogue & search ----
  List<CatalogueItem> get items => _items;
  String get searchQuery => _searchQuery;

  List<CatalogueItem> get filteredItems {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _items;

    return _items.where((i) {
      return i.productName.toLowerCase().contains(query) ||
          (i.sku?.toLowerCase().contains(query) ?? false) ||
          (i.categoryName?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  Future<Result<void>> _handleLoadCatalogue() async {
    final result = await _productRepository.getCatalogue();
    switch (result) {
      case Ok<List<CatalogueItem>>(value: final items):
        _items = items;
        notifyListeners();
        return const Result.ok(null);
      case Error<List<CatalogueItem>>(error: final err):
        return Result.error(err);
    }
  }

  // ---- Cart ----
  List<CartItem> get cart => List.unmodifiable(_cart);

  double get cartTotal =>
      _cart.fold<double>(0, (total, item) => total + item.total);

  int get cartItemCount =>
      _cart.fold<int>(0, (total, item) => total + item.quantity);

  int quantityInCart(String variantId) {
    final index = _cart.indexWhere((i) => i.productId == variantId);
    return index == -1 ? 0 : _cart[index].quantity;
  }

  /// Returns false when the cart already holds all available stock.
  bool addToCart(CatalogueItem item) {
    final inCart = quantityInCart(item.variantId);
    if (inCart >= item.stockOnHand) return false;

    final index = _cart.indexWhere((i) => i.productId == item.variantId);
    if (index != -1) {
      _cart[index] = _cart[index].copyWith(quantity: inCart + 1);
    } else {
      _cart.add(
        CartItem(
          productId: item.variantId, // variant id: this is what gets sold
          name: item.displayName,
          unitPrice: item.price,
        ),
      );
    }
    notifyListeners();
    return true;
  }

  /// Increases quantity only if stock is still available.
  bool increaseQuantity(String variantId) {
    final index = _cart.indexWhere((item) => item.productId == variantId);
    if (index == -1) return false;

    final catalogueIndex = _items.indexWhere(
      (item) => item.variantId == variantId,
    );

    if (catalogueIndex == -1) return false;

    final availableStock = _items[catalogueIndex].stockOnHand;
    final currentQuantity = _cart[index].quantity;

    if (currentQuantity >= availableStock) return false;

    _cart[index] = _cart[index].copyWith(quantity: currentQuantity + 1);

    notifyListeners();
    return true;
  }

  /// Decreases quantity; removes the item when quantity reaches zero.
  void decreaseQuantity(String variantId) {
    final index = _cart.indexWhere((item) => item.productId == variantId);
    if (index == -1) return;

    final currentQuantity = _cart[index].quantity;

    if (currentQuantity <= 1) {
      _cart.removeAt(index);
    } else {
      _cart[index] = _cart[index].copyWith(quantity: currentQuantity - 1);
    }

    notifyListeners();
  }

  void removeFromCart(String variantId) {
    _cart.removeWhere((item) => item.productId == variantId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}
