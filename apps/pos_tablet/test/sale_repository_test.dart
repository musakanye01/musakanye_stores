import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/data/local/app_database.dart';
import 'package:pos_tablet/data/repository/sale_repo.dart';
import 'package:shared_core/domain/model/sale_line.dart';
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

    final history = await repo.getSalesHistory();
    expect(history.map((h) => h.id), ['b', 'a']);
  });

  test('receipt is built locally with correct change', () async {
    await sell(tendered: 1500);

    final receipt = await repo.getSaleReceipt('sale-1');
    expect(receipt['sale']['total_cents'], 1000);
    expect(receipt['payment']['change_cents'], 500);
    final items = receipt['items'] as List;
    expect(items.single['product_name'], 'Shirt');
    expect(items.single['line_total_cents'], 1000);
  });
}
