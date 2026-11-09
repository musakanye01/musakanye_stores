import 'dart:async';

import 'package:pos_tablet/data/repository/shift_repo.dart';
import 'package:shared_core/domain/model/shift.dart';
import 'package:shared_core/util/result.dart';

Shift shiftFixture(String id, [int openingFloatCents = 1000]) => Shift(
  id: id,
  cashierId: 'cashier-1',
  openingFloatCents: openingFloatCents,
  status: 'open',
  openedAt: DateTime.utc(2026, 11, 4, 8),
  deviceId: 'device-1',
);

class FakeShiftRepository implements ShiftRepository {
  Result<Shift?> openShiftResult = const Result.ok(null);
  Result<Shift>? startResult;
  Result<void> closeResult = const Result.ok(null);
  Completer<Result<void>>? closeGate; // lets a test hold a close in flight

  int getOpenShiftCalls = 0;
  int closeCalls = 0;

  @override
  Future<Result<Shift?>> getOpenShift() async {
    getOpenShiftCalls++;
    return openShiftResult;
  }

  @override
  Future<Result<Shift>> startShift({
    required int openingFloatCents,
    String? deviceId,
  }) async => startResult ?? Result.ok(shiftFixture('new', openingFloatCents));

  @override
  Future<Result<void>> closeShift({
    required String shiftId,
    required int countedCashCents,
    String? closingNote,
  }) {
    closeCalls++;
    return closeGate?.future ?? Future.value(closeResult);
  }
}
