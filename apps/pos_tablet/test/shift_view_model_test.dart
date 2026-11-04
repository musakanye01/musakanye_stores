import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/ui/shifts/shift_view_model.dart';
import 'package:shared_core/util/result.dart';

import 'lib/data/fake_shift_repo.dart';
import 'lib/model/fake_shift.dart';

void main() {
  late FakeShiftRepository repo;
  late ShiftViewModel vm;

  setUp(() {
    repo = FakeShiftRepository();
    vm = ShiftViewModel(repo);
  });

  group('restoreShift', () {
    test('starts as unknown', () {
      expect(vm.state, ShiftState.unknown);
    });

    test('open shift in the repository gives open', () async {
      repo.openShiftResult = Result.ok(fakeShift('s1'));
      await vm.restoreShift();

      expect(vm.state, ShiftState.open);
      expect(vm.currentShift?.id, 's1');
    });

    test('no shift gives none', () async {
      await vm.restoreShift();
      expect(vm.state, ShiftState.none);
    });

    test('a read error gives none and never leaves it unknown', () async {
      repo.openShiftResult = Result.error(Exception('db broke'));
      await vm.restoreShift();
      expect(vm.state, ShiftState.none);
    });

    test('is idempotent: repeated and overlapping calls read once', () async {
      await Future.wait([vm.restoreShift(), vm.restoreShift()]);
      await vm.restoreShift();
      expect(repo.getOpenShiftCalls, 1);
    });

    test('notifies listeners when done', () async {
      var notified = 0;
      vm.addListener(() => notified++);
      await vm.restoreShift();
      expect(notified, 1);
    });
  });

  group('startShift', () {
    test('success moves to open', () async {
      await vm.startShift.execute(5000); // adjust to your Command1 API
      expect(vm.state, ShiftState.open);
      expect(vm.currentShift?.openingFloatCents, 5000);
    });

    test('failure leaves the state unchanged', () async {
      await vm.restoreShift();
      repo.startResult = Result.error(
        Exception('You already have an open shift.'),
      );

      await vm.startShift.execute(5000);
      expect(vm.state, ShiftState.none);
    });
  });

  group('closeCurrentShift', () {
    setUp(() async {
      repo.openShiftResult = Result.ok(fakeShift('s1'));
      await vm.restoreShift();
    });

    test('success moves to none', () async {
      final result = await vm.closeCurrentShift(countedCashCents: 1000);
      expect(result, isA<Ok<void>>());
      expect(vm.state, ShiftState.none);
    });

    test('failure keeps the shift open and records the error', () async {
      repo.closeResult = Result.error(Exception('disk full'));

      final result = await vm.closeCurrentShift(countedCashCents: 1000);
      expect(result, isA<Error<void>>());
      expect(vm.state, ShiftState.open);
      expect(vm.closeError, contains('disk full'));
    });

    test('second call while one is in flight is rejected', () async {
      repo.closeGate = Completer<Result<void>>();

      final first = vm.closeCurrentShift(countedCashCents: 1000);
      final second = await vm.closeCurrentShift(countedCashCents: 1000);

      expect(second, isA<Error<void>>());
      expect(repo.closeCalls, 1);

      repo.closeGate!.complete(const Result.ok(null));
      await first;
      expect(vm.state, ShiftState.none);
    });

    test('with no open shift, fails without calling the repository', () async {
      await vm.closeCurrentShift(countedCashCents: 1000); // closes it
      repo.closeCalls = 0;

      final result = await vm.closeCurrentShift(countedCashCents: 1000);
      expect(result, isA<Error<void>>());
      expect(repo.closeCalls, 0);
    });
  });

  group('reset', () {
    test(
      'returns to unknown so the next login re-reads the database',
      () async {
        repo.openShiftResult = Result.ok(fakeShift('s1'));
        await vm.restoreShift();

        vm.reset();
        expect(vm.state, ShiftState.unknown);
        expect(vm.currentShift, isNull);

        await vm.restoreShift();
        expect(repo.getOpenShiftCalls, 2);
      },
    );
  });
}
