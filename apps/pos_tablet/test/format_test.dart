import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/ui/shared/format.dart';

void main() {
  test('formats date and time with zero padding', () {
    expect(formatDateTime(DateTime(2026, 11, 9, 8, 5)), '2026-11-09 08:05');
  });
  test('payment labels', () {
    expect(paymentMethodLabel('cash'), 'Cash');
    expect(paymentMethodLabel('ecocash_usd'), 'EcoCash (USD)');
    expect(paymentMethodLabel('bank_transfer_usd'), 'Bank transfer (USD)');
    expect(paymentMethodLabel('something_else'), 'something_else');
  });
}
