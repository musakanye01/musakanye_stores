import 'package:shared_core/domain/model/shift.dart';

Shift fakeShift(String id, [int float = 1000]) => Shift(
  id: id,
  cashierId: 'cashier-1',
  openingFloatCents: float,
  deviceId: null,
  status: 'open',
  openedAt: DateTime.utc(2026, 11, 4, 8),
);
