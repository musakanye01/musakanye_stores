import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/ui/receipt/receipt_screen.dart';
import 'package:shared_core/domain/model/sale_receipt.dart';
import 'package:shared_core/domain/model/sync_status.dart';

SaleReceipt receipt({
  String method = 'cash',
  int tendered = 1500,
  SyncStatus sync = SyncStatus.synced,
}) => SaleReceipt(
  saleId: 'sale-1234',
  createdAt: DateTime(2026, 11, 9, 8, 30),
  paymentMethod: method,
  totalCents: 1000,
  tenderedCents: tendered,
  syncStatus: sync,
  lines: const [
    ReceiptLine(name: 'Shirt - M', quantity: 1, unitPriceCents: 400),
    ReceiptLine(name: 'Socks', quantity: 2, unitPriceCents: 300),
  ],
);

Future<void> pumpView(WidgetTester tester, SaleReceipt r) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: ReceiptView(receipt: r),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the stored sale time, not the current time', (
    tester,
  ) async {
    await pumpView(tester, receipt());
    expect(find.text('2026-11-09 08:30'), findsOneWidget);
  });

  testWidgets('shows lines and amounts from cents', (tester) async {
    await pumpView(tester, receipt());
    expect(find.text('Shirt - M'), findsOneWidget);
    expect(find.text('2 × \$3.00'), findsOneWidget);
    expect(find.text('\$4.00'), findsOneWidget);
    expect(find.text('\$6.00'), findsOneWidget);
    expect(find.text('\$10.00'), findsOneWidget); // total
  });

  testWidgets('cash shows received and change', (tester) async {
    await pumpView(tester, receipt());
    expect(find.text('Amount received'), findsOneWidget);
    expect(find.text('\$15.00'), findsOneWidget);
    expect(find.text('Change'), findsOneWidget);
    expect(find.text('\$5.00'), findsOneWidget);
  });

  testWidgets('EcoCash shows no received or change rows', (tester) async {
    await pumpView(tester, receipt(method: 'ecocash_usd', tendered: 1000));
    expect(find.text('EcoCash (USD)'), findsOneWidget);
    expect(find.text('Amount received'), findsNothing);
    expect(find.text('Change'), findsNothing);
  });

  testWidgets('pending and failed sales say so, synced ones do not', (
    tester,
  ) async {
    await pumpView(tester, receipt(sync: SyncStatus.pending));
    expect(find.text('Pending sync'), findsOneWidget);

    await pumpView(tester, receipt(sync: SyncStatus.failed));
    expect(find.text('Sync failed'), findsOneWidget);

    await pumpView(tester, receipt());
    expect(find.text('Pending sync'), findsNothing);
    expect(find.text('Sync failed'), findsNothing);
  });
}
