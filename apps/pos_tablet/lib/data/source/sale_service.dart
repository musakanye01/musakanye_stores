import 'package:flutter/material.dart';
import 'package:shared_core/domain/model/sale_history.dart';
import 'package:shared_core/domain/model/sale_line.dart';
import 'package:shared_core/util/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaleService {
  final SupabaseClient _client;
  SaleService(this._client);

  Future<Result<SaleResult>> createCashSale({
    required String saleId,
    required String idempotencyKey,
    required String shiftId,
    required List<SaleLine> items,
    required int tenderedCents,
    String? deviceId,
  }) async {
    try {
      debugPrint('Authenticated user: ${_client.auth.currentUser?.id}');
      debugPrint(
        'Current session exists: ${_client.auth.currentSession != null}',
      );
      debugPrint('Shift ID being submitted: $shiftId');
      final response = await _client.rpc(
        'create_cash_sale',
        params: {
          'p_sale_id': saleId,
          'p_idempotency_key': idempotencyKey,
          'p_shift_id': shiftId,
          'p_device_id': deviceId,
          'p_items': items.map((i) => i.toJson()).toList(),
          'p_tendered_cents': tenderedCents,
        },
      );
      return Result.ok(SaleResult.fromJson(response as Map<String, dynamic>));
    } on PostgrestException catch (e) {
      return Result.error(Exception(_friendly(e.message)));
    } catch (_) {
      return Result.error(
        Exception(
          'Could not complete the sale. Check your connection and try again.',
        ),
      );
    }
  }

  String _friendly(String message) {
    if (message.contains('Insufficient stock')) {
      return 'Some items are no longer in stock in that quantity. '
          'Go back and review the cart.';
    }
    if (message.contains('inactive')) {
      return 'An item in the cart is no longer available.';
    }
    if (message.contains('open shift')) {
      return 'You need an open shift to make a sale.';
    }
    if (message.contains('Cash tendered is less')) {
      return 'The amount received no longer covers the total. Prices may have changed.';
    }
    if (message.contains('cashier profile')) {
      return 'Only active cashier accounts can make sales.';
    }
    return message;
  }

  Future<Map<String, dynamic>> getSaleReceipt(String saleId) async {
    final sale = await _client
        .from('sales')
        .select('id, total_cents, created_at, status')
        .eq('id', saleId)
        .single();

    final itemRows = await _client
        .from('sale_items')
        .select(
          'variant_id, product_name, variant_description, '
          'quantity, unit_price_cents, line_total_cents',
        )
        .eq('sale_id', saleId)
        .order('created_at');

    final payment = await _client
        .from('payments')
        .select('method, amount_cents, tendered_cents, change_cents')
        .eq('sale_id', saleId)
        .single();

    return {
      'sale': sale,
      'items': List<Map<String, dynamic>>.from(itemRows),
      'payment': payment,
    };
  }

  Future<List<SaleHistory>> getSalesHistory({
    int offset = 0,
    int limit = 50,
  }) async {
    final rows = await _client
        .from('sales')
        .select('id, cashier_id, total_cents, status, created_at')
        .order('created_at', ascending: false)
        .order('id', ascending: false)
        .range(offset, offset + limit - 1);

    final sales = List<Map<String, dynamic>>.from(rows);

    if (sales.isEmpty) return [];

    final saleIds = sales.map((sale) => sale['id'] as String).toList();

    final paymentRows = await _client
        .from('payments')
        .select('sale_id, method')
        .inFilter('sale_id', saleIds);

    final methodsBySaleId = <String, String>{
      for (final payment in paymentRows)
        payment['sale_id'] as String: payment['method'] as String,
    };

    return sales.map((sale) {
      return SaleHistory.fromJson({
        ...sale,
        'payment_method': methodsBySaleId[sale['id']] ?? 'Unknown',
      });
    }).toList();
  }
}
