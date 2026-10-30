import 'package:flutter/material.dart';
import 'package:pos_tablet/data/repository/sale_repo.dart';
import 'package:pos_tablet/ui/sales/cart_item.dart';
import 'package:shared_core/domain/model/sale_line.dart';
import 'package:shared_core/util/command.dart';
import 'package:shared_core/util/result.dart';
import 'package:uuid/uuid.dart';

class CheckoutInput {
  final String shiftId;
  final List<CartItem> items;
  final int tenderedCents;
  final String paymentMethod;

  const CheckoutInput({
    required this.shiftId,
    required this.items,
    required this.tenderedCents,
    required this.paymentMethod,
  });
}

class CheckoutViewModel extends ChangeNotifier {
  final SaleRepository _saleRepository;

  static const _uuid = Uuid();

  SaleResult? _lastSale;
  SaleResult? get lastSale => _lastSale;

  String? _signature;
  String? _saleId;
  String? _idempotencyKey;

  late final Command1<void, CheckoutInput> completeSale;

  CheckoutViewModel(this._saleRepository) {
    completeSale = Command1(_handleCompleteSale);
  }

  Future<Result<void>> _handleCompleteSale(CheckoutInput input) async {
    if (input.items.isEmpty) {
      return Result.error(Exception('There are no items in this sale.'));
    }

    final lines =
        input.items
            .map(
              (item) => SaleLine(
                variantId: item.productId,
                quantity: item.quantity,
                unitPriceCents: (item.unitPrice * 100).round(),
              ),
            )
            .toList()
          ..sort((a, b) => a.variantId.compareTo(b.variantId));

    final signature =
        '${input.shiftId}|'
        '${input.paymentMethod}|'
        '${input.tenderedCents}|'
        '${lines.map((l) => '${l.variantId}:${l.quantity}:${l.unitPriceCents}').join(',')}';

    if (_signature != signature) {
      _signature = signature;
      _saleId = _uuid.v4();
      _idempotencyKey = _uuid.v4();
    }

    final result = await _saleRepository.createCashSale(
      saleId: _saleId!,
      idempotencyKey: _idempotencyKey!,
      shiftId: input.shiftId,
      paymentMethod: input.paymentMethod,
      items: lines,
      tenderedCents: input.tenderedCents,
    );

    switch (result) {
      case Ok<SaleResult>(value: final sale):
        _lastSale = sale;

        _signature = null;
        _saleId = null;
        _idempotencyKey = null;

        return const Result.ok(null);

      case Error<SaleResult>(error: final err):
        return Result.error(err);
    }
  }
}
