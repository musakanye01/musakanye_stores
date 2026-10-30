import 'package:drift/drift.dart';
import 'package:pos_tablet/data/source/shift_service.dart';
import 'package:shared_core/data/local/app_database.dart';
import 'package:shared_core/data/local/dao/shifts_dao.dart';
import 'package:shared_core/domain/model/shift.dart';
import 'package:shared_core/domain/model/shift_sales_summary.dart';
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
  final ShiftsDao _shiftsDao;

  ShiftRepositoryImpl(this._shiftService, this._shiftsDao);

  @override
  Future<Result<Shift>> startShift({
    required int openingFloatCents,
    required String idempotencyKey,
    String? deviceId,
  }) async {
    final cashierId = _shiftService.currentUserId;
    if (cashierId == null) {
      return Result.error(Exception('You are not signed in.'));
    }
    if (openingFloatCents < 0) {
      return Result.error(Exception('Opening float cannot be negative.'));
    }

    final shiftId = const Uuid().v4();
    final openedAt = DateTime.now().toUtc();

    final localShift = Shift(
      id: shiftId,
      cashierId: cashierId,
      deviceId: deviceId,
      openingFloatCents: openingFloatCents,
      status: 'open',
      openedAt: openedAt,
    );

    try {
      await _shiftsDao.upsertShift(
        ShiftsTableCompanion.insert(
          id: shiftId,
          cashierId: cashierId,
          status: 'open',
          openingFloatCents: openingFloatCents,
          idempotencyKey: idempotencyKey,
          openedAt: openedAt,
          synced: const Value(false),
        ),
      );
    } catch (e) {
      return Result.error(Exception('Could not save shift locally: $e'));
    }

    final remoteResult = await _shiftService.startShift(
      openingFloatCents: openingFloatCents,
      shiftId: shiftId,
      idempotencyKey: idempotencyKey,
      deviceId: deviceId,
    );

    switch (remoteResult) {
      case Ok<Shift>(value: final remoteShift):
        try {
          await _saveRemoteShift(remoteShift, idempotencyKey);
          await _shiftsDao.markSynced(shiftId);
        } catch (e) {
          await _shiftsDao.markSyncFailed(shiftId, e.toString());
        }
        return Result.ok(remoteShift);

      case Error<Shift>(error: final error):
        // A uniqueness conflict is a business rule violation, not an offline
        // condition. Keep the locally-created row from being treated as a
        // successful start in this case.
        if (error.toString().contains('already have an open shift') ||
            error.toString().contains('not signed in')) {
          return Result.error(error);
        }
        await _shiftsDao.markSyncFailed(shiftId, error.toString());
        return Result.ok(localShift);
    }
  }

  @override
  Future<Result<Shift?>> getOpenShift() async {
    final cashierId = _shiftService.currentUserId;
    if (cashierId == null) return Result.ok(null);

    try {
      final localShift = await _shiftsDao.getOpenShift(cashierId);
      if (localShift != null) {
        return Result.ok(ShiftsDao.toDomain(localShift));
      }

      // Do not restore a remote open shift if this device has an un-synced
      // local close for the cashier.
      if (await _shiftsDao.hasPendingClose(cashierId)) {
        return Result.ok(null);
      }

      final remoteResult = await _shiftService.getOpenShift();
      switch (remoteResult) {
        case Ok<Shift?>(value: final remoteShift):
          if (remoteShift == null) return Result.ok(null);
          await _saveRemoteShift(remoteShift, 'remote-${remoteShift.id}');
          await _shiftsDao.markSynced(remoteShift.id);
          return Result.ok(remoteShift);
        case Error<Shift?>(error: final error):
          return Result.error(error);
      }
    } catch (e) {
      return Result.error(Exception('Could not load local shift: $e'));
    }
  }

  @override
  Future<Result<ShiftSalesSummary>> getSalesSummary(String shiftId) {
    return _shiftService.getSalesSummary(shiftId);
  }

  @override
  Future<Result<void>> closeShift({
    required String shiftId,
    required int countedCashCents,
    String? closingNote,
  }) async {
    if (countedCashCents < 0) {
      return Result.error(Exception('Counted cash cannot be negative.'));
    }

    try {
      final localShift = await _shiftsDao.getById(shiftId);
      if (localShift == null) {
        return Result.error(Exception('The shift could not be found locally.'));
      }
      if (localShift.status != 'open') {
        return Result.error(Exception('This shift is already closed.'));
      }

      await _shiftsDao.markClosed(
        shiftId: shiftId,
        countedCashCents: countedCashCents,
        closingNote: closingNote?.trim().isEmpty == true
            ? null
            : closingNote?.trim(),
      );
    } catch (e) {
      return Result.error(Exception('Could not save shift close locally: $e'));
    }

    final remoteResult = await _shiftService.closeShift(
      shiftId: shiftId,
      countedCashCents: countedCashCents,
      closingNote: closingNote,
    );

    switch (remoteResult) {
      case Ok<void>():
        await _shiftsDao.markSynced(shiftId);
        return const Result.ok(null);
      case Error<void>(error: final error):
        await _shiftsDao.markSyncFailed(shiftId, error.toString());
        // The local close is authoritative for the tablet until sync retries.
        return const Result.ok(null);
    }
  }

  Future<void> _saveRemoteShift(Shift shift, String idempotencyKey) async {
    await _shiftsDao.upsertShift(
      ShiftsTableCompanion.insert(
        id: shift.id,
        cashierId: shift.cashierId,
        status: shift.status,
        openingFloatCents: shift.openingFloatCents,
        idempotencyKey: idempotencyKey,
        openedAt: shift.openedAt.toUtc(),
        closingCountedCents: Value(shift.closingFloatCents),
        synced: const Value(true),
      ),
    );
  }
}
