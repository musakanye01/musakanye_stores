import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/data/local/app_database.dart';
import 'package:pos_tablet/data/repository/product_repo.dart';

void main() {
  late AppDatabase db;
  late ProductRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ProductRepositoryImpl(db.catalogueDao); // adjust accessor name
  });
  tearDown(() => db.close());

  Future<void> addProduct(String variantId, String name, {int stock = 10}) => db
      .into(db.catalogueTable)
      .insert(
        CatalogueTableCompanion.insert(
          variantId: variantId,
          productName: name,
          stockOnHand: stock,
          productId: '',
          priceCents: 89,
          cachedAt: DateTime.now(),
          // plus any other columns your table requires
        ),
      );

  test('empty catalogue emits an empty list', () async {
    expect(await repo.watchCatalogue().first, isEmpty);
  });

  test('items are sorted by name, ignoring case', () async {
    await addProduct('v1', 'banana');
    await addProduct('v2', 'Apple');
    await addProduct('v3', 'cherry');

    final items = await repo.watchCatalogue().first;
    expect(items.map((i) => i.productName), ['Apple', 'banana', 'cherry']);
  });

  test('a local sale updates the stream without any refresh', () async {
    await addProduct('v1', 'Shirt', stock: 10);
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

    final stocks = <int>[];
    final sub = repo.watchCatalogue().listen(
      (items) => stocks.add(items.single.stockOnHand),
    );
    await pumpEventQueue();

    await db.salesDao.createSaleLocally(
      sale: SalesTableCompanion.insert(
        id: 'sale-1',
        shiftId: 'shift-1',
        paymentMethod: 'cash',
        totalCents: 1000,
        tenderedCents: 1000,
        idempotencyKey: 'key-1',
        createdAt: DateTime.utc(2026, 11, 5, 9),
      ),
      lines: [
        SaleLinesTableCompanion.insert(
          id: 'line-1',
          saleId: 'sale-1',
          variantId: 'v1',
          quantity: 2,
          unitPriceCents: 500,
        ),
      ],
    );
    await pumpEventQueue();

    expect(stocks.first, 10);
    expect(stocks.last, 8);
    await sub.cancel();
  });
}
