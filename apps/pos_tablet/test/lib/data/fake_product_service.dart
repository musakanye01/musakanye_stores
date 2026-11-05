import 'dart:async';

import 'package:pos_tablet/data/source/product_service.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';
import 'package:shared_core/util/result.dart';

class FakeProductService implements ProductService {
  Result<List<CatalogueItem>> result = Result.ok(<CatalogueItem>[]);
  Completer<void>? gate;
  int calls = 0;

  @override
  Future<Result<List<CatalogueItem>>> fetchCatalogue() async {
    calls++;
    await gate?.future;
    return result;
  }

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw StateError('Unexpected call: ${i.memberName}');
}
