import 'package:shared_core/domain/model/catalogue_item.dart';
import 'package:shared_core/domain/model/stock_receiving_item.dart';

import 'package:shared_core/util/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StockReceivingService {
  final SupabaseClient _client;

  StockReceivingService(this._client);

  Future<Result<List<CatalogueItem>>> fetchProducts() async {
    try {
      final rows = await _client
          .from('product_variants')
          .select(
            'id, sku, size, colour, price_cents, stock_on_hand, '
            'products!inner(id, name, active, categories(name))',
          )
          .eq('active', true)
          .eq('products.active', true);

      final items =
          rows.map<CatalogueItem>((row) => CatalogueItem.fromJson(row)).toList()
            ..sort((a, b) {
              final byName = a.productName.toLowerCase().compareTo(
                b.productName.toLowerCase(),
              );

              if (byName != 0) return byName;

              return (a.variantLabel ?? '').compareTo(b.variantLabel ?? '');
            });

      return Result.ok(items);
    } on PostgrestException catch (e) {
      return Result.error(Exception(e.message));
    } catch (_) {
      return Result.error(
        Exception('Could not load products. Check your connection.'),
      );
    }
  }

  Future<Result<List<StockReceiptItem>>> fetchRecentItems() async {
    try {
      final rows = await _client
          .from('stock_receipt_items')
          .select(
            'receipt_id, variant_id, quantity, note, '
            'stock_receipts!inner(id, reference, status, created_at), '
            'product_variants!inner('
            'id, sku, size, colour, '
            'products!inner(name)'
            ')',
          )
          .order('receipt_id', ascending: false);

      final items =
          rows
              .map<StockReceiptItem>((row) => StockReceiptItem.fromJson(row))
              .toList()
            ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));

      return Result.ok(items);
    } on PostgrestException catch (e) {
      return Result.error(Exception(e.message));
    } catch (_) {
      return Result.error(Exception('Could not load recent stock receipts.'));
    }
  }

  Future<Result<void>> submitReceipt({
    required String receiptId,
    required String idempotencyKey,
    required String variantId,
    required int quantity,
    required String note,
    String? reference,
    String? deviceId,
  }) async {
    try {
      await _client.rpc(
        'submit_stock_receipt',
        params: {
          'p_receipt_id': receiptId,
          'p_idempotency_key': idempotencyKey,
          'p_device_id': deviceId,
          'p_reference': reference,
          'p_note': note,
          'p_items': [
            {'variant_id': variantId, 'quantity': quantity},
          ],
        },
      );

      return const Result.ok(null);
    } on PostgrestException catch (e) {
      return Result.error(Exception(e.message));
    } catch (_) {
      return Result.error(Exception('Could not submit the stock receipt.'));
    }
  }
}
