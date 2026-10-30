import 'dart:async';

import 'package:pos_tablet/data/source/product_service.dart';
import 'package:shared_core/data/local/dao/catalogue_dao.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';
import 'package:shared_core/util/result.dart';

abstract class ProductRepository {
  Future<Result<List<CatalogueItem>>> getCatalogue();
}

class ProductRepositoryImpl implements ProductRepository {
  final ProductService _productService;
  final CatalogueDao _catalogueDao;

  Future<Result<List<CatalogueItem>>>? _initialLoad;
  Future<void>? _backgroundRefresh;
  bool _isRefreshing = false;

  ProductRepositoryImpl(this._productService, this._catalogueDao);

  @override
Future<Result<List<CatalogueItem>>> getCatalogue() async {
  final List<CatalogueItem> cachedItems;
  try {
    final cachedRows = await _catalogueDao.getAll();
    cachedItems = cachedRows.map(CatalogueDao.toDomain).toList();
  } catch (_) {
    return Result.error(
      Exception('Could not load products from local storage.'),
    );
  }

  if (cachedItems.isNotEmpty) {
    // Avoid stacking refreshes if getCatalogue() is called repeatedly.
    _backgroundRefresh ??= _refreshCatalogueInBackground()
        .catchError((_) {}) // a failed refresh must never crash the app
        .whenComplete(() => _backgroundRefresh = null);
    unawaited(_backgroundRefresh!);
    return Result.ok(cachedItems);
  }

  // Coalesce concurrent first-load requests so an empty cache doesn't
  // trigger multiple simultaneous downloads.
  try {
    return await (_initialLoad ??=
        _fetchAndCacheCatalogue().whenComplete(() => _initialLoad = null));
  } catch (e) {
    return Result.error(
      e is Exception ? e : Exception('Could not load products: $e'),
    );
  }
}
  Future<void> _refreshCatalogueInBackground() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    try {
      final result = await _productService.fetchCatalogue();
      switch (result) {
        case Ok<List<CatalogueItem>>(value: final items):
          await _replaceCachedCatalogue(items);
        case Error<List<CatalogueItem>>():
          // Keep serving the last successful cache when refresh fails.
          break;
      }
    } catch (_) {
      // A background refresh must not affect the cached catalogue already
      // returned to the caller. A later catalogue load can retry it.
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Result<List<CatalogueItem>>> _fetchAndCacheCatalogue() async {
    try {
      final result = await _productService.fetchCatalogue();
      switch (result) {
        case Ok<List<CatalogueItem>>(value: final items):
          await _replaceCachedCatalogue(items);
          return Result.ok(items);
        case Error<List<CatalogueItem>>(error: final error):
          return Result.error(error);
      }
    } catch (_) {
      return Result.error(
        Exception('Could not load products. Check your connection.'),
      );
    }
  }

  Future<void> _replaceCachedCatalogue(List<CatalogueItem> items) {
    final rows = items.map(CatalogueDao.fromDomain).toList();
    return _catalogueDao.replaceAll(rows);
  }
}
