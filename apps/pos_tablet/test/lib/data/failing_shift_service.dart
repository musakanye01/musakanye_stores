import 'package:pos_tablet/data/local/app_database.dart';
import 'package:pos_tablet/data/source/shift_service.dart';
import 'package:shared_core/util/result.dart';

class FailureShiftService implements ShiftService {
  @override
  String? get currentUserId => null;

  @override
  Future<Result<void>> openShift(ShiftsTableData shift) async {
    return Result.error(Exception('open failed'));
  }

  @override
  Future<Result<void>> closeShift(ShiftsTableData shift) async {
    return Result.error(Exception('close failed'));
  }
}
