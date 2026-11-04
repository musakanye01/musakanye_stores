import 'package:drift/drift.dart';
import 'package:pos_tablet/data/local/app_database.dart';
import 'package:pos_tablet/data/local/dao/shifts_dao.dart';
import 'package:pos_tablet/data/source/shift_service.dart';
import 'package:shared_core/domain/model/shift.dart';
import 'package:shared_core/util/result.dart';
import 'package:uuid/uuid.dart';

abstract class ShiftRepository {
  Future<Result<Shift>> startShift({
    required int openingFloatCents,
    String? deviceId,
  });

  Future<Result<Shift?>> getOpenShift();

  Future<Result<void>> closeShift({
    required String shiftId,
    required int countedCashCents,
    String? closingNote,
  });
}

class ShiftRepositoryImpl implements ShiftRepository {
  final ShiftService _shiftService; // used only for currentUserId for now
  final ShiftsDao _shiftsDao;

  ShiftRepositoryImpl(this._shiftService, this._shiftsDao);

  @override
  Future<Result<Shift>> startShift({
    required int openingFloatCents,
    String? deviceId,
  }) async {
    final cashierId =
        _shiftService.currentUserId; // read from persisted session
    if (cashierId == null) {
      return Result.error(Exception('You are not signed in.'));
    }
    if (openingFloatCents < 0) {
      return Result.error(Exception('Opening float cannot be negative.'));
    }

    final shiftId = const Uuid().v4();
    final openedAt = DateTime.now().toUtc();

    try {
      final inserted = await _shiftsDao.insertIfNoneOpen(
        ShiftsTableCompanion.insert(
          id: shiftId,
          cashierId: cashierId,
          status: 'open',
          openingFloatCents: openingFloatCents,
          idempotencyKey:
              shiftId, // the shift id is the key; column can go later
          openedAt: openedAt,
          synced: const Value(false),
        ),
        cashierId,
      );

      if (!inserted) {
        return Result.error(Exception('You already have an open shift.'));
      }
    } catch (e) {
      return Result.error(Exception('Could not save shift locally: $e'));
    }

    return Result.ok(
      Shift(
        id: shiftId,
        cashierId: cashierId,
        deviceId: deviceId,
        openingFloatCents: openingFloatCents,
        status: 'open',
        openedAt: openedAt,
      ),
    );
  }

  @override
  Future<Result<Shift?>> getOpenShift() async {
    final cashierId = _shiftService.currentUserId;
    if (cashierId == null) return Result.ok(null);

    try {
      final local = await _shiftsDao.getOpenShift(cashierId);
      return Result.ok(local == null ? null : ShiftsDao.toDomain(local));
    } catch (e) {
      return Result.error(Exception('Could not load local shift: $e'));
    }
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
      final local = await _shiftsDao.getById(shiftId);
      if (local == null) {
        return Result.error(Exception('The shift could not be found locally.'));
      }
      if (local.status != 'open') {
        return Result.error(Exception('This shift is already closed.'));
      }

      final note = closingNote?.trim();
      await _shiftsDao.markClosed(
        shiftId: shiftId,
        countedCashCents: countedCashCents,
        closingNote: (note == null || note.isEmpty) ? null : note,
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Could not save shift close locally: $e'));
    }
  }
}
