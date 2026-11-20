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

  // Optimize search for performance.
  List<CatalogueItem> get filteredItems {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) return _items;

    final exact = <CatalogueItem>[];
    final fuzzy = <CatalogueItem>[];

    for (final item in _items) {
      final name = item.productName.toLowerCase();

      if (name.contains(query)) {
        exact.add(item);
      } else if (fuzzyMatch(name, query)) {
        fuzzy.add(item);
      }
    }

    return [...exact, ...fuzzy];
  }

  bool fuzzyMatch(String text, String query) {
    text = text.toLowerCase();
    query = query.toLowerCase();

    int qi = 0;

    for (int i = 0; i < text.length && qi < query.length; i++) {
      if (text[i] == query[qi]) {
        qi++;
      }
    }

    return qi == query.length;
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
