import 'package:pos_tablet/data/local/app_database.dart';
import 'package:pos_tablet/data/source/sync_failure.dart';
import 'package:shared_core/util/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ShiftService {
  String? get currentUserId;

  Future<Result<void>> openShift(ShiftsTableData shift);

  Future<Result<void>> closeShift(ShiftsTableData shift);
}

class ShiftServiceImp implements ShiftService {
  final SupabaseClient _client;
  ShiftServiceImp({required this._client});

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  Future<Result<void>> closeShift(ShiftsTableData shift) async {
    try {
      await _client.rpc(
        'close_shift',
        params: {
          'p_shift_id': shift.id,
          'p_close_idempotency_key': shift.closeIdempotencyKey,
          'p_counted_cash_cents': shift.closingCountedCents,
          'p_closed_at': shift.closedAt?.toIso8601String(),
          'p_closing_note': shift.closingNote,
        },
      );

      return const Result.ok(null);
    } catch (error) {
      return Result.error(classifySyncError(error));
    }
  }

  @override
  Future<Result<void>> openShift(ShiftsTableData shift) async {
    try {
      await _client.rpc(
        'open_shift',
        params: {
          'p_shift_id': shift.id,
          'p_idempotency_key': shift.idempotencyKey,
          'p_opening_float_cents': shift.openingFloatCents,
          'p_opened_at': shift.openedAt.toIso8601String(),
          'p_device_id': '1', // todo
        },
      );

      return const Result.ok(null);
    } catch (error) {
      return Result.error(classifySyncError(error));
    }
  }
}
