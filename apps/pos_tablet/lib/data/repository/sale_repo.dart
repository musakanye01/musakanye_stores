import 'package:pos_tablet/data/source/sale_service.dart';
import 'package:shared_core/domain/model/sale_history.dart';
import 'package:shared_core/domain/model/sale_line.dart';

import 'package:shared_core/util/result.dart';

abstract class SaleRepository {
  Future<Result<SaleResult>> createCashSale({
    required String saleId,
    required String idempotencyKey,
    required String shiftId,
    required List<SaleLine> items,
    required int tenderedCents,
    String? deviceId,
  });

  Future<List<SaleHistory>> getSalesHistory({int offset = 0, int limit = 50});

  Future<Map<String, dynamic>> getSaleReceipt(String saleId);
}

class SaleRepositoryImpl implements SaleRepository {
  final SaleService _saleService;
  SaleRepositoryImpl(this._saleService);

  @override
  Future<Result<SaleResult>> createCashSale({
    required String saleId,
    required String idempotencyKey,
    required String shiftId,
    required List<SaleLine> items,
    required int tenderedCents,
    String? deviceId,
  }) => _saleService.createCashSale(
    saleId: saleId,
    idempotencyKey: idempotencyKey,
    shiftId: shiftId,
    items: items,
    tenderedCents: tenderedCents,
    deviceId: deviceId,
  );

  @override
  Future<List<SaleHistory>> getSalesHistory({int offset = 0, int limit = 50}) {
    return _saleService.getSalesHistory(offset: offset, limit: limit);
  }

  @override
  Future<Map<String, dynamic>> getSaleReceipt(String saleId) {
    return _saleService.getSaleReceipt(saleId);
  }
}
