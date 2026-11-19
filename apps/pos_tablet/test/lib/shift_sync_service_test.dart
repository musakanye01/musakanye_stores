import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/data/local/app_database.dart';
import 'package:pos_tablet/data/local/dao/shifts_dao.dart';
import 'package:pos_tablet/data/sync/shift_sync_service.dart';

import 'data/failing_shift_service.dart';
import 'data/partial_failing_shift_service.dart';
import 'data/success_shift_service.dart';

void main() {
  late AppDatabase db;
  late ShiftsDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = ShiftsDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('syncOpenShifts marks shift as open synced', () async {
    await dao.upsertShift(
      ShiftsTableCompanion.insert(
        id: 'shift-1',
        cashierId: 'cashier',
        status: 'open',
        openingFloatCents: 100,
        idempotencyKey: 'key-1',
        openedAt: DateTime.now(),
      ),
    );

    final sut = ShiftSyncServiceImp(
      shiftService: SuccessShiftService(),
      shiftsDao: dao,
    );

    await sut.syncOpenShifts();

    final shift = await dao.getById('shift-1');

    expect(shift!.openSynced, true);

    expect(shift.syncError, false);
  });

  test('syncOpenShifts records sync failure', () async {
    await dao.upsertShift(
      ShiftsTableCompanion.insert(
        id: 'shift-1',
        cashierId: 'cashier',
        status: 'open',
        openingFloatCents: 100,
        idempotencyKey: 'key-1',
        openedAt: DateTime.now(),
      ),
    );

    final sut = ShiftSyncServiceImp(
      shiftService: FailureShiftService(),
      shiftsDao: dao,
    );

    await sut.syncOpenShifts();

    final shift = await dao.getById('shift-1');

    expect(shift!.openSynced, false);

    expect(shift.syncError, true);
  });

  test('syncClosedShifts marks shift as close synced', () async {
    await dao.upsertShift(
      ShiftsTableCompanion.insert(
        id: 'shift-1',
        cashierId: 'cashier',
        status: 'closed',
        openingFloatCents: 100,
        idempotencyKey: 'key-1',
        closeIdempotencyKey: const Value('close-key'),
        openedAt: DateTime.now(),
        closedAt: Value(DateTime.now()),
      ),
    );

    final sut = ShiftSyncServiceImp(
      shiftService: SuccessShiftService(),
      shiftsDao: dao,
    );

    await sut.syncClosedShifts();

    final shift = await dao.getById('shift-1');

    expect(shift!.closeSynced, true);
  });

  test('syncClosedShifts records sync failure', () async {
    await dao.upsertShift(
      ShiftsTableCompanion.insert(
        id: 'shift-1',
        cashierId: 'cashier',
        status: 'closed',
        openingFloatCents: 100,
        idempotencyKey: 'key-1',
        closeIdempotencyKey: const Value('close-key'),
        openedAt: DateTime.now(),
        closedAt: Value(DateTime.now()),
      ),
    );

    final sut = ShiftSyncServiceImp(
      shiftService: FailureShiftService(),
      shiftsDao: dao,
    );

    await sut.syncClosedShifts();

    final shift = await dao.getById('shift-1');

    expect(shift!.closeSynced, false);

    expect(shift.syncError, true);
  });

  test('continues syncing after one failure', () async {
    await dao.upsertShift(
      ShiftsTableCompanion.insert(
        id: 'shift-1',
        cashierId: 'cashier',
        status: 'open',
        openingFloatCents: 100,
        idempotencyKey: 'key-1',
        openedAt: DateTime.now(),
      ),
    );

    await dao.upsertShift(
      ShiftsTableCompanion.insert(
        id: 'shift-2',
        cashierId: 'cashier',
        status: 'open',
        openingFloatCents: 100,
        idempotencyKey: 'key-2',
        openedAt: DateTime.now(),
      ),
    );

    final sut = ShiftSyncServiceImp(
      shiftService: PartiallyFailingShiftService(),
      shiftsDao: dao,
    );

    await sut.syncOpenShifts();

    final first = await dao.getById('shift-1');

    final second = await dao.getById('shift-2');

    expect(first!.syncError, true);

    expect(first.openSynced, false);

    expect(second!.openSynced, true);
  });
}
