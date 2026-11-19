import 'package:pos_tablet/data/sync/shift_sync_service.dart';

class FakeShiftSyncService implements ShiftSyncService {
  final calls = <String>[];

  @override
  Future<void> syncOpenShifts() async {
    calls.add('open');
  }

  @override
  Future<void> syncClosedShifts() async {
    calls.add('close');
  }
}
