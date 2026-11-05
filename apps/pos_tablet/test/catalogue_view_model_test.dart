import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/data/repository/product_repo.dart';
import 'package:pos_tablet/ui/sales/viewmodel/catalogue_view_model.dart';
import 'package:shared_core/domain/model/catalogue_item.dart';

import 'lib/model/fake_catalogue_item.dart';

class FakeProductRepository implements ProductRepository {
  final controller =
      StreamController<
        List<CatalogueItem>
      >.broadcast(); // the change is worth investigating.

  @override
  Stream<List<CatalogueItem>> watchCatalogue() => controller.stream;

  void dispose() {
    controller.close();
  }
}

void main() {
  late FakeProductRepository repo;
  late CatalogueViewModel vm;

  setUp(() {
    repo = FakeProductRepository();
    vm = CatalogueViewModel(repo);
  });
  tearDown(() {
    vm.dispose();
    repo.dispose();
  });

  test('not loaded until the first emission', () async {
    expect(vm.hasLoaded, isFalse);
    expect(vm.isCatalogueEmpty, isFalse); // still loading, not empty

    repo.controller.add([]);
    await pumpEventQueue();

    expect(vm.hasLoaded, isTrue);
    expect(vm.isCatalogueEmpty, isTrue);
  });

  test('follows the stream and filters by search', () async {
    repo.controller.add([
      fakeCatalogueItem('v1', 'Shirt'),
      fakeCatalogueItem('v2', 'Shoes'),
    ]);
    await pumpEventQueue();

    vm.setSearchQuery('shi');
    expect(vm.filteredItems.map((i) => i.productName), ['Shirt']);
  });

  test('a stream error is exposed and does not leave it loading', () async {
    repo.controller.addError(Exception('db broke'));
    await pumpEventQueue();

    expect(vm.error, isNotNull);
    expect(vm.hasLoaded, isTrue);
  });

  test('dispose cancels the subscription', () async {
    vm.dispose();
    expect(repo.controller.hasListener, isFalse);
    vm = CatalogueViewModel(repo); // so tearDown has something to dispose
  });
}
