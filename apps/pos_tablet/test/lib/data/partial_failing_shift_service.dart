import 'package:pos_tablet/data/local/app_database.dart';
import 'package:pos_tablet/data/source/shift_service.dart';
import 'package:shared_core/util/result.dart';

class PartiallyFailingShiftService implements ShiftService {
  bool firstCall = true;

  @override
  String? get currentUserId => null;

  @override
  Future<Result<void>> openShift(ShiftsTableData shift) async {
    if (firstCall) {
      firstCall = false;

      return Result.error(Exception('boom'));
    }

    return const Result.ok(null);
  }

  @override
  Future<Result<void>> closeShift(ShiftsTableData shift) async {
    return const Result.ok(null);
  }
}
