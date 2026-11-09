import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/data/local/app_database.dart';
import 'package:pos_tablet/data/repository/sale_repo.dart';
import 'package:shared_core/domain/model/sale_line.dart';
import 'package:shared_core/domain/model/sync_status.dart';
import 'package:shared_core/util/result.dart';

// plus your project imports

void main() {
  late AppDatabase db;
  late SaleRepositoryImpl repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SaleRepositoryImpl(db.salesDao, db.shiftsDao);

    await db.shiftsDao.upsertShift(
      ShiftsTableCompanion.insert(
        id: 'shift-1',
        cashierId: 'c1',
        status: 'open',
        openingFloatCents: 0,
        idempotencyKey: 'shift-1',
        openedAt: DateTime.utc(2026, 11, 5, 8),
      ),
    );

    // Adjust to your CatalogueTable's required columns.
    await db
        .into(db.catalogueTable)
        .insert(
          CatalogueTableCompanion.insert(
            variantId: 'v1',
            productName: 'Shirt',
            stockOnHand: 10,
            productId: '',
            priceCents: 99,
            cachedAt: DateTime.now(),
          ),
        );
  });

  tearDown(() => db.close());

  Future<Result<SaleResult>> sell({
    String id = 'sale-1',
    String method = 'cash',
    int qty = 2,
    int tendered = 2000,
    String shiftId = 'shift-1',
  }) => repo.createSale(
    saleId: id,
    idempotencyKey: 'key-$id',
    shiftId: shiftId,
    paymentMethod: method,
    items: [SaleLine(variantId: 'v1', quantity: qty, unitPriceCents: 500)],
    tenderedCents: tendered,
  );

  Future<int> stock() async =>
      (await db.select(db.catalogueTable).getSingle()).stockOnHand;

  test('cash sale is saved locally, unsynced, and stock is deducted', () async {
    final result = await sell();

    expect((result as Ok<SaleResult>).value.totalCents, 1000);
    final stored = await db.salesDao.getSaleById('sale-1');
    expect(stored!.synced, isFalse);
    expect(await stock(), 8);
  });

  test('EcoCash sale needs no tender', () async {
    final result = await sell(method: 'ecocash_usd', tendered: 0);
    expect(result, isA<Ok<SaleResult>>());
  });

  test('cash under-tender is rejected and nothing is written', () async {
    final result = await sell(tendered: 999);
    expect(result, isA<Error<SaleResult>>());
    expect(await db.salesDao.getSaleById('sale-1'), isNull);
    expect(await stock(), 10);
  });

  test('closed or missing shift is rejected', () async {
    await db.shiftsDao.markClosed(
      shiftId: 'shift-1',
      countedCashCents: 0,
      closingNote: null,
    );

    expect(await sell(), isA<Error<SaleResult>>());
    expect(await sell(id: 'sale-2', shiftId: 'nope'), isA<Error<SaleResult>>());
    expect(await stock(), 10);
  });

  test('insufficient stock is rejected and nothing is written', () async {
    final result = await sell(qty: 11, tendered: 99999);
    expect(result, isA<Error<SaleResult>>());
    expect(await db.salesDao.getSaleById('sale-1'), isNull);
    expect(await stock(), 10);
  });

  test('retrying the same sale id does not deduct stock twice', () async {
    await sell();
    await sell(); // same id
    expect(await stock(), 8);
  });

test('history comes from local data, newest first', () async {
    await sell(id: 'a');
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await sell(id: 'b');

    final history = await repo.getSalesHistory(shiftId: 'shift-1');
    expect(history.map((h) => h.id), ['b', 'a']);
  });

  test('history only contains the requested shift', () async {
    await db.shiftsDao.upsertShift(
      ShiftsTableCompanion.insert(
        id: 'shift-2',
        cashierId: 'c1',
        status: 'open',
        openingFloatCents: 0,
        idempotencyKey: 'shift-2',
        openedAt: DateTime.utc(2026, 11, 5, 9),
      ),
    );

    await sell(id: 'a', qty: 1);
    await sell(id: 'b', qty: 1, shiftId: 'shift-2');

    expect((await repo.getSalesHistory(shiftId: 'shift-1')).map((h) => h.id), [
      'a',
    ]);
    expect((await repo.getSalesHistory(shiftId: 'shift-2')).map((h) => h.id), [
      'b',
    ]);
    expect(await repo.getSalesHistory(shiftId: 'nope'), isEmpty);
  });

  test('paging is stable even when sales share the same second', () async {
    for (final id in ['a', 'b', 'c', 'd', 'e']) {
      await sell(id: id, qty: 1); // all land within one second
    }

    final page1 = await repo.getSalesHistory(
      shiftId: 'shift-1',
      limit: 2,
      offset: 0,
    );
    final page2 = await repo.getSalesHistory(
      shiftId: 'shift-1',
      limit: 2,
      offset: 2,
    );
    final page3 = await repo.getSalesHistory(
      shiftId: 'shift-1',
      limit: 2,
      offset: 4,
    );

    expect(page1.map((h) => h.id), ['e', 'd']);
    expect(page2.map((h) => h.id), ['c', 'b']);
    expect(page3.map((h) => h.id), ['a']);
  });
test('receipt is built locally with correct change', () async {
    await sell(tendered: 1500);

    final receipt = await repo.getSaleReceipt('sale-1');
    expect(receipt, isNotNull);
    expect(receipt!.totalCents, 1000);
    expect(receipt.tenderedCents, 1500);
    expect(receipt.changeCents, 500);
    expect(receipt.lines.single.name, contains('Shirt'));
    expect(receipt.lines.single.totalCents, 1000);
  });

  test('EcoCash receipt has no change', () async {
    await sell(method: 'ecocash_usd', tendered: 0);

    final receipt = await repo.getSaleReceipt('sale-1');
    expect(receipt!.isCash, isFalse);
    expect(receipt.changeCents, 0);
  });

  test('receipt for an unknown sale is null', () async {
    expect(await repo.getSaleReceipt('nope'), isNull);
  });

  test('a product removed from the catalogue shows as Unknown item', () async {
    await sell();
    await db.delete(db.catalogueTable).go();

    final receipt = await repo.getSaleReceipt('sale-1');
    expect(receipt!.lines.single.name, 'Unknown item');
  });

  test('history rows and receipts carry their sync status', () async {
    await sell(id: 'a');
    await sell(id: 'b');
    await sell(id: 'c');
    await db.salesDao.markSynced('a');
    await db.salesDao.markSyncFailed('b', 'rejected');

    final byId = {
      for (final h in await repo.getSalesHistory(shiftId: 'shift-1'))
        h.id: h.syncStatus,
    };
    expect(byId, {
      'a': SyncStatus.synced,
      'b': SyncStatus.failed,
      'c': SyncStatus.pending,
    });

    expect((await repo.getSaleReceipt('b'))!.syncStatus, SyncStatus.failed);
  });
}
