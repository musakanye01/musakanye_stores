import 'package:pos_tablet/data/local/app_database.dart';
import 'package:pos_tablet/data/local/dao/sales_dao.dart';
import 'package:pos_tablet/data/local/dao/shifts_dao.dart';
import 'package:shared_core/domain/model/sale_history.dart';
import 'package:shared_core/domain/model/sale_line.dart';
import 'package:shared_core/util/result.dart';
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

  Future<List<SaleHistory>> getSalesHistory({int offset = 0, int limit = 50});

  Future<Map<String, dynamic>> getSaleReceipt(String saleId);
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
    int offset = 0,
    int limit = 50,
  }) async {
    final rows = await _salesDao.getRecent(limit: limit, offset: offset);
    return [
      for (final s in rows)
        SaleHistory.fromJson({
          'id': s.id,
          'cashier_id': '', // not stored on the sale; single cashier per device
          'total_cents': s.totalCents,
          'status': 'completed',
          'created_at': s.createdAt.toIso8601String(),
          'payment_method': s.paymentMethod,
        }),
    ];
  }

  @override
  Future<Map<String, dynamic>> getSaleReceipt(String saleId) async {
    final sale = await _salesDao.getSaleById(saleId);
    if (sale == null) {
      throw StateError('This sale was not found on this device.');
    }

    final rows = await _salesDao.getLinesWithProducts(saleId);
    final isCash = sale.paymentMethod == 'cash';

    // Same shape the receipt screen already reads, so it needs no changes.
    return {
      'sale': {
        'id': sale.id,
        'total_cents': sale.totalCents,
        'created_at': sale.createdAt.toIso8601String(),
        'status': 'completed',
      },
      'items': [
        for (final r in rows)
          {
            'variant_id': r.line.variantId,
            'product_name': r.product?.productName ?? 'Unknown item',
            'variant_description':
                null, // add size/colour if the catalogue has it
            'quantity': r.line.quantity,
            'unit_price_cents': r.line.unitPriceCents,
            'line_total_cents': r.line.unitPriceCents * r.line.quantity,
          },
      ],
      'payment': {
        'method': sale.paymentMethod,
        'amount_cents': sale.totalCents,
        'tendered_cents': sale.tenderedCents,
        'change_cents': isCash ? sale.tenderedCents - sale.totalCents : 0,
      },
    };
  }
}
