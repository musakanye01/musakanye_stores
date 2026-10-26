import 'package:shared_core/domain/model/shift.dart';
import 'package:shared_core/domain/model/shift_sales_summary.dart';
import 'package:shared_core/util/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShiftService {
  final SupabaseClient _client;
  ShiftService(this._client);

  Future<Result<Shift>> startShift({
    required int openingFloatCents,
    required String idempotencyKey,
    required String shiftId,
    String? deviceId,
  }) async {
    if (_client.auth.currentUser == null) {
      return Result.error(Exception('You are not signed in.'));
    }

    try {
      final response = await _client.rpc(
        'open_shift',
        params: {
          'p_shift_id': shiftId,
          'p_idempotency_key': idempotencyKey,
          'p_opening_float_cents': openingFloatCents,
          'p_device_id': deviceId,
        },
      );

      final result = Map<String, dynamic>.from(response as Map);
      final returnedShiftId = result['shift_id'] as String?;
      final status = result['status'] as String?;

      if (returnedShiftId == null) {
        return Result.error(Exception('The server did not return a shift ID.'));
      }

      if (status != 'open') {
        return Result.error(
          Exception('This request refers to a shift that is not open.'),
        );
      }

      // The RPC returns a summary, so fetch the complete shift row.
      final row = await _client
          .from('shifts')
          .select()
          .eq('id', returnedShiftId)
          .single();

      return Result.ok(Shift.fromJson(row));
    } on PostgrestException catch (e) {
      if (e.code == '23505' &&
          e.message.contains('one_open_shift_per_cashier')) {
        return Result.error(Exception('You already have an open shift.'));
      }

      return Result.error(Exception(e.message));
    } catch (e) {
      return Result.error(Exception('Could not start shift: $e'));
    }
  }

  Future<Result<ShiftSalesSummary>> getSalesSummary(String shiftId) async {
    if (_client.auth.currentUser == null) {
      return Result.error(Exception('You are not signed in.'));
    }

    try {
      final sales = await _client
          .from('sales')
          .select('id')
          .eq('shift_id', shiftId)
          .eq('status', 'completed');

      final saleIds = sales.map((row) => row['id'] as String).toList();

      if (saleIds.isEmpty) {
        return const Result.ok(ShiftSalesSummary.empty());
      }

      final payments = await _client
          .from('payments')
          .select('sale_id, method, amount_cents')
          .inFilter('sale_id', saleIds);

      var cashCents = 0;
      var ecoCashCents = 0;

      for (final payment in payments) {
        final amount = (payment['amount_cents'] as num).toInt();

        switch (payment['method'] as String) {
          case 'cash':
            cashCents += amount;
            break;
          case 'ecocash_usd':
            ecoCashCents += amount;
            break;
        }
      }

      return Result.ok(
        ShiftSalesSummary(
          cashSalesCents: cashCents,
          ecoCashSalesCents: ecoCashCents,
        ),
      );
    } on PostgrestException catch (e) {
      return Result.error(Exception(e.message));
    } catch (e) {
      return Result.error(Exception('Could not load shift sales: $e'));
    }
  }

  Future<Result<Shift?>> getOpenShift() async {
    final cashierId = _client.auth.currentUser?.id;
    if (cashierId == null) return Result.ok(null);

    try {
      final row = await _client
          .from('shifts')
          .select()
          .eq('cashier_id', cashierId)
          .eq('status', 'open')
          .maybeSingle();
      return Result.ok(row == null ? null : Shift.fromJson(row));
    } on PostgrestException catch (e) {
      return Result.error(Exception(e.message));
    } catch (_) {
      return Result.error(Exception('Could not load shift.'));
    }
  }

  Future<Result<void>> closeShift({
    required String shiftId,
    required int countedCashCents,
    String? closingNote,
  }) async {
    if (_client.auth.currentUser == null) {
      return Result.error(Exception('You are not signed in.'));
    }

    if (countedCashCents < 0) {
      return Result.error(Exception('Counted cash cannot be negative.'));
    }

    try {
      await _client.rpc(
        'close_shift',
        params: {
          'p_shift_id': shiftId,
          'p_counted_cash_cents': countedCashCents,
          'p_closing_note': closingNote?.trim().isEmpty == true
              ? null
              : closingNote?.trim(),
        },
      );

      return const Result.ok(null);
    } on PostgrestException catch (e) {
      return Result.error(Exception(e.message));
    } catch (e) {
      return Result.error(Exception('Could not close shift: $e'));
    }
  }
}
