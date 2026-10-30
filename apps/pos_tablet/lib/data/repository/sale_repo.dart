import 'package:pos_tablet/data/source/sale_service.dart';
import 'package:shared_core/data/local/app_database.dart';
import 'package:shared_core/data/local/dao/sales_dao.dart';
import 'package:shared_core/domain/model/sale_history.dart';
import 'package:shared_core/domain/model/sale_line.dart';
import 'package:shared_core/util/result.dart';
import 'package:uuid/uuid.dart';

abstract class SaleRepository {
  Future<Result<SaleResult>> createCashSale({
    required String saleId,
    required String idempotencyKey,
    required String shiftId,
    required String paymentMethod,
    required List<SaleLine> items,
    required int tenderedCents,
    String? deviceId,
  });

  Future<List<SaleHistory>> getSalesHistory({
    int offset = 0,
    int limit = 50,
  });

  Future<Map<String, dynamic>> getSaleReceipt(String saleId);
}

class SaleRepositoryImpl implements SaleRepository {
  final SaleService _saleService;
  final SalesDao _salesDao;

  static const _uuid = Uuid();

  SaleRepositoryImpl(
    this._saleService,
    this._salesDao,
  );

  @override
  Future<Result<SaleResult>> createCashSale({
    required String saleId,
    required String idempotencyKey,
    required String shiftId,
    required String paymentMethod,
    required List<SaleLine> items,
    required int tenderedCents,
    String? deviceId,
  }) async {
    try {
      if (items.isEmpty) {
        return Result.error(
          Exception('There are no items in this sale.'),
        );
      }

      if (paymentMethod != 'cash' &&
          paymentMethod != 'ecocash_usd') {
        return Result.error(
          Exception('Unsupported payment method.'),
        );
      }

      final localLines = <SaleLinesTableCompanion>[];
      var totalCents = 0;

      for (final item in items) {
        final unitPriceCents = item.unitPriceCents;

        if (unitPriceCents == null || unitPriceCents < 0) {
          return Result.error(
            Exception(
              'A sale item is missing its cached price.',
            ),
          );
        }

        if (item.quantity <= 0) {
          return Result.error(
            Exception(
              'Sale quantities must be greater than zero.',
            ),
          );
        }

        totalCents += unitPriceCents * item.quantity;

        localLines.add(
          SaleLinesTableCompanion.insert(
            id: _uuid.v4(),
            saleId: saleId,
            variantId: item.variantId,
            quantity: item.quantity,
            unitPriceCents: unitPriceCents,
          ),
        );
      }

      if (tenderedCents < totalCents) {
        return Result.error(
          Exception(
            'The amount received does not cover the sale total.',
          ),
        );
      }

      await _salesDao.createSaleLocally(
        sale: SalesTableCompanion.insert(
          id: saleId,
          shiftId: shiftId,
          paymentMethod: paymentMethod,
          totalCents: totalCents,
          tenderedCents: tenderedCents,
          idempotencyKey: idempotencyKey,
          createdAt: DateTime.now().toUtc(),
        ),
        lines: localLines,
      );

      return Result.ok(
        SaleResult(
          saleId: saleId,
          totalCents: totalCents,
          duplicate: false,
        ),
      );
    } catch (e) {
      return Result.error(
        Exception(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  @override
  Future<List<SaleHistory>> getSalesHistory({
    int offset = 0,
    int limit = 50,
  }) {
    return _saleService.getSalesHistory(
      offset: offset,
      limit: limit,
    );
  }

  @override
  Future<Map<String, dynamic>> getSaleReceipt(
    String saleId,
  ) {
    return _saleService.getSaleReceipt(saleId);
  }
}