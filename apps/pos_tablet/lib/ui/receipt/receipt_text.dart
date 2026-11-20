import 'package:pos_tablet/ui/shared/format.dart';
import 'package:pos_tablet/ui/shared/money.dart';
import 'package:shared_core/domain/model/sale_receipt.dart';

String buildReceiptText(SaleReceipt r) {
  final b = StringBuffer()
    ..writeln('SALE RECEIPT')
    ..writeln('Receipt: ${r.saleId}')
    ..writeln('Date: ${formatDateTime(r.createdAt)}')
    ..writeln('--------------------------------');

  for (final l in r.lines) {
    b
      ..writeln(l.name)
      ..writeln(
        '${l.quantity} x ${formatUsd(l.unitPriceCents)} = ${formatUsd(l.totalCents)}',
      );
  }

  b
    ..writeln('--------------------------------')
    ..writeln('Payment: ${paymentMethodLabel(r.paymentMethod)}')
    ..writeln('TOTAL: ${formatUsd(r.totalCents)}');

  if (r.isCash) {
    b
      ..writeln('Received: ${formatUsd(r.tenderedCents)}')
      ..writeln('Change: ${formatUsd(r.changeCents)}');
  }

  b.writeln('\nThank you for shopping with us!');
  return b.toString();
}
