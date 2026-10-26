import 'package:shared_core/domain/model/catalogue_item.dart';
import 'package:shared_core/domain/model/stock_receiving_item.dart';
import 'package:shared_core/util/result.dart';

import '../source/stock_receiving_service.dart';

abstract class StockReceivingRepository {
  Future<Result<List<CatalogueItem>>> getProducts();

  Future<Result<List<StockReceiptItem>>> getRecentItems();

  Future<Result<void>> submitReceipt({
    required String receiptId,
    required String idempotencyKey,
    required String variantId,
    required int quantity,
    required String note,
    String? reference,
    String? deviceId,
  });
}

class StockReceivingRepositoryImpl implements StockReceivingRepository {
  final StockReceivingService _service;

  StockReceivingRepositoryImpl(this._service);

  @override
  Future<Result<List<CatalogueItem>>> getProducts() => _service.fetchProducts();

  @override
  Future<Result<List<StockReceiptItem>>> getRecentItems() =>
      _service.fetchRecentItems();

  @override
  Future<Result<void>> submitReceipt({
    required String receiptId,
    required String idempotencyKey,
    required String variantId,
    required int quantity,
    required String note,
    String? reference,
    String? deviceId,
  }) {
    return _service.submitReceipt(
      receiptId: receiptId,
      idempotencyKey: idempotencyKey,
      variantId: variantId,
      quantity: quantity,
      note: note,
      reference: reference,
      deviceId: deviceId,
    );
  }
}
