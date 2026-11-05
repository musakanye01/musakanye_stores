import 'package:pos_tablet/data/local/dao/catalogue_dao.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';

abstract class ProductRepository {
  /// Live local catalogue. Emits again whenever stock or prices change locally.
  Stream<List<CatalogueItem>> watchCatalogue();
}

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._catalogueDao);

  final CatalogueDao _catalogueDao;

  @override
  Stream<List<CatalogueItem>> watchCatalogue() {
    return _catalogueDao.watchAll().map(
      (rows) =>
          rows.map(CatalogueDao.toDomain).toList()..sort(_byNameThenVariant),
    );
  }
}

int _byNameThenVariant(CatalogueItem a, CatalogueItem b) {
  final byName = a.productName.toLowerCase().compareTo(
    b.productName.toLowerCase(),
  );
  return byName != 0
      ? byName
      : (a.variantLabel ?? '').compareTo(b.variantLabel ?? '');
}
