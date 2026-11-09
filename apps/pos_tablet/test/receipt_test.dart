import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/ui/sales/receipt_text.dart';
import 'package:shared_core/domain/model/sale_receipt.dart';

SaleReceipt receipt({String method = 'cash', int tendered = 1500}) =>
    SaleReceipt(
      saleId: 'sale-1234',
      createdAt: DateTime(2026, 11, 9, 8, 30),
      paymentMethod: method,
      totalCents: 1000,
      tenderedCents: tendered,
      lines: const [
        ReceiptLine(name: 'Shirt - M', quantity: 1, unitPriceCents: 400),
        ReceiptLine(name: 'Socks', quantity: 2, unitPriceCents: 300),
      ],
    );

void main() {
  test('contains the stored date, lines and total', () {
    final text = buildReceiptText(receipt());
    expect(text, contains('Receipt: sale-1234'));
    expect(text, contains('Date: 2026-11-09 08:30'));
    expect(text, contains('1 x \$4.00 = \$4.00'));
    expect(text, contains('2 x \$3.00 = \$6.00'));
    expect(text, contains('TOTAL: \$10.00'));
  });

  test('cash shows received and change', () {
    final text = buildReceiptText(receipt());
    expect(text, contains('Payment: Cash'));
    expect(text, contains('Received: \$15.00'));
    expect(text, contains('Change: \$5.00'));
  });

  test('EcoCash shows neither', () {
    final text = buildReceiptText(
      receipt(method: 'ecocash_usd', tendered: 1000),
    );
    expect(text, contains('Payment: EcoCash (USD)'));
    expect(text, isNot(contains('Received')));
    expect(text, isNot(contains('Change')));
  });
}
