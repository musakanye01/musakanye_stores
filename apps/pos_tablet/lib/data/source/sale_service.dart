import 'package:pos_tablet/data/source/sync_failure.dart';
import 'package:shared_core/domain/model/sale_line.dart'; // wherever SaleResult lives
import 'package:shared_core/util/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Server-side sale operations. Offline-first: only the sync engine calls this.
class SaleService {
  SaleService(this._client);
  final SupabaseClient _client;

  Future<Result<SaleResult>> syncOfflineSale({
    required String saleId,
    required String idempotencyKey,
    required String shiftId,
    required String paymentMethod,
    required DateTime createdAt,
    required int totalCents,
    required int? tenderedCents,
    required List<Map<String, dynamic>> items,
    String? deviceId,
  }) async {
    try {
      final response = await _client.rpc(
        'sync_offline_sale',
        params: {
          'p_sale_id': saleId,
          'p_idempotency_key': idempotencyKey,
          'p_shift_id': shiftId,
          'p_device_id': deviceId,
          'p_payment_method': paymentMethod,
          'p_created_at': createdAt.toUtc().toIso8601String(),
          'p_total_cents': totalCents,
          'p_tendered_cents': tenderedCents,
          'p_items': items,
        },
      );
      return Result.ok(SaleResult.fromJson(response as Map<String, dynamic>));
    } catch (error) {
      return Result.error(classifySyncError(error)); // retryable vs permanent
    }
  }
}
