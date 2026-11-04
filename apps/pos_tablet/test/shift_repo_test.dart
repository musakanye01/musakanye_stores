import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/data/local/app_database.dart';
import 'package:pos_tablet/data/repository/shift_repo.dart';
import 'package:pos_tablet/data/source/shift_service.dart';
import 'package:shared_core/domain/model/shift.dart';
import 'package:shared_core/util/result.dart';

/// Only currentUserId is allowed. Any other call means the repository touched
/// the network, which the offline-first design forbids, so the test fails.
class FakeShiftService implements ShiftService {
  @override
  String? currentUserId = 'cashier-1';

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('Network call attempted: ${invocation.memberName}');
}

void main() {
  late AppDatabase db;
  late FakeShiftService service;
  late ShiftRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(
      NativeDatabase.memory(),
    ); // constructor taking a QueryExecutor
    service = FakeShiftService();
    repo = ShiftRepositoryImpl(service, db.shiftsDao);
  });

  tearDown(() => db.close());

  Shift okValue(Result<Shift> r) => switch (r) {
    Ok<Shift>(value: final v) => v,
    Error<Shift>(error: final e) => fail('Expected Ok but got $e'),
  };

  Exception errValue(Result<Object?> r) => switch (r) {
    Error(error: final e) => e,
    Ok() => fail('Expected Error but got Ok'),
  };

  group('startShift', () {
    test('saves an open shift locally and returns it', () async {
      final shift = okValue(await repo.startShift(openingFloatCents: 5000));

      expect(shift.status, 'open');
      expect(shift.openingFloatCents, 5000);
      expect(shift.cashierId, 'cashier-1');

      final stored = await db.shiftsDao.getById(shift.id);
      expect(stored, isNotNull);
      expect(stored!.synced, isFalse); // the sync engine will pick it up
    });

    test('rejects a second start while one is open', () async {
      await repo.startShift(openingFloatCents: 5000);
      final second = await repo.startShift(openingFloatCents: 1000);

      expect(
        errValue(second).toString(),
        contains('already have an open shift'),
      );
      expect(await db.select(db.shiftsTable).get(), hasLength(1));
    });

    test('two simultaneous starts create exactly one shift', () async {
      final results = await Future.wait([
        repo.startShift(openingFloatCents: 1000),
        repo.startShift(openingFloatCents: 2000),
      ]);

      expect(results.whereType<Ok<Shift>>(), hasLength(1));
      expect(await db.select(db.shiftsTable).get(), hasLength(1));
    });

    test('rejects a negative opening float', () async {
      final result = await repo.startShift(openingFloatCents: -1);
      expect(errValue(result).toString(), contains('negative'));
      expect(await db.select(db.shiftsTable).get(), isEmpty);
    });

    test('fails when nobody is signed in', () async {
      service.currentUserId = null;
      final result = await repo.startShift(openingFloatCents: 1000);
      expect(errValue(result).toString(), contains('not signed in'));
    });

    test('can start again after closing the previous shift', () async {
      final first = okValue(await repo.startShift(openingFloatCents: 1000));
      await repo.closeShift(shiftId: first.id, countedCashCents: 1000);

      final second = await repo.startShift(openingFloatCents: 2000);
      expect(second, isA<Ok<Shift>>());
    });
  });

  group('getOpenShift', () {
    test('returns null when nothing is open', () async {
      final result = await repo.getOpenShift();
      expect((result as Ok<Shift?>).value, isNull);
    });

    test('returns the open shift', () async {
      final started = okValue(await repo.startShift(openingFloatCents: 5000));
      final result = await repo.getOpenShift();
      expect((result as Ok<Shift?>).value?.id, started.id);
    });

    test('returns null when signed out', () async {
      await repo.startShift(openingFloatCents: 5000);
      service.currentUserId = null;
      final result = await repo.getOpenShift();
      expect((result as Ok<Shift?>).value, isNull);
    });

    test(
      'survives a "restart": a new repository over the same database',
      () async {
        final started = okValue(await repo.startShift(openingFloatCents: 5000));

        final afterRestart = ShiftRepositoryImpl(service, db.shiftsDao);
        final result = await afterRestart.getOpenShift();
        expect((result as Ok<Shift?>).value?.id, started.id);
      },
    );
  });

  group('closeShift', () {
    test(
      'closes locally, leaves it unsynced, and nothing is open afterwards',
      () async {
        final shift = okValue(await repo.startShift(openingFloatCents: 5000));

        final result = await repo.closeShift(
          shiftId: shift.id,
          countedCashCents: 7000,
          closingNote: '  all good  ',
        );
        expect(result, isA<Ok<void>>());

        final stored = await db.shiftsDao.getById(shift.id);
        expect(stored!.status, 'closed');
        expect(stored.synced, isFalse);

        final open = await repo.getOpenShift();
        expect((open as Ok<Shift?>).value, isNull);
      },
    );

    test('closing twice fails the second time', () async {
      final shift = okValue(await repo.startShift(openingFloatCents: 5000));
      await repo.closeShift(shiftId: shift.id, countedCashCents: 5000);

      final again = await repo.closeShift(
        shiftId: shift.id,
        countedCashCents: 5000,
      );
      expect(errValue(again).toString(), contains('already closed'));
    });

    test('unknown shift id fails', () async {
      final result = await repo.closeShift(
        shiftId: 'missing',
        countedCashCents: 0,
      );
      expect(errValue(result).toString(), contains('could not be found'));
    });

    test('rejects negative counted cash and leaves the shift open', () async {
      final shift = okValue(await repo.startShift(openingFloatCents: 5000));
      final result = await repo.closeShift(
        shiftId: shift.id,
        countedCashCents: -5,
      );

      expect(errValue(result).toString(), contains('negative'));
      expect((await db.shiftsDao.getById(shift.id))!.status, 'open');
    });
  });
}
