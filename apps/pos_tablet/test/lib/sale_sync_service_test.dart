import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/data/local/app_database.dart';
import 'package:pos_tablet/data/local/dao/sales_dao.dart';
import 'package:pos_tablet/data/sync/sale_sync_service.dart';

import 'data/failure_sale_service.dart';
import 'data/partial_failing_sale_service.dart';
import 'data/success_sale_service.dart';

void main() {
  late AppDatabase db;
  late SalesDao dao;

  Future<void> seedCatalogue() async {
    await db
        .into(db.catalogueTable)
        .insert(
          CatalogueTableCompanion.insert(
            variantId: 'variant-1',
            productId: 'product-1',
            productName: 'Test Product',
            size: const Value(null),
            colour: const Value(null),
            priceCents: 100,
            stockOnHand: 50,
            cachedAt: DateTime.now(),
          ),
        );
  }

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = SalesDao(db);
    await seedCatalogue();
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insertSale(String id, DateTime createdAt) async {
    await dao.createSaleLocally(
      sale: SalesTableCompanion.insert(
        id: id,
        shiftId: 'shift-1',
        paymentMethod: 'cash',
        totalCents: 100,
        tenderedCents: 100,
        idempotencyKey: '$id-key',
        createdAt: createdAt,
      ),
      lines: [
        SaleLinesTableCompanion.insert(
          id: '$id-line',
          saleId: id,
          variantId: 'variant-1',
          quantity: 1,
          unitPriceCents: 100,
        ),
      ],
    );
  }

  test('syncSales marks sale synced', () async {
    await insertSale('sale-1', DateTime.now());

    final sut = SaleSyncServiceImpl(dao, SuccessSaleService());

    await sut.syncSales();

    final sale = await dao.getSaleById('sale-1');

    expect(sale!.synced, true);

    expect(sale.syncError, false);
  });

  test('syncSales records failure', () async {
    await insertSale('sale-1', DateTime.now());

    final sut = SaleSyncServiceImpl(dao, FailureSaleService());

    await sut.syncSales();

    final sale = await dao.getSaleById('sale-1');

    expect(sale!.synced, false);

    expect(sale.syncError, true);
  });

  test('continues syncing after one failure', () async {
    await insertSale('sale-1', DateTime(2026, 18, 11));

    await insertSale('sale-2', DateTime.now());

    var partiallyFailingSaleService = PartiallyFailingSaleService();
    final sut = SaleSyncServiceImpl(dao, partiallyFailingSaleService);

    await sut.syncSales();

    final first = await dao.getSaleById('sale-1');

    final second = await dao.getSaleById('sale-2');

    expect(first!.syncError, true);

    expect(first.synced, false);

    expect(second!.synced, true);
  });

  test('syncSales handles empty queue', () async {
    final sut = SaleSyncServiceImpl(dao, SuccessSaleService());

    await sut.syncSales();

    expect(await dao.getUnsynced(), isEmpty);
  });
}
