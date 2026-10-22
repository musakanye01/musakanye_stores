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
        _client
            .from('sale_items')
            .select(
              'id, sale_id, variant_id, product_name, '
              'variant_description, quantity, unit_price_cents, '
              'line_total_cents',
            ),
      ]);

      final salesRows = List<Map<String, dynamic>>.from(responses[0]);

      final paymentRows = List<Map<String, dynamic>>.from(responses[1]);

      final itemRows = List<Map<String, dynamic>>.from(responses[2]);

      final paymentMethods = <String, String>{};

      for (final payment in paymentRows) {
        final saleId = payment['sale_id'] as String?;
        final method = payment['method'] as String?;

        if (saleId != null && method != null) {
          paymentMethods[saleId] = method;
        }
      }

      final itemsBySaleId = <String, List<Map<String, dynamic>>>{};

      for (final item in itemRows) {
        final saleId = item['sale_id'] as String;

        itemsBySaleId.putIfAbsent(saleId, () => []).add(item);
      }

      final sales = salesRows.map((row) {
        final saleId = row['id'] as String;

        return SaleHistory.fromJson({
          ...row,
          'payment_method': paymentMethods[saleId] ?? 'Unknown',
          'items': itemsBySaleId[saleId] ?? <Map<String, dynamic>>[],
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
            'id, cashier_id, device_id, opening_float_cents,counted_cash_cents, status, opened_at',
          )
          .order('opened_at', ascending: false);

      final rows = List<Map<String, dynamic>>.from(response);
      final shifts = rows.map(Shift.fromJson).toList();

      for (final s in shifts) {
        debugPrint('shift ${s.id}: closing=${s.closingFloatCents}');
      }

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
