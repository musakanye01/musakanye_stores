import 'package:pos_tablet/data/source/sync_failure.dart';
import 'package:pos_tablet/data/sync/model/pending_sale_sync.dart';
import 'package:shared_core/domain/model/sale_line.dart'; // wherever SaleResult lives
import 'package:shared_core/util/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class SaleService {
  Future<Result<SaleResult>> syncOfflineSale({
    required PendingSaleSync saleSync,
  });
}

/// Server-side sale operations. Offline-first: only the sync engine calls this.
class SaleServiceImp implements SaleService {
  SaleServiceImp(this._client);
  final SupabaseClient _client;

  @override
  Future<Result<SaleResult>> syncOfflineSale({
    required PendingSaleSync saleSync,
  }) async {
    try {
      final response = await _client.rpc(
        'sync_offline_sale',
        params: {
          'p_sale_id': saleSync.sale..id,
          'p_idempotency_key': saleSync.sale..idempotencyKey,
          'p_shift_id': saleSync.sale..shiftId,
          'p_device_id': "1", //todo
          'p_payment_method': saleSync.sale..paymentMethod,
          'p_created_at': saleSync.sale..createdAt.toIso8601String(),
          'p_total_cents': saleSync.sale..totalCents,
          'p_tendered_cents': saleSync.sale..tenderedCents,
          'p_items': saleSync.items,
        },
      );
      return Result.ok(SaleResult.fromJson(response as Map<String, dynamic>));
    } catch (error) {
      return Result.error(classifySyncError(error)); // retryable vs permanent
    }
  }
}
