import 'package:flutter/foundation.dart';
import 'package:pos_tablet/data/local/dao/catalogue_dao.dart';
import 'package:pos_tablet/data/source/product_service.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';
import 'package:shared_core/util/result.dart';

/// TEMPORARY: fills an empty local catalogue so the app can be developed
/// before the bootstrap/pull exists. Never touches a non-empty catalogue,
/// so it can't overwrite stock that local sales have already reduced.
class CatalogueSeeder {
  CatalogueSeeder(this._productService, this._catalogueDao);

  final ProductService _productService;
  final CatalogueDao _catalogueDao;

  bool _running = false;

  Future<void> seedIfEmpty() async {
    if (_running) return;
    _running = true;
    try {
      if ((await _catalogueDao.getAll()).isNotEmpty) return;

      final result = await _productService.fetchCatalogue();
      if (result case Ok<List<CatalogueItem>>(value: final items)) {
        await _catalogueDao.replaceAll(
          items.map(CatalogueDao.fromDomain).toList(),
        );
      }
    } catch (e) {
      debugPrint(
        'Catalogue seed failed: $e',
      ); // offline or not signed in: try next time
    } finally {
      _running = false;
    }
  }
}
