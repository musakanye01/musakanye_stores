import 'package:pos_tablet/data/source/product_service.dart';
import 'package:shared_core/domain/catalogue_item.dart';
import 'package:shared_core/util/result.dart';

abstract class ProductRepository {
  Future<Result<List<CatalogueItem>>> getCatalogue();
}

class ProductRepositoryImpl implements ProductRepository {
  final ProductService _productService;
  ProductRepositoryImpl(this._productService);

  @override
  Future<Result<List<CatalogueItem>>> getCatalogue() =>
      _productService.fetchCatalogue();
}
