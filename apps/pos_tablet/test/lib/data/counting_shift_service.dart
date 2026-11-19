import 'package:pos_tablet/data/sync/shift_sync_service.dart';

class CountingShiftService implements ShiftSyncService {
  int openCalls = 0;

  int closeCalls = 0;

  @override
  Future<void> syncOpenShifts() async {
    openCalls++;

    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> syncClosedShifts() async {
    closeCalls++;
  }
}
