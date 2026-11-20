import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_tablet/data/repository/sale_repo.dart';
import 'package:pos_tablet/ui/sale_history/sales_history_screen.dart';
import 'package:pos_tablet/ui/sale_history/viewmodel/sales_history_view_model.dart';
import 'package:pos_tablet/ui/shifts/shift_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/domain/model/sale_history.dart';
import 'package:shared_core/domain/model/sync_status.dart';
import 'package:shared_core/util/result.dart';

import 'lib/data/fake_shift_repo.dart';

SaleHistory sale(String id, {String method = 'cash', int total = 500}) =>
    SaleHistory.fromJson({
      'id': id,
      'cashier_id': '',
      'total_cents': total,
      'status': 'completed',
      'created_at': DateTime.utc(2026, 11, 9, 8, 30).toIso8601String(),
      'payment_method': method,
    });

class _FakeSaleRepository implements SaleRepository {
  List<SaleHistory> sales = [];
  Object? failWith;
  Completer<void>? gate;

  @override
  Future<List<SaleHistory>> getSalesHistory({
    required String shiftId,
    int offset = 0,
    int limit = 50,
  }) async {
    await gate?.future;
    if (failWith != null) throw failWith!;
    return sales.skip(offset).take(limit).toList();
  }

  @override
  dynamic noSuchMethod(Invocation i) =>
      throw StateError('Unexpected call: ${i.memberName}');
}

Future<SalesHistoryViewModel> pumpBody(
  WidgetTester tester,
  _FakeSaleRepository repo, {
  String initialQuery = '',
}) async {
  final shiftRepo = FakeShiftRepository()
    ..openShiftResult = Result.ok(shiftFixture('s1'));
  final shiftVm = ShiftViewModel(shiftRepo);
  await shiftVm.restoreShift();

  final vm = SalesHistoryViewModel(repo, shiftVm);
  addTearDown(vm.dispose);
  vm.setSearchQuery(initialQuery);

  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: vm,
      child: const MaterialApp(
        home: Scaffold(
          body: Padding(padding: EdgeInsets.all(24), child: SalesHistoryBody()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return vm;
}

void main() {
  late _FakeSaleRepository repo;
  setUp(() => repo = _FakeSaleRepository());

  testWidgets('empty shift shows the empty message', (tester) async {
    await pumpBody(tester, repo);
    expect(find.text('No sales in this shift yet.'), findsOneWidget);
  });

  testWidgets('rows show formatted amounts and payment labels', (tester) async {
    repo.sales = [
      sale('a', method: 'cash', total: 500),
      sale('b', method: 'ecocash_usd', total: 1250),
    ];
    await pumpBody(tester, repo);

    expect(find.byType(ListTile), findsNWidgets(2));
    expect(find.text('\$5.00'), findsOneWidget);
    expect(find.text('\$12.50'), findsOneWidget);
    expect(find.textContaining('EcoCash (USD)'), findsOneWidget);
  });

  testWidgets('Load more appends the next page', (tester) async {
    repo.sales = [sale('a'), sale('b'), sale('c')];
    final vm = await pumpBody(tester, repo);

    vm.pageSize = 2;
    await vm.loadInitial();
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNWidgets(2));

    await tester.tap(find.text('Load more sales'));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(3));
    expect(find.text('Load more sales'), findsNothing);
  });

  testWidgets('rows show a badge for pending and failed sales only', (
    tester,
  ) async {
    SaleHistory withStatus(String id, SyncStatus s) => SaleHistory(
      id: id,
      cashierId: '',
      totalCents: 500,
      status: 'completed',
      createdAt: DateTime.utc(2026, 11, 9, 8, 30),
      paymentMethod: 'cash',
      syncStatus: s,
    );

    repo.sales = [
      withStatus('a', SyncStatus.synced),
      withStatus('b', SyncStatus.pending),
      withStatus('c', SyncStatus.failed),
    ];
    await pumpBody(tester, repo);

    expect(find.text('Pending sync'), findsOneWidget);
    expect(find.text('Sync failed'), findsOneWidget);
  });

  testWidgets('a failed first load shows the error, and Retry recovers', (
    tester,
  ) async {
    repo.failWith = Exception('db broke');
    await pumpBody(tester, repo);
    expect(find.text('Retry'), findsOneWidget);

    repo.failWith = null;
    repo.sales = [sale('a')];
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsNothing);
    expect(find.byType(ListTile), findsOneWidget);
  });

  testWidgets('a reload keeps the list visible instead of a spinner', (
    tester,
  ) async {
    repo.sales = [sale('a')];
    final vm = await pumpBody(tester, repo);

    repo.gate = Completer<void>();
    final reload = vm.loadInitial(); // hangs on the gate
    await tester.pump();

    expect(find.byType(ListTile), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    repo.gate!.complete();
    await reload;
    await tester.pumpAndSettle();
  });

  testWidgets(
    'the search field shows the active query on re-entry and filters',
    (tester) async {
      repo.sales = [
        sale('a', method: 'cash'),
        sale('b', method: 'ecocash_usd'),
      ];
      await pumpBody(tester, repo, initialQuery: 'cash');

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller?.text, 'cash');

      await tester.enterText(find.byType(TextField), 'ecocash');
      await tester.pump();
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.textContaining('EcoCash (USD)'), findsOneWidget);
    },
  );
}
