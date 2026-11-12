import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/data/local/app_database.dart';
import 'package:pos_tablet/data/local/dao/bootstrap_dao.dart';
import 'package:shared_core/domain/model/boot_strap_model.dart';
import 'package:shared_core/util/result.dart';

void main() {
  late AppDatabase database;
  late BootstrapDao dao;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());

    dao = BootstrapDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  BootstrapCatalogueItem catalogueItem({
    required String variantId,
    required String productName,
  }) {
    return BootstrapCatalogueItem(
      variantId: variantId,
      productId: 'product-$variantId',
      productName: productName,
      categoryId: 'category-1',
      categoryName: 'Drinks',
      sku: 'SKU-$variantId',
      size: '300ml',
      colour: null,
      description: null,
      priceCents: 150,
      stockOnHand: 10,
    );
  }

  group('bootstrapCatalogue', () {
    test('writes catalogue rows', () async {
      final result = await dao.bootstrapCatalogue([
        catalogueItem(variantId: 'v1', productName: 'Coke'),
        catalogueItem(variantId: 'v2', productName: 'Fanta'),
      ]);

      switch (result) {
        case Ok<void>():
          break;

        case Error<void>():
          fail(result.error.toString());
      }

      final rows = await database.select(database.catalogueTable).get();

      expect(rows.length, 2);

      expect(rows.map((e) => e.productName), containsAll(['Coke', 'Fanta']));
    });

    test('replaces existing catalogue', () async {
      await dao.bootstrapCatalogue([
        catalogueItem(variantId: 'old', productName: 'Old Product'),
      ]);

      await dao.bootstrapCatalogue([
        catalogueItem(variantId: 'new', productName: 'New Product'),
      ]);

      final rows = await database.select(database.catalogueTable).get();

      expect(rows.length, 1);

      expect(rows.first.variantId, 'new');

      expect(rows.first.productName, 'New Product');
    });

    test('creates bootstrap state row', () async {
      await dao.bootstrapCatalogue([
        catalogueItem(variantId: 'v1', productName: 'Coke'),
      ]);

      final state = await database.select(database.bootstrapState).getSingle();

      expect(state.id, 1);
      expect(state.completedAt, isNotNull);
    });

    test('all catalogue items share same cached timestamp', () async {
      await dao.bootstrapCatalogue([
        catalogueItem(variantId: 'v1', productName: 'Coke'),
        catalogueItem(variantId: 'v2', productName: 'Fanta'),
        catalogueItem(variantId: 'v3', productName: 'Sprite'),
      ]);

      final rows = await database.select(database.catalogueTable).get();

      expect(rows.length, 3);

      final cachedAt = rows.first.cachedAt;

      for (final row in rows) {
        expect(row.cachedAt, cachedAt);
      }
    });
  });

  group('isBootstrapped', () {
    test('returns false for fresh database', () async {
      final result = await dao.isBootstrapped();

      switch (result) {
        case Ok<bool>():
          expect(result.value, false);

        case Error<bool>():
          fail(result.error.toString());
      }
    });

    test('returns true after bootstrap', () async {
      await dao.bootstrapCatalogue([
        catalogueItem(variantId: 'v1', productName: 'Coke'),
      ]);

      final result = await dao.isBootstrapped();

      switch (result) {
        case Ok<bool>():
          expect(result.value, true);

        case Error<bool>():
          fail(result.error.toString());
      }
    });

    test('bootstrap state exists after successful bootstrap', () async {
      await dao.bootstrapCatalogue([
        catalogueItem(variantId: 'v1', productName: 'Coke'),
      ]);

      final state = await database
          .select(database.bootstrapState)
          .getSingleOrNull();

      expect(state, isNotNull);
    });
  });
}
