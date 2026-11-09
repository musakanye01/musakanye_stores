import 'package:shared_core/domain/model/sync_status.dart';

class ReceiptLine {
  const ReceiptLine({
    required this.name,
    required this.quantity,
    required this.unitPriceCents,
  });

  final String name;
  final int quantity;
  final int unitPriceCents;

  int get totalCents => unitPriceCents * quantity;
}

class SaleReceipt {
  const SaleReceipt({
    required this.saleId,
    required this.createdAt,
    required this.paymentMethod,
    required this.totalCents,
    required this.tenderedCents,
    required this.lines,
    this.syncStatus = SyncStatus.synced,
  });

  final String saleId;
  final DateTime createdAt;
  final String paymentMethod; // raw value: 'cash' | 'ecocash_usd'
  final int totalCents;
  final int tenderedCents;
  final List<ReceiptLine> lines;
  final SyncStatus syncStatus;

  bool get isCash => paymentMethod == 'cash';
  int get changeCents =>
      isCash && tenderedCents > totalCents ? tenderedCents - totalCents : 0;
}
