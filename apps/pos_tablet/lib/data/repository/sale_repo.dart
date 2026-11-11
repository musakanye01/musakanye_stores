import 'package:pos_tablet/data/local/app_database.dart';
import 'package:pos_tablet/data/local/dao/catalogue_dao.dart';
import 'package:pos_tablet/data/local/dao/sales_dao.dart';
import 'package:pos_tablet/data/local/dao/shifts_dao.dart';
import 'package:shared_core/domain/model/sale_history.dart';
import 'package:shared_core/domain/model/sale_line.dart';
import 'package:shared_core/domain/model/sync_status.dart';
import 'package:shared_core/util/result.dart';
import 'package:shared_core/domain/model/sale_receipt.dart';
import 'package:uuid/uuid.dart';

abstract class SaleRepository {
  Future<Result<SaleResult>> createSale({
    required String saleId,
    required String idempotencyKey,
    required String shiftId,
    required String paymentMethod,
    required List<SaleLine> items,
    required int tenderedCents,
  });

  Future<List<SaleHistory>> getSalesHistory({
    required String shiftId,
    int offset = 0,
    int limit = 50,
  });

  // interface
  Future<SaleReceipt?> getSaleReceipt(String saleId);
}

class SaleRepositoryImpl implements SaleRepository {
  SaleRepositoryImpl(this._salesDao, this._shiftsDao);

  final SalesDao _salesDao;
  final ShiftsDao _shiftsDao;

  static const _uuid = Uuid();

  @override
  Future<Result<SaleResult>> createSale({
    required String saleId,
    required String idempotencyKey,
    required String shiftId,
    required String paymentMethod,
    required List<SaleLine> items,
    required int tenderedCents,
  }) async {
    try {
      if (items.isEmpty) {
        return Result.error(Exception('There are no items in this sale.'));
      }

      final isCash = paymentMethod == 'cash';
      if (!isCash && paymentMethod != 'ecocash_usd') {
        return Result.error(Exception('Unsupported payment method.'));
      }

      final shift = await _shiftsDao.getById(shiftId);
      if (shift == null || shift.status != 'open') {
        return Result.error(
          Exception('You need an open shift to make a sale.'),
        );
      }

      final localLines = <SaleLinesTableCompanion>[];
      var totalCents = 0;

      for (final item in items) {
        final unitPriceCents = item.unitPriceCents;
        if (unitPriceCents == null || unitPriceCents < 0) {
          return Result.error(
            Exception('A sale item is missing its cached price.'),
          );
        }
        if (item.quantity <= 0) {
          return Result.error(
            Exception('Sale quantities must be greater than zero.'),
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

      if (isCash && tenderedCents < totalCents) {
        return Result.error(
          Exception('The amount received does not cover the sale total.'),
        );
      }

      await _salesDao.createSaleLocally(
        sale: SalesTableCompanion.insert(
          id: saleId,
          shiftId: shiftId,
          paymentMethod: paymentMethod,
          totalCents: totalCents,
          tenderedCents: isCash ? tenderedCents : totalCents,
          idempotencyKey: idempotencyKey,
          createdAt: DateTime.now().toUtc(),
        ),
        lines: localLines,
      );

      // No sync trigger here: the sync engine watches the local database.
      return Result.ok(
        SaleResult(saleId: saleId, totalCents: totalCents, duplicate: false),
      );
    } catch (e) {
      return Result.error(
        Exception(
          e
              .toString()
              .replaceFirst('Exception: ', '')
              .replaceFirst('Bad state: ', ''),
        ),
      );
    }
  }

  @override
  Future<List<SaleHistory>> getSalesHistory({
    required String shiftId,
    int offset = 0,
    int limit = 50,
  }) async {
    final rows = await _salesDao.getByShift(
      shiftId,
      limit: limit,
      offset: offset,
    );
    return [
      for (final s in rows)
        SaleHistory(
          id: s.id,
          cashierId: '',
          totalCents: s.totalCents,
          status: 'completed',
          createdAt: s.createdAt,
          paymentMethod: s.paymentMethod,
          syncStatus: syncStatusOf(synced: s.synced, syncError: s.syncError),
        ),
    ];
  }

  @override
  Future<SaleReceipt?> getSaleReceipt(String saleId) async {
    final sale = await _salesDao.getSaleById(saleId);
    if (sale == null) return null;

    final rows = await _salesDao.getLinesWithProducts(saleId);

    return SaleReceipt(
      saleId: sale.id,
      createdAt: sale.createdAt,
      paymentMethod: sale.paymentMethod,
      totalCents: sale.totalCents,
      tenderedCents: sale.tenderedCents,
      syncStatus: syncStatusOf(synced: sale.synced, syncError: sale.syncError),
      lines: [
        for (final r in rows)
          ReceiptLine(
            name: r.product == null
                ? 'Unknown item'
                : CatalogueDao.toDomain(r.product!).displayName,
            quantity: r.line.quantity,
            unitPriceCents: r.line.unitPriceCents,
          ),
      ],
    );
  }
}
