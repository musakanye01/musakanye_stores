import 'package:flutter/foundation.dart';
import 'package:shared_core/domain/model/sale_history.dart';
import 'package:shared_core/domain/model/shift.dart';
import 'package:shared_core/util/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerOperationsService {
  OwnerOperationsService(this._client);

  final SupabaseClient _client;

  Future<Result<List<SaleHistory>>> fetchSales() async {
    try {
      final responses = await Future.wait([
        _client
            .from('sales')
            .select('id, cashier_id, total_cents, status, created_at')
            .order('created_at', ascending: false),
        _client.from('payments').select('sale_id, method'),
      ]);

      final salesRows = List<Map<String, dynamic>>.from(responses[0]);
      final paymentRows = List<Map<String, dynamic>>.from(responses[1]);

      final paymentMethods = <String, String>{};

      for (final payment in paymentRows) {
        final saleId = payment['sale_id'] as String?;
        final method = payment['method'] as String?;

        if (saleId != null && method != null) {
          paymentMethods[saleId] = method;
        }
      }

      final sales = salesRows.map((row) {
        return SaleHistory.fromJson({
          ...row,
          'payment_method': paymentMethods[row['id'] as String] ?? 'Unknown',
        });
      }).toList();

      return Result.ok(sales);
    } on PostgrestException catch (e, s) {
      debugPrint('Owner operations sales query failed: ${e.message}\n$s');
      return Result.error(
        Exception('Unable to load sales activity. Please try again.'),
      );
    } catch (e, s) {
      debugPrint('Owner operations sales query failed: $e\n$s');
      return Result.error(
        Exception('Unable to load sales activity. Check your connection.'),
      );
    }
  }

  Future<Result<List<Shift>>> fetchShifts() async {
    try {
      final response = await _client
          .from('shifts')
          .select(
            'id, cashier_id, device_id, opening_float_cents, status, opened_at',
          )
          .order('opened_at', ascending: false);

      final rows = List<Map<String, dynamic>>.from(response);
      final shifts = rows.map(Shift.fromJson).toList();

      return Result.ok(shifts);
    } on PostgrestException catch (e, s) {
      debugPrint('Owner operations shifts query failed: ${e.message}\n$s');
      return Result.error(
        Exception('Unable to load shift activity. Please try again.'),
      );
    } catch (e, s) {
      debugPrint('Owner operations shifts query failed: $e\n$s');
      return Result.error(
        Exception('Unable to load shift activity. Check your connection.'),
      );
    }
  }
}
