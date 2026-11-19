import 'package:pos_tablet/data/local/dao/shifts_dao.dart';
import 'package:pos_tablet/data/source/shift_service.dart';
import 'package:shared_core/util/result.dart';

abstract interface class ShiftSyncService {
  Future<void> syncOpenShifts();

  Future<void> syncClosedShifts();
}

class ShiftSyncServiceImp implements ShiftSyncService {
  final ShiftService _shiftService;
  final ShiftsDao _shiftsDao;

  ShiftSyncServiceImp({required this._shiftService, required this._shiftsDao});

  @override
  Future<void> syncOpenShifts() async {
    print("Sync Open Shifts");
    final shifts = await _shiftsDao.getUnsyncedOpenShifts();

    for (final shift in shifts) {
      final result = await _shiftService.openShift(shift);

      switch (result) {
        case Ok<void>():
          await _shiftsDao.markOpenSynced(shift.id);

        case Error<void>():
          await _shiftsDao.markSyncFailed(shift.id, result.error.toString());
      }
    }
  }

  @override
  Future<void> syncClosedShifts() async {
    print("Sync Close Shifts");
    final shifts = await _shiftsDao.getUnsyncedClosedShifts();

    for (final shift in shifts) {
      final result = await _shiftService.closeShift(shift);

      switch (result) {
        case Ok<void>():
          await _shiftsDao.markCloseSynced(shift.id);

        case Error<void>():
          await _shiftsDao.markSyncFailed(shift.id, result.error.toString());
      }
    }
  }
}
