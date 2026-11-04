import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/data/local/app_database.dart';
import 'package:shared_core/domain/model/shift_sales_summary.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  // Adjust the required columns to match your SalesTable.
  Future<void> insertSale(
    String id, {
    required String shiftId,
    required String method,
    required int totalCents,
  }) => db
      .into(db.salesTable)
      .insert(
        SalesTableCompanion.insert(
          id: id,
          shiftId: shiftId,
          paymentMethod: method,
          totalCents: totalCents,
          idempotencyKey: 'key-$id',
          createdAt: DateTime.utc(2026, 11, 4, 9),
          tenderedCents: totalCents - 1,
          // tenderedCents, synced, etc.: whatever your table requires
        ),
      );

  test('shift with no sales gives zeros', () async {
    final s = await db.salesDao.watchShiftSummary('s1').first;
    expect(s.salesCount, 0);
    expect(s.cashSalesCents, 0);
    expect(s.ecoCashSalesCents, 0);
  });

  test('totals split by payment method', () async {
    await insertSale('a', shiftId: 's1', method: 'cash', totalCents: 500);
    await insertSale('b', shiftId: 's1', method: 'cash', totalCents: 250);
    await insertSale(
      'c',
      shiftId: 's1',
      method: 'ecocash_usd',
      totalCents: 1000,
    );

    final s = await db.salesDao.watchShiftSummary('s1').first;
    expect(s.salesCount, 3);
    expect(s.cashSalesCents, 750);
    expect(s.ecoCashSalesCents, 1000);
    expect(s.totalSalesCents, 1750);
  });

  test('only counts the requested shift', () async {
    await insertSale('a', shiftId: 's1', method: 'cash', totalCents: 500);
    await insertSale('b', shiftId: 's2', method: 'cash', totalCents: 9999);

    final s = await db.salesDao.watchShiftSummary('s1').first;
    expect(s.salesCount, 1);
    expect(s.cashSalesCents, 500);
  });

  test('emits again when a sale is added', () async {
    final emissions = <ShiftSalesSummary>[];
    final sub = db.salesDao.watchShiftSummary('s1').listen(emissions.add);
    await pumpEventQueue();

    await insertSale('a', shiftId: 's1', method: 'cash', totalCents: 500);
    await pumpEventQueue();

    expect(emissions.last.salesCount, 1);
    await sub.cancel();
  });
}
