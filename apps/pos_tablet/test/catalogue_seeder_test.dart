import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/data/local/app_database.dart';
import 'package:pos_tablet/data/local/dao/catalogue_dao.dart';
import 'package:pos_tablet/data/source/catalogue_seeder.dart';
import 'package:shared_core/util/result.dart';

import 'lib/data/fake_product_service.dart';
import 'lib/model/fake_catalogue_item.dart';

void main() {
  late AppDatabase db;
  late FakeProductService service;
  late CatalogueSeeder seeder;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = FakeProductService();
    seeder = CatalogueSeeder(service, db.catalogueDao);
  });
  tearDown(() => db.close());

  test('fills an empty catalogue', () async {
    service.result = Result.ok([fakeCatalogueItem('v1', 'Shirt')]);
    await seeder.seedIfEmpty();
    expect(await db.catalogueDao.getAll(), hasLength(1));
  });

  test('never fetches or overwrites a non-empty catalogue', () async {
    await db.catalogueDao.replaceAll([
      CatalogueDao.fromDomain(fakeCatalogueItem('v1', 'Shirt', stock: 3)),
    ]);
    service.result = Result.ok([fakeCatalogueItem('v1', 'Shirt', stock: 99)]);

    await seeder.seedIfEmpty();

    expect(service.calls, 0);
    expect((await db.catalogueDao.getAll()).single.stockOnHand, 3);
  });

  test('a failed fetch leaves it empty and does not throw', () async {
    service.result = Result.error(Exception('offline'));
    await seeder.seedIfEmpty();
    expect(await db.catalogueDao.getAll(), isEmpty);
  });

  test('overlapping calls fetch once', () async {
    service.gate = Completer<void>();
    service.result = Result.ok([fakeCatalogueItem('v1', 'Shirt')]);

    final a = seeder.seedIfEmpty();
    final b = seeder.seedIfEmpty();
    service.gate!.complete();
    await Future.wait([a, b]);

    expect(service.calls, 1);
  });
}
