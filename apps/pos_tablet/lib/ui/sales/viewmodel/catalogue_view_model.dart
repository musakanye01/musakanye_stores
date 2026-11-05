import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pos_tablet/data/repository/product_repo.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';

class CatalogueViewModel extends ChangeNotifier {
  CatalogueViewModel(this._productRepository) {
    _subscription = _productRepository.watchCatalogue().listen(
      (items) {
        _items = items;
        _hasLoaded = true;
        _error = null;
        notifyListeners();
      },
      onError: (Object error) {
        _error = error;
        _hasLoaded = true;
        notifyListeners();
      },
    );
  }

  final ProductRepository _productRepository;
  StreamSubscription<List<CatalogueItem>>? _subscription;

  List<CatalogueItem> _items = [];
  String _searchQuery = '';

  /// False until the first local read completes.
  bool _hasLoaded = false;
  bool get hasLoaded => _hasLoaded;

  Object? _error;
  Object? get error => _error;

  /// Loaded and empty: the catalogue hasn't been downloaded yet.
  bool get isCatalogueEmpty => _hasLoaded && _items.isEmpty;

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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
