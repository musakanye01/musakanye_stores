import 'package:pos_tablet/data/source/shift_service.dart';
import 'package:shared_core/domain/shift.dart';
import 'package:shared_core/domain/shift_sales_summary.dart';
import 'package:shared_core/util/result.dart';
import 'package:uuid/uuid.dart';

abstract class ShiftRepository {
  Future<Result<Shift>> startShift({
    required int openingFloatCents,
    required String idempotencyKey,
    String? deviceId,
  });
  Future<Result<Shift?>> getOpenShift();

  Future<Result<ShiftSalesSummary>> getSalesSummary(String shiftId);

  Future<Result<void>> closeShift({
    required String shiftId,
    required int countedCashCents,
    String? closingNote,
  });
}

class ShiftRepositoryImpl implements ShiftRepository {
  final ShiftService _shiftService;
  ShiftRepositoryImpl(this._shiftService);

  @override
  Future<Result<Shift>> startShift({
    required int openingFloatCents,
    required String idempotencyKey,
    String? deviceId,
  }) async {
    final shiftId = const Uuid().v4();

    return _shiftService.startShift(
      openingFloatCents: openingFloatCents,
      shiftId: shiftId,
      idempotencyKey: idempotencyKey,
      deviceId: deviceId,
    );
  }

  @override
  Future<Result<Shift?>> getOpenShift() => _shiftService.getOpenShift();

  @override
  Future<Result<ShiftSalesSummary>> getSalesSummary(String shiftId) {
    return _shiftService.getSalesSummary(shiftId);
  }

  @override
  Future<Result<void>> closeShift({
    required String shiftId,
    required int countedCashCents,
    String? closingNote,
  }) {
    return _shiftService.closeShift(
      shiftId: shiftId,
      countedCashCents: countedCashCents,
      closingNote: closingNote,
    );
  }
}
